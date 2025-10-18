# Core ML Tools for LLMs on iOS (Gemma-3 scale) and macOS

## **ML Program Format for LLM Conversion**

Modern versions of coremltools convert models to the **ML Program**
format by default (for iOS 15+/macOS
12+)[\[1\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=This%20section%20describes%20the%20,first%20version%20of%20Core%20ML)[\[2\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=,convert%28source_model).
This format supports flexible input shapes and dynamic control flow,
which are crucial for large language models. An ML Program decouples
model weights from the architecture, storing them in a package
(`.mlpackage`) rather than a single `.mlmodel`
file[\[3\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=An%20ML%20program%20decouples%20the,offers%20more%20flexible%20metadata%20editing).
This enables large models (e.g. GPT-style Transformers) to use dynamic
sequence lengths and advanced ops not possible in the older
neural-network
format[\[4\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=To%20convert%20a%20model%20to,model%20types%2C%20see%20%2016).
When converting a PyTorch model (the typical workflow), you should
specify a **deployment target** high enough to enable ML Program
features -- for example, `minimum_deployment_target=ct.target.iOS18` for
iOS 18 (or `macOS15` for macOS
15)[\[5\]](https://huggingface.co/blog/mistral-coreml#:~:text=To%20convert%20the%20model%20to,to%20the%20same%20conversion%20target)[\[6\]](https://huggingface.co/blog/mistral-coreml#:~:text=that%E2%80%99s%20what%20we%20specified%20for,to%20the%20same%20conversion%20target).
Core ML Tools 7+ will produce an ML Program by default if the target is
iOS 15+/macOS
12+[\[2\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=,convert%28source_model).

In practice, this means you can convert Gemma (or similar LLMs like
LLaMA or Falcon) from PyTorch to Core ML with code like:

    import coremltools as ct
    mlmodel = ct.convert(traced_model, inputs=[...], outputs=[...], 
                         minimum_deployment_target=ct.target.iOS18)
    mlmodel.save("MyLLM.mlpackage")

Here, the **ML Program** format allows flexible sequence dimensions
(e.g. using `ct.RangeDim` for token length) and is required for advanced
features like **stateful models** and fused ops. By default, weights are
saved in 16-bit float to reduce size (an 8B model in float16 was \~16 GB
in Core
ML)[\[7\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Core%20ML%20by%20default%20produces,match%20within%20a%20low%20tolerance).
You can adjust precision with `compute_precision` (float16 vs float32)
during
conversion[\[8\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=You%20can%20optionally%20set%20the,shown%20in%20the%20following%20example)[\[9\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=For%20details%20on%20ML%20program,precision%2C%20see%20Typed%20Execution),
but float16 is usually sufficient for inference and is the default.
Converting from ONNX is also possible (coremltools can ingest ONNX
graphs), though most LLM examples use PyTorch or Hugging Face
Transformers directly. TensorFlow models can be converted as well, but
official LLM conversion paths are better established via PyTorch. In
summary, **use ML Program format** for LLMs to leverage dynamic shapes
and new ops, and target at least iOS 15+ (ideally iOS 18 for the latest
features).

## **Compute Units: CPU, GPU, and ANE**

Core ML can execute models on different hardware units: the CPU, the
GPU, and the Apple Neural Engine (ANE). You can specify `computeUnits`
(in Python conversion or in Swift at runtime) to guide this: options are
`.all` (use ANE if available, otherwise GPU/CPU), `.cpuAndGPU`,
`.cpuAndNeuralEngine`, or
`.cpuOnly`[\[10\]](https://github.com/huggingface/exporters#:~:text=%2A%20%60,cpu_and_ne).
**By default, Core ML tries to use all accelerators** for the best
performance[\[11\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=leveraging%20the%20Metal%20Performance%20Shaders,to%20deploy%20models%20on%20Apple).
In fact, when you load a model without specifying, Core ML will create a
hybrid plan that blends CPU, GPU, and ANE as
needed[\[12\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=coremltools%2C%20Apple%E2%80%99s%20open,any%20particular%20device%20or%20implementation).
The `compute_units` flag in `ct.convert()` is mostly a **hint for
immediate testing** -- it doesn't bake a permanent setting into the
model
file[\[13\]](https://github.com/apple/coremltools/issues/1849#:~:text=The%20coremltools%20,argument)[\[14\]](https://github.com/apple/coremltools/issues/1849#:~:text=So%20it%20seems%20to%20me,mlpackage).
At runtime, you control this via `MLModelConfiguration.computeUnits`.
For example, on an iPhone you might start with `.all` to let Core ML use
the Neural Engine for maximum efficiency, and fall back to `.cpuAndGPU`
if you encounter issues.

**Why choose one over another?** Large autoregressive models are often
*memory-bandwidth bound*, so the **GPU** (with its high memory
throughput) tends to offer the best speed on Mac and on M-series
chips[\[15\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20hosted%20on%20Hugging%20Face,the%20device%20of%20our%20interest)[\[16\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=optimize%20it%20for%20on,memory%20bandwidth%20on%20the%20device).
Apple's Llama2 8B example explicitly targets the GPU on M1 Max for \~33
tokens/s
throughput[\[17\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=This%20technical%20post%20details%20how,based%20LLMs%20of%20different%20sizes)[\[15\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20hosted%20on%20Hugging%20Face,the%20device%20of%20our%20interest).
The **Neural Engine (ANE)** can accelerate smaller models efficiently on
iPhones and iPads (and on Mac M1/M2), often with very low power usage.
However, to fully utilize ANE, the model may need to be optimized (e.g.
certain 4-D tensor shapes, ops that map to
ANE)[\[18\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=developers%20worldwide%20a%20way%20to,Transformer%20models%20on%20Apple%20devices)[\[19\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=This%20implementation%20is%20specifically%20optimized,device%2C%20not%20on%20the%20server).
By default, Core ML will attempt to use ANE for any ops it can, but
extremely large models might *not fit entirely* in ANE memory. In
practice, many current LLM apps on iOS run on GPU/CPU because of ANE
memory constraints and API
limitations[\[20\]](https://news.ycombinator.com/item?id=38907919#:~:text=DR%3A%20No%2C%20nearly%20all%20these,of%20benefit%20for%20the%20cost).
If you find that using `.all` (which includes ANE) causes issues -- for
example, one developer found a model that ran on an A16 GPU but crashed
on an A18 when ANE was used, with memory spiking to \~6
GB[\[21\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=As%20we%20described%20on%20the,Until%20now%2C%20I%20have%20tried)[\[22\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=Error%3D_ANECompiler%20%3A%20ANECCompile%28%29%20FAILED,kindof%20fix%20should%20I%20do)
-- you might restrict to `.cpuAndGPU`. On the other hand, smaller 1--3B
models *can* run on ANE, and Apple is working on examples to maximize
ANE performance for
those[\[23\]](https://huggingface.co/blog/mistral-coreml#:~:text=,for%20great%20candidates%20to%20explore)[\[24\]](https://huggingface.co/blog/mistral-coreml#:~:text=Getting%20the%20most%20performance%20out,for%20great%20candidates%20to%20explore).
In summary, on **iOS devices**, start with `ComputeUnit.ALL` to use ANE
and monitor performance; if the model is too large or ANE fallback
fails, use `CPU_AND_GPU`. On **macOS**, using the GPU (with
`.CPU_AND_GPU` or `.ALL` on an M-series Mac) typically yields the best
throughput for 7B+
models[\[25\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=optimize%20it%20for%20on,the%20device%20of%20our%20interest).
Always profile on real devices -- the optimal setting can vary by chip
generation and model size.

## **Stateful Models and KV Cache**

**Key-Value caching** is critical for efficient autoregressive
generation. In a transformer LLM, each new token's attention layer needs
the past keys and values (KV) from previous tokens. By caching these, we
avoid recomputing attention on the entire sequence for every new token.
Core ML supports this via **stateful models** (introduced around iOS 18
/ macOS 15) which let you maintain state (like KV tensors) between
prediction
calls[\[26\]](https://huggingface.co/blog/mistral-coreml#:~:text=However%2C%20there%20are%20practical%20limitations%3A,time%20you%20use%20the%20model)[\[27\]](https://huggingface.co/blog/mistral-coreml#:~:text=Stateful%20buffers%20were%20introduced%20in,candidate%20for%20using%20stateful%20buffers).
Traditionally, without stateful support, one would pass the previous
tokens' K and V as additional *inputs* to the model and get updated K,V
as outputs every step -- but doing so for large tensors every iteration
incurs significant memory bandwidth
cost[\[26\]](https://huggingface.co/blog/mistral-coreml#:~:text=However%2C%20there%20are%20practical%20limitations%3A,time%20you%20use%20the%20model).
The new approach allows the model to **hold the KV cache in GPU/ANE
memory** between runs, greatly reducing
overhead[\[28\]](https://huggingface.co/blog/mistral-coreml#:~:text=bottleneck%20is%20usually%20your%20computer%E2%80%99s,time%20you%20use%20the%20model)[\[29\]](https://huggingface.co/blog/mistral-coreml#:~:text=kv,guide%20update%20about%20stateful%20models).

**Using stateful KV in coremltools:** When converting, you can designate
certain inputs/outputs as *state* using `ct.StateType`. For example,
Apple's Mistral 7B example wraps the cache tensors as states named
`"keyCache"` and
`"valueCache"`[\[30\]](https://huggingface.co/blog/mistral-coreml#:~:text=name%3D,%29%2C)[\[5\]](https://huggingface.co/blog/mistral-coreml#:~:text=To%20convert%20the%20model%20to,to%20the%20same%20conversion%20target).
The converted model then has those as `MLState` objects in Swift. You
initialize them once (usually as empty or zero arrays of max size) and
pass the state from one prediction to the next. On iOS 18+, Core ML will
update the state in-place on the GPU/ANE without copying to CPU each
time[\[28\]](https://huggingface.co/blog/mistral-coreml#:~:text=bottleneck%20is%20usually%20your%20computer%E2%80%99s,time%20you%20use%20the%20model).
This yields a big speedup in generation. In code, a stateful model might
be invoked like:

    // Pseudocode in Swift
    let modelConfig = MLModelConfiguration()
    modelConfig.computeUnits = .all 
    let model = try MyLLM(configuration: modelConfig) 

    var state = model.blankState // initial zero-initialized KV cache
    // Prefill stage: infer on the prompt tokens in one go
    let promptOut = try model.prediction(inputIds: promptIDs, state: state)
    state = promptOut.state  // KV cache now filled for prompt

    // Decoding loop: generate next N tokens
    for _ in 0..<N {
        let out = try model.prediction(inputIds: [currentTokenID], state: state)
        state = out.state  // state updated with new token’s KV
        let nextTokenProbs = out.logits // model's output probabilities
        ... // pick next token from probs
    }

With **Gemma-3 or LLaMA-class models**, the KV cache can be large: e.g.
for an 8B model with 32 layers and 2048 max tokens, each of the key or
value cache might be shape \[32, 1, numHeads, 2048, headDim\] (tens of
millions of
elements)[\[31\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=previous%20tokens,will%20have%20the)[\[32\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=that%2C%20we%20now%20create%20a,tensor%20will%20be%20computed%20and).
Managing this as state avoids copying these tens of MBs on each
iteration. If you target iOS 18+, simply design the model with stateful
inputs/outputs; coremltools will ensure the Core ML model uses
**MLProgram states**. For earlier iOS versions (iOS 17 and below) where
true stateful models aren't available, you would need to fall back to
passing the cache manually as multi-array inputs/outputs. This is
possible (Hugging Face's Core ML exporter supports a "with-past" mode
for models, which adds the past K/V as extra input/output
tensors[\[33\]](https://github.com/huggingface/exporters#:~:text=has%20a%20sequence%20classification%20head)),
but it means every iteration your app must handle large MLMultiArray
objects for the cache. This can still work but is slower due to the
memory shuffling.

**Gemma-specific caveat:** If "Gemma-3" uses a similar transformer
architecture, there is nothing fundamentally different -- you'd apply
the same KV caching technique. Ensure that the model is converted with
**flexible sequence length** and explicit cache inputs. Apple's
documentation shows a toy example making an `attention_mask` and KV
cache explicit in the model forward pass before
conversion[\[34\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20consumes%2C%20now%20we%20can,them%20flexible%20shaped%2C%20as%20follows)[\[35\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=,applied%2C%20the%20dot%20products%20of).
In practice, you might need to modify Gemma's PyTorch code to accept and
update a cache (similar to how one would modify a GPT-2 model to use
past key/values). Then trace and convert it to Core ML with those state
tensors. The **bottom line** is that to achieve good performance for any
LLM (Gemma, LLaMA, GPT-2, etc.), you must use KV caching either via Core
ML's state API (preferred on iOS 18+) or via manual tensors on earlier
versions.

## **Memory Considerations and Context Length**

Running LLMs on-device is memory-intensive. There are two major memory
consumers: **model weights** and **activations (especially the KV
cache)**. A model like LLaMA-8B in float16 is \~16 GB just for
weights[\[7\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Core%20ML%20by%20default%20produces,match%20within%20a%20low%20tolerance),
which is far beyond iPhone memory. Thus, **quantization** is essential.
Core ML now supports **block-wise 4-bit quantization**, which can shrink
model size dramatically with minimal quality
loss[\[36\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Block)[\[37\]](https://huggingface.co/blog/mistral-coreml#:~:text=Using%20the%20new%20block,bit%20weights).
In the Mistral 7B example, applying 4-bit weight quantization (with
32-element blocks) reduced the Core ML package to \~3.8 GB, down from
\~14 GB in
float16[\[38\]](https://huggingface.co/blog/mistral-coreml#:~:text=).
The weights are stored in int4 and transparently decompressed to float16
on the fly during inference, saving
bandwidth[\[37\]](https://huggingface.co/blog/mistral-coreml#:~:text=Using%20the%20new%20block,bit%20weights)[\[39\]](https://huggingface.co/blog/mistral-coreml#:~:text=make%20the%20model%20run%20faster,bit%20weights).
You can use `coremltools.optimize.coreml.linear_quantize_weights(...)`
with an `int4` config as shown in Apple's example to achieve
this[\[40\]](https://huggingface.co/blog/mistral-coreml#:~:text=The%20quantization%20parameters%20are%20configured,as%20follows)[\[41\]](https://huggingface.co/blog/mistral-coreml#:~:text=Let%E2%80%99s%20use%20that%20configuration%20to,a%20few%20minutes%20to%20run).
For slightly smaller models, 8-bit (quantize to int8) is another option.
The **computeUnits** choice can also affect memory -- for instance, ANE
may have more limited memory for models than the GPU. If a model is
right at the edge of what fits, you might find the GPU can handle it but
ANE cannot, in which case you'd use GPU.

**Context length** (maximum sequence length) has a *quadratic* effect on
memory usage in transformers due to attention matrices and cache size.
If your use case permits a shorter context, consider reducing it to
lower memory demands. Apple's benchmarks showed that cutting context
from 2048 to 512 greatly improved throughput (from \~0.19 to 0.8
tokens/s on a baseline 8B model) and of course reduces memory
load[\[42\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Maximum%20Context%20Size%20Extend%20Throughput,23).
Gemma-3n might be a variant with a different context or optimized size
-- if "3n" stands for a smaller version or distilled model, it could be
more feasible for mobile. Each token in the KV cache for all layers
consumes memory proportional to layers \* hidden_dim. For example, a
single additional token for a 7B model can add a few megabytes across
all caches. Using **float16** for cache (which coremltools does by
default) helps halve the activation memory. Core ML will allocate the
full max context size for the state buffer up front (e.g. if max length
is 1024, the state is that size). Thus, don't oversize the context
beyond what you need. In code, you define a flexible shape
`[1, maxSeqLen]` for the token input and similarly for the cache state
dimensions[\[34\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20consumes%2C%20now%20we%20can,them%20flexible%20shaped%2C%20as%20follows)
-- this `maxSeqLen` determines allocation. Choosing a reasonable limit
(e.g. 512 or 1024 tokens on mobile) can prevent out-of-memory crashes.

Another memory consideration is **intermediate activations**. On iOS
devices, memory is often contiguous and limited; a 4GB model might just
barely fit into a high-end iPhone's RAM. Monitor peak memory during the
first inference, which includes compilation overhead. Core ML may unload
some intermediate buffers as soon as possible (especially with ML
Program's memory optimizations), but when pushing the limits (like a 7B
model on a 6GB RAM phone), you might hit the app memory limit. In
testing, ensure to handle memory warnings. If necessary, use a smaller
model or further compression (some developers even use *GPT-2 size
(\~1.5B)* models or distilled versions for phone deployment).

**Performance Tips:** Use the newest Core ML features available on your
deployment target. For example, iOS 18/macOS 15 introduced a fused
`scaled_dot_product_attention` op that Core ML will use if the model is
converted with that minimum
target[\[43\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Starting%20with%20macOS%20Sequoia%2C%20the,need%20not%20be%20fully%20materialized)[\[44\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=While%20the%20Core%20ML,see%20Figure%201).
This fused attention can avoid materializing huge attention score
matrices and instead compute them in a single GPU kernel, saving memory
and time. Ensure your PyTorch model uses the standard
`torch.nn.functional.scaled_dot_product_attention` (Hugging Face models
do), so coremltools can recognize and fuse
it[\[44\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=While%20the%20Core%20ML,see%20Figure%201).
Quantizing weights not only saves memory but also often **speeds up
inference** (since less data is transferred from
memory)[\[37\]](https://huggingface.co/blog/mistral-coreml#:~:text=Using%20the%20new%20block,bit%20weights)[\[39\]](https://huggingface.co/blog/mistral-coreml#:~:text=make%20the%20model%20run%20faster,bit%20weights).
Do note, quantization might slightly reduce accuracy, but for many
applications the trade-off is acceptable, especially with int8/int4
block-wise methods that minimize
impact[\[45\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=macOS%20Sequoia%20introduced%20several%20low,wise%20linear%20quantization).

Finally, **test on real devices** and try different `computeUnits` and
batch sizes. On Macs, the GPU is typically best for throughput, whereas
on iPhone the ANE can give better efficiency for smaller models. Core
ML's default scheduling is generally good, but if you notice
under-utilized GPU or the app becoming unresponsive, you might pin to
CPU for parts (for example, do prefill on GPU but decoding on CPU if the
GPU is saturated rendering UI -- though this is advanced and usually not
needed).

## **Input/Output Handling and Tokenization**

Core ML models don't inherently know about text, so **tokenization must
be done in the app** (just as on other platforms). Typically, you'll use
the same tokenizer as the original model (e.g. Byte-Pair Encoding for
GPT-2/LLaMA). You can either include a tokenizer library (like Hugging
Face `Tokenizer.swift`, or a custom Swift implementation of the BPE
algorithm and vocab) or even store a lookup dictionary in your app. Core
ML expects numeric tensors. For example, the Llama 8B Core ML model
takes two inputs: an `inputIds` tensor of shape `(1, N)` of token IDs
and an `attentionMask` or `causalMask`
tensor[\[46\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=constant%20irrespective%20of%20the%20length,of%20the%20input%20text)[\[47\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=,nature%20of%20the%20language%20model).
In a simpler setup, you might just feed `inputIds` and have the model
internally generate an attention mask. However, for performance, the
Apple examples pass in a precomputed causal mask tensor as input to
avoid the model doing it each
time[\[48\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=each%20decoding%20step%20will%20result,the%20cache%20by%201%20token).
In your Swift code, you'll prepare the `MLMultiArray` (or use the new
`MLShapedArray`/`MLTensor` APIs for convenience) with the token IDs.
Apple's new **Swift** `MLTensor` API (iOS 18+) makes this easier -- you
can create a `Tensor<Int32>` directly and even apply operations like
softmax in
Swift[\[49\]](https://huggingface.co/blog/mistral-coreml#:~:text=The%20first%20feature%20we%20want,with%20tensor%20data%20in%20Swift)[\[50\]](https://huggingface.co/blog/mistral-coreml#:~:text=The%20new%20,these%20operations%20without%20custom%20code).
The outputs of the model are usually the logits or probabilities for the
next token. For instance, a GPT-style model returns a `(1, vocab_size)`
logits array for the last token in the input sequence. Your app must
interpret that, typically by applying softmax and selecting the
highest-probability token (or using a sampling strategy for text
generation). Core ML can't do the token selection for you (unless you
converted the model differently to output the argmax token, but that's
not common for LLMs). So, after each prediction, you'll decode the next
token ID to a word/piece via your tokenizer's vocabulary and append it
to the context.

Hugging Face's Core ML exporter tries to streamline this -- it can embed
the **vocabulary labels** in a classifier model, but for LLMs it usually
leaves the heavy lifting to the developer. "Core ML does not have the
concept of a tokenizer," the Hugging Face docs note -- you must handle
that in
Swift[\[51\]](https://github.com/huggingface/exporters#:~:text=models%2C%20you%20might%20need%20to,do%20more%20work).
They provide an example of Swift tokenization for
reference[\[51\]](https://github.com/huggingface/exporters#:~:text=models%2C%20you%20might%20need%20to,do%20more%20work).
Alternatively, you might store the tokenizer files (vocab.json,
merges.txt or similar for BPE) within your app and write a small
tokenizer function. The **metadata** of the Core ML model can also be
used to store a reference to the tokenizer: for example, the Mistral 7B
`.mlpackage` has a user-defined metadata field with the model's
HuggingFace ID, which the demo Swift code uses to fetch tokenizer
files[\[52\]](https://huggingface.co/blog/mistral-coreml#:~:text=There%E2%80%99s%20a%20final%20step%20after,it%E2%80%99s%20different%20for%20every%20model).
In a production app, you'd likely bundle the tokenizer to avoid network
dependence.

**Attention masks**: If your model expects an `attentionMask` input
(like many transformer implementations do), typically it's a 0/1 mask of
shape `(1, N)` indicating which tokens are real and which are padding.
In autoregressive use, you actually want a causal mask (upper triangle
of matrix = --inf). Apple's optimized approach was to input the full
causal mask matrix to the
model[\[48\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=each%20decoding%20step%20will%20result,the%20cache%20by%201%20token),
but that increases input size (N×N matrix). Another approach is to let
the model generate the causal mask internally from the length (which
Core ML can do if you feed just the 1D mask). For simplicity, if using
stateful generation one token at a time, you can often bypass needing a
mask input after the prompt -- because with one token input, there are
no future tokens to mask. During the prompt/prefill, if you feed the
whole prompt at once, you provide the triangular mask so the model
doesn't attend beyond current positions. Apple's toy example
demonstrates constructing a causal mask and updating it for each
step[\[53\]](https://apple.github.io/coremltools/docs-guides/source/stateful-models.html#:~:text=def%20forward,value%28x)[\[54\]](https://apple.github.io/coremltools/docs-guides/source/stateful-models.html#:~:text=,%3Aend_step%2C).
In practice, if using the **Hugging Face conversion (with "causal-lm"
feature)**, the Core ML model likely handles masking internally (the
model might take just `input_ids` and perhaps a `position` or
`attention_mask` vector). Always check the input descriptions of your
converted model in Xcode or via `mlmodel` description to know what to
feed.

**Streaming generation** (token-by-token) is the usual pattern.
Typically you do a **"prefill"** by inputting the entire user prompt to
the model (which is faster than looping token-by-token for the prompt).
This populates the KV cache with the prompt's context. Then you switch
to an iterative loop, feeding one token at a time and using the cache
state to get the next token, and so on. This yields the best performance
and mirrors how one would use an LLM on a PC. Core ML supports this
pattern well: after one multi-token pass, the state contains the
prompt's cached values; subsequent single-token calls use and update
that state. One caveat observed (as per an Apple Developer Forums
discussion) is that *when doing a batched initial call*, some users
noticed the state not fully updating for the entire prompt in one
go[\[55\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=Hello%2C%20I%27m%20running%20a%20large,issue%20only%20happens%20during%20the)[\[56\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=prefill%20stage%20%28i,cache%20during).
This could be due to an implementation quirk or bug -- e.g., maybe the
model's internal mask caused some part of the state to remain zero for
padding tokens. The workaround in such a case could be to feed the
prompt in smaller chunks or simply ensure your attention mask is
correct. Generally, though, Apple's own examples feed the full prompt in
one batch and it works, so this may not be a widespread issue. Just be
aware and test: verify that after the prompt stage, generating one more
token continues the sequence correctly (if it doesn't, you might need to
generate the prompt tokens iteratively instead).

## **Device and OS Version Differences**

**iOS (iPhone/iPad)** is the primary target for on-device LLM use here,
and **macOS** is secondary. The good news is that Core ML models are
portable between the two (especially when using ML Program). However,
there are a few differences to note:

-   **ANE availability:** All modern iPhones and iPads (A12 chip and
    later, actually A11 had first Neural Engine) have the Neural Engine,
    and all Apple Silicon Macs (M1/M2 series) do as well. Intel Macs do
    not have ANE, so on those macOS will use CPU/GPU only. If your app
    might run on Intel Macs, keep that in mind (the model will still
    work via CPU/GPU). On iOS devices, ANE has significant speed/Watt
    advantages for many ops, but as discussed, very large models might
    not fully utilize it. Smaller LLMs (1--4B parameters) can often run
    wholly on the ANE in iOS 17+, especially if optimized. Apple has
    demonstrated smaller language models (like their 500M param
    **OpenELM** model) running efficiently on-device using
    ANE[\[23\]](https://huggingface.co/blog/mistral-coreml#:~:text=,for%20great%20candidates%20to%20explore).
    For Gemma-3 (if it's a 3B param model, say), an iPhone 14/15 could
    potentially handle it with 4-bit weights on ANE, but testing is
    required. Mac computers with more memory can naturally handle larger
    contexts or models than an iPhone -- for example, an 8B model at
    2048 context might run on a 32GB RAM MacBook, but would be
    impossible on an 8GB phone.

-   **Minimum OS for features:** If you plan to support older iOS
    versions, note that **stateful models (MLState)** and some of the
    performance features require **iOS 18 or
    later**[\[6\]](https://huggingface.co/blog/mistral-coreml#:~:text=that%E2%80%99s%20what%20we%20specified%20for,to%20the%20same%20conversion%20target)[\[57\]](https://huggingface.co/blog/mistral-coreml#:~:text=Since%20adopting%20these%20features%20is,branch%20for%20now).
    If you must run on iOS 17 or 16, you can still use the Core ML
    model, but you won't get the stateful KV caching -- you'd have to
    pass caches in/out manually as discussed. The ML Program format
    itself is available since iOS
    15[\[58\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=The%20ML%20program%20model%20type,see%20Availability%20of%20ML%20Programs)[\[59\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=You%20can%20convert%20a%20TensorFlow,method),
    so you can target as low as iOS 15 if needed (coremltools will
    produce an MLProgram for iOS15+). But the cutting-edge optimizations
    (fused attention, stateful buffers, block quantization) came in iOS
    18/macOS 15. On macOS, ensure you target at least macOS 14 or 15 if
    you want those same features (macOS 14 corresponds to the 2024
    release, aka Sonoma; macOS 15 "Sequoia" is the 2025 release
    mentioned in docs). For development, you'll need Xcode 15+ to deploy
    iOS 18 and use `.mlpackage` models (Xcode 13+ is required for
    mlpackage
    support)[\[60\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=Requires%20Xcode%2013%20or%20Newer).

-   **Performance differences:** Mobile chips (A-series) have fewer GPU
    cores and less memory bandwidth than M-series Mac chips. An iPhone
    15 Pro's ANE is very fast (up to \~17 TOPS) but the GPU, while
    capable, is limited by thermal and power constraints. So on iOS, you
    might see that using ANE (if the model fits) gives better sustained
    performance without heating up the device, whereas on Mac, the GPU
    can be pushed hard with cooling. For long text generation sessions
    on iPhone, pay attention to thermal throttling -- the device may
    slow down if it overheats. Using the ANE can mitigate this since
    it's designed for efficient ML inference. Apple's 2022 ANE
    optimization article shows a **10× speed and 14× memory reduction**
    for a transformer by tailoring it to ANE
    execution[\[61\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=In%20this%20article%20we%20share,less%20memory%20after%20our%20optimizations)[\[62\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=execution,less%20memory%20after%20our%20optimizations).
    Those principles (like using 4D tensors, avoiding unsupported ops)
    might not be trivial to apply to a large model conversion, but they
    indicate that **with proper optimization an iPhone can handle
    surprising workloads**. For now, rely on coremltools and default
    optimizations; if needed, you can experiment with the techniques
    from Apple's reference (e.g., replacing some operations with
    equivalent forms more friendly to ANE, such as using `Conv2d` layers
    instead of large `MatMul` in certain
    places[\[63\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=data%20format%20for%20the%20ANE,first)[\[64\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=are%20both%20channels,weights%20shape%20as%20shown%20here),
    though this is advanced).

-   **Memory limits on iOS:** iOS apps have memory limits (and no swap).
    A model that uses \~4-5 GB RAM might simply be killed on a device
    with 6 GB total. macOS, having virtual memory, can handle temporary
    spikes more gracefully (albeit with slowdown if swapping).
    Therefore, it's often necessary to use a smaller model or more
    aggressive quantization for iOS. If Gemma-3 is too large for
    comfort, consider a distillation or smaller variant for on-device.
    You could also partition the model (not typical for LLMs, but for
    example using only some layers or a LoRA adapter approach -- beyond
    scope, but an idea).

In short, **iOS 18+ on recent devices is ideal** for on-device LLM with
Core ML (enabling ANE and stateful performance boosts). macOS can handle
bigger models and is great for development and testing (since you can
run the same `.mlpackage` on Mac). When providing guidance to users, you
might note if certain features (like longer contexts or larger models)
require the latest devices.

## **Packaging and Deployment**

Deploying a multi-gigabyte model to mobile requires careful packaging.
Apple provides a few options:

-   **App bundle vs On-Demand Resources:** You can ship the Core ML
    model with the app (by dragging the `.mlmodel` or `.mlpackage` into
    Xcode, it gets compiled into the app bundle). But this will inflate
    the app size significantly. To mitigate App Store download size, you
    can mark the model as an **On-Demand Resource (ODR)** so that it
    isn't downloaded until
    needed[\[65\]](https://www.zignuts.com/blog/how-to-use-core-ml-in-ios-guide#:~:text=How%20to%20Use%20Core%20ML,Quantization).
    For example, you might tag the model as "MLModel" resource that the
    app fetches upon first use. Another approach is to **download the
    model at runtime** from your server or a cloud bucket. Apple
    supports this: you can host the `.mlmodel` (or a compressed archive
    of an `.mlpackage`), download it via URLSession, then use
    `MLModel.compileModel(at: URL)` on device to compile
    it[\[66\]](https://medium.com/57blocks/introduction-to-using-core-ml-6753e5cd274b#:~:text=Here%20are%20the%20steps%20in,compile%20models%20within%20your%20app)[\[67\]](https://medium.com/57blocks/introduction-to-using-core-ml-6753e5cd274b#:~:text=,tune%20the%20model).
    The compiled model (.mlmodelc or .mlpackage) can be saved in the
    app's Documents directory for reuse. Apple's documentation notes
    that after compiling, you should move the model to a permanent
    location to avoid re-compiling each
    time[\[67\]](https://medium.com/57blocks/introduction-to-using-core-ml-6753e5cd274b#:~:text=,tune%20the%20model).
    Keep in mind, compiling a large model on device (especially an older
    phone) can take a non-trivial amount of time (tens of seconds to a
    minute). If you go the on-demand download route, consider showing a
    progress indicator or doing it at a convenient time (like app
    setup). On first run, Core ML might also JIT compile parts of the
    model for ANE/GPU -- this happens automatically and can cause a
    one-time delay. Subsequent uses are faster. iOS will cache the
    compiled model in the device's Core ML cache. (There isn't a public
    API to check the cache, but typically if the model hasn't changed,
    it won't recompile on every app launch -- it's cached by a
    fingerprint of the model content).

-   **Model format in Xcode:** If you include a `.mlmodel` in Xcode, it
    will compile to `.mlmodelc` at build time. If you include a
    `.mlpackage` (the ML Program container), Xcode will bundle it as-is
    (since it's already a compiled format in a sense). Ensure you're
    using a recent Xcode that supports model packages. In code, you load
    a `.mlmodelc` or `.mlpackage` the same way (the URL initialization
    handles both). For an ODR, you'd get the file URL from the
    downloaded resource.

-   **Integrity and security:** If your model is downloaded externally,
    you should verify it. You can use a checksum or code-sign it. Apple
    does allow **ML model encryption** -- you can encrypt a `.mlmodel`
    with a key and have the app retrieve a decryption key from a server
    at runtime. This is an enterprise feature to protect IP (it uses
    `MLModelConfiguration` with a model encryption key). It might be
    overkill for many apps, but it's available (introduced in iOS 14).
    At minimum, use HTTPS and consider validating the model file's hash
    against a known value. When using on-demand resources through
    Apple's infrastructure, integrity is managed by the App Store (the
    files are delivered securely and match what you uploaded).

-   **Storage considerations:** A 4GB model is too large for older
    appstore cellular download limits (Apple's limit was 200 MB over
    cellular, though they lifted the hard limit in recent iOS).
    Regardless, large initial downloads can frustrate users. Using ODR
    or post-install downloads lets you gate this -- e.g., download the
    model after user opts in to a feature. If the model is \~4GB, ensure
    the device has that free space. The `.mlpackage` might be compressed
    in transit (if you zip it), but once compiled it will occupy its
    full size on disk. Core ML does not support streaming the model from
    disk; it needs the whole model available in storage and memory.

-   **On-device resource management:** If your app might use multiple
    models (say a smaller one for older devices and a bigger one for
    newer), you can use *App Thinning* or ODR tags to deliver different
    models to different devices. Alternatively, have both and choose at
    runtime. Keep in mind memory: it might be wise to unload the MLModel
    when not in use. Core ML models can be large in memory; setting the
    model variable to nil and calling `MLModel.close()` (if available)
    can free memory when generation is done.

-   **Packaging tokenizers/resources:** Don't forget to include
    tokenizer files or any prompts needed. These are small (a few MB at
    most) compared to the model. If using Hugging Face tokenizers, you
    might also include their JSON merges file and code to parse it. This
    can be part of your app bundle.

In summary, **plan your model delivery** such that the user isn't forced
to download gigabytes they won't use. Utilize on-demand resources or
in-app
downloads[\[65\]](https://www.zignuts.com/blog/how-to-use-core-ml-in-ios-guide#:~:text=How%20to%20Use%20Core%20ML,Quantization).
Apple's guidelines allow apps to be up to 4GB in size, but ideally not
all users have to pay that cost. For integrity, treat the model like
code: verify it if coming from outside, and consider encryption if the
model IP is sensitive.

By following these guidelines -- converting your LLM (Gemma-3 or
analogous models) with coremltools to an ML Program, leveraging stateful
KV caching, choosing appropriate hardware units, quantizing for size,
and using Apple's on-device deployment tools -- you can achieve
efficient on-device text generation on iOS. Core ML has evolved to
handle transformers increasingly well, as evidenced by examples like
GPT-2[\[68\]](https://apple.github.io/coremltools/docs-guides/source/convert-nlp-model.html#:~:text=Now%20run%20the%20converted%20Core,model%20with%20the%20same%20input)[\[69\]](https://apple.github.io/coremltools/docs-guides/source/convert-nlp-model.html#:~:text=Completed%3A%20The%20Manhattan%20bridge%20is,the%20busiest%20in%20the%20country)
and
LLaMA/Mistral[\[70\]](https://apple.github.io/coremltools/docs-guides/source/stateful-models.html#:~:text=runtime%20performance%20improvements,along%20with%20the%20blog%20article)[\[71\]](https://huggingface.co/blog/mistral-coreml#:~:text=Core%20ML%20Conversion).
With iOS 18 and newer devices, real-time generation is within reach for
mid-sized models, and even on iOS 17 or macOS you can run smaller or
quantized versions. The key is to optimize for the platform: use the
Neural Engine where possible, mind the memory limits, and streamline
your generation loop with the MLProgram features. This ensures your iOS
port of the LLM will be *practical, performant, and user-friendly*.

**Sources:** Documentation and examples from Apple Core ML Tools and
Hugging Face have been used in compiling this guidance, including
Apple's Core ML guide and WWDC materials on LLM
conversion[\[31\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=previous%20tokens,will%20have%20the)[\[5\]](https://huggingface.co/blog/mistral-coreml#:~:text=To%20convert%20the%20model%20to,to%20the%20same%20conversion%20target),
Apple's Llama-2 8B on-device optimization
report[\[15\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20hosted%20on%20Hugging%20Face,the%20device%20of%20our%20interest)[\[42\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Maximum%20Context%20Size%20Extend%20Throughput,23),
Hugging Face's blog on running Mistral 7B with Core
ML[\[37\]](https://huggingface.co/blog/mistral-coreml#:~:text=Using%20the%20new%20block,bit%20weights)[\[38\]](https://huggingface.co/blog/mistral-coreml#:~:text=),
and Apple Developer discussions on model
deployment[\[66\]](https://medium.com/57blocks/introduction-to-using-core-ml-6753e5cd274b#:~:text=Here%20are%20the%20steps%20in,compile%20models%20within%20your%20app)[\[65\]](https://www.zignuts.com/blog/how-to-use-core-ml-in-ios-guide#:~:text=How%20to%20Use%20Core%20ML,Quantization).
These provide real-world insights into porting large transformer models
to Core ML.

[\[1\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=This%20section%20describes%20the%20,first%20version%20of%20Core%20ML)
[\[2\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=,convert%28source_model)
[\[3\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=An%20ML%20program%20decouples%20the,offers%20more%20flexible%20metadata%20editing)
[\[4\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=To%20convert%20a%20model%20to,model%20types%2C%20see%20%2016)
[\[8\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=You%20can%20optionally%20set%20the,shown%20in%20the%20following%20example)
[\[9\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=For%20details%20on%20ML%20program,precision%2C%20see%20Typed%20Execution)
[\[58\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=The%20ML%20program%20model%20type,see%20Availability%20of%20ML%20Programs)
[\[59\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=You%20can%20convert%20a%20TensorFlow,method)
[\[60\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=Requires%20Xcode%2013%20or%20Newer)
Convert Models to ML Programs --- Guide to Core ML Tools

<https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html>

[\[5\]](https://huggingface.co/blog/mistral-coreml#:~:text=To%20convert%20the%20model%20to,to%20the%20same%20conversion%20target)
[\[6\]](https://huggingface.co/blog/mistral-coreml#:~:text=that%E2%80%99s%20what%20we%20specified%20for,to%20the%20same%20conversion%20target)
[\[23\]](https://huggingface.co/blog/mistral-coreml#:~:text=,for%20great%20candidates%20to%20explore)
[\[24\]](https://huggingface.co/blog/mistral-coreml#:~:text=Getting%20the%20most%20performance%20out,for%20great%20candidates%20to%20explore)
[\[26\]](https://huggingface.co/blog/mistral-coreml#:~:text=However%2C%20there%20are%20practical%20limitations%3A,time%20you%20use%20the%20model)
[\[27\]](https://huggingface.co/blog/mistral-coreml#:~:text=Stateful%20buffers%20were%20introduced%20in,candidate%20for%20using%20stateful%20buffers)
[\[28\]](https://huggingface.co/blog/mistral-coreml#:~:text=bottleneck%20is%20usually%20your%20computer%E2%80%99s,time%20you%20use%20the%20model)
[\[29\]](https://huggingface.co/blog/mistral-coreml#:~:text=kv,guide%20update%20about%20stateful%20models)
[\[30\]](https://huggingface.co/blog/mistral-coreml#:~:text=name%3D,%29%2C)
[\[37\]](https://huggingface.co/blog/mistral-coreml#:~:text=Using%20the%20new%20block,bit%20weights)
[\[38\]](https://huggingface.co/blog/mistral-coreml#:~:text=)
[\[39\]](https://huggingface.co/blog/mistral-coreml#:~:text=make%20the%20model%20run%20faster,bit%20weights)
[\[40\]](https://huggingface.co/blog/mistral-coreml#:~:text=The%20quantization%20parameters%20are%20configured,as%20follows)
[\[41\]](https://huggingface.co/blog/mistral-coreml#:~:text=Let%E2%80%99s%20use%20that%20configuration%20to,a%20few%20minutes%20to%20run)
[\[49\]](https://huggingface.co/blog/mistral-coreml#:~:text=The%20first%20feature%20we%20want,with%20tensor%20data%20in%20Swift)
[\[50\]](https://huggingface.co/blog/mistral-coreml#:~:text=The%20new%20,these%20operations%20without%20custom%20code)
[\[52\]](https://huggingface.co/blog/mistral-coreml#:~:text=There%E2%80%99s%20a%20final%20step%20after,it%E2%80%99s%20different%20for%20every%20model)
[\[57\]](https://huggingface.co/blog/mistral-coreml#:~:text=Since%20adopting%20these%20features%20is,branch%20for%20now)
[\[71\]](https://huggingface.co/blog/mistral-coreml#:~:text=Core%20ML%20Conversion)
WWDC 24: Running Mistral 7B with Core ML

<https://huggingface.co/blog/mistral-coreml>

[\[7\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Core%20ML%20by%20default%20produces,match%20within%20a%20low%20tolerance)
[\[15\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20hosted%20on%20Hugging%20Face,the%20device%20of%20our%20interest)
[\[16\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=optimize%20it%20for%20on,memory%20bandwidth%20on%20the%20device)
[\[17\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=This%20technical%20post%20details%20how,based%20LLMs%20of%20different%20sizes)
[\[25\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=optimize%20it%20for%20on,the%20device%20of%20our%20interest)
[\[31\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=previous%20tokens,will%20have%20the)
[\[32\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=that%2C%20we%20now%20create%20a,tensor%20will%20be%20computed%20and)
[\[34\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20consumes%2C%20now%20we%20can,them%20flexible%20shaped%2C%20as%20follows)
[\[35\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=,applied%2C%20the%20dot%20products%20of)
[\[36\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Block)
[\[42\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Maximum%20Context%20Size%20Extend%20Throughput,23)
[\[43\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Starting%20with%20macOS%20Sequoia%2C%20the,need%20not%20be%20fully%20materialized)
[\[44\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=While%20the%20Core%20ML,see%20Figure%201)
[\[45\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=macOS%20Sequoia%20introduced%20several%20low,wise%20linear%20quantization)
[\[46\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=constant%20irrespective%20of%20the%20length,of%20the%20input%20text)
[\[47\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=,nature%20of%20the%20language%20model)
[\[48\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=each%20decoding%20step%20will%20result,the%20cache%20by%201%20token)
On Device Llama 3.1 with Core ML - Apple Machine Learning Research

<https://machinelearning.apple.com/research/core-ml-on-device-llama>

[\[10\]](https://github.com/huggingface/exporters#:~:text=%2A%20%60,cpu_and_ne)
[\[33\]](https://github.com/huggingface/exporters#:~:text=has%20a%20sequence%20classification%20head)
[\[51\]](https://github.com/huggingface/exporters#:~:text=models%2C%20you%20might%20need%20to,do%20more%20work)
GitHub - huggingface/exporters: Export Hugging Face models to Core ML
and TensorFlow Lite

<https://github.com/huggingface/exporters>

[\[11\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=leveraging%20the%20Metal%20Performance%20Shaders,to%20deploy%20models%20on%20Apple)
[\[12\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=coremltools%2C%20Apple%E2%80%99s%20open,any%20particular%20device%20or%20implementation)
[\[18\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=developers%20worldwide%20a%20way%20to,Transformer%20models%20on%20Apple%20devices)
[\[19\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=This%20implementation%20is%20specifically%20optimized,device%2C%20not%20on%20the%20server)
[\[61\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=In%20this%20article%20we%20share,less%20memory%20after%20our%20optimizations)
[\[62\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=execution,less%20memory%20after%20our%20optimizations)
[\[63\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=data%20format%20for%20the%20ANE,first)
[\[64\]](https://machinelearning.apple.com/research/neural-engine-transformers#:~:text=are%20both%20channels,weights%20shape%20as%20shown%20here)
Deploying Transformers on the Apple Neural Engine - Apple Machine
Learning Research

<https://machinelearning.apple.com/research/neural-engine-transformers>

[\[13\]](https://github.com/apple/coremltools/issues/1849#:~:text=The%20coremltools%20,argument)
[\[14\]](https://github.com/apple/coremltools/issues/1849#:~:text=So%20it%20seems%20to%20me,mlpackage)
Clarify when/how compute_units are effected · Issue #1849 ·
apple/coremltools · GitHub

<https://github.com/apple/coremltools/issues/1849>

[\[20\]](https://news.ycombinator.com/item?id=38907919#:~:text=DR%3A%20No%2C%20nearly%20all%20these,of%20benefit%20for%20the%20cost)
DR: No, nearly all these apps will use GPU (via Metal), or CPU, \*not
\...

<https://news.ycombinator.com/item?id=38907919>

[\[21\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=As%20we%20described%20on%20the,Until%20now%2C%20I%20have%20tried)
[\[22\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=Error%3D_ANECompiler%20%3A%20ANECCompile%28%29%20FAILED,kindof%20fix%20should%20I%20do)
[\[55\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=Hello%2C%20I%27m%20running%20a%20large,issue%20only%20happens%20during%20the)
[\[56\]](https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2#:~:text=prefill%20stage%20%28i,cache%20during)
Core ML \| Apple Developer Forums

<https://developer.apple.com/forums/topics/machine-learning-and-ai/machine-learning-topic-core-ml?page=2>

[\[53\]](https://apple.github.io/coremltools/docs-guides/source/stateful-models.html#:~:text=def%20forward,value%28x)
[\[54\]](https://apple.github.io/coremltools/docs-guides/source/stateful-models.html#:~:text=,%3Aend_step%2C)
[\[70\]](https://apple.github.io/coremltools/docs-guides/source/stateful-models.html#:~:text=runtime%20performance%20improvements,along%20with%20the%20blog%20article)
Stateful Models --- Guide to Core ML Tools

<https://apple.github.io/coremltools/docs-guides/source/stateful-models.html>

[\[65\]](https://www.zignuts.com/blog/how-to-use-core-ml-in-ios-guide#:~:text=How%20to%20Use%20Core%20ML,Quantization)
How to Use Core ML in iOS: A Complete Guide with Examples

<https://www.zignuts.com/blog/how-to-use-core-ml-in-ios-guide>

[\[66\]](https://medium.com/57blocks/introduction-to-using-core-ml-6753e5cd274b#:~:text=Here%20are%20the%20steps%20in,compile%20models%20within%20your%20app)
[\[67\]](https://medium.com/57blocks/introduction-to-using-core-ml-6753e5cd274b#:~:text=,tune%20the%20model)
Introduction to Using Core ML. Preface \| by Kevin Wang \| 57Blocks \|
Medium

<https://medium.com/57blocks/introduction-to-using-core-ml-6753e5cd274b>

[\[68\]](https://apple.github.io/coremltools/docs-guides/source/convert-nlp-model.html#:~:text=Now%20run%20the%20converted%20Core,model%20with%20the%20same%20input)
[\[69\]](https://apple.github.io/coremltools/docs-guides/source/convert-nlp-model.html#:~:text=Completed%3A%20The%20Manhattan%20bridge%20is,the%20busiest%20in%20the%20country)
Converting a Natural Language Processing Model --- Guide to Core ML
Tools

<https://apple.github.io/coremltools/docs-guides/source/convert-nlp-model.html>
