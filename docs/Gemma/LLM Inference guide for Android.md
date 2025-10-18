[LLM Inference guide for Android]{.underline}

[**Note:** Use of the MediaPipe LLM Inference API is subject to the
[Generative AI Prohibited Use
Policy](https://policies.google.com/terms/generative-ai/use-policy).]{.underline}

[The LLM Inference API lets you run large language models (LLMs)
completely on-device for Android applications, which you can use to
perform a wide range of tasks, such as generating text, retrieving
information in natural language form, and summarizing documents. The
task provides built-in support for multiple text-to-text large language
models, so you can apply the latest on-device generative AI models to
your Android apps.]{.underline}

[To quickly add the LLM Inference API to your Android application,
follow the
[Quickstart](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#quickstart).
For a basic example of an Android application running the LLM Inference
API, see the [sample
application](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#sample-application).
For a more in-depth understanding of how the LLM Inference API works,
refer to the [configuration
options](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#configuration-options),
[model
conversion](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index#convert-pytorch),
and [LoRA
tuning](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android#lora-customization)
sections.]{.underline}

[You can see this task in action with the [MediaPipe Studio
demo](https://mediapipe-studio.webapps.google.com/studio/demo/llm_inference).
For more information about the capabilities, models, and configuration
options of this task, see the
[Overview](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index).]{.underline}

## [Quickstart]{.underline}

[Use the following steps to add the LLM Inference API to your Android
application. The LLM Inference API is optimized for high-end Android
devices, such as Pixel 8 and Samsung S23 or later, and does not reliably
support device emulators.]{.underline}

### [Add dependencies]{.underline}

[The LLM Inference API uses the com.google.mediapipe:tasks-genai
library. Add this dependency to the build.gradle file of your Android
app:]{.underline}

[dependencies {]{.underline}

[implementation
\'com.google.mediapipe:tasks-genai:0.10.27\']{.underline}

[}]{.underline}

### [Download a model]{.underline}

[Download Gemma-3 1B in a 4-bit quantized format from [Hugging
Face](https://huggingface.co/litert-community/Gemma3-1B-IT). For more
information on the available models, see the [Models
documentation](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/index#models).]{.underline}

[Push the content of the *output_path* folder to the Android
device.]{.underline}

[\$ adb shell rm -r /data/local/tmp/llm/ \# Remove any previously loaded
models]{.underline}

[\$ adb shell mkdir -p /data/local/tmp/llm/]{.underline}

[\$ adb push *output_path*
/data/local/tmp/llm/*model_version*.task]{.underline}

[**Note:** During development, you can use adb to push the model to your
test device for a simpler workflow. For deployment, host the model on a
server and download it at runtime. The model is too large to be bundled
in an APK.]{.underline}

### [Initialize the Task]{.underline}

[Initialize the task with basic configuration options:]{.underline}

[// Set the configuration options for the LLM Inference
task]{.underline}

[val taskOptions = LlmInferenceOptions.builder()]{.underline}

[.setModelPath(\'/data/local/tmp/llm/*model_version*.task\')]{.underline}

[.setMaxTopK(64)]{.underline}

[.build()]{.underline}

[// Create an instance of the LLM Inference task]{.underline}

[llmInference = LlmInference.createFromOptions(context,
taskOptions)]{.underline}

### [Run the Task]{.underline}

[Use the generateResponse() method to generate a text response. This
produces a single generated response.]{.underline}

[val result = llmInference.generateResponse(inputPrompt)]{.underline}

[logger.atInfo().log(\"result: \$result\")]{.underline}

[To stream the response, use the generateResponseAsync()
method.]{.underline}

[val options = LlmInference.LlmInferenceOptions.builder()]{.underline}

[\...]{.underline}

[.setResultListener { partialResult, done -\>]{.underline}

[logger.atInfo().log(\"partial result: \$partialResult\")]{.underline}

[}]{.underline}

[.build()]{.underline}

[llmInference.generateResponseAsync(inputPrompt)]{.underline}

## [Sample application]{.underline}

[**Note:** The Google AI Edge Gallery is an Alpha release.]{.underline}

[To see the LLM Inference APIs in action and explore a comprehensive
range of on-device Generative AI capabilities, check out the [Google AI
Edge Gallery
app](https://github.com/google-ai-edge/gallery).]{.underline}

[The Google AI Edge Gallery is an open-source Android application that
serves as an interactive playground for developers. It
showcases:]{.underline}

-   [Practical examples of using the LLM Inference API for various
    > tasks, including:]{.underline}

    -   [Ask Image: Upload an image and ask questions about it. Get
        > descriptions, solve problems, or identify
        > objects.]{.underline}

    -   [Prompt Lab: Summarize, rewrite, generate code, or use freeform
        > prompts to explore single-turn LLM use cases.]{.underline}

    -   [AI Chat: Engage in multi-turn conversations.]{.underline}

-   [The ability to discover, download, and experiment with a variety of
    > LiteRT-optimized models from the Hugging Face LiteRT Community and
    > official Google releases (e.g. Gemma 3N).]{.underline}

-   [Real-time on-device performance benchmarks for different models
    > (Time To First Token, decode speed, etc.).]{.underline}

-   [How to import and test your own custom .litertlm or .task
    > models.]{.underline}

[This app is a resource to understand the practical implementation of
the LLM Inference API and the potential of on-device Generative AI.
Explore the source code and download the app from the]{.underline}
[[Google AI Edge Gallery GitHub
repository](https://github.com/google-ai-edge/gallery).]{.underline}

## [Configuration options]{.underline}

[Use the following configuration options to set up an Android
app:]{.underline}

  ----------------------------------------------------------------------------------------------------------------------------
  [Option Name]{.underline}      [Description]{.underline}                        [Value                  [Default
                                                                                  Range]{.underline}      Value]{.underline}
  ------------------------------ ------------------------------------------------ ----------------------- --------------------
  [modelPath]{.underline}        [The path to where the model is stored within    [PATH]{.underline}      [N/A]{.underline}
                                 the project directory.]{.underline}                                      

  [maxTokens]{.underline}        [The maximum number of tokens (input tokens +    [Integer]{.underline}   [512]{.underline}
                                 output tokens) the model handles.]{.underline}                           

  [topK]{.underline}             [The number of tokens the model considers at     [Integer]{.underline}   [40]{.underline}
                                 each step of generation. Limits predictions to                           
                                 the top k most-probable tokens.]{.underline}                             

  [temperature]{.underline}      [The amount of randomness introduced during      [Float]{.underline}     [0.8]{.underline}
                                 generation. A higher temperature results in more                         
                                 creativity in the generated text, while a lower                          
                                 temperature produces more predictable                                    
                                 generation.]{.underline}                                                 

  [randomSeed]{.underline}       [The random seed used during text                [Integer]{.underline}   [0]{.underline}
                                 generation.]{.underline}                                                 

  [loraPath]{.underline}         [The absolute path to the LoRA model locally on  [PATH]{.underline}      [N/A]{.underline}
                                 the device. Note: this is only compatible with                           
                                 GPU models.]{.underline}                                                 

  [resultListener]{.underline}   [Sets the result listener to receive the results [N/A]{.underline}       [N/A]{.underline}
                                 asynchronously. Only applicable when using the                           
                                 async generation method.]{.underline}                                    

  [errorListener]{.underline}    [Sets an optional error listener.]{.underline}   [N/A]{.underline}       [N/A]{.underline}
  ----------------------------------------------------------------------------------------------------------------------------

## [Multimodal prompting]{.underline}

[The LLM Inference API Android APIs support multimodal prompting with
models that accept text, image, and audio inputs. With multimodality
enabled, users can include a combination of images and text or audio and
text in their prompts.The LLM then provides a text
response.]{.underline}

[To get started, use a MediaPipe-compatible variant of [Gemma
3n](https://ai.google.dev/gemma/docs/gemma-3n):]{.underline}

-   [[Gemma-3n
    > E2B](https://huggingface.co/google/gemma-3n-E2B-it-litert-lm): an
    > effective 2B model of the Gemma-3n family.]{.underline}

-   [[Gemma-3n
    > E4B](https://huggingface.co/google/gemma-3n-E4B-it-litert-lm): an
    > effective 4B model of the Gemma-3n family.]{.underline}

[For more information, see the [Gemma-3n
documentation](https://ai.google.dev/gemma/docs/gemma-3n).]{.underline}

[Follow the steps below to enable image or audio input for LLM Inference
API.]{.underline}

### [Image input]{.underline}

[To provide images within a prompt, convert the input images or frames
to a com.google.mediapipe.framework.image.MPImage object before passing
it to the LLM Inference API:]{.underline}

[import
com.google.mediapipe.framework.image.BitmapImageBuilder]{.underline}

[import com.google.mediapipe.framework.image.MPImage]{.underline}

[// Convert the input Bitmap object to an MPImage object to run
inference]{.underline}

[val mpImage = BitmapImageBuilder(image).build()]{.underline}

[To enable vision support for the LLM Inference API, set the
EnableVisionModality configuration option to true within the Graph
options:]{.underline}

[LlmInferenceSession.LlmInferenceSessionOptions sessionOptions
=]{.underline}

[LlmInferenceSession.LlmInferenceSessionOptions.builder()]{.underline}

[\...]{.underline}

[.setGraphOptions(GraphOptions.builder().setEnableVisionModality(true).build())]{.underline}

[.build();]{.underline}

[Set the maximum of 10 images per session.]{.underline}

[LlmInferenceOptions options =
LlmInferenceOptions.builder()]{.underline}

[\...]{.underline}

[.setMaxNumImages(10)]{.underline}

[.build();]{.underline}

[The following is an example implementation of the LLM Inference API set
up to handle vision and text inputs:]{.underline}

[MPImage image = getImageFromAsset(BURGER_IMAGE);]{.underline}

[LlmInferenceSession.LlmInferenceSessionOptions sessionOptions
=]{.underline}

[LlmInferenceSession.LlmInferenceSessionOptions.builder()]{.underline}

[.setTopK(10)]{.underline}

[.setTemperature(0.4f)]{.underline}

[.setGraphOptions(GraphOptions.builder().setEnableVisionModality(true).build())]{.underline}

[.build();]{.underline}

[try (LlmInference llmInference =]{.underline}

[LlmInference.createFromOptions(ApplicationProvider.getApplicationContext(),
options);]{.underline}

[LlmInferenceSession session =]{.underline}

[LlmInferenceSession.createFromOptions(llmInference, sessionOptions))
{]{.underline}

[session.addQueryChunk(\"Describe the objects in the
image.\");]{.underline}

[session.addImage(image);]{.underline}

[String result = session.generateResponse();]{.underline}

[}]{.underline}

### [Audio input]{.underline}

[Enable audio support in LlmInferenceOptions]{.underline}

[val inferenceOptions =
LlmInference.LlmInferenceOptions.builder()]{.underline}

[\...]{.underline}

[.setAudioModelOptions(AudioModelOptions.builder().build())]{.underline}

[.build()]{.underline}

[Enable Audio support in sessionOptions]{.underline}

[val sessionOptions = LlmInferenceSessionOptions.builder()]{.underline}

[\...]{.underline}

[.setGraphOptions(GraphOptions.builder().setEnableAudioModality(true).build())]{.underline}

[.build()]{.underline}

[Send audio data during inference. Note: Audio must be mono channel
formatted as .wav]{.underline}

[val audioData: ByteArray = \...]{.underline}

[inferenceEngine.llmInferenceSession.addAudio(audioData)]{.underline}

[The following is an example implementation of the LLM Inference API set
up to handle audio and text inputs:]{.underline}

[val audioData: ByteArray = \...]{.underline}

[val inferenceOptions =
LlmInference.LlmInferenceOptions.builder()]{.underline}

[\...]{.underline}

[.setAudioModelOptions(AudioModelOptions.builder().build())]{.underline}

[.build()]{.underline}

[val sessionOptions = LlmInferenceSessionOptions.builder()]{.underline}

[\...]{.underline}

[.setGraphOptions(GraphOptions.builder().setEnableAudioModality(true).build())]{.underline}

[.build()]{.underline}

[LlmInference.createFromOptions(context, inferenceOptions).use {
llmInference -\>]{.underline}

[LlmInferenceSession.createFromOptions(llmInference, sessionOptions).use
{ session -\>]{.underline}

[session.addQueryChunk(\"Transcribe the following speech
segment:\")]{.underline}

[session.addAudio(audioData)]{.underline}

[val result = session.generateResponse()]{.underline}

[}]{.underline}

[}]{.underline}

## [LoRA customization]{.underline}

[The LLM Inference API supports LoRA (Low-Rank Adaptation) tuning using
the [PEFT](https://huggingface.co/docs/peft/main/en/index)
(Parameter-Efficient Fine-Tuning) library. LoRA tuning customizes the
behavior of LLMs through a cost-effective training process, creating a
small set of trainable weights based on new training data rather than
retraining the entire model.]{.underline}

[The LLM Inference API supports adding LoRA weights to attention layers
of the [Gemma-2 2B](https://huggingface.co/google/gemma-2-2b), [Gemma
2B](https://huggingface.co/google/gemma-2b) and
[Phi-2](https://huggingface.co/microsoft/phi-2) models. Download the
model in the safetensors format.]{.underline}

[The base model must be in the safetensors format in order to create
LoRA weights. After LoRA training, you can convert the models into the
FlatBuffers format to run on MediaPipe.]{.underline}

### [Prepare LoRA weights]{.underline}

[Use the [LoRA
Methods](https://huggingface.co/docs/peft/main/en/task_guides/lora_based_methods)
guide from PEFT to train a fine-tuned LoRA model on your own
dataset.]{.underline}

[The LLM Inference API only supports LoRA on attention layers, so only
specify the attention layers in LoraConfig:]{.underline}

[\# For Gemma]{.underline}

[from peft import LoraConfig]{.underline}

[config = LoraConfig(]{.underline}

[r=LORA_RANK,]{.underline}

[target_modules=\[\"q_proj\", \"v_proj\", \"k_proj\",
\"o_proj\"\],]{.underline}

[)]{.underline}

[\# For Phi-2]{.underline}

[config = LoraConfig(]{.underline}

[r=LORA_RANK,]{.underline}

[target_modules=\[\"q_proj\", \"v_proj\", \"k_proj\",
\"dense\"\],]{.underline}

[)]{.underline}

[After training on the prepared dataset and saving the model, the
fine-tuned LoRA model weights are available in
adapter_model.safetensors. The safetensors file is the LoRA checkpoint
used during model conversion.]{.underline}

### [Model conversion]{.underline}

[Use the MediaPipe Python Package to convert the model weights into the
Flatbuffer format. The ConversionConfig specifies the base model options
along with the additional LoRA options.]{.underline}

[**Note:** Since the API only supports LoRA inference with GPU, the
backend must be set to **\'gpu\'**.]{.underline}

[import mediapipe as mp]{.underline}

[from mediapipe.tasks.python.genai import converter]{.underline}

[config = converter.ConversionConfig(]{.underline}

[\# Other params related to base model]{.underline}

[\...]{.underline}

[\# Must use gpu backend for LoRA conversion]{.underline}

[backend=\'gpu\',]{.underline}

[\# LoRA related params]{.underline}

[lora_ckpt=*LORA_CKPT*,]{.underline}

[lora_rank=*LORA_RANK*,]{.underline}

[lora_output_tflite_file=*LORA_OUTPUT_FILE*,]{.underline}

[)]{.underline}

[converter.convert_checkpoint(config)]{.underline}

[The converter will produce two Flatbuffer files, one for the base model
and another for the LoRA model.]{.underline}

### [LoRA model inference]{.underline}

[Android supports static LoRA during initialization. To load a LoRA
model, specify the LoRA model path as well as the base LLM.]{.underline}

[// Set the configuration options for the LLM Inference
task]{.underline}

[val options = LlmInferenceOptions.builder()]{.underline}

[.setModelPath(*BASE_MODEL_PATH*)]{.underline}

[.setMaxTokens(1000)]{.underline}

[.setTopK(40)]{.underline}

[.setTemperature(0.8)]{.underline}

[.setRandomSeed(101)]{.underline}

[.setLoraPath(*LORA_MODEL_PATH*)]{.underline}

[.build()]{.underline}

[// Create an instance of the LLM Inference task]{.underline}

[llmInference = LlmInference.createFromOptions(context,
options)]{.underline}

[To run LLM inference with LoRA, use the same generateResponse() or
generateResponseAsync() methods as the base model.]{.underline}
