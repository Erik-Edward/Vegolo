# Gemma 3/3n Tokenizer and Mobile Integration Guide

## Gemma 3/3n Tokenizer and Prompt Format

Gemma 3 uses a SentencePiece tokenizer (same as Gemini 2.0) with a very large vocabulary (~256k tokens) optimized for multilingual text. Special control tokens are reserved for conversation roles and turns, including `<bos>` (BOS), `<eos>` (EOS), `<start_of_turn>`, `<end_of_turn>`, and the role labels `user` and `model`.

### Normalization

The tokenizer improves encoding of CJK scripts (at slight expense to English token counts). Maximum sequence lengths depend on the model:
- **Gemma 3n and smaller Gemma 3** (270M, 1B): up to 32k tokens
- **Larger Gemma 3** (4B+): up to 128k tokens

### Prompt Format

Instruction-tuned Gemma models expect a chat-style formatting with role and turn tokens. For a single query, wrap it as:

```
<start_of_turn>user
Your question here<end_of_turn>
<start_of_turn>model
```

The model will then complete the assistant's answer.

**Important:** *Gemma does not use a separate "system" role; include any system instructions in the first user prompt.*

**Example:**

```
<start_of_turn>user
Only reply like a pirate.

What is the answer to life, the universe, and everything?<end_of_turn>
<start_of_turn>model
```

This ensures the model follows instructions and knows when the user prompt ends. The bundled Task config uses `<bos>` as the start token and stops generation at `<eos>` or `<end_of_turn>`.

---

## MediaPipe LiteRT‑LM Inference API (Android)

Google's **MediaPipe GenAI LLM Inference API** (code-named LiteRT-LM) provides a high-level wrapper to run Gemma 3 models fully on-device in Android apps. It handles loading `.task` model bundles, manages the tokenization and caching, and offers easy text generation calls.

### Setup

Add the Gradle dependency:

```gradle
implementation 'com.google.mediapipe:tasks-genai:0.10.27'
```

Ensure you have a Gemma 3 `.task` bundle on device. For development, push the model via ADB; for production, plan to download it at runtime since these models are too large for the APK.

### Usage

**Initialize the inference task:**

```kotlin
val taskOptions = LlmInferenceOptions.builder()
    .setModelPath("/data/local/tmp/llm/my_model.task")
    .setMaxTokens(4096)             // e.g. limit output length
    .build()
val llm = LlmInference.createFromOptions(context, taskOptions)
val session = LlmInferenceSession.createFromOptions(
    llm, 
    LlmInferenceSession.LlmInferenceSessionOptions.builder()
        .setTopK(64).setTopP(0.95f).setTemperature(1.0f)
        .build()
)
val resultText = session.generateResponse(inputPrompt)
```

The API also supports streaming generation via `generateResponseAsync()` with partial result callbacks.

### What's Included

Under the hood, the `.task` file contains:
- TFLite model
- SentencePiece tokenizer
- Metadata

You only need to provide the text prompt. The runtime handles:
- Tokenization
- Inference with caching (using efficient KV cache for multi-turn or long prompts)
- Detokenization

### Configuring Delegates

By default, LiteRT uses optimized CPU execution (XNNPACK). You can adjust:
- Number of threads via `options.setNumThreads(n)` to utilize multi-core CPUs
- Add NNAPI or GPU delegates via `options.addDelegate()`

**Note:** As of now the GenAI API is *CPU-focused* – it's optimized for Pixel 8-class chipsets and may not yet have full GPU/NPU acceleration support (the AI Edge Torch tooling is "CPU-only" for now).

### Requirements

- Android 13+ recommended
- High-end SOC recommended
- The `.task` model is memory-mapped from storage for efficiency, so store it in a file path (e.g. app's internal storage) rather than inside the APK

---

## TensorFlow Lite (tflite_flutter) Fallback Integration

If the MediaPipe LLM API cannot be used, you can integrate the Gemma model manually via **TensorFlow Lite** (e.g. using the `tflite_flutter` plugin in Flutter). This approach gives lower-level control but requires implementing prompt tokenization and autoregressive inference loops yourself.

### Process

1. Convert Gemma to a TFLite format (the `.tflite` inside the `.task` bundle) with support for multiple "signature" functions
2. Load the model from a file on disk (ensuring it's not compressed in assets, to allow memory-mapping)
3. Configure the `InterpreterOptions` for performance

### Configuration Example (Dart)

```dart
final interpreterOptions = InterpreterOptions()..threads = 4;
interpreterOptions.useNnApiForAndroid = true;  // attempt NNAPI
final interpreter = await Interpreter.fromFile(modelFile, options: interpreterOptions);
```

### Performance Options

- **Enable XNNPACK**: Optimized CPU execution (usually on by default)
- **Set `useNnApi(true)`**: Try accelerating int8 ops on supported devices (NNAPI may speed up quantized models on dedicated hardware)
- **Specify threads**: Equal to the number of big CPU cores for optimal throughput

### Generation Process

After loading, you must handle generation:

1. Split the user prompt into tokens with Gemma's SentencePiece model
2. Invoke the TFLite interpreter in a loop:
   - First call the "prefill" signature with the prompt tokens to prime the KV cache
   - Then repeatedly call the "decode" (one token at a time) signature to generate output tokens
   - Feed back the cache state each time
3. Each iteration yields the next token logits
4. Sample or select the next token (according to top-k/p and temperature)
5. Continue until an EOS token is produced or you hit the token limit

### Caveats

- **Complex approach**: Must manage the model's multiple inputs/outputs (including the cache tensors) and implement decoding logic
- **Performance**: Not all TFLite ops used by LLMs have optimized kernels for int8 on all delegates, so performance might lag behind the MediaPipe API
- **Memory constraints**: Large models (~1GB+) might strain the Dart isolate memory; consider using platform channels to run TFLite on the native side
- **Recommendation**: Prefer the official LiteRT-LM API for production if possible, as it streamlines tokenization and generation and is kept up-to-date by Google

---

## Post-Training Quantization for On-Device LLMs

**INT8 quantization** is crucial to shrink model size and speed up inference on mobile CPUs, but it comes with accuracy and compatibility trade-offs.

### Quantization-Aware Training (QAT)

Google provides QAT checkpoints for Gemma 3, enabling high-quality 8-bit and even 4-bit models. For example:
- Gemma 3 270M at 16-bit: ~400 MB
- 8-bit weights: ~297 MB
- 4-bit: ~240 MB

These smaller models run faster and use less memory/power. Gemma 3 QAT models are specifically optimized to retain accuracy when quantized (QAT fine-tunes the model with quantization simulated during training).

**Quality comparison:**
- Post-hoc quantization of standard FP16 model: ~5% lower accuracy
- QAT models: Greatly reduced quality drop

### Quantization Options

When converting Gemma for LiteRT, you can choose schemes like `fp16`, `dynamic_int8`, or `weight_only_int8`:

**FP16**
- Half-precision floats for weights
- Faster than FP32, but still heavy on mobile

**Dynamic INT8**
- 8-bit weights AND integer arithmetic for ops
- XNNPACK will use int8 GEMM paths
- Activations remain in FP32 for range flexibility
- Yields maximum speedup
- Requires that TFLite has int8 kernels for all ops in the model

**Weight-only INT8**
- 8-bit weights but computations in float
- TFLite will dequantize weights to FP32 at runtime
- Reduces model size but gives smaller speed gains
- Mainly useful if some int8 ops aren't supported on the device

### Representative Dataset

Fully quantizing activations (for static int8) usually needs a calibration dataset. However, the Gemma conversion uses "dynamic" quant which doesn't require explicit calibration data – it quantizes weights and uses on-the-fly scaling for activations.

If you need maximum optimization (e.g. int8 for both weights and activations with fixed scales), prepare a small sample of typical text inputs to calibrate the model. In practice, the provided `dynamic_int8` recipe is the recommended balance for LLMs.

### Performance

**Speed improvements:**
- INT8 can significantly boost CPU throughput (2-4× faster inference is common)
- Cut memory use in half
- Decode phase (iterative token generation) especially benefits from lower precision (memory-bound)

**Hardware acceleration:**
- On devices with NPUs or DSPs, quantized models may run on specialized hardware via NNAPI
- Fully int8 Gemma model might run on Qualcomm Hexagon DSP or Google's Android TPU if available
- XNNPACK will still give good speedup on CPU if int8 model falls back

**Accuracy:**
- Per-channel quantization (each weight matrix channel has its own scale) is used by TFLite for conv/dense weights to improve accuracy
- Handled automatically by the converter
- Perplexity increases can be kept under 0.5 for 4-bit with clever techniques

### Recommendations

- Use the QAT versions of Gemma for best results
- Choose the highest compression (8-bit or 4-bit) that still meets your quality bar
- For on-device reasoning, INT8 is generally the sweet spot for fast CPU inference
- 4-bit models need custom runtime (e.g. llama.cpp or GPU support) since TFLite doesn't natively support 4-bit quantized ops
- On mobile CPU you'll stick to 8-bit

---

## Core ML Integration for Gemma Models (iOS)

To run Gemma 3 on iOS, leverage Apple's **Core ML** framework. Core ML 3+ can handle large transformer models by using the *ML Program* format (which supports flexible shapes and control flow).

### Workflow

1. Convert the model (and tokenizer) to Core ML
2. Integrate it into your app
3. Configure the runtime for best performance

### Conversion

Use `coremltools` (v8 or newer) to convert Gemma's PyTorch model.

**Recommended approach:**
1. Trace the model with *no KV cache* initially to get a baseline `.mlmodel`
2. Iteratively add features like the cache

**Example conversion:**

```python
import coremltools as ct
mlmodel = ct.convert(torch_model, convert_to="mlprogram", 
                     compute_precision=ct.precision.FLOAT16,
                     minimum_deployment_target=ct.target.iOS16)
mlmodel.save("Gemma3n.mlpackage")
```

Apple's Llama 3.1 example shows converting an 8B parameter model by scripting it and calling `ct.convert(...)` with a dynamic sequence length dimension. For an 8B model, they used a context length of 2048 for export and got a 16GB FP16 model file.

### Model Size Considerations

Gemma 3 270M or 1B models will be much smaller (hundreds of MB), but you should still use at least FP16 weights. Core ML will by default store weights in 16-bit and use 16-bit compute on ANE/GPU, which is generally optimal.

### Quantization

You can apply quantization in coremltools:
- Linear 8-bit quantization
- Apple's **palettization** (a weight clustering technique) to compress the model further
- Be aware this may require iOS17+ and the Neural Engine may have limits on running quantized layers of very large models

### Memory and Compute Units

When loading the Core ML model in your app, use `MLModelConfiguration` to control execution:

```swift
let config = MLModelConfiguration()
config.computeUnits = .all   // use CPU, GPU, ANE 
let model = try MyGemmaModel(configuration: config)
```

**Setting `config.computeUnits = .all`** (equivalent to `.cpuAndGPUAndNeuralEngine`) allows Core ML to utilize:
- Neural Engine (ANE)
- GPU
- CPU as needed

**Hardware behavior:**
- On A-Series and M-Series chips, the ANE can massively accelerate 8-bit and 16-bit matrix ops
- ANE has finite memory – if the model doesn't fit entirely, Core ML may split execution between ANE and GPU/CPU
- Smaller Gemma variants (270M, 1B) can likely run fully on ANE of modern iPhones
- Larger ones might partially execute on the GPU

**Memory optimization:**
- Monitor memory using Instruments or `MLModelConfiguration.allowLowMemoryAccumulation`
- Core ML runtime in iOS17+ has gotten faster and more memory-efficient
- iOS 18 reportedly further boosted throughput for many models automatically

### Example Integration

**Pseudo-code:**

```swift
let config = MLModelConfiguration()
config.computeUnits = .all   // use CPU, GPU, ANE 
let model = try MyGemmaModel(configuration: config)
let tokenizer = MySentencePieceTokenizer()  // SentencePiece decoding logic (not built-in)
let promptTokens = tokenizer.encode(promptText)
var state = MLMultiArray(...)  // if using manual cache state handling

// Run autoregressive generation:
var output = ""
for token in promptTokens {
    // initial forward pass or subsequent calls
    let modelOut = try model.prediction(input_ids: token, cache: state)
    state = modelOut.cache  // update KV cache
    if let newToken = modelOut.nextToken {
        output += tokenizer.decode([newToken])
        if newToken == tokenizer.eosId { break }
    }
}
```

### iOS 18 Conveniences

Apple is introducing conveniences for LLMs:
- **MLTokenizer** and **MLTokenizers**: Might handle tokenization
- **Stateful models**: Can carry KV cache internally so you don't have to manage it between loops
- **MLMultiFunction models**: Allow combining sub-parts (e.g. an encoder and decoder) in one file – potentially useful if you integrate vision or audio with Gemma

### Testing

Always test on a real device, as simulator won't use ANE/GPU.

### Conversion Resources

**Apple's technical resources:**
- *"On-Device Llama 3.1 with Core ML"* (Nov 2024): Step-by-step for optimizing an 8B LLM on Apple Silicon
- Covers using `skip_model_load=True` to speed up conversion, adjusting RoPE handling, etc.
- Core ML Tools example of converting a 270M OpenELM (similar size to Gemma 3n)
- Demonstrates dynamic shape export and running generation in Python to verify output

### Requirements

- **Device compatibility**: ML Programs require **A12 chip or newer** (iPhone XS/XR or later) due to ANE usage
- **RAM requirements**: Large models may not load at all on devices with <4GB RAM
- Always test on a range of devices

---

## Mobile Model Packaging and Delivery

Deploying ~300MB–1GB model files to mobile users requires a strategy for **app size management** and reliable download.

### Android – Google Play Asset Delivery (Play "On-Device AI")

Google introduced *Play for On-Device AI* in 2024, which extends Android App Bundles to include ML model packs. You can package your Gemma `.task` file as an **"AI pack"** when building your app bundle.

**Delivery modes:**

1. **Install-time**
   - Model APK installs along with the app
   - Guaranteed available at first launch
   - Increases initial download size

2. **Fast-follow**
   - App is smaller initially
   - Model begins downloading in background right after app install
   - User may start using the app while download continues

3. **On-demand**
   - App can explicitly request the model asset at runtime
   - E.g. when the user enters a feature that needs the LLM

**Benefits:**
- No need for custom download code
- Google Play delivers the model to the app's internal storage
- Can target specific device ABIs or RAM with different model variants
- Each AI pack can be up to ~1.5 GB compressed
- Apps over 1GB must target Android 5.0+ (SDK 21)

**Updates:**
- Play handles updates smartly
- If you publish a new app version without changing the model file, users won't have to re-download it (patches are applied)

**Configuration:**
Update your `bundletool` or Android Gradle Plugin to designate the model file as an asset pack of type "machine learning model". Note: Play for On-Device AI is in beta, so check the latest Android Developer docs for configuration steps.

### Alternative: Manual Download (Android)

If you cannot use Play delivery (e.g. sideloading or alternate stores):

1. Host model on a CDN or cloud storage
2. Use Android's download manager or streaming HTTP library to fetch it
3. Implement resume support (Android's `DownloadManager` supports resuming and gives progress notifications)
4. After download, verify integrity via SHA-256 checksum before using the file
5. Use `MessageDigest` in Java or Kotlin to compute the hash and compare to a known good hash from your server
6. Store the model in a non-cache internal directory (e.g. `context.getDir("models", ...)`)
7. **Memory-map** the model by loading via file path (TFLite will do this automatically)

**Best practices:**
- Check free storage space before download
- Provide UI to show download progress
- Allow pause/cancel if needed (users may be on cellular data)
- Guard against incomplete downloads or tampering

### iOS – On-Demand Resources / External Download

**On-Demand Resources (ODR):**

1. Tag the `.mlmodelc` (or compressed archive) as an on-demand resource in Xcode with a specific asset tag
2. Upon app launch or when needed, use `NSBundleResourceRequest` with that tag:

```swift
let request = NSBundleResourceRequest(tags: ["AIModel"])
request.beginAccessingResources { (error) in … }
```

3. System will fetch it in background from App Store CDN
4. Monitor progress and know when it's ready
5. Keeps base app size small
6. Only downloads model for users who trigger that code path

**Benefits:**
- App Thinning guidelines allow ODR for assets not immediately needed
- Fits large ML models perfectly

**Alternative: Custom Download:**

If the model is optional:
1. Download from your own server on first use
2. Use `URLSessionDownloadTask` with background configuration for reliable downloading
3. Consider enabling byte-range requests on your server for resumable downloads
4. Use Apple's CryptoKit or CommonCrypto to compute SHA-256 and verify file integrity
5. Package as `.mlmodelc` (bundle directory) or distribute as compiled `.mlpackage`
6. May be easier to host as .zip and unzip on device

**Storage:**
- Place model in app's Documents or Library directory (not in Caches if you don't want OS to purge it)
- Mark files with "PreventBackup" attribute if large (avoid iCloud backup bloat)
- Core ML can load models from file path: `MLModel(contentsOf: fileURL, configuration: config)`

### Best Practices (Both Platforms)

**User experience:**
- Provide clear indication of download
- Use Wi-Fi by default (models are large)
- Ask for user consent if on cellular

**Integrity and licensing:**
- Include necessary attribution or usage terms
- For Gemma: Bundle copy of Gemma Terms of Use
- Ensure user is aware of terms if required
- Terms require redistribution includes use restrictions notice

**Android (Play Asset Delivery):**
- Model included as part of app's distribution
- Provide Terms of Use in app's "About" or licenses section

**iOS:**
- Include text file in Settings or as part of EULA
- Note: "Gemma is provided under the Gemma Terms of Use (ai.google.dev/gemma/terms)"

---

## Gemma 3/3n Licensing and Compliance

Gemma 3 and 3n are released as open, commercially usable models by Google DeepMind, but they come with a **Terms of Use** that you must follow when integrating into your app.

### Key Points

**Commercial use and modification:**
- ✅ Allowed – models are open-weight
- ✅ Can be tuned or incorporated into products (even paid apps)
- ✅ Must use responsibly
- ✅ Google explicitly permits responsible commercial use
- ✅ No license fee
- ℹ️ Custom agreement (not an OSI license) with usage restrictions

### Distribution Requirements

If you distribute the model weights (by bundling or downloading to the app), you **must include**:
- Google's Gemma Terms of Use
- Usage restrictions for end users
- Notice that Gemma is subject to those terms

**Example notice:**

```
"Gemma is provided under the Gemma Terms of Use (ai.google.dev/gemma/terms). 
By using this app's AI features, you agree to those terms."
```

**Requirements:**
- Don't remove or obscure Google's notices
- If you fine-tune or modify the model (creating a "Model Derivative"), mark it as modified
- Still include the original Terms

### Prohibited Uses

Google has a **Prohibited Use Policy** (Section 3.2) that likely bans:
- Illegal activities
- Harassment
- Other harmful uses

**Your responsibilities:**
- Enforce this in your usage policies
- Provide usage guidelines
- Consider filters to prevent disallowed content
- You're responsible for moderation (especially since it's on-device)

Google reserves the right to remotely restrict usage if someone violates the terms (though on-device models likely aren't phone-home, this clause mostly applies to their cloud APIs).

### Attribution

While the Terms don't grant trademark use (you can't call your app "Google Gemma Assistant" as if Google endorses it), you *should* credit Google DeepMind for the model.

**Recommended attribution:**

```
"Uses Google's Gemma 3n model (© 2025 Google DeepMind) under the Gemma Terms of Use."
```

The Terms themselves don't explicitly demand a specific attribution phrase, but including one is good practice and covered by the requirement to include the Notice text file.

### Privacy and Data

**On-device benefits:**
- User queries don't leave the device (privacy win)
- Disclose in privacy policy that AI processing is on-device (users will appreciate that)

**Knowledge cutoff:**
- Note the model's knowledge cutoff (June 2024 for Gemma 3n)
- Won't know events after that date
- May need explaining to users for recent queries

### Updates

**Model updates:**
- If Google releases an updated model or fixes, update your app's model accordingly
- If Google were to revoke the license (unlikely for an open model, but Terms allow termination if you breach them), you'd have to remove the model
- Keep an eye on "Gemma Releases" page for new versions or patches

**License updates:**
- Google may update the model or terms
- Stay aware of changes

### Technical Licensing Details

The model weights are under:
- CC BY 4.0-like terms for content
- Apache 2.0 for code samples in docs
- Terms of Use is the primary license document

### Compliance Summary

**To comply with Gemma Terms:**
1. ✅ Include the license notice
2. ✅ Don't enable disallowed uses
3. ✅ Credit the source
4. ✅ Pass along use restrictions to end users
5. ✅ Mark any modifications
6. ✅ Keep fine-tunes under same terms (no open-source requirement)

By following these guidelines, you ensure your app's AI feature is both legally and ethically aligned.