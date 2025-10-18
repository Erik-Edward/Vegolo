# Gemma 3 vs. Gemma 3n Tokenizer Details

## Gemma 3 Tokenizer

-   **Tokenizer Artifact & Download:** Gemma 3 uses a SentencePiece
    model (often named `tokenizer.model`) of \~4.7 MB defining a \~256k
    vocabulary[\[1\]](https://goo.gle/Gemma3Report#:~:text=to%20Gemma%202%2C%20with%20some,models%2C%20while%20introducing%20image%20understanding)[\[2\]](https://huggingface.co/google/gemma-3-1b-it/tree/main#:~:text=33,42).
    The official tokenizer file is provided by Google (e.g. via Google
    Cloud Storage at
    `gs://gemma-data/tokenizers/tokenizer_gemma3.model`[\[3\]](https://gemma-llm.readthedocs.io/en/latest/api/gm/text/Gemma3Tokenizer.html#:~:text=class%20gemma))
    and is also included in the Hugging Face model repo (e.g.
    `google/gemma-3-1b-it`)[\[2\]](https://huggingface.co/google/gemma-3-1b-it/tree/main#:~:text=33,42).
    You can download it from the Gemma 3 Hugging Face repository after
    accepting the license.

-   **Special Tokens:** The SentencePiece vocabulary reserves standard
    special tokens: `<pad>` (ID 0), `<eos>` (ID 1), `<bos>` (ID 2),
    `<unk>` (ID 3), and `<mask>`
    (ID 4)[\[4\]](https://medium.com/@manyi.yim/in-depth-understanding-of-google-gemma-tokenizer-7d7e3d4fe202#:~:text=Let%27s%20go%20over%20some%20important,mask%3E%27%3A%204).
    Gemma 3 also defines tokens for dialogue and multimodal prompts,
    including `<start_of_turn>` and `<end_of_turn>` (used to delimit
    user/model turns in instruction-tuned chat
    models)[\[5\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_turn%3E%60%20%2F%20%60%3Cend_of_turn%3E%60),
    as well as `<start_of_image>` (used in text to mark an image
    insertion
    point)[\[6\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_image%3E%60).
    *(Note:* `<end_of_image>` exists but is handled internally by the
    model[\[6\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_image%3E%60).)
    Additionally, \~99 unused token IDs are reserved for custom use
    (appearing as `<unused0>` ... `<unused98>` if
    needed)[\[7\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=Custom%20tokens).
    The model expects one `<bos>` at the beginning of an input and may
    generate `<eos>` to signal
    completion[\[8\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cbos%3E%60%20%2F%20%60%3Ceos%3E%60)[\[9\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=Similarly%2C%20the%20model%20can%20output,indicate%20the%20prediction%20is%20complete).

-   **Unicode Normalization & Preprocessing:** The tokenizer applies
    SentencePiece's default normalization. Specifically, it performs
    NFKC-based unicode normalization (using the "nmt_nfkc"
    rule)[\[10\]](https://github.com/google/sentencepiece#:~:text=GitHub%20github.com%20%20NFKC,a%20software%2Falgorithm%2C%20one%20can)
    -- e.g. characters with compatibility forms are normalized -- and it
    converts newline characters to spaces (to avoid breaking text
    context) as part of that rule. The tokenizer **preserves case and
    whitespace**: spaces are treated as significant (they become part of
    tokens) and text is not
    lowercased[\[11\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=,underground%27%2C%20%27%20city%27%2C).
    For example, `" hello"` (with a leading space) and `"hello"`
    tokenize to different
    IDs[\[12\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=One%20thing%20to%20notice%20is,to%202%20different%20token%20ids).
    No whitespace trimming is done, so users should avoid unintended
    leading/trailing spaces in prompts to prevent odd tokens (e.g. a
    trailing space would become an extra
    token)[\[13\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=would%20make%20the%20out%20of,distribution).

-   **Maximum Sequence Length:** Gemma 3 supports very long contexts.
    The 1B parameter variant (used in on-device inference) has a
    **32,768 token** input context
    window[\[14\]](https://huggingface.co/blog/gemma3#:~:text=Pre%20Trained%20Instruction%20Tuned%20Multimodal,it%20%E2%9C%85%20%2B140%20languages%20128K).
    Larger Gemma 3 models (4B, 12B, 27B) are built for **131,072 tokens
    (128K)** of
    context[\[14\]](https://huggingface.co/blog/gemma3#:~:text=Pre%20Trained%20Instruction%20Tuned%20Multimodal,it%20%E2%9C%85%20%2B140%20languages%20128K).
    (These longer contexts are enabled by the model's interleaved
    local/global attention
    design[\[15\]](https://developers.googleblog.com/en/gemma-explained-whats-new-in-gemma-3/#:~:text=As%20a%20result%20of%20the,128k%20tokens%20for%20larger%20models).)
    The tokenizer itself can produce sequences up to those lengths, and
    the MediaPipe GenAI runtime requires configuring `maxTokens` to
    exactly the model's context
    length[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=Low,is%20only%20available%20for%20Web).

-   **Overlength Prompt Handling:** If an input prompt exceeds the
    model's context limit, the system will **truncate** it to the
    maximum supported length. In practice, frameworks enforce the
    model's context window: any excess tokens beyond the limit are
    silently discarded (truncated) so that the sequence
    fits[\[17\]](https://www.reddit.com/r/ollama/comments/1jbifhz/what_happens_if_context_length_is_set_larger_than/#:~:text=1,at%20its%20maximum%20supported%20limit).
    In other words, Gemma 3 will only attend to the last *N* tokens
    within its 32k/128k window and ignore or drop earlier tokens beyond
    that. It's recommended to proactively trim prompts to the max length
    to avoid losing prompt content. (Exceeding the limit may
    alternatively raise an error in some libraries, but truncation is
    the typical
    behavior[\[17\]](https://www.reddit.com/r/ollama/comments/1jbifhz/what_happens_if_context_length_is_set_larger_than/#:~:text=1,at%20its%20maximum%20supported%20limit).)

-   **Version/Commit Reference:** Official Gemma 3 support was added in
    Hugging Face *Transformers* around version 4.50.0 (initially via a
    special branch `v4.49.0-Gemma-3` for early
    access[\[18\]](https://huggingface.co/blog/gemma3#:~:text=Gemma%203%20comes%20with%20day,stable%20release%20of%20Gemma%203)).
    The Gemma 3 1B model and tokenizer are distributed openly under
    Google's Gemma
    license[\[19\]](https://huggingface.co/google/gemma-3n-E2B-it-litert-lm#:~:text=Access%20Gemma%20on%20Hugging%20Face),
    and the tokenizer is the *same* one used for Google's internal
    "Gemini 2.0"
    model[\[1\]](https://goo.gle/Gemma3Report#:~:text=to%20Gemma%202%2C%20with%20some,models%2C%20while%20introducing%20image%20understanding).
    (The Gemma 3 technical report confirms the vocabulary is \~256k
    tokens drawn from that
    tokenizer[\[1\]](https://goo.gle/Gemma3Report#:~:text=to%20Gemma%202%2C%20with%20some,models%2C%20while%20introducing%20image%20understanding).)
    When using MediaPipe's LiteRT-LM, the `.task` bundle for Gemma 3
    includes this tokenizer model embedded alongside the TFLite model.

## Gemma 3n Tokenizer (E2B / E4B)

-   **Tokenizer Artifact & Download:** Gemma 3n (Effective 2B and 4B
    models) uses **the same SentencePiece tokenizer as Gemma 3**. There
    is no new vocabulary for 3n -- it leverages Gemma3's 256k-entry
    tokenizer to maintain multilingual
    coverage[\[1\]](https://goo.gle/Gemma3Report#:~:text=to%20Gemma%202%2C%20with%20some,models%2C%20while%20introducing%20image%20understanding).
    The tokenizer `.model` file for Gemma 3n is identical to Gemma 3's
    (≈4.70 MB), and is provided with the Gemma 3n model checkpoints. For
    example, the Hugging Face repos `google/gemma-3n-e2b-it` and
    `...-e4b-it` include the `tokenizer.model` (the file size matches
    Gemma3's, confirming it's
    reused)[\[20\]](https://www.kaggle.com/code/danielhanchen/gemma-3n-4b-multimodal-finetuning-inference#:~:text=...%20gemma,4.70M%2F4.70M%20%5B00%3A01%3C00%3A00%2C%20157kB%2Fs).
    Developers can download it from those repositories (after agreeing
    to the license) or use the Hugging Face API to load the tokenizer
    directly (via
    `AutoTokenizer.from_pretrained("google/gemma-3n-e4b-it")`).

-   **Special Tokens:** Gemma 3n's tokenizer has the **same special
    tokens** set as described above for Gemma 3. All IDs and token
    strings for `<pad>`, `<eos>`, `<bos>`, `<unk>`, `<mask>` and the
    control tokens remain consistent across Gemma variants. In
    particular, 3n's instruction-tuned models use
    `<start_of_turn>`/`<end_of_turn>` around dialogue turns just like
    Gemma 3[\[5\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_turn%3E%60%20%2F%20%60%3Cend_of_turn%3E%60),
    and use `<start_of_image>` to denote image inputs in multimodal
    prompts[\[6\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_image%3E%60).
    (Gemma 3n models also accept audio/video, but these modalities are
    handled via the same textual placeholders -- e.g. an audio segment
    might be inserted with an internal tag, though no separate special
    token string like `<audio>` was introduced publicly.) The key point
    is that a prompt formatted for Gemma 3 (with the appropriate special
    tokens) will tokenize identically under Gemma 3n's tokenizer.

-   **Unicode Normalization & Preprocessing:** Because the tokenizer is
    shared, **the normalization rules are identical to Gemma 3's**.
    Input text is processed with NFKC-like normalization (default
    SentencePiece normalization, including mapping newlines to
    spaces)[\[10\]](https://github.com/google/sentencepiece#:~:text=GitHub%20github.com%20%20NFKC,a%20software%2Falgorithm%2C%20one%20can).
    Case, punctuation, and spacing are preserved as in Gemma 3. This
    consistency ensures that Gemma 3n can understand the same wide range
    of languages and scripts. (The Gemma 3n models were trained on the
    same multilingual tokenization; e.g. they cover 140+ languages using
    this
    vocab[\[21\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=Description),
    with improved encoding of CJK scripts as inherited from the Gemini
    2.0
    tokenizer[\[22\]](https://developers.googleblog.com/en/gemma-explained-whats-new-in-gemma-3/#:~:text=Gemma%203%20also%20introduces%20an,English%20languages).)

-   **Maximum Sequence Length:** All Gemma 3n variants support a
    **32,768 token** context window for input, matching the smaller
    Gemma 3
    models[\[23\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=,a%20summary%20of%20a%20document).
    (Unlike base Gemma 3, the 3n models do *not* use 128k context, as
    they prioritize efficiency on device. The official docs list "32K
    token context" as a feature of
    Gemma 3n[\[24\]](https://ai.google.dev/gemma/docs/gemma-3n#:~:text=resources.%20Learn%20more%20,data%20and%20handling%20processing%20tasks)[\[23\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=,a%20summary%20of%20a%20document).)
    The *output* length for generation is also effectively capped by the
    same window -- e.g. one can get up to 32k total tokens output, minus
    input
    length[\[25\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=,subtracting%20the%20request%20input%20tokens).
    This long context is enabled by 3n's architecture (which shares the
    sliding-window attention scheme of Gemma 3). In practice, developers
    should set the `max_new_tokens`/`maxTokens` in their pipelines such
    that input + output ≤ 32k tokens for Gemma 3n.

-   **Overlength Prompt Handling:** If a prompt longer than 32k tokens
    is given to Gemma 3n, the behavior is the same as Gemma 3 -- the
    tokenizer/model will **truncate any tokens beyond the 32k limit**.
    The MediaPipe LLM Inference API, for example, will not accept a
    bundle configured with a larger context, and if more tokens are
    provided, the excess are dropped to stay within the model's
    context[\[17\]](https://www.reddit.com/r/ollama/comments/1jbifhz/what_happens_if_context_length_is_set_larger_than/#:~:text=1,at%20its%20maximum%20supported%20limit).
    This means prompts should be curated or trimmed beforehand. There
    isn't a "rejection" of overlength input (no special error token);
    instead the input is clipped to 32k silently in most
    implementations[\[17\]](https://www.reddit.com/r/ollama/comments/1jbifhz/what_happens_if_context_length_is_set_larger_than/#:~:text=1,at%20its%20maximum%20supported%20limit).

-   **Version/Commit Reference:** Gemma 3n became available mid-2025 and
    is supported in *Transformers* as of version
    **4.53.0**[\[26\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=Below%2C%20there%20are%20some%20code,0).
    (Ensure you have transformers v4.53+ to use
    `Gemma3nForConditionalGeneration` and the associated
    processor[\[27\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=Below%2C%20there%20are%20some%20code,0).)
    The Hugging Face model cards for Gemma 3n E2B/E4B confirm the
    context size and multimodal
    capabilities[\[23\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=,a%20summary%20of%20a%20document).
    In Google's on-device pipeline (LiteRT-LM), Gemma 3n is packaged as
    a `.litertlm` with the tokenizer included, so developers converting
    the model should supply the same `tokenizer.model` when
    bundling[\[28\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=1,file%20and%20the%20model%20tokenizer)[\[29\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=tokenizer_model%3DTOKENIZER_MODEL%2C%20start_token%3DSTART_TOKEN%2C%20stop_tokens%3DSTOP_TOKENS%2C%20output_filename%3DOUTPUT_FILENAME%2C%20enable_bytes_to_unicode_mapping%3DENABLE_BYTES_TO_UNICODE_MAPPING%2C,create_bundle%28config).
    The Gemma 3n release was closely tied to Google's efficient
    inference efforts (MatFormer, PLE, etc.), but importantly from a
    tokenization standpoint, **no changes were made to the tokenizer
    between Gemma 3 and 3n** -- they share the exact commit/version of
    the SentencePiece model for tokenization.

**Sources:** Gemma 3 blog (Google
Developers)[\[22\]](https://developers.googleblog.com/en/gemma-explained-whats-new-in-gemma-3/#:~:text=Gemma%203%20also%20introduces%20an,English%20languages);
Gemma 3 technical
report[\[1\]](https://goo.gle/Gemma3Report#:~:text=to%20Gemma%202%2C%20with%20some,models%2C%20while%20introducing%20image%20understanding);
Google AI Developers
documentation[\[24\]](https://ai.google.dev/gemma/docs/gemma-3n#:~:text=resources.%20Learn%20more%20,data%20and%20handling%20processing%20tasks)[\[23\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=,a%20summary%20of%20a%20document);
Gemma Tokenizer
tutorial[\[5\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_turn%3E%60%20%2F%20%60%3Cend_of_turn%3E%60)[\[6\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_image%3E%60);
Hugging Face Gemma model
cards[\[30\]](https://huggingface.co/google/gemma-3-1b-it#:~:text=,Output)[\[26\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=Below%2C%20there%20are%20some%20code,0);
Reddit LLM discussion (on context
truncation)[\[17\]](https://www.reddit.com/r/ollama/comments/1jbifhz/what_happens_if_context_length_is_set_larger_than/#:~:text=1,at%20its%20maximum%20supported%20limit);
SentencePiece GitHub
(normalization)[\[10\]](https://github.com/google/sentencepiece#:~:text=GitHub%20github.com%20%20NFKC,a%20software%2Falgorithm%2C%20one%20can).

[\[1\]](https://goo.gle/Gemma3Report#:~:text=to%20Gemma%202%2C%20with%20some,models%2C%20while%20introducing%20image%20understanding)
goo.gle

<https://goo.gle/Gemma3Report>

[\[2\]](https://huggingface.co/google/gemma-3-1b-it/tree/main#:~:text=33,42)
google/gemma-3-1b-it at main

<https://huggingface.co/google/gemma-3-1b-it/tree/main>

[\[3\]](https://gemma-llm.readthedocs.io/en/latest/api/gm/text/Gemma3Tokenizer.html#:~:text=class%20gemma)
gm.text.Gemma3Tokenizer --- gemma

<https://gemma-llm.readthedocs.io/en/latest/api/gm/text/Gemma3Tokenizer.html>

[\[4\]](https://medium.com/@manyi.yim/in-depth-understanding-of-google-gemma-tokenizer-7d7e3d4fe202#:~:text=Let%27s%20go%20over%20some%20important,mask%3E%27%3A%204)
In-depth understanding of Google Gemma Tokenizer - Medium

<https://medium.com/@manyi.yim/in-depth-understanding-of-google-gemma-tokenizer-7d7e3d4fe202>

[\[5\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_turn%3E%60%20%2F%20%60%3Cend_of_turn%3E%60)
[\[6\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cstart_of_image%3E%60)
[\[7\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=Custom%20tokens)
[\[8\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=%60%3Cbos%3E%60%20%2F%20%60%3Ceos%3E%60)
[\[9\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=Similarly%2C%20the%20model%20can%20output,indicate%20the%20prediction%20is%20complete)
[\[11\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=,underground%27%2C%20%27%20city%27%2C)
[\[12\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=One%20thing%20to%20notice%20is,to%202%20different%20token%20ids)
[\[13\]](https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html#:~:text=would%20make%20the%20out%20of,distribution)
Tokenizer --- gemma

<https://gemma-llm.readthedocs.io/en/latest/colab_tokenizer.html>

[\[10\]](https://github.com/google/sentencepiece#:~:text=GitHub%20github.com%20%20NFKC,a%20software%2Falgorithm%2C%20one%20can)
google/sentencepiece: Unsupervised text tokenizer for \... - GitHub

<https://github.com/google/sentencepiece>

[\[14\]](https://huggingface.co/blog/gemma3#:~:text=Pre%20Trained%20Instruction%20Tuned%20Multimodal,it%20%E2%9C%85%20%2B140%20languages%20128K)
[\[18\]](https://huggingface.co/blog/gemma3#:~:text=Gemma%203%20comes%20with%20day,stable%20release%20of%20Gemma%203)
Welcome Gemma 3: Google\'s all new multimodal, multilingual, long
context open LLM

<https://huggingface.co/blog/gemma3>

[\[15\]](https://developers.googleblog.com/en/gemma-explained-whats-new-in-gemma-3/#:~:text=As%20a%20result%20of%20the,128k%20tokens%20for%20larger%20models)
[\[22\]](https://developers.googleblog.com/en/gemma-explained-whats-new-in-gemma-3/#:~:text=Gemma%203%20also%20introduces%20an,English%20languages)
Gemma explained: What's new in Gemma 3 - Google Developers Blog

<https://developers.googleblog.com/en/gemma-explained-whats-new-in-gemma-3/>

[\[16\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=Low,is%20only%20available%20for%20Web)
[\[28\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=1,file%20and%20the%20model%20tokenizer)
[\[29\]](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference#:~:text=tokenizer_model%3DTOKENIZER_MODEL%2C%20start_token%3DSTART_TOKEN%2C%20stop_tokens%3DSTOP_TOKENS%2C%20output_filename%3DOUTPUT_FILENAME%2C%20enable_bytes_to_unicode_mapping%3DENABLE_BYTES_TO_UNICODE_MAPPING%2C,create_bundle%28config)
LLM Inference guide  \|  Google AI Edge  \|  Google AI for Developers

<https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference>

[\[17\]](https://www.reddit.com/r/ollama/comments/1jbifhz/what_happens_if_context_length_is_set_larger_than/#:~:text=1,at%20its%20maximum%20supported%20limit)
What happens if Context Length is set larger than the Model supports? :
r/ollama

<https://www.reddit.com/r/ollama/comments/1jbifhz/what_happens_if_context_length_is_set_larger_than/>

[\[19\]](https://huggingface.co/google/gemma-3n-E2B-it-litert-lm#:~:text=Access%20Gemma%20on%20Hugging%20Face)
google/gemma-3n-E2B-it-litert-lm · Hugging Face

<https://huggingface.co/google/gemma-3n-E2B-it-litert-lm>

[\[20\]](https://www.kaggle.com/code/danielhanchen/gemma-3n-4b-multimodal-finetuning-inference#:~:text=...%20gemma,4.70M%2F4.70M%20%5B00%3A01%3C00%3A00%2C%20157kB%2Fs)
Gemma 3N 4B Multimodal finetuning + inference - Kaggle

<https://www.kaggle.com/code/danielhanchen/gemma-3n-4b-multimodal-finetuning-inference>

[\[21\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=Description)
[\[23\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=,a%20summary%20of%20a%20document)
[\[25\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=,subtracting%20the%20request%20input%20tokens)
[\[26\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=Below%2C%20there%20are%20some%20code,0)
[\[27\]](https://huggingface.co/google/gemma-3n-E4B#:~:text=Below%2C%20there%20are%20some%20code,0)
google/gemma-3n-E4B · Hugging Face

<https://huggingface.co/google/gemma-3n-E4B>

[\[24\]](https://ai.google.dev/gemma/docs/gemma-3n#:~:text=resources.%20Learn%20more%20,data%20and%20handling%20processing%20tasks)
Gemma 3n model overview  \|  Google AI for Developers

<https://ai.google.dev/gemma/docs/gemma-3n>

[\[30\]](https://huggingface.co/google/gemma-3-1b-it#:~:text=,Output)
google/gemma-3-1b-it · Hugging Face

<https://huggingface.co/google/gemma-3-1b-it>
