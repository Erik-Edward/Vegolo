# Integrating MediaPipe GenAI LLM Inference (LiteRT‑LM) on Android

To run a **MediaPipe GenAI LLM (LiteRT‑LM)** model (e.g. a **Gemma 3N**
variant or Gemini Nano) on Android, you can use the official *MediaPipe
LLM Inference API*. Below is a minimal Kotlin example (from Google's
open-source demo app, commit **c6c11bb** on 2025-02-26) that covers
model loading with memory mapping, delegate/threads configuration, model
initialization (with optional warm-up), starting a session (KV-cache),
generating text (with streaming), and basic error/timeout handling.

## 1. Loading and Configuring the LiteRT‑LM Model

First, add the GenAI tasks library to your app's Gradle dependencies:

    dependencies {
        implementation 'com.google.mediapipe:tasks-genai:0.10.27'
    }

**Download or include a model** in MediaPipe's `.task` format (e.g. a
4-bit quantized Gemma3 or Gemini model). Models are typically large
(hundreds of MB), so they are **memory-mapped from external storage**
rather than packaged in the
APK[\[1\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task)[\[2\]](https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6#:~:text=%24%20adb%20push%20output_path%20%2Fdata%2Flocal%2Ftmp%2Fllm%2Fmodel_version).
For example, you might push a model file to the device's internal
storage via ADB (as shown below) and then supply its path to the API:

    $ adb shell mkdir -p /data/local/tmp/llm/
    $ adb push <your_model>.task /data/local/tmp/llm/model.task

> *Note:* The model should reside in accessible storage (e.g.
> `/data/local/tmp`); due to size, **do not bundle it in the
> APK**[\[3\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task).

Now, create and configure the LLM inference **options**. This includes
the model's file path and various inference parameters. You can also
select the **delegate/backend** (CPU, GPU, or NNAPI) and number of
threads here. In the example below, we set a model path and some
generation parameters, and explicitly choose the GPU backend (the
default is
CPU/XNNPACK)[\[4\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=,build)[\[5\]](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/support/model/Model.Options#:~:text=,and%20default%20value%20is%201):

    val options = LlmInference.LlmInferenceOptions.builder()
        .setModelPath("/data/local/tmp/llm/model.task")      // Memory-mapped model file
        .setMaxTokens(512)                                   // Max tokens (prompt + output)[6]
        .setTopK(40)                                         // Top-K sampling limit[7]
        .setTemperature(0.8f)                                // Sampling temperature[8]
        .setRandomSeed(42)                                   // Random seed for reproducibility[9]
        .setPreferredBackend(LlmInference.Backend.GPU)       // Delegate: GPU (use CPU/XNNPACK by default)[10]
        .setNumThreads(4)                                    // Use 4 threads for CPU inference (if CPU chosen)[5]
        .build()

    val llmInference = LlmInference.createFromOptions(appContext, options)

In this snippet, `.setPreferredBackend(...)` selects the hardware
delegate (e.g. GPU vs. CPU) and `.setNumThreads(...)` configures
TFLite's thread pool when using
CPU[\[5\]](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/support/model/Model.Options#:~:text=,and%20default%20value%20is%201).
By default the **CPU delegate uses XNNPACK** (optimized CPU kernels) and
the **GPU delegate** uses OpenGL/Metal; NNAPI is also supported on CPU
devices (for DSP/NPU acceleration on Android) via the NNAPI delegate.
After building the options,
`LlmInference.createFromOptions(context, options)` **loads the model
into memory** and initializes the inference
engine[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%2F%2F%20Set%20the%20configuration%20options,build).

*Error handling:* If the model fails to load (e.g. file not found or
incompatible), `createFromOptions` will throw an exception. In practice,
the sample code checks for the model file's existence and wraps
initialization in a try-catch, e.g. returning an error message if
loading
fails[\[12\]](https://2bab.me/en/blog/2024-09-01-on-device-model-integration-kmp/#:~:text=%7D%20return%20try%20,%7D%20loadModel%28modelPath%29%20initialized.set%28true%29%20null):

    if (!File(modelPath).exists()) {
        return "Model not found at path: $modelPath"
    }
    return try {
        llmInference = LlmInference.createFromOptions(context, options)
        null  // success
    } catch (e: Exception) {
        e.message  // return error
    }

You may also perform a **warm-up** by running a trivial inference (e.g.
an empty prompt) right after loading, which can reduce first-query
latency.

## 2. Initializing an Inference Session (KV-Cache)

For **stateful** interactions (like multi-turn chat or long text
generation), the API uses a session object that maintains the model's
**KV-cache (history)** in
memory[\[13\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,LM%20under%20the%20hood)[\[14\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=Session,LLM%20chat%20apps%20on%20Android).
Create a new session from the loaded engine and configure any
session-specific options (like decoding strategy or modalities):

    val session = LlmInferenceSession.createFromOptions(
        llmInference,
        LlmInferenceSession.LlmInferenceSessionOptions.builder()
            .setTopK(40)                // (Session-level option, e.g. override top-K)[15]
            .setTemperature(0.8f)       // (Session-level temperature, etc.)
            .build()
    )

Each `LlmInferenceSession` holds its own **conversation context** (the
KV-cache of past key/value attention tensors). **Queries** (prompts) are
added to the session sequentially. For example, to start a new prompt or
conversation, call `session.addQueryChunk(promptText)`. If generating a
long response or using streaming, you can also feed the prompt in
smaller parts via multiple `addQueryChunk` calls (the API will
accumulate them). The session automatically appends this prompt to any
prior context from earlier turns (unless you reset or create a new
session)[\[16\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=Session,LLM%20chat%20apps%20on%20Android).
In a chat scenario, you would reuse the same session for each user query
to preserve conversational memory, and call `session.reset()` (or simply
start a new session) to clear history when needed.

## 3. Generating Text Output (Synchronous vs. Streaming)

Once the session has the prompt, invoke the generation method. You can
use either **synchronous** generation (returns the full result when
done) or **asynchronous streaming** that yields partial tokens. Below is
an example using the **streaming** callback with
`generateResponseAsync()`[\[17\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=session.addQueryChunk%28):

    session.addQueryChunk("Explain AI in one sentence.")    // Provide prompt to session[17]

    // Start asynchronous generation (streaming partial results):
    session.generateResponseAsync { partialText, done ->
        if (partialText.isNotEmpty()) {
            Log.i(TAG, "Model output: $partialText")
        }
        if (done) {
            Log.i(TAG, "--- Generation completed ---")
            // (Optional) close or reset after completion
            llmInference.close()  // free model resources[18]
        }
    }

In this example, `generateResponseAsync` immediately returns and invokes
the given **callback** on a background thread as tokens are produced.
The `partialText` parameter contains a chunk of newly generated text,
and the `done` flag indicates when the model has finished or reached the
token limit. The MediaPipe API ensures thread-safe callbacks so you can
update UI from them (or accumulate the output in a buffer). If you
prefer a blocking call, you can use
`val result = session.generateResponse(prompt)` to get the full text
result
synchronously[\[19\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20,produces%20a%20single%20generated%20response)[\[20\]](https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6#:~:text=Use%20the%20,produces%20a%20single%20generated%20response).

**Under the hood**, the LiteRT-LM engine manages the iterative decoding
process and **KV-cache** state during
generation[\[13\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,LM%20under%20the%20hood).
This means the session remembers past prompts and responses, enabling
the model to generate contextually coherent continuations. (The KV-cache
is automatically used --- no manual handling is required from the
developer.)

## 4. Error Handling and Timeout Management

During generation, it's important to handle errors and potential long
runtimes:

-   **Memory/Resource Errors:** Large models might exhaust memory on
    older devices. Catch exceptions from `createFromOptions` or
    generation calls, and surface a graceful error (as shown earlier).
    Also ensure to call `llmInference.close()` when done to release
    native memory (model and
    cache)[\[18\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=%2F%2F%205,close%28%29)[\[21\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=fun%20cleanup%28%29%20,close%28%29).

-   **Timeouts & Cancellation:** Depending on prompt and model size,
    generation can take several seconds (or more for large outputs). The
    `generateResponseAsync` call is non-blocking and runs in the
    LiteRT-LM's internal thread. If you need to enforce a timeout, you
    can start a timer when invoking generation and then cancel the
    request if it exceeds a threshold. Currently, the API does not
    provide a direct `cancel()` method for an ongoing generation. A
    common strategy is to cancel at the application level: e.g., ignore
    further callback results after a timeout, or destroy and recreate
    the session/engine to stop work. The underlying TFLite interpreter
    **does support cancellation
    flags**[\[22\]](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options#:~:text=,boolean%20allow),
    and future versions of MediaPipe may expose this. For now, you
    should design your UI to allow the user to interrupt or reset the
    session if a response is taking too long (for example, by closing
    the session or starting a new one).

-   **Threading:** Ensure UI updates occur on the main thread. The
    callback in `generateResponseAsync` will be on a background thread,
    so switch context if updating UI elements. In Jetpack Compose or
    Android Views, you might accumulate `partialText` in a
    `MutableLiveData`/`Flow` or Compose
    `remember { mutableStateOf("") }` and collect it on the UI side (the
    official sample uses this
    approach)[\[23\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=session.addQueryChunk%28,)[\[24\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=fun%20generateResponse,addQueryChunk%28prompt).

Finally, be mindful of **device requirements and model size**. On-device
LLM inference with Gemma/Gemini models is best on newer devices (Pixel
8, Samsung S23 or later) with sufficient RAM and ideally an NPU or
GPU[\[25\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20following%20steps%20to,not%20reliably%20support%20device%20emulators).
The example above demonstrates the minimal integration; the full
**Google AI Edge Gallery** app showcases additional features like
multi-turn chat and image-grounded prompts, as well as runtime model
downloads[\[26\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Note%3A%20The%20Google%20AI%20Edge,Gallery%20is%20an%20Alpha%20release)[\[27\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Time%20To).

**Sources:** The code sample above is adapted from Google's MediaPipe
LLM inference demo (open-sourced in Feb 2025) and official
documentation. Key references include the \[MediaPipe LLM Inference
Android guide\]\[19\], the \[MediaPipe sample app repository\]\[41\]
(Google AI Edge Gallery, commit c6c11bb, 2025-02-26), and Google
developers' blogs. These sources provide further details on model
conversion, available model variants, and on-device performance
considerations[\[28\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Download%20Gemma,models%2C%20see%20the%20Models%20documentation)[\[13\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,LM%20under%20the%20hood).

[\[1\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task)
[\[3\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%24%20adb%20shell%20rm%20,task)
[\[11\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=%2F%2F%20Set%20the%20configuration%20options,build)
[\[19\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20,produces%20a%20single%20generated%20response)
[\[25\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Use%20the%20following%20steps%20to,not%20reliably%20support%20device%20emulators)
[\[26\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Note%3A%20The%20Google%20AI%20Edge,Gallery%20is%20an%20Alpha%20release)
[\[27\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=,Time%20To)
[\[28\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#:~:text=Download%20Gemma,models%2C%20see%20the%20Models%20documentation)
LLM Inference guide for Android  \|  Google AI Edge  \|  Google AI for
Developers

<https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android>

[\[2\]](https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6#:~:text=%24%20adb%20push%20output_path%20%2Fdata%2Flocal%2Ftmp%2Fllm%2Fmodel_version)
[\[6\]](https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6#:~:text=val%20options%20%3D%20LlmInferenceOptions,build)
[\[8\]](https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6#:~:text=)
[\[9\]](https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6#:~:text=)
[\[20\]](https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6#:~:text=Use%20the%20,produces%20a%20single%20generated%20response)
Running an LLM on-device using Google's MediaPipe \| by Areeb Bashir \|
Medium

<https://medium.com/@areebbashir13/running-a-llm-on-device-using-googles-mediapipe-c48c5ad816c6>

[\[4\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=,build)
[\[7\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=LlmInferenceSession,)
[\[10\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=,build)
[\[14\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=Session,LLM%20chat%20apps%20on%20Android)
[\[15\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=%2F%2F%203,build%28%29)
[\[16\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=Session,LLM%20chat%20apps%20on%20Android)
[\[17\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=session.addQueryChunk%28)
[\[18\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=%2F%2F%205,close%28%29)
[\[21\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=fun%20cleanup%28%29%20,close%28%29)
[\[23\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=session.addQueryChunk%28,)
[\[24\]](https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52#:~:text=fun%20generateResponse,addQueryChunk%28prompt)
Complete Guide to Running LLMs on Android Devices: On-Device Inference
with MediaPipe \| by MLBoy \| Medium

<https://rockyshikoku.medium.com/running-llm-on-android-devices-complete-guide-with-mediapipe-on-device-inference-957daa537f52>

[\[5\]](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/support/model/Model.Options#:~:text=,and%20default%20value%20is%201)
Model.Options  \|  Google AI Edge  \|  Google AI for Developers

<https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/support/model/Model.Options>

[\[12\]](https://2bab.me/en/blog/2024-09-01-on-device-model-integration-kmp/#:~:text=%7D%20return%20try%20,%7D%20loadModel%28modelPath%29%20initialized.set%28true%29%20null)
Adapting MediaPipe Demos for Kotlin Multiplatform: LLM Inference \|
2BAB\'s Blog

<https://2bab.me/en/blog/2024-09-01-on-device-model-integration-kmp/>

[\[13\]](https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/#:~:text=,LM%20under%20the%20hood)
On-device GenAI in Chrome, Chromebook Plus, and Pixel Watch with
LiteRT-LM - Google Developers Blog

<https://developers.googleblog.com/en/on-device-genai-in-chrome-chromebook-plus-and-pixel-watch-with-litert-lm/>

[\[22\]](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options#:~:text=,boolean%20allow)
Interpreter.Options  \|  Google AI Edge  \|  Google AI for Developers

<https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options>
