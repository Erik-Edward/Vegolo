# Post-Training INT8 Quantization for LLMs on LiteRT (MediaPipe/TFLite)

## Official PTQ Guidance for LLMs

Google's official documentation emphasizes that post-training
quantization can greatly reduce model size and inference cost "with
little degradation in model
accuracy"[\[1\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Post,format%20using%20the%20LiteRT%20Converter).
In the context of **LiteRT** (the next-gen TensorFlow Lite runtime), you
quantize a trained float model at conversion time using the
LiteRT/TFLite
Converter[\[2\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Post,format%20using%20the%20LiteRT%20Converter).
There are multiple PTQ options: for example, **dynamic-range
quantization** (weights in int8, activations quantized on the fly)
yields \~4× smaller models and 2--3× speedups on CPU, while **full
integer quantization** (weights *and* activations int8) gives \~4×
smaller models with **3×+** speedups and enables accelerators like Edge
TPU[\[3\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Technique%20Benefits%20Hardware%20Dynamic%20range,smaller%2C%20GPU%20acceleration%20CPU%2C%20GPU).
The MediaPipe GenAI team applied these techniques to LLMs in 2024,
enabling on-device run of models like Gemma, Falcon, etc., with int8
weight quantization by
default[\[4\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=The%20following%20speeds%20were%20taken,bit%20weight%20quantization).
(Notably, their demo used int8 weights for all supported models -- only
the extremely memory-constrained Gemma 2B variant fell back to int4
weights[\[4\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=The%20following%20speeds%20were%20taken,bit%20weight%20quantization)[\[5\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=precision%20loss%20according%20to%20our,models%20on%20iOS%20as%20well).)
In summary, **post-training INT8 quantization** is a key part of
Google's on-device LLM pipeline: you convert HuggingFace or TensorFlow
checkpoints to a `.tflite`/`.litertlm` file with quantization, then run
it with the LiteRT-LM runtime or MediaPipe's LLM Inference
API[\[6\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=2,using%20the%20MediaPipe%20Python%20Package)[\[7\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=1,file%20and%20the%20model%20tokenizer).

## Per-Channel vs Per-Tensor INT8 Quantization

**Per-tensor** quantization uses one scale/zero-point for an entire
tensor, whereas **per-axis (per-channel)** quantization uses separate
scales for slices (e.g. each output channel of a weight
matrix)[\[8\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Per).
TensorFlow Lite (LiteRT) by default employs **per-channel int8
quantization for weights** in conv and fully-connected layers, since
this finer granularity vastly improves accuracy for deep
models[\[9\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Often%2C%20the%20,has%20large%20improvements%20to%20accuracy)[\[10\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=FULLY_CONNECTED%20Input%200%3A%20data_type%20,axis%20%28dim%20%3D%200).
In an int8 model, weights are stored as signed int8 in \[-127,127\] with
zero-point = 0 (symmetric quantization), either per-tensor or
per-channel as
supported[\[11\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=%2A%20Per,point%20equal%20to%200).
Activations (and inputs) use per-tensor quantization (asymmetric int8 in
\[-128,127\] with nonzero
zero-point)[\[11\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=%2A%20Per,point%20equal%20to%200).
Per-channel weight quantization is almost always preferred for LLMs
because each row/column of the weight can be scaled independently,
preserving precision -- this has "large improvements to accuracy" with
no runtime cost on supported
ops[\[9\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Often%2C%20the%20,has%20large%20improvements%20to%20accuracy).
You would only use per-tensor weight quantization if per-axis isn't
supported (e.g. certain ops or older delegates). At the time of the
quantization spec (mid-2024), per-axis quantization was supported for
`CONV_2D`, `DEPTHWISE_CONV_2D`, and by extension fully-connected (which
maps to a conv2d in
TFLite)[\[9\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Often%2C%20the%20,has%20large%20improvements%20to%20accuracy)[\[12\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=FULLY_CONNECTED%20Input%200%3A%20data_type%20,restriction%3A%20zero_point%20%3D%200).
In practice, all large GEMMs in a transformer (QKV projections,
feed-forward matmuls) are covered by these, so weight tensors can be
quantized per-channel. Indeed, Google's Edge TPU and other NPUs
*require* symmetric per-channel weight quantization (with int32
accumulators)[\[13\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Activations%20are%20asymmetric%3A%20they%20can,can%20be%20optimized%20pretty%20heavily)
-- the TFLite converter automatically enforces this for compatible ops.
In summary: **use per-channel int8 for weights whenever possible**
(which the converter does by default for LLM layers), as it yields much
better accuracy than a single scale for an entire matrix. Per-tensor
quantization is mainly seen for biases and for ops like adds or
activations where per-axis isn't
applicable[\[14\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Input%202%20,tensor)[\[15\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=SOFTMAX%20Input%200%3A%20data_type%20,tensor).

## Representative Dataset for Calibration

For **full integer PTQ**, you must provide a *representative dataset* to
calibrate the quantization ranges of
activations[\[16\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=For%20full%20integer%20quantization%2C%20you,function%20below).
The official guidance is that this can be a *small* sample (on the order
of **100--500 examples**) of typical
data[\[16\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=For%20full%20integer%20quantization%2C%20you,function%20below).
In the case of LLMs, that means a few hundred text sequences (documents,
prompts, etc.) that reflect the model's usage. The key is to cover the
distribution of input tokens and lengths your model will see. Google's
blog suggests that even "just a hundred example sentences" can suffice
for post-training quantization of large models when carefully
chosen[\[17\]](https://latitude-blog.ghost.io/blog/how-quantization-reduces-llm-latency/#:~:text=ranging%20from%20high,IoT%20devices).
These examples should be **realistic and diverse** -- e.g. taken from
the model's training corpus or target domain -- to capture rare tokens,
punctuation, numerals, and so on. In practice, if using the TensorFlow
Lite converter in Python, you'd implement `representative_dataset()` to
yield batches of input
tensors[\[18\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=def%20representative_dataset,tf.dtypes.cast%28data%2C%20tf.float32).
For an LLM with a single token-ID input, you might feed sequences of
token IDs (as int32 or int64 tensors) representing encoded text. (If
using the MediaPipe **Torch Generative Converter**, this is handled
internally: you would load the model and provide sample *text* or token
sequences via its API for calibration. The converter library then runs a
few inference passes to collect
ranges[\[7\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=1,file%20and%20the%20model%20tokenizer).)
It's generally recommended to use **pre-tokenized data** for calibration
-- i.e. actual token ID sequences -- because the model itself expects
integer token inputs. The calibration mechanism will run those through
the embedding and transformer, recording min/max activation values.
Feeding raw text strings would only make sense if the model graph
included tokenization, which it typically does not. Finally, ensure the
representative data covers the **length range** of interest (e.g. some
short prompts and some near the max context length) because transformer
activation ranges (especially in attention softmax, etc.) can differ for
long vs. short sequences. With a well-chosen calibration set, the
converter will assign an optimal scale to each activation tensor,
minimizing quantization error.

## Supported Operators and Common Quantization Caveats

**Operator support:** Most operations in a standard Transformer are
supported by TFLite's int8 quantization kernels, but it's important to
know the limits. All *linear* layers (matrix multiplications implemented
as fully-connected or conv ops) support per-axis int8 as noted
above[\[10\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=FULLY_CONNECTED%20Input%200%3A%20data_type%20,axis%20%28dim%20%3D%200).
Elementwise ops (add, multiply, etc.) have int8 kernels but often
require that their inputs share the same scale (they must be quantized
identically)[\[19\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Below%20we%20describe%20the%20quantization,for%20our%20int8%20tflite%20kernels)[\[20\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=MUL%20Input%200%3A%20data_type%20,tensor%20Output%200)
-- the converter will insert rescaling ops if needed, or sometimes leave
an op in float if it can't reconcile scales. Certain activation
functions like ReLU, tanh, logistic, softmax also have int8
implementations with fixed scales or restrictions (e.g. int8 softmax
outputs are quantized with a preset scale 1/256 and zero-point
-128)[\[15\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=SOFTMAX%20Input%200%3A%20data_type%20,tensor).
One **common caveat** in LLMs is **layer normalization**: TFLite doesn't
have a native LayerNorm op, so Transformer models often fold layer norm
into surrounding computations or use subgraph logic. The AI Edge
converter's example implementations likely handle this (e.g. by
converting LayerNorm into a sequence of supported ops), but if any part
of the LayerNorm can't be quantized, that part might stay in float. In
general, the converter will **fallback to float** for any ops that lack
an integer kernel *if* you allow it. By default,
`converter.optimizations = [Optimize.DEFAULT]` with a rep dataset will
quantize everything it can, and leave anything else as float (marked by
dequantize ops around it). You can control this with
`target_spec.supported_ops`. For example, to force full int8-only
execution (for deployment on integer-only devices), you'd set
`supported_ops=[tf.lite.OpsSet.TFLITE_BUILTINS_INT8]` and also specify
int8
inputs/outputs[\[21\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=import%20tensorflow%20as%20tf%20converter,convert).
If an unsupported operation then appears, conversion *will fail* in this
strict mode. In a development scenario, it's often convenient to allow
mixed quantization (int8 with float fallback) by including both int8 and
float in supported ops. The TensorFlow Lite guide shows using
`supported_ops = [tf.lite.OpsSet.EXPERIMENTAL_TFLITE_BUILTINS_ACTIVATIONS_INT16_WEIGHTS_INT8, tf.lite.OpsSet.TFLITE_BUILTINS]`
to allow a fallback for any ops not supported in 16x8
mode[\[22\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=If%2016x8%20quantization%20is%20not,the%20target_spec%20to%20allow%20this);
similarly, one could combine INT8 and FLOAT ops in the list to allow
float ops to remain for safety. Just note that a model with float
fallbacks won't run on pure int8 accelerators (like Edge TPU) -- it's
only suitable for CPU/GPU execution.

**Attention and sequence handling:** There isn't a single "Attention" op
in TFLite; multi-head attention decomposes into matmul, transpose,
softmax, etc., all of which can be quantized. One challenge is the **k/v
cache** and looping for generation. In MediaPipe's LLM Inference API,
the generation loop is handled outside of the model graph (the model is
invoked step by step, or with a dual "prefill" and "decode" subgraph
strategy)[\[23\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=Weights%20Sharing%3A%20The%20LLM%20inference,connected%20operator%20separately%20to%20ensure)[\[24\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=Balancing%20Compute%20and%20Memory%3A%20Upon,the%20main%20mathematical%20convolution%20operations).
For custom conversion, you may have to set a fixed maximum sequence
length so that the cache tensors have fixed shape -- TFLite doesn't
support dynamically growing tensors or loops. The on-device team noted
that their GPU runtime doesn't support truly dynamic ops, so they "opt
for fixed operations with a predefined maximum cache size" in the
graph[\[25\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=operations).
This means at conversion time, you might need to unroll a certain number
of decode steps or at least allocate fixed-length cache buffers. If
using the AI Edge Torch converter with their LLM examples, this is
likely handled for you (they produce a `.litertlm` with the two-phase
prefill/decode architecture similar to the sample apps). But be aware
that **long context sizes** (e.g. 4K, 8K tokens) lead to very large
intermediate tensors -- quantization helps by making those int8 (4×
smaller than float), yet memory can still be a limitation on-device for
extreme contexts. Also, certain fused patterns (like the combined QKV
projection or bias-adds) might be implemented as fused ops in TensorFlow
but need to be broken into supported ops in TFLite. The conversion
tooling tries to **match known patterns** (the AI Edge team built
support for common Hugging Face
architectures[\[26\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=,two%20quantization%20frameworks%20are%20here)),
but if you author a custom model, ensure you use standard layers (Dense,
Conv1D, etc.) so that the converter can recognize and quantize them.

**Embedding layers:** Large language models often have huge embedding
tables (for tokens or vocabulary). Quantizing these embeddings is highly
beneficial for memory. TensorFlow Lite will quantize embedding matrices
just like any other weight -- **if** the embedding lookup is implemented
as a gather op, the weights can be int8. Support for quantized gather
(embedding) was actually a recent addition in Google's toolset: a May
2025 update explicitly *"added quantization support for embedding
tables"* in the AI Edge
converter[\[27\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=,quantization%20support%20for%20embedding%20tables).
In a quantized TFLite model, an embedding lookup appears as an `INT8`
**GATHER** operation: the input indices remain int32, the embedding
matrix is int8, and the output vectors are int8. The spec requires that
all gathered output shares the same scale/zero-point as the weight
matrix[\[28\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=GATHER%20Input%200%3A%20data_type%20,tensor),
so the entire embedding tensor uses one quantization scale (per-tensor
quantization). This is a point to watch: if your vocabulary has some
extremely high-magnitude embeddings, they could dominate the scale and
cause lesser-used tokens to suffer precision loss. A good calibration
dataset for embeddings would include a wide variety of tokens (common
and rare) to set a balanced scale. If necessary, one could exclude the
embedding from quantization (keeping it float) -- but that costs a lot
of memory. Instead, the approach taken in Gemma 3n is *Per-Layer
Embeddings (PLE)*: they actually split and store part of the embeddings
on CPU in higher
precision[\[29\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=accelerator%20%28GPU%2FTPU%29)[\[30\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=With%20Per,parameters%20loaded%20in%20your%20accelerator).
For most developers, simply quantizing the embeddings to int8 is the
straightforward approach; just be mindful that it's per-tensor
quantization and calibrate accordingly.

**Accuracy and debugging:** Quantizing LLMs can introduce subtle errors.
It's recommended to test the quantized model's outputs on some prompts
and compare to the float model. TensorFlow Lite provides a
**quantization debug** tool (the *Benchmark Tool* with
`--enable_op_profiling` and `--dump_quant_error` flags) to inspect each
layer's quantization
error[\[31\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Per,128%2C%20127)[\[32\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=scale%20values%20to%20be%20per,This%20generalizes%20readily%2C%20as%20follows).
Google's docs also suggest verifying the float TFLite model first as a
baseline[\[33\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=import%20tensorflow%20as%20tf%20converter,convert).
In some cases, you might find a particular layer (e.g. output softmax or
a layernorm) that causes a large accuracy drop when quantized -- you
could choose to keep that in float (by altering supported_ops or using
hybrid quantization for that op). The MediaPipe team's integration chose
int8 for all weights and used either fp16 or fp32 for activations
depending on the model's
tolerance[\[34\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=On%20the%20GPU%2C%20Falcon%201B,models%20on%20iOS%20as%20well)
-- for example, they found some models' activations needed 32-bit to
maintain quality, while others were fine with 16-bit. This kind of mixed
strategy is more advanced, but it underscores that **PTQ isn't
one-size-fits-all** -- you may need to experiment with allowing certain
higher-precision parts if you have specific accuracy targets.

## Accuracy, Memory, and Latency Trade-offs

**Model size and memory:** Quantizing from 16-bit to 8-bit cuts model
size roughly in half. For instance, the **Gemma 3 (Gemma3)** 4B model
requires about **6.4 GB** in BF16, versus **4.4 GB** after 8-bit
quantization[\[35\]](https://ai.google.dev/gemma/docs/core#:~:text=%288,1%20GB%2021%20GB).
The 1B model goes from \~1.5 GB (BF16) to \~1.1 GB
(INT8)[\[36\]](https://ai.google.dev/gemma/docs/core#:~:text=%288,1%20GB%2021%20GB).
This is a substantial savings, often the difference between fitting in
mobile memory or not. The table below from the official Gemma 3 overview
shows the trend across sizes:

-   *Gemma 3 4B:* 6.4 GB in BF16 vs 4.4 GB in 8-bit
-   *Gemma 3 12B:* 20 GB in BF16 vs 12.2 GB in 8-bit
-   *Gemma 3 27B:* 46.4 GB in BF16 vs 29.1 GB in
    8-bit[\[35\]](https://ai.google.dev/gemma/docs/core#:~:text=%288,1%20GB%2021%20GB)

And if you quantize further to 4-bit (using QAT or advanced PTQ), the 4B
model drops to
\~3.4 GB[\[35\]](https://ai.google.dev/gemma/docs/core#:~:text=%288,1%20GB%2021%20GB).
In practice, Google provides QAT checkpoints for 4-bit (INT4) weights
for Gemma
models[\[37\]](https://developers.googleblog.com/en/introducing-gemma-3-270m/#:~:text=%2A%20Production,constrained%20devices),
but with PTQ alone you'd typically stick to 8-bit weights (or 8-bit
weights + 16-bit activations) for the best balance of accuracy and
compression. It's worth noting that Gemma 3n models use some clever
tricks (MatFormer and PLE) to reduce effective parameters -- e.g.
Gemma 3n E4B is an 8B parameter model but only \~4B core weights need to
reside in accelerator
memory[\[29\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=accelerator%20%28GPU%2FTPU%29).
Those core weights in int8 would be \~4 GB, which fits on high-end
phones and laptops, whereas in BF16 they'd be \~8 GB (not feasible
on-device). Quantization is essentially *enabling* these models to run
on-device by shrinking memory usage and bandwidth needs.

**Latency and throughput:** Quantization often brings significant
speedups by leveraging efficient integer arithmetic. On ARM CPUs, 8-bit
matrix multiply instructions (e.g. Armv9's I8MM) can double the
throughput compared to FP16 or older NEON
operations[\[38\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=two%20significant%20optimizations%20for%20LLM,based).
Google's data shows int8 PTQ can yield *3× or more* faster inference on
CPU[\[3\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Technique%20Benefits%20Hardware%20Dynamic%20range,smaller%2C%20GPU%20acceleration%20CPU%2C%20GPU).
In on-device LLM benchmarks, many models see large gains in the
**prefill phase** (when processing the input) from int8, because that
phase is highly compute-bound (lots of big matmuls). The MediaPipe team
even fused weight dequantization steps to optimize this: in the prefill,
they dequantize int8 weights once upfront to float to maximize compute
throughput, whereas in the decode phase (generation) they interleave
dequantization to save memory
bandwidth[\[24\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=Balancing%20Compute%20and%20Memory%3A%20Upon,the%20main%20mathematical%20convolution%20operations).
The net effect is very efficient token generation. For example, with
int8 or int4 quantization, a 4B model can achieve on the order of
**hundreds of tokens per second** during the initial batch processing,
and then dozens of tokens/sec during autoregressive generation on modern
phone
hardware[\[39\]](https://huggingface.co/google/gemma-3n-E4B-it-litert-lm#:~:text=Gemma3n,4).
(Actual numbers from a Snapdragon 8 Gen3 phone running Gemma3n-E4B
4-bit: \~73 tokens/sec in the prefill and \~9 tokens/sec per token in
streaming decode on
CPU[\[39\]](https://huggingface.co/google/gemma-3n-E4B-it-litert-lm#:~:text=Gemma3n,4).
An int8 model would likely have slightly higher decode throughput since
8-bit dequant is simpler than 4-bit.) Latency to first token is heavily
improved by quantization -- Google cited a **2× faster prefill** for
Gemma 3n's 4B model compared to an earlier 4B model, largely thanks to
architecture and quantization
optimizations[\[40\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=KV%20Cache%20Sharing%20optimizes%20how,sequences%20much%20faster%20than%20before)[\[41\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=Benefiting%20from%20novel%20architectural%20designs,language%20tasks).

That said, not all parts of the pipeline scale equally. The **decode
phase** (generating one token at a time) can become *memory-bound*
rather than compute-bound, especially with int8: each token generation
involves reading large weight matrices from memory. Quantization helps
here by cutting memory traffic (8-bit reads instead of 16- or 32-bit),
but if the device's memory bandwidth is the bottleneck, the speedup from
int8 vs float16 might be smaller. The MediaPipe team noted exactly this:
prefill was compute-limited (benefiting greatly from int8 math), while
decode was memory-limited (benefiting mainly from smaller memory
transfers)[\[24\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=Balancing%20Compute%20and%20Memory%3A%20Upon,the%20main%20mathematical%20convolution%20operations).
Even so, quantization *never hurt* performance in their experiments --
at worst int8 decode was similar speed to float, and at best it was
modestly faster. One edge case: extremely small models or ops with a lot
of scalar overhead might see a regression with quantization (due to
overhead of quant/dequant). In fact, Google's release notes mention that
"inference latency with quantized models is higher than unquantized in
some cases" as a known
issue[\[42\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=Known%20Issues).
This tends to be for smaller networks; for LLMs, the sheer size usually
means quantization pays off. If you do encounter such a case, a solution
is *weight-only quantization* (a hybrid mode) -- which the AI Edge
toolkit added as an option in
v0.1.1[\[27\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=,quantization%20support%20for%20embedding%20tables).
That keeps activations in float but still gets memory savings from int8
weights, avoiding any extra dequant latency.

**Accuracy impact:** INT8 PTQ generally preserves model accuracy
**within a few percent** of the float baseline for large LLMs,
especially when using per-channel weights. Google's documentation and
blog posts repeatedly note that quantization can be done "with minimal
performance
degradation"[\[37\]](https://developers.googleblog.com/en/introducing-gemma-3-270m/#:~:text=%2A%20Production,constrained%20devices).
In quantitative terms, an 8-bit weight + activation quantization might
cause a small increase in perplexity or a slight drop in certain
benchmark scores, but it's often very minor -- e.g. SmoothQuant (W8A8)
on GPT-style models yields \<1% accuracy drop on
benchmarks[\[43\]](https://latitude-blog.ghost.io/blog/how-quantization-reduces-llm-latency/#:~:text=SmoothQuant%20offers%20notable%20benefits%3A%20up,quarter%20of%20its%20FP32%20size).
The Gemma 3 models were actually released with **quantization-aware
training (QAT)** variants to virtually eliminate this
drop[\[44\]](https://ai.google.dev/gemma/docs/core#:~:text=For%20all%20Gemma%203%20models%2C,quality).
If you use the QAT checkpoint, the int8 (or even int4) model's quality
is almost the same as FP16. Without QAT, PTQ 8-bit still retains high
quality for two reasons: (1) 8-bit is fairly high precision, and (2) the
biggest sources of error (outlier activations) can often be mitigated by
calibration or techniques like SmoothQuant. Developers have reported
that int8 PTQ on LLaMA 7B/13B, for example, yields no noticeable
difference in chat quality for many tasks -- the model might only
struggle on very sensitive tasks (e.g. mathematical reasoning) unless
quantization outlier mitigation is applied. For Gemma 3n, we can infer
from its design that it handles quantization well: it was "built for
efficient execution on low-resource devices" and even the *Edge TPU*
int8 variants maintain strong accuracy (the blog notes a quantized
vision encoder getting **13× speedup** for only a tiny accuracy drop
compared to 6.5× with float16 on Pixel
TPU)[\[45\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=Benefiting%20from%20novel%20architectural%20designs,language%20tasks).
In summary, **accuracy loss from int8 PTQ is small** -- typically a
worthwhile trade-off for the 2× reduction in memory and big speed gains.
And if that loss isn't acceptable, you have the option of 16-bit
activations (int8 weights with int16
accumulators)[\[46\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Integer%20only%3A%2016,bit%20weights%20%28experimental)
or full QAT. In practice, many on-device apps use int8 PTQ and find the
model's responses still excellent for conversation, reasoning, etc.,
especially for the larger model variants.

**Gemma 3 vs 3n variants:** The question specifically mentions Gemma 3
and 3n "Nano/Standard/Full" variants. Gemma 3 (earlier generation) had
model sizes from 270M up to 27B, and their quantized performance is
covered by the table above. **Gemma 3n**, introduced in late 2025, comes
in effectively *2B (E2B)* and *4B (E4B)* parameter versions (sometimes
dubbed "Nano" and "Full"). Thanks to the MatFormer nested architecture,
the 4B model contains the 2B model inside
it[\[47\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=effective%20parameter%20%28E2B%29%20sub,capabilities%20and%20use%20cases%20today).
The smaller 3n model can run faster -- it offers "up to **2× faster**
inference" than the full 4B model, at lower memory
cost[\[48\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=1%3A%20Pre,up%20to%202x%20faster%20inference).
Naturally, the 4B will be more accurate (it's the first sub-10B model to
exceed 1300 LMArena
score)[\[49\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=of%2035%20languages,parameters%20to%20reach%20this%20benchmark),
while the 2B is a bit less capable. Both support int8 quantization. If
deploying to a very constrained device (e.g. a mid-tier phone or
embedded board), the 2B model in int8 will be a better fit (roughly
\~2GB of weights in int8, or \~1GB with 4-bit). On higher-end devices,
the 4B int8 model might still be feasible (4GB of weights) and gives
better quality. Google's on-device benchmarking of Gemma 3n (Preview)
used 4-bit weights to push performance, but the reported numbers give a
sense of int8 as well. For example, on a Mac M3 laptop CPU, Gemma3n-4B
ran \~170 tokens/sec prefill and 20 tokens/sec decode with 4-bit
weights[\[39\]](https://huggingface.co/google/gemma-3n-E4B-it-litert-lm#:~:text=Gemma3n,4).
With int8 weights, we'd expect slightly lower prefill throughput
(because twice the memory load vs int4) but still in the hundreds of
tokens/sec, and decode likely similar or a bit higher than 20 tokens/sec
due to easier decoding. On a Snapdragon 8 Gen3 phone (Galaxy S24), the
4B model achieved \~73 tokens/sec prefill and \~9 tokens/sec decode with
int4[\[39\]](https://huggingface.co/google/gemma-3n-E4B-it-litert-lm#:~:text=Gemma3n,4)
-- an int8 model would use more memory but still comfortably run,
potentially with decode in the \~10--15 tokens/sec range on CPU. These
figures underline that on-device LLMs are now practical: a quantized 2B
model can easily double those speeds, and even multiple tokens per
second is fine for many applications. Finally, note that **quantization
interacts with model architecture**: Gemma 3n's PLE (Per-Layer
Embeddings) means some embedding weights stay in higher precision on
CPU, which can slightly reduce the quantization error in practice (since
not everything is quantized in the GPU
memory)[\[29\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=accelerator%20%28GPU%2FTPU%29).
The KV cache sharing and other optimizations also improve effective
throughput[\[40\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=KV%20Cache%20Sharing%20optimizes%20how,sequences%20much%20faster%20than%20before),
making the *quantized* 3n models especially efficient. The bottom line
is that *post-training int8 quantization is a crucial enabler for Gemma
models on-device*, yielding huge memory and speed gains at a very small
cost in accuracy. All the tools to do this -- from the TFLite/LiteRT
converter (last updated August
2024)[\[50\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Last%20updated%202024)
to the MediaPipe GenAI pipeline -- are provided by Google, along with
documentation and even ready-made quantized checkpoints. Developers
should leverage these resources (see Google's AI Edge docs and the Gemma
Cookbook on GitHub) to quantize and deploy LLMs effectively.

**Sources:** Official Google AI Edge documentation on \[post-training
quantization (PTQ)
methods\][\[1\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Post,format%20using%20the%20LiteRT%20Converter)[\[51\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=For%20full%20integer%20quantization%2C%20you,function%20below)
and the \[8-bit quantization
spec\][\[9\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Often%2C%20the%20,has%20large%20improvements%20to%20accuracy)[\[13\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Activations%20are%20asymmetric%3A%20they%20can,can%20be%20optimized%20pretty%20heavily);
*MediaPipe LLM Inference* blog post (Mar 2024) detailing on-device
optimizations (int8 quantization,
caching)[\[38\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=two%20significant%20optimizations%20for%20LLM,based)[\[24\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=Balancing%20Compute%20and%20Memory%3A%20Upon,the%20main%20mathematical%20convolution%20operations);
Gemma 3 model overview (Aug 2025) with memory/precision
trade-offs[\[35\]](https://ai.google.dev/gemma/docs/core#:~:text=%288,1%20GB%2021%20GB);
Gemma 3n developer guide (Oct 2025) for architecture-specific
insights[\[52\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=1%3A%20Pre,up%20to%202x%20faster%20inference)[\[40\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=KV%20Cache%20Sharing%20optimizes%20how,sequences%20much%20faster%20than%20before);
and Google AI Edge GitHub releases (May--June 2025) for converter
updates[\[27\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=,quantization%20support%20for%20embedding%20tables)[\[42\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=Known%20Issues).
These provide the latest authoritative guidance on PTQ for LLMs
targeting on-device LiteRT-LM deployment.

[\[1\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Post,format%20using%20the%20LiteRT%20Converter)
[\[2\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Post,format%20using%20the%20LiteRT%20Converter)
[\[3\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Technique%20Benefits%20Hardware%20Dynamic%20range,smaller%2C%20GPU%20acceleration%20CPU%2C%20GPU)
[\[11\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=%2A%20Per,point%20equal%20to%200)
[\[16\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=For%20full%20integer%20quantization%2C%20you,function%20below)
[\[18\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=def%20representative_dataset,tf.dtypes.cast%28data%2C%20tf.float32)
[\[21\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=import%20tensorflow%20as%20tf%20converter,convert)
[\[22\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=If%2016x8%20quantization%20is%20not,the%20target_spec%20to%20allow%20this)
[\[33\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=import%20tensorflow%20as%20tf%20converter,convert)
[\[46\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Integer%20only%3A%2016,bit%20weights%20%28experimental)
[\[50\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=Last%20updated%202024)
[\[51\]](https://ai.google.dev/edge/litert/models/post_training_quantization#:~:text=For%20full%20integer%20quantization%2C%20you,function%20below)
Post-training quantization  \|  Google AI Edge  \|  Google AI for
Developers

<https://ai.google.dev/edge/litert/models/post_training_quantization>

[\[4\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=The%20following%20speeds%20were%20taken,bit%20weight%20quantization)
[\[5\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=precision%20loss%20according%20to%20our,models%20on%20iOS%20as%20well)
[\[6\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=2,using%20the%20MediaPipe%20Python%20Package)
[\[23\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=Weights%20Sharing%3A%20The%20LLM%20inference,connected%20operator%20separately%20to%20ensure)
[\[24\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=Balancing%20Compute%20and%20Memory%3A%20Upon,the%20main%20mathematical%20convolution%20operations)
[\[25\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=operations)
[\[34\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=On%20the%20GPU%2C%20Falcon%201B,models%20on%20iOS%20as%20well)
[\[38\]](https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/#:~:text=two%20significant%20optimizations%20for%20LLM,based)
Large Language Models On-Device with MediaPipe and TensorFlow Lite -
Google Developers Blog

<https://developers.googleblog.com/en/large-language-models-on-device-with-mediapipe-and-tensorflow-lite/>

[\[7\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=1,file%20and%20the%20model%20tokenizer)
LLM Inference guide  \|  Google AI Edge  \|  Google AI for Developers

<https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference>

[\[8\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Per)
[\[9\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Often%2C%20the%20,has%20large%20improvements%20to%20accuracy)
[\[10\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=FULLY_CONNECTED%20Input%200%3A%20data_type%20,axis%20%28dim%20%3D%200)
[\[12\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=FULLY_CONNECTED%20Input%200%3A%20data_type%20,restriction%3A%20zero_point%20%3D%200)
[\[13\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Activations%20are%20asymmetric%3A%20they%20can,can%20be%20optimized%20pretty%20heavily)
[\[14\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Input%202%20,tensor)
[\[15\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=SOFTMAX%20Input%200%3A%20data_type%20,tensor)
[\[19\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Below%20we%20describe%20the%20quantization,for%20our%20int8%20tflite%20kernels)
[\[20\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=MUL%20Input%200%3A%20data_type%20,tensor%20Output%200)
[\[28\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=GATHER%20Input%200%3A%20data_type%20,tensor)
[\[31\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=Per,128%2C%20127)
[\[32\]](https://ai.google.dev/edge/litert/models/quantization_spec#:~:text=scale%20values%20to%20be%20per,This%20generalizes%20readily%2C%20as%20follows)
LiteRT 8-bit quantization specification  \|  Google AI Edge  \|  Google
AI for Developers

<https://ai.google.dev/edge/litert/models/quantization_spec>

[\[17\]](https://latitude-blog.ghost.io/blog/how-quantization-reduces-llm-latency/#:~:text=ranging%20from%20high,IoT%20devices)
[\[43\]](https://latitude-blog.ghost.io/blog/how-quantization-reduces-llm-latency/#:~:text=SmoothQuant%20offers%20notable%20benefits%3A%20up,quarter%20of%20its%20FP32%20size)
How Quantization Reduces LLM Latency

<https://latitude-blog.ghost.io/blog/how-quantization-reduces-llm-latency/>

[\[26\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=,two%20quantization%20frameworks%20are%20here)
[\[27\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=,quantization%20support%20for%20embedding%20tables)
[\[42\]](https://github.com/google-ai-edge/ai-edge-torch/releases#:~:text=Known%20Issues)
Releases · google-ai-edge/ai-edge-torch · GitHub

<https://github.com/google-ai-edge/ai-edge-torch/releases>

[\[29\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=accelerator%20%28GPU%2FTPU%29)
[\[30\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=With%20Per,parameters%20loaded%20in%20your%20accelerator)
[\[40\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=KV%20Cache%20Sharing%20optimizes%20how,sequences%20much%20faster%20than%20before)
[\[41\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=Benefiting%20from%20novel%20architectural%20designs,language%20tasks)
[\[45\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=Benefiting%20from%20novel%20architectural%20designs,language%20tasks)
[\[47\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=effective%20parameter%20%28E2B%29%20sub,capabilities%20and%20use%20cases%20today)
[\[48\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=1%3A%20Pre,up%20to%202x%20faster%20inference)
[\[49\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=of%2035%20languages,parameters%20to%20reach%20this%20benchmark)
[\[52\]](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#:~:text=1%3A%20Pre,up%20to%202x%20faster%20inference)
Introducing Gemma 3n: The developer guide - Google Developers Blog

<https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/>

[\[35\]](https://ai.google.dev/gemma/docs/core#:~:text=%288,1%20GB%2021%20GB)
[\[36\]](https://ai.google.dev/gemma/docs/core#:~:text=%288,1%20GB%2021%20GB)
[\[44\]](https://ai.google.dev/gemma/docs/core#:~:text=For%20all%20Gemma%203%20models%2C,quality)
Gemma 3 model overview  \|  Google AI for Developers

<https://ai.google.dev/gemma/docs/core>

[\[37\]](https://developers.googleblog.com/en/introducing-gemma-3-270m/#:~:text=%2A%20Production,constrained%20devices)
Introducing Gemma 3 270M: The compact model for hyper-efficient AI -
Google Developers Blog

<https://developers.googleblog.com/en/introducing-gemma-3-270m/>

[\[39\]](https://huggingface.co/google/gemma-3n-E4B-it-litert-lm#:~:text=Gemma3n,4)
google/gemma-3n-E4B-it-litert-lm · Hugging Face

<https://huggingface.co/google/gemma-3n-E4B-it-litert-lm>
