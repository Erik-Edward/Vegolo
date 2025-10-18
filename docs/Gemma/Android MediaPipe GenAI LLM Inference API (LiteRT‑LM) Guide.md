# Android MediaPipe GenAI LLM Inference API (LiteRT‑LM) Guide

**Overview:** The MediaPipe **LLM Inference API** for Android allows you
to run large language models entirely on-device for tasks like text
generation, Q&A, and
summarization[\[1\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=The%20LLM%20Inference%20API%20lets,models%20to%20your%20Android%20apps).
It provides a high-level Kotlin API (built on the LiteRT‑LM engine used
in Google's
products[\[2\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=You%20can%20already%20leverage%20the,our%20APIs%20to%20start%20building))
to load a model, configure generation parameters, and get responses
either in one shot or as a streaming sequence of tokens. This guide
covers model loading, configuration, KV-cache sessions for context,
running inference (including streaming), and error handling when
integrating a model such as **Gemma-3n** into an Android app (e.g.
Vegolo). For a reference implementation, see Google's open-source AI
Edge Gallery app (commit `c6c11bb` on Feb 26, 2025) -- the first public
LLM Inference
demo[\[3\]](https://github.com/google-ai-edge/mediapipe-samples/releases#:~:text=26%20Feb%2018%3A23)[\[4\]](https://github.com/google-ai-edge/mediapipe-samples/releases#:~:text=v0).

> **Prerequisites:** This API is optimized for real devices running
> **Android 12 (API 31)** or
> above[\[5\]](https://github.com/google-ai-edge/gallery#:~:text=Get%20Started%20in%20Minutes%21).
> It targets modern high-end hardware (e.g. Pixel 8, Samsung S23) and is
> not reliably supported on
> emulators[\[6\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20following%20steps%20to,not%20reliably%20support%20device%20emulators).
> Ensure your test device meets these requirements for the best
> experience.

## Model Loading

**1. Add the dependency.** Include the MediaPipe GenAI Tasks library in
your app's Gradle setup. In your module's `build.gradle` (or Gradle
Kotlin DSL), add the GenAI dependency:

    dependencies {
        implementation 'com.google.mediapipe:tasks-genai:0.10.27'
    }
    ```【1†L383-L391】

    This library provides the `LlmInference` classes needed for on-device inference.

    **2. Obtain an LLM model.** Download a supported model and convert it to MediaPipe’s format (`.task` or `.litertlm`). For example, you can download **Gemma-3 1B (4-bit)** from Hugging Face【1†L390-L398】 or use the Gemma-3n E2B (2B) or E4B (4B) models provided for MediaPipe【3†L496-L504】. After conversion, you will have a model package (FlatBuffer format) typically with a `.task` extension. 

    **3. Deploy the model to the device.** During development you can push the model file via ADB. For instance, to push a model file to a temporary directory on the device: 

    ```sh
    $ adb shell rm -r /data/local/tmp/llm/    # remove any old model
    $ adb shell mkdir -p /data/local/tmp/llm/
    $ adb push output_path /data/local/tmp/llm/model_version.task
    ```[7]

    This places the model at `/data/local/tmp/llm/model_version.task` on the device. In a production app, **do not** bundle large model files in your APK (they can be several hundred MBs). Instead, host the model remotely and download it on first run. *The model is too large to include in an APK* – you should retrieve it at runtime and store it in app storage【1†L401-L404】.

    > **Note:** Ensure the model file is accessible and in the expected location before initializing the API. If the file is missing or unreadable, model loading will fail at runtime.

    ## Configuration

    Before running inference, you must configure two sets of options:

    - **Engine options (`LlmInferenceOptions`):** Defines global model parameters and settings when loading the model (the “engine”).  
    - **Session options (`LlmInferenceSessionOptions`):** Defines per-session generation parameters (for each conversation or inference session).

    **Engine (Model) Options:** When creating the `LlmInference` engine, you **must specify the model path** and can tweak memory/accuracy tradeoffs. Key options include:

    - **`modelPath`** – Filesystem path to the model `.task` file (or `.litertlm`). **Required.**[8]
    - **`maxTokens`** – The maximum total tokens (prompt + output) the model will handle. *(Default 512)*[9]. This defines the context length.
    - **`preferredBackend`** – (CPU/GPU delegate selection) The hardware backend to use for acceleration. You can set this if your model is GPU-compatible. For example, use `setPreferredBackend(LlmInferenceOptions.Backend.GPU)` to run on GPU (if supported), or CPU otherwise【36†L55-L63】. *Note:* LoRA-adapted models require GPU backend【30†L7-L10】.
    - **`loraPath`** – Optional path to a LoRA weights file to **merge low-rank adaptations** into the base model at load time. *(GPU-only; for Gemma-2B, Phi-2, etc.)*【3†L481-L487】【30†L1-L4】.
    - **`maxNumImages` / `AudioModelOptions`:** If using multi-modal prompts (image or audio), you can configure maximum images per session or enable audio processing here. (See **Multimodal** note below.)

    You build these options with `LlmInference.LlmInferenceOptions.builder()`. For example:

    ```kotlin
    val engineOptions = LlmInference.LlmInferenceOptions.builder()
        .setModelPath("/data/local/tmp/llm/model_version.task")
        .setMaxTokens(1024)
        .setPreferredBackend(LlmInferenceOptions.Backend.CPU)  // or GPU if available
        .build()

In the above, we set a custom `maxTokens` and explicitly choose CPU
backend. If your model or device supports GPU acceleration, you may set
`Backend.GPU` to improve performance (e.g., Gemma-3n models with TFLite
GPU delegate).

**Session (Generation) Options:** Each inference **session** (which can
be thought of as a conversation or single query session) can have its
own generation parameters:

-   `topK` -- Limits the token sampling to the top-K most probable
    tokens at each step. *(Default
    40)*[\[13\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Note%3A%20this).
    Higher values consider a broader set of tokens.
-   `topP` -- Limits sampling to the top cumulative probability mass
    (nucleus sampling). For example, 0.9 means only tokens within 90%
    total probability are considered. This can be used instead of or
    alongside `topK` to control diversity.
-   `temperature` -- Controls randomness. Higher values (\>1.0) yield
    more random (creative) output, while lower values (\<1.0) make
    outputs more deterministic. *(Default
    0.8)*[\[14\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,to%20receive%20the%20results%20asynchronously).
-   `randomSeed` -- Sets a seed for the pseudo-random generator (for
    reproducible outputs). *(Default
    0)*[\[15\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Note%3A%20this).
-   `resultListener` -- (Async only) A callback to receive partial
    results during streaming
    generation[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,N%2FA%20N%2FA).
-   `errorListener` -- (Async only) An optional callback to handle
    errors during asynchronous
    generation[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,N%2FA%20N%2FA).
-   `EnableVisionModality` **/** `EnableAudioModality` -- Flags in
    `GraphOptions` to enable image or audio input support for the
    session[\[17\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=To%20enable%20vision%20support%20for,within%20the%20Graph%20options)[\[18\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Enable%20Audio%20support%20in%20sessionOptions)
    (only needed if your model supports multimodal prompts).

Build session config with
`LlmInferenceSession.LlmInferenceSessionOptions.builder()`. For example,
to configure a session with nucleus sampling and a specific temperature:

    val sessionOptions = LlmInferenceSessionOptions.builder()
        .setTopK(40)
        .setTopP(0.95f)
        .setTemperature(0.7f)
        .build()

You will pass both the engine options and session options when
initializing the API, as described below. The table below summarizes
common options and defaults:

-   **modelPath:** Path to model file (FlatBuffer `.task`),
    **required**[\[8\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Option%20Name%20Description%20Value%20Range,generated%20text%2C%20while%20a%20lower).
-   **maxTokens:** Max tokens (prompt + output), *default
    512*[\[9\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=PATH%20N%2FA%20,generated%20text%2C%20while%20a%20lower).
-   **topK:** Sample from top-K tokens, *default
    40*[\[13\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Note%3A%20this).
-   **topP:** Nucleus sampling cutoff (0--1), *default \~1.0* (no
    cutoff).
-   **temperature:** Randomness in generation, *default
    0.8*[\[14\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,to%20receive%20the%20results%20asynchronously).
-   **randomSeed:** RNG seed, *default 0*
    (random)[\[15\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Note%3A%20this).
-   **loraPath:** LoRA weights file (for GPU
    models)[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=temperature%20produces%20more%20predictable%20generation,N%2FA%20N%2FA).
-   **resultListener:** Callback for streaming tokens (async
    only)[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,N%2FA%20N%2FA).
-   **errorListener:** Callback for errors (async
    only)[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,N%2FA%20N%2FA).

> **Multimodal inputs:** If using a multimodal model (e.g. Gemma-3n
> supports text+image
> queries[\[19\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=To%20get%20started%2C%20use%20a,compatible%20variant%20of%20Gemma%203n)),
> enable the vision or audio modality in the session's GraphOptions. For
> example, call `graphOptions.setEnableVisionModality(true)` to allow
> image
> prompts[\[17\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=To%20enable%20vision%20support%20for,within%20the%20Graph%20options).
> Images must be converted to `MPImage` objects (e.g. via
> `BitmapImageBuilder`) before adding to the
> prompt[\[20\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=import%20com).
> Audio input (mono WAV) can be enabled similarly with
> `EnableAudioModality(true)` and added via
> `session.addAudio(byteArray)`[\[18\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Enable%20Audio%20support%20in%20sessionOptions)[\[21\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=val%20audioData%3A%20ByteArray%20%3D%20,addAudio%28audioData).
> (If you are only doing text generation, you can ignore these
> modalities.)

## KV-Cache and Session Management

To support **long conversations or multiple turns**, the API provides a
**Session** abstraction. Each `LlmInferenceSession` represents a
distinct conversational context, maintaining its own state (including
the transformer's *KV-cache* of key/value attention tensors for past
tokens)[\[22\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,state%20and%20saving%20significant%20computation).
The **engine** (`LlmInference`) loads the model and is shared, while
each Session is a lightweight stateful interface for one conversation or
query
thread[\[23\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,customize%20the%20base%20model%27s%20behavior).

Creating a session is optional for one-off prompts, but required for
multi-turn interactions or multimodal prompts. You create a session by
supplying the engine and the session options:

    // Initialize the engine with model (if not already created)
    val llmInference = LlmInference.createFromOptions(context, engineOptions)

    // Start a new session with desired generation parameters
    val sessionOptions = LlmInferenceSessionOptions.builder()
        .setTopK(40)
        .setTemperature(0.8f)
        .build()
    val session = LlmInferenceSession.createFromOptions(llmInference, sessionOptions)

Once a session is created, you **add prompts** to it and generate
responses. Use `session.addQueryChunk()` to feed in a user's prompt (or
a part of it). If your prompt consists of multiple parts (e.g. system
prompt + user question), you can call `addQueryChunk` for each segment.
You may also add modalities: e.g. `session.addImage(mpImage)` for an
image
input[\[24\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=LlmInferenceSession%20session%20%3D%20LlmInferenceSession,generateResponse%28%29%3B).
Finally, call `session.generateResponse()` to produce the model's answer
for the accumulated prompt.

    session.addQueryChunk("User: Describe the objects in the image.")
    // (optionally add images or other data if supported)
    val answer: String = session.generateResponse()

After generation, the session's state now includes the prompt and
response in its internal context. To continue a conversation, you can
call `addQueryChunk()` again with a follow-up question or prompt, then
call `generateResponse()` again. The model will use the prior context
(KV-cache) to generate a contextual answer, *without needing to resend
the entire conversation history each time* -- the Session manages it for
you[\[22\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,state%20and%20saving%20significant%20computation).
This makes multi-turn dialogues efficient.

If you want to start a fresh conversation, you can **reset** or create a
new session. The sample app shows a `resetSession()` function that
closes the old session and starts a new
one[\[25\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L50-L53).
You can also maintain multiple sessions (for different concurrent
conversations or tasks) as needed -- the engine supports it by sharing
the loaded model among
sessions[\[26\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,to%20customize%20the%20base%20model%27s).
Advanced use-cases can even **clone sessions** to branch context or
perform prompt precomputation (using cached KV
state)[\[22\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,state%20and%20saving%20significant%20computation),
though this is typically not needed for basic integrations.

## Running Inference (Single-turn)

Once the engine and session (if used) are ready, you can generate text.
There are two primary methods:

-   **Synchronous generation:** Call `generateResponse()` to get the
    complete result in one call (blocking the current thread until
    done).
-   **Asynchronous streaming generation:** Call
    `generateResponseAsync()` to receive partial results (tokens) via a
    callback as the model generates them.

For simple one-turn prompts (no need to preserve state), you can skip
creating a session and call the engine directly:

    val llmInference = LlmInference.createFromOptions(context, engineOptions)
    val outputText: String = llmInference.generateResponse("Hello, world!")

This will load the model, run inference on the prompt `"Hello, world!"`,
and return the full generated response as a
string[\[27\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20,produces%20a%20single%20generated%20response).
Under the hood, the API processes the text and runs the model to
completion before returning.

When using a `Session`, the usage is similar except you call the method
on the session:

    session.addQueryChunk("Q: What is the tallest mountain?")
    val answer: String = session.generateResponse()
    // answer might be: "A: Mount Everest."

The first `generateResponse()` on a fresh session will include the
prompt in the model's context. If you call it again after adding another
query chunk, the new call will include the prior Q&A as context (thanks
to the session's KV-cache). Each `generateResponse()` produces one
complete response for the current assembled prompt. The API handles
token generation internally based on your `maxTokens`, stopping when
either the model signals end-of-sequence or the token limit is reached.

**Note:** The **first token may take longer** to arrive (model has to
process the prompt) -- this is often referred to as *time-to-first-token
(TTFT)*. Subsequent tokens stream faster. On high-end devices, TTFT can
be sub-second for models like Gemma 3N, but it varies with model size
and hardware.

## Streaming Inference (Token Streaming)

For a better user experience, you can generate the response
**incrementally (streaming)**. Instead of waiting for the full output,
the API can invoke a callback as tokens are generated. This allows
showing partial results (like a typing indicator) in real time.

To use streaming, you must configure a `resultListener` on the options
and call the asynchronous method. For example:

    val engineOptions = LlmInferenceOptions.builder()
        .setModelPath(modelPath)
        .setMaxTokens(1000)
        .setResultListener { partialText, isDone ->
            Log.i(TAG, "Partial result: $partialText")
            if (isDone) {
                Log.i(TAG, "Generation completed.")
            }
        }
        .setErrorListener { error ->
            Log.e(TAG, "Generation error: ${error.message}")
        }
        .build()
    val llmInference = LlmInference.createFromOptions(context, engineOptions)

    // Start streaming generation (non-blocking call)
    llmInference.generateResponseAsync(userPrompt)

Here we set a `resultListener` lambda to handle interim results. The
listener provides two arguments: a `partialText` (the token(s) generated
so far, appended to previous callbacks) and a boolean `isDone` flag
indicating
completion[\[28\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=val%20options%20%3D%20LlmInference,%7D%20.build).
The API will call this repeatedly on a background thread as the model
produces text. When `isDone` is true, no more tokens will arrive for
this prompt. We also set an `errorListener` to catch any issues during
generation (e.g., if the model runs out of memory mid-generation). The
`generateResponseAsync(prompt)` call returns immediately; the results
come via the callbacks.

**Important:** The `resultListener` and `errorListener` are only used
with the async method -- they will be ignored for the blocking
`generateResponse()`[\[12\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=is%20only%20compatible%20with%20GPU,N%2FA%20N%2FA).
Also note that you should **not call** any other generate methods on the
same `llmInference` (or session) while an async generation is in
progress. If needed, cancel the task or wait for it to finish before
starting another.

Streaming is useful for longer outputs or chat UIs, as it gives the
impression of the model "typing" an answer. Ensure your UI appends the
`partialText` tokens appropriately (they may arrive as complete words or
sub-word pieces depending on the model's tokenizer).

## Error Handling and Resource Management

Using on-device LLMs can encounter errors due to large model sizes and
limited device resources. Here are best practices for error handling:

-   **Engine initialization failures:** Calling
    `LlmInference.createFromOptions` may throw an exception if the model
    fails to load (file not found, insufficient memory, etc.). Wrap this
    in a try-catch. For example, the sample app does:

```{=html}
<!-- -->
```
    try {
        llmInference = LlmInference.createFromOptions(context, engineOptions)
    } catch (e: Exception) {
        Log.e(TAG, "Load model error: ${e.message}", e)
        // Handle error, e.g., show user a message or retry
        throw ModelLoadFailException()
    }

[\[29\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L62-L70)If
an error occurs here, the model was not loaded -- you might prompt the
user to free up memory or verify the model file. Common issues include
using a model not compatible with the device or running out of RAM for
large models.

-   **Session creation failures:** Similarly, creating a session with
    `LlmInferenceSession.createFromOptions` can throw if the session
    can't be allocated. Catch exceptions around
    it[\[30\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L77-L83).
    This could happen if the model isn't properly loaded or if resources
    for a new session are exhausted.

-   **Inference errors:** The synchronous `generateResponse()` can throw
    runtime exceptions (for example, if generation fails or is manually
    canceled). Use try-catch around it if needed. In asynchronous mode,
    any generation error will trigger the `errorListener` callback
    instead of
    throwing[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,N%2FA%20N%2FA).
    In the example above, we log the error in the listener. You could
    also update the UI to indicate failure or attempt a fallback.

-   **Timeouts and cancellations:** The API itself does not impose a
    specific timeout, but you may want to implement one if you expect
    results within a certain time. For async calls, you can cancel the
    future (if one is returned) or signal the model to stop (current API
    may not have an explicit cancel, but closing the session or engine
    may interrupt it). Ensure your UI has a way to cancel long-running
    requests if needed.

**Resource cleanup:** Always release resources when done. The model
engine occupies memory (potentially several hundred MBs of weights).
Call `close()` on the `LlmInference` engine when your app no longer
needs the model loaded (e.g., on ViewModel cleared or Activity
destroy)[\[31\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L45-L53).
Likewise, call `close()` on any active `LlmInferenceSession` when
finished with that
session[\[31\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L45-L53).
An easy way in Kotlin is to use the `.use { ... }` extension or
try-with-resources, for example:

    LlmInference.createFromOptions(context, engineOptions).use { engine ->
        LlmInferenceSession.createFromOptions(engine, sessionOptions).use { session ->
            // ... perform generateResponse, etc.
        }
    }  // engine and session are automatically closed here

Closing the session frees its cache and any GPU/CPU buffers, and closing
the engine unloads the model from memory. Failing to close them could
lead to memory leaks or the model staying loaded longer than needed.

Finally, test on a range of devices if possible. On-device LLM inference
is memory-intensive; if targeting lower-end devices, use smaller models
or quantized versions (e.g., 4-bit quantization) and lower `maxTokens`
limits to avoid out-of-memory issues. Monitor logs for any `MediaPipe`
errors or warnings -- the API may log detailed info if something goes
wrong.

## References

-   Google AI Edge **LLM Inference Guide for Android** (official
    documentation)[\[1\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=The%20LLM%20Inference%20API%20lets,models%20to%20your%20Android%20apps)[\[32\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20,produces%20a%20single%20generated%20response)
-   Google AI Edge Gallery sample app (Android LLM demo, *commit
    c6c11bb*, Feb 26
    2025)[\[3\]](https://github.com/google-ai-edge/mediapipe-samples/releases#:~:text=26%20Feb%2018%3A23)[\[4\]](https://github.com/google-ai-edge/mediapipe-samples/releases#:~:text=v0)
    -- first release of the MediaPipe LLM Inference Android demo.
-   *On-Device GenAI with LiteRT-LM* -- Google Developers Blog
    (architecture of LiteRT-LM engine, Engine/Session design,
    etc.)[\[23\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,customize%20the%20base%20model%27s%20behavior)[\[22\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,state%20and%20saving%20significant%20computation).
-   MediaPipe LLM Inference API configuration options (official
    docs)[\[8\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Option%20Name%20Description%20Value%20Range,generated%20text%2C%20while%20a%20lower)[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=temperature%20produces%20more%20predictable%20generation,N%2FA%20N%2FA).
-   MediaPipe example code (InferenceModel.kt from sample app) -- for
    usage of `LlmInference`, session, and error
    handling[\[10\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L56-L64)[\[33\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L70-L78).

[\[1\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=The%20LLM%20Inference%20API%20lets,models%20to%20your%20Android%20apps)
[\[6\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20following%20steps%20to,not%20reliably%20support%20device%20emulators)
[\[7\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task)
[\[8\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Option%20Name%20Description%20Value%20Range,generated%20text%2C%20while%20a%20lower)
[\[9\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=PATH%20N%2FA%20,generated%20text%2C%20while%20a%20lower)
[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=temperature%20produces%20more%20predictable%20generation,N%2FA%20N%2FA)
[\[12\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=is%20only%20compatible%20with%20GPU,N%2FA%20N%2FA)
[\[13\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Note%3A%20this)
[\[14\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,to%20receive%20the%20results%20asynchronously)
[\[15\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Note%3A%20this)
[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,N%2FA%20N%2FA)
[\[17\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=To%20enable%20vision%20support%20for,within%20the%20Graph%20options)
[\[18\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Enable%20Audio%20support%20in%20sessionOptions)
[\[19\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=To%20get%20started%2C%20use%20a,compatible%20variant%20of%20Gemma%203n)
[\[20\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=import%20com)
[\[21\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=val%20audioData%3A%20ByteArray%20%3D%20,addAudio%28audioData)
[\[24\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=LlmInferenceSession%20session%20%3D%20LlmInferenceSession,generateResponse%28%29%3B)
[\[27\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20,produces%20a%20single%20generated%20response)
[\[28\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=val%20options%20%3D%20LlmInference,%7D%20.build)
[\[32\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20,produces%20a%20single%20generated%20response)
LLM Inference guide for Android  \|  Google AI Edge  \|  Google AI for
Developers

<https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android>

[\[2\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=You%20can%20already%20leverage%20the,our%20APIs%20to%20start%20building)
[\[22\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,state%20and%20saving%20significant%20computation)
[\[23\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,customize%20the%20base%20model%27s%20behavior)
[\[26\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,to%20customize%20the%20base%20model%27s)
On-device GenAI in Chrome, Chromebook Plus, and Pixel Watch with
LiteRT-LM - Google Developers Blog

<https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/>

[\[3\]](https://github.com/google-ai-edge/mediapipe-samples/releases#:~:text=26%20Feb%2018%3A23)
[\[4\]](https://github.com/google-ai-edge/mediapipe-samples/releases#:~:text=v0)
Releases · google-ai-edge/mediapipe-samples · GitHub

<https://github.com/google-ai-edge/mediapipe-samples/releases>

[\[5\]](https://github.com/google-ai-edge/gallery#:~:text=Get%20Started%20in%20Minutes%21)
GitHub - google-ai-edge/gallery: A gallery that showcases on-device
ML/GenAI use cases and allows people to try and use models locally.

<https://github.com/google-ai-edge/gallery>

[\[10\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L56-L64)
[\[25\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L50-L53)
[\[29\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L62-L70)
[\[30\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L77-L83)
[\[31\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L45-L53)
[\[33\]](https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt#L70-L78)
InferenceModel.kt

<https://github.com/google-ai-edge/mediapipe-samples/blob/3c7146b5298f6528b8e8dbde79e686b29af7cdba/examples/llm_inference/android/app/src/main/java/com/google/mediapipe/examples/llminference/InferenceModel.kt>
