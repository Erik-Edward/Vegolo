> [Deploy Gemma on mobile devices]{.underline}

[This document outlines various methods and tools for deploying and
running Gemma models on mobile devices, including using the Google AI
Edge Gallery app and the MediaPipe LLM Inference API.]{.underline}

[For information on converting a fine-tuned Gemma model to a LiteRT
version, see the [Conversion
Guide](https://ai.google.dev/gemma/docs/conversions/hf-to-mediapipe-task).]{.underline}

## [Google AI Edge Gallery app]{.underline}

[To see the LLM Inference APIs in action and test your Task Bundle
model, you can use the [Google AI Edge Gallery
app](https://github.com/google-ai-edge/gallery). This app provides a
user interface for interacting with on-device LLMs, allowing you
to:]{.underline}

-   [**Import Models:** Load your custom .task models into the
    > app.]{.underline}

-   [**Configure Parameters:** Adjust settings like temperature and
    > top-k.]{.underline}

-   [**Generate Text:** Input prompts and view the model\'s
    > responses.]{.underline}

-   [**Test Performance:** Evaluate the model\'s speed and
    > accuracy.]{.underline}

[For a detailed guide on how to use the Google AI Edge Gallery app,
including instructions for importing your own models, refer to the
app\'s
[documentation](https://github.com/google-ai-edge/gallery/blob/main/README.md).]{.underline}

## [MediaPipe LLM]{.underline}

[You can run Gemma models on mobile devices with the [MediaPipe LLM
Inference
API](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference).
The LLM Inference API acts as a wrapper for large language models,
enabling you run Gemma models on-device for common text-to-text
generation tasks like information retrieval, email drafting, and
document summarization.]{.underline}

[The LLM Inference API is available on the following mobile
platforms:]{.underline}

-   [[Android]{.underline}](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android)

-   [[iOS]{.underline}](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/ios)
