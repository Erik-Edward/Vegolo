# MediaPipe GenAI LLM Inference API - Complete Guide

## 1. MediaPipe GenAI LLM Inference API (LiteRT-LM) – Android Integration

### Summary

Google's MediaPipe GenAI LLM Inference API (LiteRT-LM) enables running large language models on-device with high performance. Developers use the `com.google.mediapipe:tasks-genai` SDK to load a converted Gemma model (FlatBuffer `.task` or `.litertlm` file), configure runtime options (model path, decoding params, and backend), and then generate text responses either synchronously or asynchronously.

The API internally leverages **XNNPACK** (CPU delegate) by default (with 4 threads) and supports a **GPU backend** for devices with accelerators (using `libLiteRtGpuAccelerator.so`). The engine uses a session-based design: a heavyweight `LlmInference` engine holds model weights (memory-mapped for efficiency) and lightweight `LlmInferenceSession` instances manage per-query state (including KV cache across tokens).

### Documentation & Repositories

- **LLM Inference Guide (Android)** – last updated 2025-09-29 – provides a quickstart and configuration options
- The open-source **Google AI Edge Gallery** (GitHub) demonstrates model loading and inference in an Android app (commit `18e3f06` from Aug 2024) with Gemma models

### Key API Snippets

**Initialize the engine:**

```kotlin
val options = LlmInferenceOptions.builder()
    .setModelPath("/data/local/tmp/llm/gemma3-1B-it-int4.task")
    .setPreferredBackend(LlmInference.Backend.CPU)    // or GPU if supported
    .setMaxTokens(1024)  
    .setTopK(50).setTemperature(0.7f)                 // decoding params
    .build()
val llm = LlmInference.createFromOptions(context, options)
```

**Generate text for a query:**

```kotlin
val session = LlmInferenceSession.createFromOptions(llm, LlmInferenceSessionOptions.builder().build())
session.addQueryChunk(userPrompt)
val result = session.generateResponse()  // synchronous generation
```

Asynchronous streaming is supported via `generateResponseAsync()` with a callback.

### Key Features

- **Memory-mapped model weights**: The API automatically uses memory-mapped model weights (if the model file is uncompressed) for efficiency
- **KV cache**: Maintains an internal KV cache in the session to reuse key/value attention states between tokens (improving decode speed)
- **Multimodal prompts**: Toggle modalities in graph options (e.g. vision with `setEnableVisionModality(true)`) and attach image or audio data to the session

### Caveats & Notes

- **Experimental API**: Android use is for dev/research only
- **Requirements**: Android 14+ on high-end devices (Pixel 8, etc.) for best performance
- **Not for emulators**: Will not work on emulators
- **GPU backend**: When using GPU backend, you must bundle the additional native `.so` accelerators. The first load may be slower due to on-device tuning (weights are optimized and cached on first run)
- **Model loading**: Can be slow (several seconds) especially on first run. Recommended to perform initialization on a background thread and possibly warm up the session
- **APK compression**: Ensure the model file is not APK-compressed (to allow mmap)
- **Session lifecycle**: For long-running chats, manage the session lifecycle (the KV cache grows with conversation length – you may reset or truncate context to avoid memory bloat)
- **Timeout controls**: Not directly exposed; handle in the app by running generation in a coroutine or background thread and interrupt as needed

Overall, LiteRT-LM provides a ready-to-use, optimized wrapper so you seldom need to manually adjust `Interpreter` threads or delegates – simply choose the backend (`CPU` uses XNNPACK with multithreading, `GPU` offloads to Android's NNAPI/OpenCL drivers).

---

## 2. Gemma 3/3n Tokenizer Artifacts & Prompt Format

### Summary

**Gemma 3** models use a SentencePiece tokenizer (shared with Google's Gemini 2.0) with a vocabulary of **262k subwords**. The SentencePiece model (`.spm` or `.model` file) for Gemma 3/3n is distributed with the model weights.

All Gemma variants (Nano E2B, E4B, etc.) share this tokenizer, which was designed to improve encoding of CJK languages at a slight cost to English token length. The tokenizer performs Unicode normalization and byte fallback internally via SentencePiece, so inputs should be given in UTF-8 text; no additional manual preprocessing is required beyond trimming whitespace.

### Special Tokens

Special tokens in Gemma's vocabulary include:
- `<pad>` (Pad, ID 0)
- `<bos>` (Beginning of Sequence, ID 1)
- `<eos>` (End of Sequence, ID 2)
- `<unk>` (Unknown, ID 3)
- Additional tokens for multi-modal prompts (e.g. `<Img>` for images and `<Audio>` for audio if applicable)

Instruction-tuned Gemma models recognize system/user roles in prompts without needing explicit tokens – they were trained on a ChatML-like format where the first user prompt implicitly starts the conversation.

### Obtaining the Tokenizer

The official pointer for the tokenizer is the Gemma model release itself. Once you have access to Gemma 3n on Hugging Face (after agreeing to the license), you can download the SentencePiece model. For example, the **Gemma 3n E4B** pack includes `gemma-3n-E4B-it-int4.tokenizer.model`.

Alternatively, Google's Keras Hub provides a preset:

```python
keras_hub.tokenizers.Gemma3Tokenizer.from_preset("gemma3_instruct_1b")
```

### Prompt Format

Gemma uses a decoder-only (causal LM) format. The **`<bos>`** token is used to begin a new sequence/conversation. For single-turn prompts, you generally prepend the `<bos>` token (though some APIs do this automatically) and append `<eos>` at the end of the generated output if needed.

In chat scenarios with multiple turns, Gemma's **instruction-tuned** models follow a format similar to LLaMA-2 Chat: there is an optional system message followed by alternating user and assistant turns, separated by the end-of-sequence token.

**Example format:**
```
<bos><sys> [System message] </sys>\n<usr> User question... </usr>\n<asm>
```

For best results in Q&A or instruction tasks, format the prompt explicitly:
```
Q: {question}\nA:
```

### Key Details

- **Max sequence length**: 32,768 tokens for Gemma 3n (Nano) models
- **Stopping**: Use `<eos>` in stop criteria during generation so the model stops when finished
- **Case sensitivity**: The tokenizer is case-sensitive and built with Unicode normalization
- **Unknown characters**: SentencePiece handles unknown characters by breaking into bytes

### Caveats

- When using the MediaPipe Task API, tokenization is handled internally – you just provide text
- If using the tokenizer separately (e.g. via Hugging Face), load the same tokenizer model to get correct token-IDs
- Certain special sequences (e.g. `<image>` or `<audio>` tokens for multimodal input) have dedicated IDs

---

## 3. LLM Quantization for LiteRT/TFLite – INT8/INT4 Best Practices

### Summary

Quantization is crucial for getting large models to run on mobile. **TensorFlow Lite's post-training quantization** supports 8-bit integer weights (and even 4-bit in hybrid schemes) to drastically reduce model size and improve CPU cache usage.

### Best Practices

**Per-channel quantization**: Use per-channel (per-axis) quantization for weight matrices in fully-connected and convolution layers whenever possible, as this preserves accuracy better by allowing each output channel its own scale. Per-tensor quantization (one scale for a whole tensor) is generally only used for activations or when an op doesn't support per-channel.

**Representative datasets**: Essential for calibrating dynamic ranges. Supply a sample input set covering the distribution of real data. Use a few hundred typical prompts during conversion to determine optimal scaling factors, especially for outlier tokens in LLMs.

**Mixed precision**: Certain ops (e.g. LayerNorm, softmax) do not quantize easily. The MediaPipe conversion scripts will leave those in float (mixed precision model), since fully quantizing them would hurt accuracy or is unsupported.

### Accuracy-Latency Trade-off

- **INT8 weight-only quantization**: Usually yields <1% perplexity increase on 4B models, for ~4× smaller size and ~30-50% faster CPU inference
- **INT4**: Further cuts size (~2× smaller than int8) but can degrade quality. Gemma Nano models use a mixed int4/int8 scheme to balance this

### Gemma-Specific Mobile Quantization

Google's Gemma 3 models are provided in 4-bit quantized form for mobile (e.g. Gemma-3 1B int4). They achieve this by quantizing weights to int4 and keeping activations in 8-bit or higher precision. Per-group quantization was likely used to handle outliers.

If accuracy drops too much after quantization, consider:
- **16-bit activations** (16x8 mode: 8-bit weights with int16 activations)
- **Quantization-aware training (QAT)** to fine-tune the model with fake quantization to recover lost accuracy

### Operator Constraints

Not all ops are compatible with int8 in TFLite. The MediaPipe converter will fallback to float for unsupported ops (you end up with a mostly-int8 model). This still yields speedups, as the matmul-heavy parts are int8.

### Performance Notes

- Using int8 can bring ~2-4× speed improvement on CPU for LLMs due to reduced memory bandwidth and better cache fit
- The decode phase (iterative token generation) especially benefits from lower precision because it's memory-bound
- Empirical tests show perplexity increases can be kept under 0.5 for 4-bit with clever techniques

### Key Recommendations

1. Start with int8 full integer quantization
2. Verify model quality on key tasks
3. If quality is good, you've gained speed and 75% size reduction
4. If not, try 16x8 or selective higher precision on problematic layers
5. Enable XNNPACK delegate's thread tuning on big.LITTLE CPUs

---

## 4. Core ML Conversion (iOS) – From Gemma to MLModel (ML Program)

### Summary

To run Gemma models on iOS, use Apple's **coremltools** to convert the model (from PyTorch or ONNX) into a Core ML **ML Program** format, which supports large Transformer models and flexible sequence length. Coremltools 7+ defaults to producing an `mlprogram` (requiring iOS 15+ deployment target).

### Conversion Process

**Basic conversion:**

```python
import coremltools as ct
mlmodel = ct.convert(torch_model, convert_to="mlprogram", 
                     compute_precision=ct.precision.FLOAT16,
                     minimum_deployment_target=ct.target.iOS16)
mlmodel.save("Gemma3n.mlpackage")
```

This converts a Gemma (decoder-only) model to an ML Program, with weights in float16 (half-precision) to reduce memory. The result is saved as an `.mlpackage` bundle.

**Alternative path via ONNX:**

```python
ct.convert("model.onnx", convert_to="mlprogram", ...)
```

### Compute Units

When loading and running the model on-device, specify `MLComputeUnits`:

```swift
let config = MLModelConfiguration()
config.computeUnits = .all   // .all = CPU, GPU, and Neural Engine
let model = try Gemma3n(configuration: config)
```

**Recommendations:**
- Use `.all` (or `.cpuAndNeuralEngine`) – lets Core ML schedule as much as possible on the Apple Neural Engine (ANE) for speed
- `.all` ensures best performance
- `.cpuOnly` would be much slower
- `.cpuAndGPU` might use Metal which isn't as optimized for LLMs as ANE

### Memory Considerations

Gemma 3n E4B (~2.7B actual params) in FP16 is ~5.4 GB – too large for many iOS devices. Strategies:

1. **Use smaller models**: Gemma-3n E2B ~1.91B effective (~4 GB at FP16) works on devices with 6GB RAM (iPhone 13/14)
2. **Quantization**: Use 8-bit weight quantization via palettization or linear quantization
3. **Model splitting**: Use only a subset if possible
4. **MLC LM**: Alternative framework by MLC.ai that can run quantized models on iOS via Metal

**Storage tips:**
- Set `compute_precision=FLOAT16` (default for MLPrograms) – cuts weight size in half
- `.mlpackage` format stores weights in multiple files (sharded) – iOS will memory-map as needed
- Store .mlpackage in app bundle (if it fits) or download on first launch
- Use persistent storage: app's Documents or Library directory

### Conversion Example & Caveats

**Important steps:**
1. Disable KV cache (`use_cache=False`) during export – Core ML can't represent a dynamic cache well
2. Handle cache manually in Swift by running the model in a loop
3. Iterate token by token in Swift using `predict(inputs: MLShapedArray)`

**Performance:** Core ML on ANE can generate ~several tokens per second for a 1-2B model

**Device compatibility:**
- ML Programs require **A12 chip or newer** (iPhone XS/XR or later)
- Large models may not load on devices with <4GB RAM
- Always test on a range of devices

**App packaging:**
- Use Xcode app slicing or ODR tags for multiple model sizes
- On-Demand Resources (ODR) allow non-essential initial download
- Asset packs up to 8 GB allowed on iOS 18+ (4 GB on older)
- Use `NSBundleResourceRequest` API with tags for model files

**App Store limits:**
- 4GB for app download (excluding ODR)
- Use app thinning – tag model assets properly

---

## 5. Model Packaging & Delivery at Scale (Android & iOS)

### Summary

Shipping multi-hundred-MB or GB-scale models requires special distribution strategies:
- **Android**: Google Play Asset Delivery (PAD) and Play for On‑Device AI (PODAI)
- **iOS**: On-Demand Resources (ODR) and app thinning

### Android – Play for On‑device AI

**Play for On‑Device AI** (beta as of 2025) is specifically tailored for ML models using "AI packs":

**Delivery modes:**
- **Install-time**: Model delivered with app install (good for critical tiny models)
- **Fast-follow**: Model begins downloading right after app install, in background
- **On-demand**: Download when you actually need it

**Key features:**
- Upload model as part of Play App Bundle
- Google Play handles hosting, resumable download, and updates at no extra cost
- Supports **device targeting** – upload multiple variants based on device specs (model, SDK, RAM size)

**Integrity & Updates:**
- Model files are integrity-verified (part of signed app bundle)
- AI packs stored in app's internal storage (not accessible to other apps)
- Delta updates only change bytes that differ, minimizing update download size

**Loading & Storage:**
- Files stored under app's internal storage (`/data/data/yourapp/...`)
- Get file path via `PlayCore.getPackLocation(packName)`
- Models ensured uncompressed for memory-mapping
- Use `java.nio.MappedByteBuffer` via `FileChannel.map()` for mmap

**Resuming downloads:**
- Play for AI automatically handles resuming partial downloads
- For custom implementation, use `DownloadManager` with foreground service

### iOS – On-Demand Resources

**ODR** lets you tag assets (including model files) for lazy download:

**Setup in Xcode:**
```swift
let request = NSBundleResourceRequest(tags: ["AIModel"])
request.beginAccessingResources { (error) in … }
```

**Key features:**
- Triggers download of asset pack (with progress and resume handled by system)
- Assets digitally signed and verified
- Access model via `request.bundle` or `MLModel(contentsOf: url)`
- Model packs remain on device until system needs to purge

**App Thinning:**
- Devices only download what they need
- Include multiple model variants for different device capabilities
- Total ODR storage up to 20GB on App Store
- iOS 18: per-pack limit raised to 8GB after thinning
- Models >4GB must use ODR (4GB app size limit)

**Storage Best Practices:**
- For non-ODR: save in **Library/Application Support** or **Caches**
- Mark with "do not backup" attribute if in Documents
- Use `URLSessionDownloadTask` for resume support
- Verify checksum (Apple doesn't verify external downloads)
- Load via `MLModel(contentsOf:)` for `.mlmodelc` or `.mlpackage`

### Common Best Practices

**Progress UI:**
- Provide user feedback during model downloads
- Android: Use `AssetPackStateUpdateListener` from Play Core SDK
- iOS: Observe `NSBundleResourceRequest.progress` for UI updates

**Memory-mapping:**
- Store on internal flash and map to avoid copying entire model to RAM
- Both Play and ODR deliver uncompressed files for mmap usage

**Security:**
- Models in app storage remain sandboxed
- Users could still extract files (especially on rooted Android devices)
- Consider this in licensing decisions

---

## 6. Gemma 3/3n Licensing & Attribution Requirements

### Summary

**Gemma 3 and 3n models** are released as open weight models under Google's "Gemma Terms of Use" license. This permits commercial use with conditions.

### Key License Terms

**Permitted uses:**
- Fine-tune, distribute, and deploy Gemma models in your app
- Commercial use allowed
- Redistribution of model weights allowed only as part of an application

**Requirements:**
- Follow usage policies (no disallowed use cases per Google's GenAI prohibited use policy)
- Include proper notices and attribution
- Pass on same use restrictions to end users
- Preserve copyright, attribution, and license notices
- Do not use to generate disallowed content (hate, violence, etc.)

**Responsibilities:**
- You are responsible for ensuring downstream users comply with restrictions
- Models cannot be accessed by other apps from yours
- Fine-tuned derivatives fall under same terms
- No requirement to open-source fine-tunes

### Attribution Requirements

**Include in your app's About section:**

```
This app includes Gemma 3n open model (© 2025 Google DeepMind) 
under the Gemma Terms of Use. Gemma is a trademark of Google DeepMind. 
Used with permission.
```

**Additional requirements:**
- Include copy of Gemma Terms or link in app's settings/legal section
- Credit line: "Authors: Google DeepMind"
- Citation reference (see model card)
- Link to terms: https://ai.google.dev/gemma/terms

### Important Notes

**Commercial use:**
- You can charge for your app that uses Gemma
- Cannot sell the model on its own
- Must be integrated into an experience
- Cannot use Google's or DeepMind's logos to imply endorsement

**Updates:**
- License may be updated (last modified March 24, 2025)
- Stay aware of changes
- Check for updates periodically

**No viral copyleft:**
- License is about responsible use, not copyleft
- Keep fine-tunes proprietary if desired
- Note material modifications in documentation for transparency

### Compliance Summary

By complying with the Gemma license, you can confidently deploy Gemma 3n on-device. Always refer to the official Gemma Terms of Use for definitive guidance.