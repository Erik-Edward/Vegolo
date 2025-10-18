[Gemma 3n model card]{.underline}

[**Model Page**: [Gemma
3n](https://ai.google.dev/gemma/docs/gemma-3n)]{.underline}

[**Resources and Technical Documentation**:]{.underline}

-   [[Responsible Generative AI
    > Toolkit]{.underline}](https://ai.google.dev/responsible)

-   [[Gemma on
    > Kaggle]{.underline}](https://www.kaggle.com/models/google/gemma-3n)

-   [[Gemma on
    > HuggingFace]{.underline}](https://huggingface.co/collections/google/gemma-3n-685065323f5984ef315c93f4)

-   [[Gemma on Vertex Model
    > Garden]{.underline}](https://console.cloud.google.com/vertex-ai/publishers/google/model-garden/gemma3n)

[**Terms of Use**: [Terms\
](https://ai.google.dev/gemma/terms)**Authors**: Google
DeepMind]{.underline}

## [Model Information]{.underline}

[Summary description and brief definition of inputs and
outputs.]{.underline}

### [Description]{.underline}

[Gemma is a family of lightweight, state-of-the-art open models from
Google, built from the same research and technology used to create the
Gemini models. Gemma 3n models are designed for efficient execution on
low-resource devices. They are capable of multimodal input, handling
text, image, video, and audio input, and generating text outputs, with
open weights for pre-trained and instruction-tuned variants. These
models were trained with data in over 140 spoken languages.]{.underline}

[Gemma 3n models use selective parameter activation technology to reduce
resource requirements. This technique allows the models to operate at an
effective size of 2B and 4B parameters, which is lower than the total
number of parameters they contain. For more information on Gemma 3n\'s
efficient parameter management technology, see the [Gemma
3n](https://ai.google.dev/gemma/docs/gemma-3n#parameters)
page.]{.underline}

### [Inputs and outputs]{.underline}

-   **[Input:]{.underline}**

    -   [Text string, such as a question, a prompt, or a document to be
        > summarized]{.underline}

    -   [Images, normalized to 256x256, 512x512, or 768x768 resolution
        > and encoded to 256 tokens each]{.underline}

    -   [Audio data encoded to 6.25 tokens per second from a single
        > channel]{.underline}

    -   [Total input context of 32K tokens]{.underline}

-   **[Output:]{.underline}**

    -   [Generated text in response to the input, such as an answer to a
        > question, analysis of image content, or a summary of a
        > document]{.underline}

    -   [Total output length up to 32K tokens, subtracting the request
        > input tokens]{.underline}

### [Citation]{.underline}

[\@article{gemma_3n_2025,]{.underline}

[title={Gemma 3n},]{.underline}

[url={https://ai.google.dev/gemma/docs/gemma-3n},]{.underline}

[publisher={Google DeepMind},]{.underline}

[author={Gemma Team},]{.underline}

[year={2025}]{.underline}

[}]{.underline}

## [Model Data]{.underline}

[Data used for model training and how the data was
processed.]{.underline}

### [Training Dataset]{.underline}

[These models were trained on a dataset that includes a wide variety of
sources totalling approximately 11 trillion tokens. The knowledge cutoff
date for the training data was June 2024. Here are the key
components:]{.underline}

-   [**Web Documents**: A diverse collection of web text ensures the
    > model is exposed to a broad range of linguistic styles, topics,
    > and vocabulary. The training dataset includes content in over 140
    > languages.]{.underline}

-   [**Code**: Exposing the model to code helps it to learn the syntax
    > and patterns of programming languages, which improves its ability
    > to generate code and understand code-related
    > questions.]{.underline}

-   [**Mathematics**: Training on mathematical text helps the model
    > learn logical reasoning, symbolic representation, and to address
    > mathematical queries.]{.underline}

-   [**Images**: A wide range of images enables the model to perform
    > image analysis and visual data extraction tasks.]{.underline}

-   [Audio: A diverse set of sound samples enables the model to
    > recognize speech, transcribe text from recordings, and identify
    > information in audio data.]{.underline}

[The combination of these diverse data sources is crucial for training a
powerful multimodal model that can handle a wide variety of different
tasks and data formats.]{.underline}

### [Data Preprocessing]{.underline}

[Here are the key data cleaning and filtering methods applied to the
training data:]{.underline}

-   [**CSAM Filtering**: Rigorous CSAM (Child Sexual Abuse Material)
    > filtering was applied at multiple stages in the data preparation
    > process to ensure the exclusion of harmful and illegal
    > content.]{.underline}

-   [**Sensitive Data Filtering**: As part of making Gemma pre-trained
    > models safe and reliable, automated techniques were used to filter
    > out certain personal information and other sensitive data from
    > training sets.]{.underline}

-   [**Additional methods**: Filtering based on content quality and
    > safety in line with [our
    > policies](https://ai.google/static/documents/ai-responsibility-update-published-february-2025.pdf).]{.underline}

## [Implementation Information]{.underline}

[Details about the model internals.]{.underline}

### [Hardware]{.underline}

[Gemma was trained using [Tensor Processing Unit
(TPU)](https://cloud.google.com/tpu/docs/intro-to-tpu) hardware (TPUv4p,
TPUv5p and TPUv5e). Training generative models requires significant
computational power. TPUs, designed specifically for matrix operations
common in machine learning, offer several advantages in this
domain:]{.underline}

-   [**Performance**: TPUs are specifically designed to handle the
    > massive computations involved in training generative models. They
    > can speed up training considerably compared to CPUs.]{.underline}

-   [**Memory**: TPUs often come with large amounts of high-bandwidth
    > memory, allowing for the handling of large models and batch sizes
    > during training. This can lead to better model
    > quality.]{.underline}

-   [**Scalability**: TPU Pods (large clusters of TPUs) provide a
    > scalable solution for handling the growing complexity of large
    > foundation models. You can distribute training across multiple TPU
    > devices for faster and more efficient processing.]{.underline}

-   [**Cost-effectiveness**: In many scenarios, TPUs can provide a more
    > cost-effective solution for training large models compared to
    > CPU-based infrastructure, especially when considering the time and
    > resources saved due to faster training.]{.underline}

[These advantages are aligned with [Google\'s commitments to operate
sustainably](https://sustainability.google/operating-sustainably/).]{.underline}

### [Software]{.underline}

[Training was done using [JAX](https://github.com/jax-ml/jax) and [ML
Pathways](https://blog.google/technology/ai/introducing-pathways-next-generation-ai-architecture/).
JAX allows researchers to take advantage of the latest generation of
hardware, including TPUs, for faster and more efficient training of
large models. ML Pathways is Google\'s latest effort to build
artificially intelligent systems capable of generalizing across multiple
tasks. This is specially suitable for foundation models, including large
language models like these ones.]{.underline}

[Together, JAX and ML Pathways are used as described in the [paper about
the Gemini family of models](https://goo.gle/gemma2report): *\"the
\'single controller\' programming model of Jax and Pathways allows a
single Python process to orchestrate the entire training run,
dramatically simplifying the development workflow.\"*]{.underline}

## [Evaluation]{.underline}

[Model evaluation metrics and results.]{.underline}

### [Benchmark Results]{.underline}

[These models were evaluated at full precision (float32) against a large
collection of different datasets and metrics to cover different aspects
of content generation. Evaluation results marked with **IT** are for
instruction-tuned models. Evaluation results marked with **PT** are for
pre-trained models.]{.underline}

#### [Reasoning and factuality]{.underline}

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [Benchmark]{.underline}                                                                  [Metric]{.underline}     [n-shot]{.underline}     [E2B PT]{.underline} [E4B PT]{.underline}
  ---------------------------------------------------------------------------------------- ------------------------ ------------------------ -------------------- --------------------
  [[HellaSwag]{.underline}](https://arxiv.org/abs/1905.07830)                              [Accuracy]{.underline}   [10-shot]{.underline}    [72.2]{.underline}   [78.6]{.underline}

  [[BoolQ]{.underline}](https://arxiv.org/abs/1905.10044)                                  [Accuracy]{.underline}   [0-shot]{.underline}     [76.4]{.underline}   [81.6]{.underline}

  [[PIQA]{.underline}](https://arxiv.org/abs/1911.11641)                                   [Accuracy]{.underline}   [0-shot]{.underline}     [78.9]{.underline}   [81.0]{.underline}

  [[SocialIQA]{.underline}](https://arxiv.org/abs/1904.09728)                              [Accuracy]{.underline}   [0-shot]{.underline}     [48.8]{.underline}   [50.0]{.underline}

  [[TriviaQA]{.underline}](https://arxiv.org/abs/1705.03551)                               [Accuracy]{.underline}   [5-shot]{.underline}     [60.8]{.underline}   [70.2]{.underline}

  [[Natural                                                                                [Accuracy]{.underline}   [5-shot]{.underline}     [15.5]{.underline}   [20.9]{.underline}
  Questions]{.underline}](https://github.com/google-research-datasets/natural-questions)                                                                          

  [[ARC-c]{.underline}](https://arxiv.org/abs/1911.01547)                                  [Accuracy]{.underline}   [25-shot]{.underline}    [51.7]{.underline}   [61.6]{.underline}

  [[ARC-e]{.underline}](https://arxiv.org/abs/1911.01547)                                  [Accuracy]{.underline}   [0-shot]{.underline}     [75.8]{.underline}   [81.6]{.underline}

  [[WinoGrande]{.underline}](https://arxiv.org/abs/1907.10641)                             [Accuracy]{.underline}   [5-shot]{.underline}     [66.8]{.underline}   [71.7]{.underline}

  [[BIG-Bench Hard]{.underline}](https://paperswithcode.com/dataset/bbh)                   [Accuracy]{.underline}   [few-shot]{.underline}   [44.3]{.underline}   [52.9]{.underline}

  [[DROP]{.underline}](https://arxiv.org/abs/1903.00161)                                   [Token F1                [1-shot]{.underline}     [53.9]{.underline}   [60.8]{.underline}
                                                                                           score]{.underline}                                                     
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### [Multilingual]{.underline}

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [Benchmark]{.underline}                                                               [Metric]{.underline}     [n-shot]{.underline}   [E2B IT]{.underline} [E4B IT]{.underline}
  ------------------------------------------------------------------------------------- ------------------------ ---------------------- -------------------- --------------------
  [[MGSM]{.underline}](https://arxiv.org/abs/2210.03057)                                [Accuracy]{.underline}   [0-shot]{.underline}   [53.1]{.underline}   [60.7]{.underline}

  [[WMT24++](https://arxiv.org/abs/2502.12404v1) (ChrF)]{.underline}                    [Character-level         [0-shot]{.underline}   [42.7]{.underline}   [50.1]{.underline}
                                                                                        F-score]{.underline}                                                 

  [[Include]{.underline}](https://arxiv.org/abs/2411.19799)                             [Accuracy]{.underline}   [0-shot]{.underline}   [38.6]{.underline}   [57.2]{.underline}

  [[MMLU](https://arxiv.org/abs/2009.03300) (ProX)]{.underline}                         [Accuracy]{.underline}   [0-shot]{.underline}   [8.1]{.underline}    [19.9]{.underline}

  [[OpenAI MMLU]{.underline}](https://huggingface.co/datasets/openai/MMMLU)             [Accuracy]{.underline}   [0-shot]{.underline}   [22.3]{.underline}   [35.6]{.underline}

  [[Global-MMLU]{.underline}](https://huggingface.co/datasets/CohereLabs/Global-MMLU)   [Accuracy]{.underline}   [0-shot]{.underline}   [55.1]{.underline}   [60.3]{.underline}

  [[ECLeKTic]{.underline}](https://arxiv.org/abs/2502.21228)                            [ECLeKTic                [0-shot]{.underline}   [2.5]{.underline}    [1.9]{.underline}
                                                                                        score]{.underline}                                                   
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### [STEM and code]{.underline}

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [Benchmark]{.underline}                                              [Metric]{.underline}                     [n-shot]{.underline}   [E2B IT]{.underline} [E4B IT]{.underline}
  -------------------------------------------------------------------- ---------------------------------------- ---------------------- -------------------- --------------------
  [[GPQA](https://arxiv.org/abs/2311.12022) Diamond]{.underline}       [RelaxedAccuracy/accuracy]{.underline}   [0-shot]{.underline}   [24.8]{.underline}   [23.7]{.underline}

  [[LiveCodeBench](https://arxiv.org/abs/2403.07974) v5]{.underline}   [pass@1]{.underline}                     [0-shot]{.underline}   [18.6]{.underline}   [25.7]{.underline}

  [Codegolf v2.2]{.underline}                                          [pass@1]{.underline}                     [0-shot]{.underline}   [11.0]{.underline}   [16.8]{.underline}

  [[AIME                                                               [Accuracy]{.underline}                   [0-shot]{.underline}   [6.7]{.underline}    [11.6]{.underline}
  2025]{.underline}](https://www.vals.ai/benchmarks/aime-2025-05-09)                                                                                        
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### [Additional benchmarks]{.underline}

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [Benchmark]{.underline}                                                                          [Metric]{.underline}     [n-shot]{.underline}   [E2B IT]{.underline} [E4B IT]{.underline}
  ------------------------------------------------------------------------------------------------ ------------------------ ---------------------- -------------------- --------------------
  [[MMLU]{.underline}](https://arxiv.org/abs/2009.03300)                                           [Accuracy]{.underline}   [0-shot]{.underline}   [60.1]{.underline}   [64.9]{.underline}

  [[MBPP]{.underline}](https://arxiv.org/abs/2108.07732)                                           [pass@1]{.underline}     [3-shot]{.underline}   [56.6]{.underline}   [63.6]{.underline}

  [[HumanEval]{.underline}](https://arxiv.org/abs/2107.03374)                                      [pass@1]{.underline}     [0-shot]{.underline}   [66.5]{.underline}   [75.0]{.underline}

  [[LiveCodeBench]{.underline}](https://arxiv.org/abs/2403.07974)                                  [pass@1]{.underline}     [0-shot]{.underline}   [13.2]{.underline}   [13.2]{.underline}

  [HiddenMath]{.underline}                                                                         [Accuracy]{.underline}   [0-shot]{.underline}   [27.7]{.underline}   [37.7]{.underline}

  [[Global-MMLU-Lite]{.underline}](https://huggingface.co/datasets/CohereForAI/Global-MMLU-Lite)   [Accuracy]{.underline}   [0-shot]{.underline}   [59.0]{.underline}   [64.5]{.underline}

  [[MMLU](https://arxiv.org/abs/2009.03300) (Pro)]{.underline}                                     [Accuracy]{.underline}   [0-shot]{.underline}   [40.5]{.underline}   [50.6]{.underline}
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## [Ethics and Safety]{.underline}

[Ethics and safety evaluation approach and results.]{.underline}

### [Evaluation Approach]{.underline}

[Our evaluation methods include structured evaluations and internal
red-teaming testing of relevant content policies. Red-teaming was
conducted by a number of different teams, each with different goals and
human evaluation metrics. These models were evaluated against a number
of different categories relevant to ethics and safety,
including:]{.underline}

-   [**Child Safety**: Evaluation of text-to-text and image to text
    > prompts covering child safety policies, including child sexual
    > abuse and exploitation.]{.underline}

-   [**Content Safety:** Evaluation of text-to-text and image to text
    > prompts covering safety policies including, harassment, violence
    > and gore, and hate speech.]{.underline}

-   [**Representational Harms**: Evaluation of text-to-text and image to
    > text prompts covering safety policies including bias,
    > stereotyping, and harmful associations or
    > inaccuracies.]{.underline}

[In addition to development level evaluations, we conduct \"assurance
evaluations\" which are our \'arms-length\' internal evaluations for
responsibility governance decision making. They are conducted separately
from the model development team, to inform decision making about
release. High level findings are fed back to the model team, but prompt
sets are held-out to prevent overfitting and preserve the results\'
ability to inform decision making. Notable assurance evaluation results
are reported to our Responsibility & Safety Council as part of release
review.]{.underline}

### [Evaluation Results]{.underline}

[For all areas of safety testing, we saw safe levels of performance
across the categories of child safety, content safety, and
representational harms relative to previous Gemma models. All testing
was conducted without safety filters to evaluate the model capabilities
and behaviors. For text-to-text, image-to-text, and audio-to-text, and
across all model sizes, the model produced minimal policy violations,
and showed significant improvements over previous Gemma models\'
performance with respect to high severity violations. A limitation of
our evaluations was they included primarily English language
prompts.]{.underline}

## [Usage and Limitations]{.underline}

[These models have certain limitations that users should be aware
of.]{.underline}

### [Intended Usage]{.underline}

[Open generative models have a wide range of applications across various
industries and domains. The following list of potential uses is not
comprehensive. The purpose of this list is to provide contextual
information about the possible use-cases that the model creators
considered as part of model training and development.]{.underline}

-   [Content Creation and Communication]{.underline}

    -   [**Text Generation**: Generate creative text formats such as
        > poems, scripts, code, marketing copy, and email
        > drafts.]{.underline}

    -   [**Chatbots and Conversational AI**: Power conversational
        > interfaces for customer service, virtual assistants, or
        > interactive applications.]{.underline}

    -   [**Text Summarization**: Generate concise summaries of a text
        > corpus, research papers, or reports.]{.underline}

    -   [**Image Data Extraction**: Extract, interpret, and summarize
        > visual data for text communications.]{.underline}

    -   [**Audio Data Extraction**: Transcribe spoken language,
        > translate speech to text in other languages, and analyze
        > sound-based data.]{.underline}

-   [Research and Education]{.underline}

    -   [**Natural Language Processing (NLP) and generative model
        > Research**: These models can serve as a foundation for
        > researchers to experiment with generative models and NLP
        > techniques, develop algorithms, and contribute to the
        > advancement of the field.]{.underline}

    -   [**Language Learning Tools**: Support interactive language
        > learning experiences, aiding in grammar correction or
        > providing writing practice.]{.underline}

    -   [**Knowledge Exploration**: Assist researchers in exploring
        > large bodies of data by generating summaries or answering
        > questions about specific topics.]{.underline}

### [Limitations]{.underline}

-   [Training Data]{.underline}

    -   [The quality and diversity of the training data significantly
        > influence the model\'s capabilities. Biases or gaps in the
        > training data can lead to limitations in the model\'s
        > responses.]{.underline}

    -   [The scope of the training dataset determines the subject areas
        > the model can handle effectively.]{.underline}

-   [Context and Task Complexity]{.underline}

    -   [Models are better at tasks that can be framed with clear
        > prompts and instructions. Open-ended or highly complex tasks
        > might be challenging.]{.underline}

    -   [A model\'s performance can be influenced by the amount of
        > context provided (longer context generally leads to better
        > outputs, up to a certain point).]{.underline}

-   [Language Ambiguity and Nuance]{.underline}

    -   [Natural language is inherently complex. Models might struggle
        > to grasp subtle nuances, sarcasm, or figurative
        > language.]{.underline}

-   [Factual Accuracy]{.underline}

    -   [Models generate responses based on information they learned
        > from their training datasets, but they are not knowledge
        > bases. They may generate incorrect or outdated factual
        > statements.]{.underline}

-   [Common Sense]{.underline}

    -   [Models rely on statistical patterns in language. They might
        > lack the ability to apply common sense reasoning in certain
        > situations.]{.underline}

### [Ethical Considerations and Risks]{.underline}

[The development of generative models raises several ethical concerns.
In creating an open model, we have carefully considered the
following:]{.underline}

-   [Bias and Fairness]{.underline}

    -   [Generative models trained on large-scale, real-world text and
        > image data can reflect socio-cultural biases embedded in the
        > training material. These models underwent careful scrutiny,
        > input data pre-processing described and posterior evaluations
        > reported in this card.]{.underline}

-   [Misinformation and Misuse]{.underline}

    -   [Generative models can be misused to generate text that is
        > false, misleading, or harmful.]{.underline}

    -   [Guidelines are provided for responsible use with the model, see
        > the [Responsible Generative AI
        > Toolkit](https://ai.google.dev/responsible).]{.underline}

-   [Transparency and Accountability:]{.underline}

    -   [This model card summarizes details on the models\'
        > architecture, capabilities, limitations, and evaluation
        > processes.]{.underline}

    -   [A responsibly developed open model offers the opportunity to
        > share innovation by making generative model technology
        > accessible to developers and researchers across the AI
        > ecosystem.]{.underline}

[Risks identified and mitigations:]{.underline}

-   [**Perpetuation of biases**: It\'s encouraged to perform continuous
    > monitoring (using evaluation metrics, human review) and the
    > exploration of de-biasing techniques during model training,
    > fine-tuning, and other use cases.]{.underline}

-   [**Generation of harmful content**: Mechanisms and guidelines for
    > content safety are essential. Developers are encouraged to
    > exercise caution and implement appropriate content safety
    > safeguards based on their specific product policies and
    > application use cases.]{.underline}

-   [**Misuse for malicious purposes**: Technical limitations and
    > developer and end-user education can help mitigate against
    > malicious applications of generative models. Educational resources
    > and reporting mechanisms for users to flag misuse are provided.
    > Prohibited uses of Gemma models are outlined in the [Gemma
    > Prohibited Use
    > Policy](https://ai.google.dev/gemma/prohibited_use_policy).]{.underline}

-   [**Privacy violations**: Models were trained on data filtered for
    > removal of certain personal information and other sensitive data.
    > Developers are encouraged to adhere to privacy regulations with
    > privacy-preserving techniques.]{.underline}

### [Benefits]{.underline}

[At the time of release, this family of models provides high-performance
open generative model implementations designed from the ground up for
responsible AI development compared to similarly sized
models.]{.underline}

[Using the benchmark evaluation metrics described in this document,
these models have shown to provide superior performance to other,
comparably-sized open model alternatives.]{.underline}
