## Gemma 3/3n Tokenizer & Prompt Format

**Summary:** Gemma uses a SentencePiece tokenizer with a very large
vocabulary (\~256k
tokens)[\[1\]](https://developers.googleblog.com/en/gemma-explained-overview-gemma-model-family-architectures/#:~:text=Vocab%20size%20,256128).
The instruction-tuned variants require a special dialogue formatting
with reserved tokens to indicate roles and
turns[\[2\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=,end_of_turn).
Specifically, prompts must include `<start_of_turn>` and `<end_of_turn>`
tokens around each speaker's text, with the role keywords `user` and
`model` to label user vs. assistant
turns[\[2\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=,end_of_turn).
There is **no separate system role** in Gemma's format -- any system
instructions should be included in the first user turn (the model was
not trained on an explicit system
prompt)[\[3\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=System%20instructions).
For example, to ask *"What is Cramer's Rule?"* you would format the
input as:

    <start_of_turn>user  
    What is Cramer's Rule?<end_of_turn>  
    <start_of_turn>model

The model will then generate the answer following the
`<start_of_turn>model`
token[\[4\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=The%20token%20%60,feed%20the%20model%20as%20follows).
Gemma's tokenizer preserves whitespace (using the familiar `▁` character
to mark spaces) and handles multiple languages. The context window is
very large -- Gemma 3 supports up to **32K tokens of context** for the
smaller models (1B and 270M) and 128K for larger
sizes[\[5\]](https://ai.google.dev/gemma/docs/core/model_card_3#:~:text=,Output)
-- enabling long prompts or documents. In summary, use the official
SentencePiece model (bundled with Gemma) for tokenization, adhere to the
`<start_of_turn>…<end_of_turn>` prompt format for instruction/QA tasks,
and remember no `<system>` token is used (embed any system directives in
the user's first
turn)[\[3\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=System%20instructions).
These details are documented in Gemma's model card and prompt
engineering guide (last updated March
2025)[\[6\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=Gemma%20formatting%20and%20system%20instructions)[\[4\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=The%20token%20%60,feed%20the%20model%20as%20follows).

**Sources:** Gemma prompt formatting
guide[\[2\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=,end_of_turn)[\[4\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=The%20token%20%60,feed%20the%20model%20as%20follows);
Gemma architecture blog
(DeepMind)[\[1\]](https://developers.googleblog.com/en/gemma-explained-overview-gemma-model-family-architectures/#:~:text=Vocab%20size%20,256128);
Gemma 3 model
card[\[5\]](https://ai.google.dev/gemma/docs/core/model_card_3#:~:text=,Output).

## MediaPipe GenAI LLM Inference API (Android LiteRT-LM)

**Summary:** For Android, Google provides the **MediaPipe GenAI LLM
Inference API** (also called *LiteRT-LM* in preview) to run Gemma
on-device with high efficiency. This comes as part of the Google AI Edge
SDK. You add the Gradle dependency
`com.google.mediapipe:tasks-genai:0.10.27` to include the
API[\[7\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Add%20dependencies).
The API handles model loading, tokenization, inference, and caching
under the hood. You first obtain a Gemma `.task` file (a
TFLite+tokenizer bundle) -- e.g. Gemma 3 1B int4 is available from the
Hugging Face "LiteRT community"
page[\[8\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Download%20Gemma,models%2C%20see%20the%20Models%20documentation)
-- and push or download it to the device's storage (it's **too large for
an APK**, so it must be a runtime
asset)[\[9\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task).
Then, in your Android code, configure the inference task: for example,
use `LlmInferenceOptions.builder()` to set the model path and any
options, then create the `LlmInference` instance. A minimal setup in
Kotlin looks like:

    val taskOptions = LlmInferenceOptions.builder()
        .setModelPath("/data/local/tmp/llm/model.task")
        .setMaxTopK(64)              // example option: top-k sampling
        .build()
    val llm = LlmInference.createFromOptions(context, taskOptions)
    val result = llm.generateResponse(inputPrompt)

This will load the model and generate a completion for the given
`inputPrompt`[\[10\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%2F%2F%20Set%20the%20configuration%20options,build)[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Run%20the%20Task).
There's also an asynchronous streaming mode (`generateResponseAsync`)
where you get partial results via a
listener[\[12\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=val%20options%20%3D%20LlmInference,%7D%20.build)
-- useful for token-by-token UI updates. Under the hood, this API uses
TFLite with optimized backends (it will use **XNNPack** for CPU and can
leverage the Android NNAPI or GPU if the model/delegate supports it).
Notably, the Gemma `.task` file itself is platform-neutral; at runtime
you can choose CPU vs GPU execution. In Google's sample *AI Edge
Gallery* app, users can switch between running on CPU or GPU -- the
model is compiled on first load for the chosen
backend[\[13\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=Step%202%3A%20Select%20CPU%20or,GPU).
The LLM Inference API is **optimized for modern devices** -- Google
recommends Pixel 8, Samsung S23 or similar with 6+ GB RAM for 1B models
-- and it *may not work on
emulators*[\[14\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20following%20steps%20to,not%20reliably%20support%20device%20emulators).
Key configuration options (documented in the API) include `maxTokens`
(max new tokens to generate), `temperature`, `topK/topP` sampling
settings,
etc.[\[15\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=Option%20Name%20Description%20Value%20Range,generated%20text%2C%20while%20a%20lower).
For detailed examples, Google's open-source **AI Edge Gallery** app on
GitHub demonstrates using this API with Gemma 3N in chat, QA, and
image+text
scenarios[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Gemma%203N).
In summary, **LiteRT-LM** on Android is the **authoritative approach**
to on-device Gemma: include the tasks-genai library, download the Gemma
model bundle, initialize the `LlmInference` with your model path, and
call `generateResponse()` to get outputs. This abstracts away low-level
concerns like multi-threading, caching, and tokenization, letting you
focus on the app logic. (Google AI Edge docs,
2024)[\[17\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Initialize%20the%20task%20with%20basic,configuration%20options)[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Run%20the%20Task).

**Sources:** Google AI Edge Android
guide[\[17\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Initialize%20the%20task%20with%20basic,configuration%20options)[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Run%20the%20Task);
AI Edge quickstart
docs[\[14\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20following%20steps%20to,not%20reliably%20support%20device%20emulators)[\[9\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task);
Google Developers Blog (Gemma 3 on
mobile)[\[13\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=Step%202%3A%20Select%20CPU%20or,GPU).

## TensorFlow Lite in Flutter (TFLite Interpreter)

**Summary:** If you choose to run Gemma via the lower-level **TensorFlow
Lite interpreter** (e.g. using the `tflite_flutter` plugin in a Flutter
app), you'll need to manage a few settings manually. **Acceleration:**
By default, TFLite on mobile enables the XNNPack delegate for CPU, which
provides substantial speedups for LLM-style models on ARM and other
platforms[\[18\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=XNNPack%20is%20the%20default%20TensorFlow,friendly%20to%20the%20processors%E2%80%99%20pipelines).
Ensure XNNPack is not disabled -- it packs weights and uses optimized
kernels for matmul and other ops. You can also enable multithreading on
the interpreter (e.g., set 4 threads to utilize big CPU cores for
parallelism). Large models should be loaded from a file on disk rather
than from memory. TFLite supports memory-mapping model weights when you
use `Interpreter.fromFile(...)`, which avoids extra copies and allows
the OS to page in only needed
portions[\[19\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=The%20TFLite%20Delegate%20now%20uses,technique%2C%20for%20the%20following%20advantages).
This **mmap** capability is crucial for large models to keep memory
usage manageable. If the model is quantized and the device has a capable
DSP/NPU, you can experiment with the NNAPI delegate on Android
(`InterpreterOptions.addDelegate(NnApiDelegate())`). However, current
NPUs have limited support for complex transformer ops and context sizes
-- in practice many LLMs default to CPU even with NNAPI. Google's
Flutter TFLite plugin supports NNAPI and GPU delegates on Android and
Metal/CoreML delegates on
iOS[\[20\]](https://pub.dev/packages/tflite_flutter#:~:text=TensorFlow%20Lite%20Flutter%20plugin%20provides,XNNPack%20delegate%20on%20Desktop%20platforms),
but those are better suited to vision models; for Gemma's decoder-only
model, CPU (with int8/4 and XNNPack) tends to be the most reliable path.
**Memory:** The Gemma 1B int4 model is \~500 MB, so plan for that file
size and memory-mapping. On Android, store it in `app_internal_dir`
(e.g. `/data/data/your.app/files`) or as an asset delivered via Play
Asset Delivery (if using that). On iOS, ensure the model is not in the
app's main bundle if it's huge -- it could be an On-Demand Resource or
downloaded on first run. **Limitations:** Using TFLite directly means
you have to handle tokenization and prompting format yourself (e.g.,
apply the SentencePiece tokenizer to the input text and add
`<start_of_turn>` tokens as needed). It also means handling the **decode
loop**: Gemma's TFLite model likely has a single-step inference
signature, so you would call the interpreter repeatedly to generate
tokens one-by-one (unless the `.task` includes a serving driver). The
MediaPipe LLM API automates this loop with internal caching of KV
tensors. If implementing manually, you'll need to feed the prompt, then
iteratively feed each new token to generate the next, managing the LLM's
KV cache (which is non-trivial in pure TFLite). For this reason, using
the MediaPipe GenAI API is recommended when possible. But if you do go
with `tflite_flutter`, use the **latest TensorFlow Lite** (to benefit
from edge optimizations in 2024), enable XNNPack and threads, and test
on target devices (Pixel 8/Google Tensor G3 devices have specialized
int8 hardware *i8mm* that will greatly speed up quantized models).
TFLite's default behavior already incorporates many optimizations (like
weight packing caching to disk for reuse) as of
2024[\[21\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=Loading%20the%20Cache%20From%20Disk,MMAP%20in%20the%20TFLite%20Delegate).
In short, **TFLite + Flutter** gives you flexibility, but you must
implement the high-level loop and ensure the model is properly quantized
and configured to achieve good performance.

**Sources:** TensorFlow Lite XNNPack
update[\[18\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=XNNPack%20is%20the%20default%20TensorFlow,friendly%20to%20the%20processors%E2%80%99%20pipelines)
(Google, Aug 2024); TFLite weight mmap
caching[\[19\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=The%20TFLite%20Delegate%20now%20uses,technique%2C%20for%20the%20following%20advantages);
TensorFlow Lite Flutter plugin
docs[\[20\]](https://pub.dev/packages/tflite_flutter#:~:text=TensorFlow%20Lite%20Flutter%20plugin%20provides,XNNPack%20delegate%20on%20Desktop%20platforms).

## Quantization for On‑Device LLMs (Gemma)

**Summary:** **Quantization** is a critical technique to fit large
language models on mobile-class hardware. Gemma models can be quantized
post-training to INT8 (8-bit) or even INT4. Google's official Gemma
releases include a 4-bit quantized version of Gemma 3 1B, produced via
**quantization-aware training (QAT)** to preserve model
quality[\[22\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=The%20demo%20and%20measurements%20here,it%20uses%20a%20context%20length).
This int4 model is only \~529 MB and achieves \~2.5K tokens/sec on
Pixel-class hardware (as reported by
Google)[\[23\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=At%20only%20529MB%20in%20size%2C,tunable).
For custom models or sizes, you can quantize using TensorFlow Lite
tooling or the **AI Edge Toolkit**: Google provides an "AI Edge Torch"
converter that can export a PyTorch Gemma model to TFLite and quantize
it in one
step[\[24\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index#convert-pytorch#:~:text=2,file%20and%20the%20model%20tokenizer).
If doing **post-training quantization** (PTQ) to INT8, you should use
**per-channel weight quantization** (also known as per-axis) for
fully-connected layers -- this gives better accuracy by allowing each
output channel (or each attention head) its own scale. TFLite supports
per-channel quant for conv and dense layers by default. You'll need a
**representative dataset** of prompts to calibrate the activations (to
determine quantization ranges) if using PTQ. A common approach is to
collect sample text inputs representative of your use case and run a few
inference passes during conversion. Note that PTQ 8-bit quantization may
cause some quality loss (especially for generative tasks), but often the
impact is modest and well worth a \~4x speed and memory improvement.
QAT, as done for Gemma 3 1B int4, can reduce loss further by training
the model to be
quantization-aware[\[22\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=The%20demo%20and%20measurements%20here,it%20uses%20a%20context%20length).
In terms of **performance**: quantized models can leverage **fixed-point
acceleration**. On CPU, modern ARM cores (Cortex-A78/A710 and beyond)
have dot-product instructions for int8 (e.g., ARMv9's *i8mm* feature)
that TFLite's XNNPack will use -- this yields large speedups on Pixel
7/8 and newer devices. On DSP/NPUs (via NNAPI), quantization is usually
required to run on the accelerator at all. **Operator support:** Gemma's
architecture is transformer-based (matrix multiplies, layer norms, etc.)
-- all of these have int8 implementations in TFLite. One caveat:
*multi-head attention* may be implemented via fused ops or as generic
matmuls; either way, int8 should be supported, but ensure to disable any
ops that aren't quantized (e.g., if there were a custom op). If
something isn't supported by NNAPI or GPU in quantized form, it will run
on CPU. **Accuracy vs. latency:** INT8 quantization typically has a
small accuracy hit for LLMs (on the order of 1--3 perplexity points or a
few percent drop on some benchmarks), while 4-bit can incur a larger hit
unless carefully done with QAT or GPTQ techniques. Google's QAT int4
model reportedly retains strong accuracy while *doubling* decoding
speed[\[22\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=The%20demo%20and%20measurements%20here,it%20uses%20a%20context%20length).
In practice, start with int8 quantization (e.g., TFLite's "dynamic
range" quantization or full int8 quant with calibration) and test your
specific task. If you need even more compression and can tolerate some
quality loss, explore 4-bit. Also consider mixed-precision: for example,
you might keep layer norm and output layers in float and quantize only
matmul weights. The **bottom line** is that quantization is recommended
for on-device Gemma: it **shrinks model size** (memory/storage) and
**improves inference speed** dramatically, enabling models like Gemma 3
(270M, 1B, 4B...) to run on phones. Use Google's provided quantized
checkpoints when available, or convert your own following their
guidelines for the MediaPipe-compatible
format[\[24\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index#convert-pytorch#:~:text=2,file%20and%20the%20model%20tokenizer).
Always verify the quantized model's outputs (e.g., some sample Q&A
pairs) to ensure the quality is acceptable before deployment.

**Sources:** Google AI Blog (Gemma 3 1B QAT int4
performance)[\[22\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=The%20demo%20and%20measurements%20here,it%20uses%20a%20context%20length);
AI Edge conversion guide (model export &
quantize)[\[24\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index#convert-pytorch#:~:text=2,file%20and%20the%20model%20tokenizer);
Google Developers Blog on TFLite LLM optimizations (int8 XNNPack and
weight
cache)[\[18\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=XNNPack%20is%20the%20default%20TensorFlow,friendly%20to%20the%20processors%E2%80%99%20pipelines)[\[19\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=The%20TFLite%20Delegate%20now%20uses,technique%2C%20for%20the%20following%20advantages).

## Core ML Integration (iOS -- Gemma on-device)

**Summary:** Deploying Gemma on iOS involves converting the model to
Apple's Core ML format. For LLMs, Apple recommends using the **ML
Program** model type (introduced in iOS 15+) because it can handle very
large models and dynamic control flow. Using coremltools (e.g., v8.x),
you would convert the Gemma model (likely from PyTorch or TFLite) with
`ct.convert()`, which by default produces an ML Program in *float16*
precision[\[25\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=In%20Core%20ML%20Tools%207,by%20default)[\[26\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=You%20can%20optionally%20set%20the,shown%20in%20the%20following%20example).
An ML Program is saved as a package (`.mlpackage` directory) rather than
a single `.mlmodel` -- this format **stores weights separately** from
the model
code[\[27\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=An%20ML%20program%20decouples%20the,offers%20more%20flexible%20metadata%20editing).
That separation is crucial: it allows the **weights to be
memory-mapped** and not all loaded into RAM at once, and it bypasses the
500MB single-file size limit that .mlmodel had. After conversion, you'll
have a Gemma `.mlpackage` which you can include in your app or an
On-Demand Resource. At runtime, you use `MLModel` or `NLModel` APIs to
load it. **Compute units:** It's important to configure the Core ML
model to use the appropriate hardware. By default, `MLModel` will use
`.all` compute units (meaning it will utilize **CPU, GPU, and ANE** as
available) -- you can explicitly set
`MLModelConfiguration.computeUnits = .all` (which is equivalent to
`.CPUAndGPUAndNeuralEngine`)[\[28\]](https://apple.github.io/coremltools/source/coremltools.models.html#:~:text=,available%2C%20including%20the%20neural%20engine).
This lets the Core ML runtime schedule different parts of the neural
network on the Neural Engine or GPU for optimal speed. In practice, the
Apple Neural Engine (ANE) excels at fixed-size, lower-precision ops but
can be limited by on-chip memory for very large models. The GPU (Apple's
Metal Performance Shaders) has high memory bandwidth and is often used
for the bulk of LLM computation. Apple's internal testing with an 8B
Llama2-like model showed that targeting the **GPU** yielded about *33
tokens/sec* on an M1 Max
Mac[\[29\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=This%20technical%20post%20details%20how,based%20LLMs%20of%20different%20sizes),
whereas the ANE's benefit might be seen in certain smaller models or
portions of the model (and the CPU handles any ops not supported by
ANE/GPU). You should definitely keep the **Neural Engine enabled**, as
newer ANEs (in A17/M3 chips and beyond) may improve and can offload some
transformer operations. **Memory considerations:** When you first load
the model, Core ML will compile and may allocate a large chunk of memory
for model parameters (e.g., an 8B parameter model in float16 is \~16 GB
of
weights[\[30\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Core%20ML%20by%20default%20produces,match%20within%20a%20low%20tolerance),
which is obviously too large for iPhone memory). The solution is that
Core ML supports *loading weights on demand*: the `.mlpackage` keeps
weights compressed and pages them in as needed. Additionally, you can
reduce precision: the default is float16, but coremltools can compress
to even 8-bit integers via **palettization/linear quantization** (this
is an advanced feature where you supply `precision=INT8` or use the
compression APIs after conversion). Apple's WWDC materials and the Core
ML Tools docs have examples of quantizing models like Whisper and Llama
for iOS. You might also consider splitting the model into chunks or
using only a smaller Gemma variant (e.g., 270M or 1B) for iOS if memory
is tight -- iPhones have \~6GB RAM for apps on high-end models.
**Conversion caveats:** Converting very large HuggingFace models to Core
ML can hit some snags -- e.g., certain ops (`__ior__` in PyTorch or
multi-head attention) might not be directly supported. The community has
filed issues (e.g., converting `google/gemma-3-1b-it` required minor
code adjustments in coremltools as of
mid-2023[\[31\]](https://github.com/apple/coremltools/issues/2560#:~:text=GitHub%20github,results%20in%20a%20RuntimeError%3A)).
Ensure you use an updated coremltools (8.0+), and consider using Apple's
reference code for Llama 2 conversion as a template (since Gemma is
similar architecture). **At runtime:** use the Core ML **MLModel API**
for inference. You'll feed the token IDs as an input (probably as a 2D
tensor \[1, N\] of Int32 for input ids and \[1, N\] for the attention
mask, as shown in Apple's Llama
example[\[32\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=batch_size%2C%20context_size%20%3D%201%2C%202048,batch_size%2C%20context_size)[\[33\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=inputs%3A%20list,)).
Core ML's execution will then produce the next-token probabilities.
However, Core ML does not internally manage an auto-regressive loop or
KV cache for you -- you might have to implement the generation loop in
Swift, or use Apple's NLModel if they support causal LM (currently they
support transformers for classification and translation, but full
generation might still require manual looping). On the bright side, Core
ML *can* keep state between calls if you include the KV cache as an
output/input in the model (Apple's blog shows how to modify the model to
output logits and also return updated cache, then feed that cache back
in). This is an advanced setup but necessary for efficient
token-by-token generation on iOS. If that's too complex, an alternative
is to run the generation loop in a short Python script with coremltools'
`MLModel.predict()` (for prototype) or use a third-party library like
*MLC LLM* (by MLC.ai) which wraps Core ML models for generation. In
summary, Core ML can definitely run Gemma models on-device -- use ML
Program format, set `.ALL` compute units
(CPU/GPU/ANE)[\[28\]](https://apple.github.io/coremltools/source/coremltools.models.html#:~:text=,available%2C%20including%20the%20neural%20engine),
and be mindful of memory (leverage float16 and weight mmap). Expect to
do some work to implement the generation loop and possibly stateful
model inputs. The result, however, is private, on-device text generation
leveraging Apple's optimized silicon.

**Sources:** Apple Core ML Tools
docs[\[27\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=An%20ML%20program%20decouples%20the,offers%20more%20flexible%20metadata%20editing)[\[28\]](https://apple.github.io/coremltools/source/coremltools.models.html#:~:text=,available%2C%20including%20the%20neural%20engine);
Apple ML research blog (Llama 2 on Core ML,
2024)[\[29\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=This%20technical%20post%20details%20how,based%20LLMs%20of%20different%20sizes)[\[34\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20hosted%20on%20Hugging%20Face,the%20device%20of%20our%20interest);
coremltools API reference
(computeUnits)[\[28\]](https://apple.github.io/coremltools/source/coremltools.models.html#:~:text=,available%2C%20including%20the%20neural%20engine).

## Mobile Model Packaging & Delivery

**Summary:** Deploying a large LLM model like Gemma in a mobile app
requires careful handling of the model files due to their size.
**Android -- Download vs. Bundle:** Google's documentation explicitly
states that Gemma models are *"too large to be bundled in an APK"* and
recommends hosting the model on a server, then downloading it at runtime
in the
app[\[9\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task).
For production, one robust approach is **Google Play Asset Delivery
(PAD)**. PAD allows you to include large assets in your app bundle as
separate packs (install-time, fast-follow, or on-demand) even if they
exceed the usual 150MB APK
limit[\[35\]](https://developer.android.com/guide/playcore/asset-delivery#:~:text=Play%20Asset%20Delivery%20,OBBs).
For example, you could make the 500MB Gemma model an on-demand asset
pack -- the first time the user enters the feature, the app requests the
pack from the Play Store, which handles downloading with resume,
caching, and integrity verification. If not using PAD, a manual approach
is to host the model on e.g. Google Cloud or Hugging Face (behind the
license gate) and have the app download it via HTTP. In that case, you
must implement download resume (use Android's DownloadManager or a
library) and verify the file's integrity (e.g., check SHA-256 hash
against a known value) before using it. Store the model in app-specific
storage (like `Context.getFilesDir()` or `Context.getExternalFilesDir()`
-- *not* in cache if you want it persisted). **Memory-mapping:** Once
downloaded, prefer APIs that allow memory-mapping the model file. Both
TFLite and Core ML will do this if given a direct file path or asset FD,
which significantly reduces RAM usage by avoiding extra copies. **iOS --
App Thinning:** Apple offers **On-Demand Resources (ODR)** to handle
large assets for iOS apps. ODR allows you to tag resources (like a Core
ML `.mlpackage` or a `.bin` file) as not needed at initial install, and
the App Store will host them separately -- the app can trigger download
of those resources at runtime when
needed[\[36\]](https://docs.unity3d.com/6000.2/Documentation/Manual/ios-ondemand-resources.html#:~:text=On).
This is analogous to PAD. You can also split the model across multiple
ODR tags if needed (though one model file likely can't be split, you'd
just treat the whole model as one resource). If you choose not to use
ODR, you again have the option to download the model on first launch.
For that, you could leverage NSURLSession download tasks with resume
support. Once downloaded, move the file to your app's Documents or
Library directory. Ensure it's not backed up to iCloud (set the
`NSURLIsExcludedFromBackupKey` attribute) given its size. **Progress
UX:** In either platform, provide a user-friendly download progress UI
and consider downloading over Wi-Fi only or with user consent if the
file is huge. **Updates:** If you release a new model version, you'll
need to handle updating the asset -- PAD/ODR can manage versioned asset
updates seamlessly when the app updates. If self-hosting, you might
include a version check in the app. **Storage constraints:** On Android,
external storage might be preferable if internal storage is limited, but
external (shared) storage would mean the model file isn't private. Many
apps keep it internal for security (especially if the model is gated by
a license). On iOS, you're limited to app sandbox anyway. Be mindful of
users' storage -- clean up any old model files when no longer needed,
and possibly provide an option to remove downloaded models. **Integrity
and license compliance:** Since Gemma's license requires presenting
terms to users (see below), you might have the user accept the model
download (the Google AI Edge Gallery app, for example, forces a Hugging
Face login to confirm
terms[\[37\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=Step%203%3A%20Download%20the%20Model,from%20Hugging%20Face)).
If you use PAD/ODR, that implies the model is packaged with the app (so
you, the developer, have accepted the terms and are responsible for
compliance). In that case, include the required NOTICE file and license
text in your app distribution (perhaps in Settings -\> About or in a
LICENSE asset). In summary, **best practice** is: don't bundle the large
model in the base install; use Play Asset Delivery or On-Demand
Resources for store-managed downloads, or implement a secure download
with progress and verification on first use. This ensures your app isn't
bloated on initial install and only users who use the LLM feature incur
the download. Both Google and Apple's distribution systems are designed
to handle large ML assets beyond normal app size limits (games have done
this for years with expansion files/PAD on Android and ODR on iOS). Plan
for network failure (allow resume) and low-space conditions (check
available storage before downloading \~500MB). Once the model is on
device, initialize it via the ML framework directly from file to take
advantage of memory
mapping[\[19\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=The%20TFLite%20Delegate%20now%20uses,technique%2C%20for%20the%20following%20advantages).

**Sources:** Android quickstart note on model
bundling[\[9\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task);
Play Asset Delivery intro (Android dev
docs)[\[35\]](https://developer.android.com/guide/playcore/asset-delivery#:~:text=Play%20Asset%20Delivery%20,OBBs);
Unity docs on iOS On-Demand Resources (concept applies to any iOS
app)[\[36\]](https://docs.unity3d.com/6000.2/Documentation/Manual/ios-ondemand-resources.html#:~:text=On).

## Gemma 3/3n License & On-Device Compliance

**Summary:** **Gemma 3 and 3n models are released under Google's custom
Gemma Terms of Use**, not a standard open-source license. This license
allows use and modification of the model and even commercial deployment,
but with important restrictions and obligations. Notably, if you
**distribute** the model (which you do by including it in an app or
providing it to users), you **must include the Gemma Terms of Use and
usage restrictions with your
distribution**[\[38\]](https://ai.google.dev/gemma/terms#:~:text=You%20may%20reproduce%20or%20Distribute,all%20of%20the%20following%20conditions).
In practice, this means you should add an attribution in your app (for
example, a file or about screen saying *"Includes Gemma model --
provided under the Google Gemma Terms of Use"* with a link). You also
must flow down the **Prohibited Use Policy** -- Google's policy forbids
certain uses of the model, such as generating disallowed content (e.g.,
hate, extreme violence,
etc.)[\[39\]](https://ai.google.dev/gemma/terms#:~:text=3). By using the
model, you've agreed to those restrictions, and you need to make sure
your end-users can't easily use it for those purposes (and/or have them
agree as well). For example, if your app is a chat bot, you should have
content filtering to avoid outputs that violate the policy, since the
license prohibits using Gemma for those cases. Another key point: any
**derivative models** you create from Gemma (fine-tunes, distillations,
etc.) are also covered by the Gemma
license[\[40\]](https://ai.google.dev/gemma/terms#:~:text=%28c%29%20,that%20you%20obtained%20it%20from).
You're free to do them, but you can't escape the license by altering the
model -- the derivatives would carry the same obligations. However,
**the model's outputs are explicitly your property**: Google's terms say
they **claim no rights in the outputs** you generate with
Gemma[\[41\]](https://ai.google.dev/gemma/terms#:~:text=3), which is
good for you and your users (you can use generated text freely).
**On-device distribution:** The license does *not* forbid distributing
the model weights to end users (unlike some previous model licenses); it
just ties that distribution to the above conditions. So including Gemma
in a mobile app is allowed as long as you, the developer, ensure the
terms are met. Also, the Gemma license is protective of Google's rights:
you may not remove the license or claim it's your own model. Include the
required NOTICE file (the Hugging Face Gemma repo provides one) and any
modifications you made must be clearly
noted[\[42\]](https://ai.google.dev/gemma/terms#:~:text=etc,Gemma%20is%20provided).
If your app provides an API or hosted service based on Gemma, that's
also considered a form of distribution ("Hosted Service" in the
terms)[\[43\]](https://ai.google.dev/gemma/terms#:~:text=%28b%29%20,Hosted%20Service),
which again is allowed only if users are bound by the same use
restrictions. And of course, you **cannot use Gemma to break laws or to
attempt to re-train a competitor model using Gemma's outputs in a way
that circumvents the license** (the terms define certain forbidden
"model derivatives" like using Gemma's outputs to train another LLM --
that would still count as a derivative under their
license)[\[40\]](https://ai.google.dev/gemma/terms#:~:text=%28c%29%20,that%20you%20obtained%20it%20from).
**Action items for compliance:** (1) Include attribution and the text of
Gemma's Terms of Use (or a link) in your app or documentation. (2)
Include a mechanism to enforce or inform users of the acceptable use
restrictions (many apps simply put this in their Terms of Service or
EULA that by using the feature, the user agrees not to misuse it as per
Gemma's policy). (3) Do not remove or obfuscate Google's
copyright/license info from the model files. (4) If prompted by the
Hugging Face gating (which currently requires clicking "I agree" to the
license to download), you as the developer have done so -- but your end
users might not individually do that step if you're packaging the model.
Thus, the onus is on you to ensure they are aware of and constrained by
the same rules. In summary, **Gemma's license is similar to Meta's LLaMA
license in spirit** -- it's not viral (doesn't require open-sourcing
your code) but is **restrictive** about usage. For an on-device app,
take it seriously: implement content safeguards and include the proper
notices. If these steps are done, deploying Gemma 3n on-device is
legally and ethically viable. (The license was updated March 24, 2025,
and the latest terms can be read on Google's
site[\[44\]](https://ai.google.dev/gemma/terms#:~:text=Last%20modified%3A%20March%2024%2C%202025).)

**Sources:** Gemma Terms of Use (Google AI
Dev)[\[38\]](https://ai.google.dev/gemma/terms#:~:text=You%20may%20reproduce%20or%20Distribute,all%20of%20the%20following%20conditions)[\[39\]](https://ai.google.dev/gemma/terms#:~:text=3);
License
definitions[\[40\]](https://ai.google.dev/gemma/terms#:~:text=%28c%29%20,that%20you%20obtained%20it%20from);
Output rights
clause[\[41\]](https://ai.google.dev/gemma/terms#:~:text=3); HuggingFace
model card noting agreement
required[\[45\]](https://huggingface.co/google/gemma-3-270m#:~:text=To%20access%20Gemma%20on%20Hugging,ensure%20you%27re%20logged%20in).

[\[1\]](https://developers.googleblog.com/en/gemma-explained-overview-gemma-model-family-architectures/#:~:text=Vocab%20size%20,256128)
Gemma explained: An overview of Gemma model family architectures -
Google Developers Blog

<https://developers.googleblog.com/en/gemma-explained-overview-gemma-model-family-architectures/>

[\[2\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=,end_of_turn)
[\[3\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=System%20instructions)
[\[4\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=The%20token%20%60,feed%20the%20model%20as%20follows)
[\[6\]](https://ai.google.dev/gemma/docs/core/prompt-structure#:~:text=Gemma%20formatting%20and%20system%20instructions)
Gemma formatting and system instructions  \|  Google AI for Developers

<https://ai.google.dev/gemma/docs/core/prompt-structure>

[\[5\]](https://ai.google.dev/gemma/docs/core/model_card_3#:~:text=,Output)
Gemma 3 model card  \|  Google AI for Developers

<https://ai.google.dev/gemma/docs/core/model_card_3>

[\[7\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Add%20dependencies)
[\[8\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Download%20Gemma,models%2C%20see%20the%20Models%20documentation)
[\[9\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task)
[\[10\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%2F%2F%20Set%20the%20configuration%20options,build)
[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Run%20the%20Task)
[\[12\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=val%20options%20%3D%20LlmInference,%7D%20.build)
[\[14\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20following%20steps%20to,not%20reliably%20support%20device%20emulators)
[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Gemma%203N)
[\[17\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Initialize%20the%20task%20with%20basic,configuration%20options)
LLM Inference guide for Android  \|  Google AI Edge  \|  Google AI for
Developers

<https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android>

[\[13\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=Step%202%3A%20Select%20CPU%20or,GPU)
[\[22\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=The%20demo%20and%20measurements%20here,it%20uses%20a%20context%20length)
[\[23\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=At%20only%20529MB%20in%20size%2C,tunable)
[\[37\]](https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/#:~:text=Step%203%3A%20Download%20the%20Model,from%20Hugging%20Face)
Gemma 3 on mobile and web with Google AI Edge - Google Developers Blog

<https://developers.googleblog.com/en/gemma-3-on-mobile-and-web-with-google-ai-edge/>

[\[15\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=Option%20Name%20Description%20Value%20Range,generated%20text%2C%20while%20a%20lower)
LLM Inference guide  \|  Google AI Edge  \|  Google AI for Developers

<https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference>

[\[18\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=XNNPack%20is%20the%20default%20TensorFlow,friendly%20to%20the%20processors%E2%80%99%20pipelines)
[\[19\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=The%20TFLite%20Delegate%20now%20uses,technique%2C%20for%20the%20following%20advantages)
[\[21\]](https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/#:~:text=Loading%20the%20Cache%20From%20Disk,MMAP%20in%20the%20TFLite%20Delegate)
Streamlining LLM Inference at the Edge with TFLite - Google Developers
Blog

<https://developers.googleblog.com/en/streamlining-llm-inference-at-the-edge-with-tflite/>

[\[20\]](https://pub.dev/packages/tflite_flutter#:~:text=TensorFlow%20Lite%20Flutter%20plugin%20provides,XNNPack%20delegate%20on%20Desktop%20platforms)
tflite_flutter \| Flutter package

<https://pub.dev/packages/tflite_flutter>

[\[24\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index#convert-pytorch#:~:text=2,file%20and%20the%20model%20tokenizer)
LLM Inference guide  \|  Google AI Edge  \|  Google AI for Developers

<https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index>

[\[25\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=In%20Core%20ML%20Tools%207,by%20default)
[\[26\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=You%20can%20optionally%20set%20the,shown%20in%20the%20following%20example)
[\[27\]](https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html#:~:text=An%20ML%20program%20decouples%20the,offers%20more%20flexible%20metadata%20editing)
Convert Models to ML Programs --- Guide to Core ML Tools

<https://apple.github.io/coremltools/docs-guides/source/convert-to-ml-program.html>

[\[28\]](https://apple.github.io/coremltools/source/coremltools.models.html#:~:text=,available%2C%20including%20the%20neural%20engine)
Model APIs --- coremltools API Reference 8.1 documentation

<https://apple.github.io/coremltools/source/coremltools.models.html>

[\[29\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=This%20technical%20post%20details%20how,based%20LLMs%20of%20different%20sizes)
[\[30\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=Core%20ML%20by%20default%20produces,match%20within%20a%20low%20tolerance)
[\[32\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=batch_size%2C%20context_size%20%3D%201%2C%202048,batch_size%2C%20context_size)
[\[33\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=inputs%3A%20list,)
[\[34\]](https://machinelearning.apple.com/research/core-ml-on-device-llama#:~:text=model%20hosted%20on%20Hugging%20Face,the%20device%20of%20our%20interest)
On Device Llama 3.1 with Core ML - Apple Machine Learning Research

<https://machinelearning.apple.com/research/core-ml-on-device-llama>

[\[31\]](https://github.com/apple/coremltools/issues/2560#:~:text=GitHub%20github,results%20in%20a%20RuntimeError%3A)
\[Bug\]: PyTorch Gemma-3-1b-it conversion fails with \_\_ior\_\_ \... -
GitHub

<https://github.com/apple/coremltools/issues/2560>

[\[35\]](https://developer.android.com/guide/playcore/asset-delivery#:~:text=Play%20Asset%20Delivery%20,OBBs)
Play Asset Delivery - Android Developers

<https://developer.android.com/guide/playcore/asset-delivery>

[\[36\]](https://docs.unity3d.com/6000.2/Documentation/Manual/ios-ondemand-resources.html#:~:text=On)
Unity - Manual: On-demand resources

<https://docs.unity3d.com/6000.2/Documentation/Manual/ios-ondemand-resources.html>

[\[38\]](https://ai.google.dev/gemma/terms#:~:text=You%20may%20reproduce%20or%20Distribute,all%20of%20the%20following%20conditions)
[\[39\]](https://ai.google.dev/gemma/terms#:~:text=3)
[\[40\]](https://ai.google.dev/gemma/terms#:~:text=%28c%29%20,that%20you%20obtained%20it%20from)
[\[41\]](https://ai.google.dev/gemma/terms#:~:text=3)
[\[42\]](https://ai.google.dev/gemma/terms#:~:text=etc,Gemma%20is%20provided)
[\[43\]](https://ai.google.dev/gemma/terms#:~:text=%28b%29%20,Hosted%20Service)
[\[44\]](https://ai.google.dev/gemma/terms#:~:text=Last%20modified%3A%20March%2024%2C%202025)
Gemma Terms of Use  \|  Google AI for Developers

<https://ai.google.dev/gemma/terms>

[\[45\]](https://huggingface.co/google/gemma-3-270m#:~:text=To%20access%20Gemma%20on%20Hugging,ensure%20you%27re%20logged%20in)
google/gemma-3-270m - Hugging Face

<https://huggingface.co/google/gemma-3-270m>
