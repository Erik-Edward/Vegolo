[Gemma 3n model overview]{.underline}

[Gemma 3n is a generative AI model optimized for use in everyday
devices, such as phones, laptops, and tablets. This model includes
innovations in parameter-efficient processing, including Per-Layer
Embedding (PLE) parameter caching and a MatFormer model architecture
that provides the flexibility to reduce compute and memory requirements.
These models feature audio input handling, as well as text and visual
data.]{.underline}

[Gemma 3n includes the following key features:]{.underline}

-   [**Audio input**: Process sound data for speech recognition,
    > translation, and audio data analysis. [Learn
    > more](https://ai.google.dev/gemma/docs/core/huggingface_inference#audio)]{.underline}

-   [**Visual and text input**: Multimodal capabilities let you handle
    > vision, sound, and text to help you understand and analyze the
    > world around you. [Learn
    > more](https://ai.google.dev/gemma/docs/core/huggingface_inference#vision)]{.underline}

-   [**Vision encoder:** High-performance MobileNet-V5 encoder
    > substantially improves speed and accuracy of processing visual
    > data. [Learn
    > more](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/#mobilenet-v5:-new-state-of-the-art-vision-encoder)]{.underline}

-   [**PLE caching**: Per-Layer Embedding (PLE) parameters contained in
    > these models can be cached to fast, local storage to reduce model
    > memory run costs. [Learn
    > more](https://ai.google.dev/gemma/docs/gemma-3n#ple-caching)]{.underline}

-   [**MatFormer architecture:** Matryoshka Transformer architecture
    > allows for selective activation of the models parameters per
    > request to reduce compute cost and response times. [Learn
    > more](https://ai.google.dev/gemma/docs/gemma-3n#matformer)]{.underline}

-   [**Conditional parameter loading:** Bypass loading of vision and
    > audio parameters in the model to reduce the total number of loaded
    > parameters and save memory resources. [Learn
    > more](https://ai.google.dev/gemma/docs/gemma-3n#conditional-parameter)]{.underline}

-   [**Wide language support**: Wide linguistic capabilities, trained in
    > over 140 languages.]{.underline}

-   [**32K token context**: Substantial input context for analyzing data
    > and handling processing tasks.]{.underline}

[Try Gemma
3n](https://aistudio.google.com/prompts/new_chat?model=gemma-3n-e4b-it)
[Get it on Kaggle](https://www.kaggle.com/models/google/gemma-3n) [Get
it on Hugging
Face](https://huggingface.co/collections/google/gemma-3n-685065323f5984ef315c93f4)

[As with other Gemma models, Gemma 3n is provided with open weights and
licensed for responsible [commercial
use](https://ai.google.dev/gemma/terms), allowing you to tune and deploy
it in your own projects and applications.]{.underline}

[**Tip:** If you are interested in building generative AI solutions for
Android mobile applications, check out Gemini Nano. For more
information, see the Android [Gemini
Nano](https://developer.android.com/ai/gemini-nano) developer
docs.]{.underline}

## [Model parameters and effective parameters]{.underline}

[Gemma 3n models are listed with parameter counts, such as **E2B** and
**E4B**, that are *lower* than the total number of parameters contained
in the models. The **E** prefix indicates these models can operate with
a reduced set of Effective parameters. This reduced parameter operation
can be achieved using the flexible parameter technology built into Gemma
3n models to help them run efficiently on lower resource
devices.]{.underline}

[The parameters in Gemma 3n models are divided into 4 main groups: text,
visual, audio, and per-layer embedding (PLE) parameters. With standard
execution of the E2B model, over 5 billion parameters are loaded when
executing the model. However, using parameter skipping and PLE caching
techniques, this model can be operated with an effective memory load of
just under 2 billion (1.91B) parameters, as illustrated in Figure
1.]{.underline}

![Gemma 3n diagram of parameter
usage](media/image1.png){width="6.267716535433071in"
height="3.111111111111111in"}

[**Figure 1.** Gemma 3n E2B model parameters running in standard
execution versus an effectively lower parameter load using PLE caching
and parameter skipping techniques.]{.underline}

[Using these parameter offloading and selective activation techniques,
you can run the model with a very lean set of parameters or activate
additional parameters to handle other data types such as visual and
audio. These features enable you to ramp up model functionality or ramp
down capabilities based on device capabilities or task requirements. The
following sections explain more about the parameter efficient techniques
available in Gemma 3n models.]{.underline}

## [PLE caching]{.underline}

[Gemma 3n models include Per-Layer Embedding (PLE) parameters that are
used during model execution to create data that enhances the performance
of each model layer. The PLE data can be generated separately, outside
the operating memory of the model, cached to fast storage, and then
added to the model inference process as each layer runs. This approach
allows PLE parameters to be kept out of the model memory space, reducing
resource consumption while still improving model response
quality.]{.underline}

## [MatFormer architecture]{.underline}

[Gemma 3n models use a Matryoshka Transformer or *MatFormer* model
architecture that contains nested, smaller models within a single,
larger model. The nested sub-models can be used for inferences without
activating the parameters of the enclosing models when responding to
requests. This ability to run just the smaller, core models within a
MatFormer model can reduce compute cost, and response time, and energy
footprint for the model. In the case of Gemma 3n, the E4B model contains
the parameters of the E2B model. This architecture also lets you select
parameters and assemble models in intermediate sizes between 2B and 4B.
For more details on this approach, see the [MatFormer research
paper](https://arxiv.org/pdf/2310.07707). Try using MatFormer techniques
to reduce the size of a Gemma 3n model with the [MatFormer
Lab](https://goo.gle/gemma3n-matformer-lab) guide.]{.underline}

## [Conditional parameter loading]{.underline}

[Similar to PLE parameters, you can skip loading of some parameters into
memory, such as audio or visual parameters, in the Gemma 3n model to
reduce memory load. These parameters can be dynamically loaded at
runtime if the device has the required resources. Overall, parameter
skipping can further reduce the required operating memory for a Gemma 3n
model, enabling execution on a wider range of devices and allowing
developers to increase resource efficiency for less demanding
tasks.]{.underline}
