[\`\`\`]{.underline}

[2025-03-]{.underline}

[\`\`\`]{.underline}

[\# Gemma 3 Technical Report]{.underline}

[\`\`\`]{.underline}

[Gemma Team, Google DeepMind\^1]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[We introduce Gemma 3, a multimodal addition to the Gemma family of
lightweight open models, ranging]{.underline}

[in scale from 1 to 27 billion parameters. This version introduces
vision understanding abilities, a wider]{.underline}

[coverage of languages and longer context -- at least 128K tokens. We
also change the architecture of]{.underline}

[the model to reduce the KV-cache memory that tends to explode with long
context. This is achieved by]{.underline}

[increasing the ratio of local to global attention layers, and keeping
the span on local attention short.]{.underline}

[The Gemma 3 models are trained with distillation and achieve superior
performance to Gemma 2]{.underline}

[for both pre-trained and instruction finetuned versions. In particular,
our novel post-training recipe]{.underline}

[significantly improves the math, chat, instruction-following and
multilingual abilities, making Gemma3-]{.underline}

[4B-IT competitive with Gemma2-27B-IT and Gemma3-27B-IT comparable to
Gemini-1.5-Pro across]{.underline}

[benchmarks. We release all our models to the community.]{.underline}

[\`\`\`]{.underline}

[\## 1. Introduction]{.underline}

[\`\`\`]{.underline}

[We present the newest version of Gemma open]{.underline}

[language models (Gemma Team, 2024a), co-]{.underline}

[designed with the family of Gemini frontier mod-]{.underline}

[els (Gemini Team, 2023). This new version]{.underline}

[comes in sizes comparable to Gemma 2 (Gemma]{.underline}

[Team, 2024b), with the addition of a 1B model.]{.underline}

[These models are designed to run on standard]{.underline}

[consumer-grade hardware such as phones, lap-]{.underline}

[tops, and high-end GPUs. This version comes]{.underline}

[with several new abilities to the Gemma family;]{.underline}

[namely, multimodality, long context, and mul-]{.underline}

[tilinguality, while preserving or surpassing the]{.underline}

[performance of prior versions.]{.underline}

[In terms of multimodality, most Gemma 3 mod-]{.underline}

[els are compatible with a tailored version of the]{.underline}

[SigLIP vision encoder (Zhai et al., 2023). The]{.underline}

[language models treat images as a sequence of]{.underline}

[soft tokens encoded by SigLIP. We reduce the in-]{.underline}

[ference cost of image processing by condensing]{.underline}

[the vision embeddings into a fixed size of 256]{.underline}

[vectors. The encoder works at a fixed resolution]{.underline}

[and we take inspiration from LLaVA (Liu et al.,]{.underline}

[2024) to enable flexible resolutions with a Pan]{.underline}

[and Scan (P&S) method.]{.underline}

[The second main architectural improvement is]{.underline}

[an increase in context size to 128K tokens, with-]{.underline}

[out reducing performance. A challenge with long]{.underline}

[context is the memory explosion of the KV cache]{.underline}

[during inference. To reduce this issue, we inter-]{.underline}

[leave multiple local layers between each global]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[layer, and assign a smaller span of only 1024]{.underline}

[tokens to the local layers. Therefore, only the]{.underline}

[global layers attend to long context, and we have]{.underline}

[1 global for every 5 local layers.]{.underline}

[The pre-training optimization recipe is similar]{.underline}

[to Gemma 2, with some modifications in the ar-]{.underline}

[chitecture design. We use the same tokenizer as]{.underline}

[Gemini 2.0, and we also revisit our data mixture]{.underline}

[to improve the multilingual capabilities of the]{.underline}

[models, while introducing image understanding.]{.underline}

[All Gemma 3 models are trained with knowledge]{.underline}

[distillation (Hinton et al., 2015).]{.underline}

[In post-training, we focus our efforts on im-]{.underline}

[proving mathematics, reasoning, and chat abili-]{.underline}

[ties, as well as integrating the new capabilities of]{.underline}

[Gemma 3, long-context, and image inputs. We]{.underline}

[use a novel post-training approach that brings]{.underline}

[gains across all capabilities, including math, cod-]{.underline}

[ing, chat, instruction following, and multilingual.]{.underline}

[The resulting Gemma 3 instruction-tuned models]{.underline}

[are both powerful and versatile, outperforming]{.underline}

[their predecessors by a wide margin.]{.underline}

[In the following sections, we provide a brief]{.underline}

[overview of our models, including the architec-]{.underline}

[ture and pre- and post-training recipes. We also]{.underline}

[provide detailed evaluations across a wide vari-]{.underline}

[ety of quantitative and qualitative benchmarks.]{.underline}

[We discuss our approach to safe and responsible]{.underline}

[deployment and outline the broader implications]{.underline}

[of Gemma 3, its limitations, and advantages.]{.underline}

[\`\`\`]{.underline}

[(\^1) See Contributions and Acknowledgments section for full author
list. Please send correspondence
togemma-3-report@google.com.]{.underline}

[©2025 Google DeepMind. All rights reserved]{.underline}

[\## arXiv:2503.19786v1 \[cs.CL\] 25 Mar 2025]{.underline}

[\`\`\`]{.underline}

[Figure 1 \|Example of visual interaction with]{.underline}

[Gemma 3 27B IT model.]{.underline}

[\`\`\`]{.underline}

[\## 2. Model Architecture]{.underline}

[Gemma 3 models follow the same general]{.underline}

[decoder-only transformer architecture as previ-]{.underline}

[ous iterations (Vaswani et al., 2017), with most]{.underline}

[architecture elements similar to the first two]{.underline}

[Gemma versions. We use a Grouped-Query Atten-]{.underline}

[tion (GQA) (Ainslie et al., 2023) with post-norm]{.underline}

[and pre-norm with RMSNorm (Zhang and Sen-]{.underline}

[nrich, 2019). Inspired by Dehghani et al. (2023),]{.underline}

[Wortsman et al. (2023) and Chameleon Team]{.underline}

[(2024), we replace the soft-capping of Gemma 2]{.underline}

[with QK-norm. In this section, we focus on some]{.underline}

[key differences from previous versions below.]{.underline}

[\*\*5:1 interleaving of local/global layers.\*\* We]{.underline}

[alternate between a local sliding window self-]{.underline}

[attention (Beltagy et al., 2020) and global self-]{.underline}

[\`\`\`]{.underline}

[Model Vision]{.underline}

[Encoder]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Embedding]{.underline}

[Parameters]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Non-embedding]{.underline}

[Parameters]{.underline}

[1B 0 302M 698M]{.underline}

[4B 417M 675M 3,209M]{.underline}

[12B 417M 1,012M 10,759M]{.underline}

[27B 417M 1,416M 25,600M]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Table 1\|Parameter counts for the Gemma 3 mod-]{.underline}

[els. Our vocabulary has 256k entries.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[attention (Luong et al., 2015), with a pattern of]{.underline}

[5 local layers for every global layer, starting with]{.underline}

[a local layer as the first layer of the model.]{.underline}

[Long context. Gemma 3 models support context]{.underline}

[length of 128K tokens, with the exception of the]{.underline}

[1B model that has 32K. We increase RoPE base]{.underline}

[frequency from 10k to 1M on global self-attention]{.underline}

[layers, and keep the frequency of the local lay-]{.underline}

[ers at 10k. We follow a process similar to the]{.underline}

[positional interpolation of Chen et al. (2023) to]{.underline}

[extend the span of the global self-attention layers.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[2.1. Vision modality]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Vision encoder. We use a 400M variant of the]{.underline}

[SigLIP encoder (Zhai et al., 2023), a Vision Trans-]{.underline}

[former (Dosovitskiy, 2020) trained with a varia-]{.underline}

[tion of the CLIP loss (Radford et al., 2021). The]{.underline}

[Gemma vision encoder takes as input square im-]{.underline}

[ages resized to 896 x 896, and is finetuned on]{.underline}

[data from visual assistant tasks. For simplicity, we]{.underline}

[share the vision encoder across our 4B, 12B, and]{.underline}

[27B models, keeping it frozen during training.]{.underline}

[Pan & Scan (P&S). The Gemma vision encoder]{.underline}

[operates at a fixed resolution of 896×896. This]{.underline}

[results in artifacts when processing non-square]{.underline}

[aspect ratios and high-resolution images, leading]{.underline}

[to unreadable text, or small objects disappearing.]{.underline}

[We address this issue with an adaptive windowing]{.underline}

[algorithm during inference. This algorithm seg-]{.underline}

[ments images into non-overlapping crops of equal]{.underline}

[size, covering the whole image, and resize them]{.underline}

[to 896×896 pixels to pass them to the encoder.]{.underline}

[This windowing is applied only when necessary,]{.underline}

[and control for the maximum number of crops.]{.underline}

[It is an inference-time only optimization and can]{.underline}

[be disabled for faster inference.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Shards]{.underline}

[Model Type #Chips Data Seq. Replica]{.underline}

[1B TPUv5e 512 16 16 2]{.underline}

[4B TPUv5e 2048 16 16 8]{.underline}

[12B TPUv4 6144 16 16 24]{.underline}

[27B TPUv5p 6144 24 8 32]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Table 2\|Training infrastructure with sharding by]{.underline}

[data, sequence (Seq.), and replica.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[2.2. Pre-training]{.underline}

[\`\`\`]{.underline}

[We follow a similar recipe as in Gemma 2 for]{.underline}

[pre-training with knowledge distillation.]{.underline}

[\*\*Training data.\*\* We pre-train our models on a]{.underline}

[slightly larger token budget than Gemma 2, i.e.,]{.underline}

[we train on 14T tokens for Gemma 3 27B, 12T]{.underline}

[for the 12B version, 4T for the 4B, and 2T to-]{.underline}

[kens for the 1B. The increase in tokens accounts]{.underline}

[for the mix of images and text used during pre-]{.underline}

[training. We also increase the amount of multi-]{.underline}

[lingual data to improve language coverage. We]{.underline}

[add both monolingual and parallel data, and we]{.underline}

[handle the imbalance in language representation]{.underline}

[using a strategy inspired by Chung et al. (2023).]{.underline}

[\*\*Tokenizer.\*\* We use the same tokenizer as Gem-]{.underline}

[ini 2.0: a SentencePiece tokenizer with split dig-]{.underline}

[its, preserved whitespace, and byte-level encod-]{.underline}

[ings (Kudo and Richardson, 2018). The resulting]{.underline}

[vocabulary has 262k entries. This tokenizer is]{.underline}

[more balanced for non-English languages.]{.underline}

[\*\*Filtering.\*\* We use filtering techniques that reduce]{.underline}

[the risk of unwanted or unsafe utterances and]{.underline}

[remove certain personal information and other]{.underline}

[sensitive data. We decontaminate evaluation sets]{.underline}

[from our pre-training data mixture, and reduce]{.underline}

[the risk of recitation by minimizing the prolifer-]{.underline}

[ation of sensitive outputs. We also apply a qual-]{.underline}

[ity reweighing step inspired by Sachdeva et al.]{.underline}

[(2024) to reduce occurrences of low quality data.]{.underline}

[\`\`\`]{.underline}

[Distillation. We sample 256 logits per token,]{.underline}

[weighted by teacher probabilities. The student]{.underline}

[learns the teacher's distribution within these sam-]{.underline}

[ples via cross-entropy loss. The teacher's target]{.underline}

[distribution is set to zero probability for non-]{.underline}

[sampled logits, and renormalized.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Raw (GB) Quantized (GB)]{.underline}

[Model bf16 Int4 Int4blocks=32 SFP]{.underline}

[1B 2.0 0.5 0.7 1.]{.underline}

[+KV 2.9 1.4 1.6 1.]{.underline}

[4B 8.0 2.6 2.9 4.]{.underline}

[+KV 12.7 7.3 7.6 9.]{.underline}

[12B 24.0 6.6 7.1 12.]{.underline}

[+KV 38.9 21.5 22.0 27.]{.underline}

[27B 54.0 14.1 15.3 27.]{.underline}

[+KV 72.7 32.8 34.0 46.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Table 3\|Memory footprints (in GB) comparison]{.underline}

[between raw (bfloat16) and quantized check-]{.underline}

[points for weights and KV caching (+KV) at]{.underline}

[32,768 context size, quantized in 8 bits.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[2.3. Quantization Aware Training]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Along with the raw checkpoints, we also provide]{.underline}

[quantized versions of our models in different stan-]{.underline}

[dard formats. These versions are obtained by fine-]{.underline}

[tuning each model for a small number of steps,]{.underline}

[typically 5,000, using Quantization Aware Train-]{.underline}

[ing (QAT) (Jacob et al., 2018). We use prob-]{.underline}

[abilities from the non-quantized checkpoint as]{.underline}

[targets, and adapt the data to match the pre-]{.underline}

[training and post-training distributions. Based]{.underline}

[on the most popular open source quantization]{.underline}

[inference engines (e.g. llama.cpp), we focus on]{.underline}

[three weight representations: per-channel int4,]{.underline}

[per-block int4, and switched fp8. In Table 3, we]{.underline}

[report the memory filled by raw and quantized]{.underline}

[models for each weight representation with and]{.underline}

[without a KV-cache for a sequence of 32k tokens.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[2.4. Compute Infrastructure]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[We train our models with TPUv4, TPUv5e, and]{.underline}

[TPUv5p as outlined in Table 2. Each model con-]{.underline}

[figuration is optimized to minimize training step]{.underline}

[time. For the vision encoder, we pre-compute]{.underline}

[the embeddings for each image and directly train]{.underline}

[with the embeddings, adding no cost to the train-]{.underline}

[ing of the language models.]{.underline}

[The optimizer state is sharded using an im-]{.underline}

[plementation of ZeRO-3 (Ren et al., 2021). For]{.underline}

[multi-pod training, we perform a data replica re-]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Context Formatting]{.underline}

[User turn \<start_of_turn\>user]{.underline}

[Model turn \<start_of_turn\>model]{.underline}

[End of turn \<end_of_turn\>]{.underline}

[Example of discussion:]{.underline}

[User: Who are you?]{.underline}

[Model: My name is Gemma!]{.underline}

[User: What is 2+2?]{.underline}

[Model: 2+2=4.]{.underline}

[Model input:]{.underline}

[\[BOS\]\<start_of_turn\>user]{.underline}

[Who are you?\<end_of_turn\>]{.underline}

[\<start_of_turn\>model]{.underline}

[My name is Gemma!\<end_of_turn\>]{.underline}

[\<start_of_turn\>user]{.underline}

[What is 2+2?\<end_of_turn\>]{.underline}

[\<start_of_turn\>model]{.underline}

[Model output:]{.underline}

[2+2=4.\<end_of_turn\>]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Table 4\|Formatting for Gemma IT models. Explic-]{.underline}

[\`\`\`]{.underline}

[\### itly add the\[BOS\]token after tokenization, or]{.underline}

[\### use theadd_bos=Trueoption in the tokenizer.]{.underline}

[\`\`\`]{.underline}

[Do not tokenize the text \"\[BOS\]\".]{.underline}

[\`\`\`]{.underline}

[duction over the data center network, using the]{.underline}

[Pathways approach of Barham et al. (2022). We]{.underline}

[use the 'single controller' programming paradigm]{.underline}

[of Jax (Roberts et al., 2023) and Pathways]{.underline}

[(Barham et al., 2022), along with the GSPMD]{.underline}

[partitioner (Xu et al., 2021) and the MegaScale]{.underline}

[XLA compiler (XLA, 2019).]{.underline}

[\## 3. Instruction-Tuning]{.underline}

[\`\`\`]{.underline}

[Pre-trained models are turned into instruction-]{.underline}

[tuned models with an improved post-training ap-]{.underline}

[proach compared to our prior recipe (see Table 6).]{.underline}

[Techniques. Our post-training approach relies]{.underline}

[on an improved version of knowledge distilla-]{.underline}

[tion (Agarwal et al., 2024; Anil et al., 2018; Hin-]{.underline}

[ton et al., 2015) from a large IT teacher, along]{.underline}

[with a RL finetuning phase based on improved ver-]{.underline}

[sions of BOND (Sessa et al., 2024), WARM (Ramé]{.underline}

[et al., 2024b), and WARP (Ramé et al., 2024a).]{.underline}

[Reinforcement learning objectives. We use]{.underline}

[a variety of reward functions to improve help-]{.underline}

[fulness, math, coding, reasoning, instruction-]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[following, and multilingual abilities, while mini-]{.underline}

[mizing model harmfulness. This includes learn-]{.underline}

[ing from weight averaged reward models (Ramé]{.underline}

[et al., 2024b) trained with human feedback data,]{.underline}

[code execution feedback (Gehring et al., 2024),]{.underline}

[and ground-truth rewards for solving math prob-]{.underline}

[lems (DeepSeek-AI, 2025; Lambert et al., 2024).]{.underline}

[Data filtering. We carefully optimize the data]{.underline}

[used in post-training to maximize model perfor-]{.underline}

[mance. We filter examples that show certain per-]{.underline}

[sonal information, unsafe or toxic model outputs,]{.underline}

[mistaken self-identification data, and duplicated]{.underline}

[examples. Including subsets of data that encour-]{.underline}

[age better in-context attribution, hedging, and]{.underline}

[refusals to minimize hallucinations also improves]{.underline}

[performance on factuality metrics, without de-]{.underline}

[grading model performance on other metrics.]{.underline}

[\[BOS\] token. For both PT and IT models, text]{.underline}

[\`\`\`]{.underline}

[\### starts with a\[BOS\]token, that needs to be added]{.underline}

[\`\`\`]{.underline}

[explicitly since the text "\[BOS\]" does not map to]{.underline}

[\`\`\`]{.underline}

[\### the\[BOS\]token. For instance, Flax has an option,]{.underline}

[\### add_bos=True, to add this token automatically]{.underline}

[\`\`\`]{.underline}

[when tokenizing. An example of the formatting]{.underline}

[for an IT model is shown in Table 4,]{.underline}

[PT versus IT Formatting. All models share the]{.underline}

[same tokenizer, with some control tokens dedi-]{.underline}

[cated to IT formatting. A key difference is that PT]{.underline}

[\`\`\`]{.underline}

[\### models output a\<eos\>token at the end of gener-]{.underline}

[\### ation, while IT models output a\<end_of_turn\>]{.underline}

[\`\`\`]{.underline}

[at the end of the generation, as shown for IT in]{.underline}

[Table 4. Fine-tuning either model type thus also]{.underline}

[requires adding their respective end tokens.]{.underline}

[\`\`\`]{.underline}

[\## 4. Evaluation of final models]{.underline}

[\`\`\`]{.underline}

[In this section, we evaluate the IT models over]{.underline}

[a series of automated benchmarks and human]{.underline}

[evaluations across a variety of domains, as well]{.underline}

[as static benchmarks such as MMLU.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[4.1. LMSYS Chatbot Arena]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[In this section, we report the performance of our]{.underline}

[IT 27B model on LMSys Chatbot Arena (Chiang]{.underline}

[et al., 2024) in blind side-by-side evaluations by]{.underline}

[human raters against other state-of-the-art mod-]{.underline}

[els. We report Elo scores in Table 5. Gemma 3 27B]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Rank Model Elo 95% CI Open Type #params/#activated]{.underline}

[1 Grok-3-Preview-02-24 1412 +8/-10 - - -]{.underline}

[1 GPT-4.5-Preview 1411 +11/-11 - - -]{.underline}

[3 Gemini-2.0-Flash-Thinking-Exp-01-21 1384 +6/-5 - - -]{.underline}

[3 Gemini-2.0-Pro-Exp-02-05 1380 +5/-6 - - -]{.underline}

[3 ChatGPT-4o-latest (2025-01-29) 1377 +5/-4 - - -]{.underline}

[6 DeepSeek-R1 1363 +8/-6 yes MoE 671B/37B]{.underline}

[6 Gemini-2.0-Flash-001 1357 +6/-5 - - -]{.underline}

[8 o1-2024-12-17 1352 +4/-6 - - -]{.underline}

[9 Gemma-3-27B-IT 1338 +8/-9 yes Dense 27B]{.underline}

[9 Qwen2.5-Max 1336 +7/-5 - - -]{.underline}

[9 o1-preview 1335 +4/-3 - - -]{.underline}

[9 o3-mini-high 1329 +8/-6 - - -]{.underline}

[13 DeepSeek-V3 1318 +8/-6 yes MoE 671B/37B]{.underline}

[14 GLM-4-Plus-0111 1311 +8/-8 - - -]{.underline}

[14 Qwen-Plus-0125 1310 +7/-5 - - -]{.underline}

[14 Claude 3.7 Sonnet 1309 +9/-11 - - -]{.underline}

[14 Gemini-2.0-Flash-Lite 1308 +5/-5 - - -]{.underline}

[18 Step-2-16K-Exp 1305 +7/-6 - - -]{.underline}

[18 o3-mini 1304 +5/-4 - - -]{.underline}

[18 o1-mini 1304 +4/-3 - - -]{.underline}

[18 Gemini-1.5-Pro-002 1302 +3/-3 - - -]{.underline}

[\...]{.underline}

[28 Meta-Llama-3.1-405B-Instruct-bf16 1269 +4/-3 yes Dense
405B]{.underline}

[\...]{.underline}

[38 Llama-3.3-70B-Instruct 1257 +5/-3 yes Dense 70B]{.underline}

[\...]{.underline}

[39 Qwen2.5-72B-Instruct 1257 +3/-3 yes Dense 72B]{.underline}

[\...]{.underline}

[59 Gemma-2-27B-it 1220 +3/-2 yes Dense 27B]{.underline}

[\`\`\`]{.underline}

[Table 5\|Evaluation of Gemma 3 27B IT model in the Chatbot Arena
(Chiang et al., 2024). All the]{.underline}

[models are evaluated against each other through blind side-by-side
evaluations by human raters. Each]{.underline}

[model is attributed a score, based on the Elo rating system.
\_Gemma-3-27B-IT numbers are preliminary]{.underline}

[results received on March 8, 2025\_.]{.underline}

[IT (1338) is among the top 10 best models, with a]{.underline}

[score above other non-thinking open models, such]{.underline}

[as DeepSeek-V3 (1318), LLaMA 3 405B (1257),]{.underline}

[and Qwen2.5-70B (1257), which are much larger]{.underline}

[models. Finally, the Elo of Gemma 3 is signifi-]{.underline}

[cantly higher than Gemma 2, at 1220. Note that]{.underline}

[Elo scores do not take into account visual abilities,]{.underline}

[which none of the aforementioned models have.]{.underline}

[\*\*4.2. Standard benchmarks\*\*]{.underline}

[In Table 6, we show the performance of our final]{.underline}

[models across a variety of benchmarks compared]{.underline}

[to our previous model iteration, and Gemini 1.5.]{.underline}

[We do not compare directly with external models]{.underline}

[that often report their own evaluation settings,]{.underline}

[since running them in our setting does not guaran-]{.underline}

[tee a fair comparison. We encourage the reader to]{.underline}

[\`\`\`]{.underline}

[follow third-party static leaderboards for a fairer]{.underline}

[comparison across models. We include additional]{.underline}

[evaluations of our models on other benchmarks]{.underline}

[in the appendix.]{.underline}

[\`\`\`]{.underline}

[\## 5. Ablations]{.underline}

[\`\`\`]{.underline}

[In this section, we focus on the impact of our]{.underline}

[architecture changes, as well as some of the vision]{.underline}

[abilities new to this model.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[5.1. Pre-training ability probing]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[We use several standard benchmarks as probes]{.underline}

[during pre-training to ensure our models capture]{.underline}

[general abilities, and in Figure 2, we compare the]{.underline}

[quality of pre-trained models from Gemma 2 and]{.underline}

[3 across these general abilities, namely, science,]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Gemini 1.5 Gemini 2.0 Gemma 2 Gemma 3]{.underline}

[Flash Pro Flash Pro 2B 9B 27B 1B 4B 12B 27B]{.underline}

[MMLU-Pro 67.3 75.8 77.6 79.1 15.6 46.8 56.9 14.7 43.6 60.6
67.]{.underline}

[LiveCodeBench 30.7 34.2 34.5 36.0 1.2 10.8 20.4 1.9 12.6 24.6
29.]{.underline}

[Bird-SQL (dev) 45.6 54.4 58.7 59.3 12.2 33.8 46.7 6.4 36.3 47.9
54.]{.underline}

[GPQA Diamond 51.0 59.1 60.1 64.7 24.7 28.8 34.3 19.2 30.8 40.9
42.]{.underline}

[SimpleQA 8.6 24.9 29.9 44.3 2.8 5.3 9.2 2.2 4.0 6.3 10.]{.underline}

[FACTS Grounding 82.9 80.0 84.6 82.8 43.8 62.0 62.4 36.4 70.1 75.8
74.]{.underline}

[Global MMLU-Lite 73.7 80.8 83.4 86.5 41.9 64.8 68.6 34.2 54.5 69.5
75.]{.underline}

[MATH 77.9 86.5 90.9 91.8 27.2 49.4 55.6 48.0 75.6 83.8 89.]{.underline}

[HiddenMath 47.2 52.0 63.5 65.2 1.8 10.4 14.8 15.8 43.0 54.5
60.]{.underline}

[MMMU (val) 62.3 65.9 71.7 72.7 - - - - 48.8 59.6 64.]{.underline}

[\`\`\`]{.underline}

[Table 6\|Performance of instruction fine-tuned (IT) models compared to
Gemini 1.5, Gemini 2.0, and]{.underline}

[Gemma 2 on zero-shot benchmarks across different
abilities.]{.underline}

[Figure 2\|Summary of the performance of different pre-trained models
from Gemma 2 and 3 across]{.underline}

[general abilities. These plots are meant to give a simplified summary
and details are in the appendix.]{.underline}

[code, factuality, multilinguality, reasoning, and]{.underline}

[vision. The details of the performance across the]{.underline}

[different public benchmarks used in these plots]{.underline}

[are summarized in the appendix. Overall, we see]{.underline}

[that the new versions improve in most categories,]{.underline}

[despite the addition of vision. We particularly]{.underline}

[focus on multilinguality in this version, and this]{.underline}

[directly impacts the quality of our models. How-]{.underline}

[ever, despite the use of decontamination tech-]{.underline}

[niques, there is always a risk of contamination]{.underline}

[of these probes (Mirzadeh et al., 2024), making]{.underline}

[more definitive conclusions harder to assess.]{.underline}

[\*\*5.2. Local:Global attention layers\*\*]{.underline}

[We measure the impact of changes to local and]{.underline}

[global self-attention layers on performance and]{.underline}

[memory consumption during inference.]{.underline}

[\*\*Local:Global ratio.\*\* In Fig. 3, we compare differ-]{.underline}

[\`\`\`]{.underline}

[1:1 3:1 5:1 7:]{.underline}

[Local:Global]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Perplexity]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[2B]{.underline}

[9B]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Figure 3\| Impact of Local:Global ratio on the]{.underline}

[perplexity on a validation set. The impact is mini-]{.underline}

[mal, even with 7-to-1 local to global. This ablation]{.underline}

[is run with text-only models.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[ent ratios of local to global attention layers. 1:]{.underline}

[is used in Gemma 2 models, and 5:1 is used in]{.underline}

[Gemma 3. We observe minimal impact on per-]{.underline}

[plexity when changing this ratio.]{.underline}

[Sliding window size. In Fig. 4, we compare]{.underline}

[different sliding window sizes for the local at-]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[tention layers in different global:local ratio con-]{.underline}

[figurations. The sliding window can be reduced]{.underline}

[significantly without impacting perplexity.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[512 1024 2048 4096]{.underline}

[Sliding Window]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Perplexity 2B L:G=1:]{.underline}

[2B L:G=3:]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Figure 4\| Impact of Sliding Window size on per-]{.underline}

[plexity measured on a validation set. We consider]{.underline}

[2 2B models, with 1:1 and 1:3 local to global layer]{.underline}

[ratios. This ablation is run with text-only models.]{.underline}

[\`\`\`]{.underline}

[\*\*Impact on KV cache memory.\*\* In Fig. 5, we show]{.underline}

[the balance between the memory used by the]{.underline}

[model and the KV cache during inference with a]{.underline}

[context of 32k tokens. The "global only" configu-]{.underline}

[ration is the standard configuration used across]{.underline}

[most dense models. The "1:1, sw=4096" is used]{.underline}

[in Gemma 2. We observe that the "global only"]{.underline}

[configuration results in a memory overhead of]{.underline}

[60%, while this is reduced to less than 15% with]{.underline}

[1:3 and sliding windows of 1024 ("sw=1024").]{.underline}

[In Fig. 6, we compute the memory used by the]{.underline}

[KV cache as a function of the context length with]{.underline}

[either our 2B architecture (L:G=5:1, sw=1024)]{.underline}

[versus a "global only" 2B model.]{.underline}

[(\^0) global only 1:1, sw=4096 1:1 sw=1024 1:3 sw=4096 1:3
sw=]{.underline}

[1000]{.underline}

[2000]{.underline}

[3000]{.underline}

[4000]{.underline}

[5000]{.underline}

[Inference memory (MB)]{.underline}

[model]{.underline}

[kv cache]{.underline}

[Figure 5\| \*\*Model versus KV cache memory\*\* dur-]{.underline}

[ing inference with a pre-fill KV cache of size 32k.]{.underline}

[We consider a 2B model with different local to]{.underline}

[global ratios and sliding window sizes (sw). We]{.underline}

[compare to global only, which is the standard]{.underline}

[used in Gemma 1 and Llama. This ablation is run]{.underline}

[with a text-only model.]{.underline}

[\*\*5.3. Enabling long context\*\*]{.underline}

[Instead of training with 128K sequences from]{.underline}

[scratch, we pre-train our models with 32K se-]{.underline}

[1K 4K 8K 16K 32K 64K128K]{.underline}

[Context length]{.underline}

[0]{.underline}

[2000]{.underline}

[4000]{.underline}

[6000]{.underline}

[KV Cache memory (MB)]{.underline}

[2B L:G=5:1, sw=]{.underline}

[2B global only]{.underline}

[Figure 6\| \*\*KV cache memory versus context]{.underline}

[length.\*\* We show the memory usage of the KV]{.underline}

[cache for our architecture (L:G=5:1, sw=1024)]{.underline}

[and a transformer with global attention only -- as]{.underline}

[used in LLaMa or Gemma 1.]{.underline}

[quences and then scale the 4B, 12B, and 27B mod-]{.underline}

[els up to 128K tokens at the end of pre-training]{.underline}

[while rescaling RoPE (Chen et al., 2023). We]{.underline}

[find a scaling factor of 8 to work well in practice.]{.underline}

[Note that compared to Gemma 2, we have also]{.underline}

[increased the RoPE base frequency of global self-]{.underline}

[attention layers from 10k to 1M, while keeping]{.underline}

[10k for the local self-attention layers. In Figure 7,]{.underline}

[we show the impact on perplexity for different]{.underline}

[context lengths. Our models generalize to 128K,]{.underline}

[but rapidly degrade as we continue to scale.]{.underline}

[Figure 7 \| \*\*Long context\*\* performance of pre-]{.underline}

[trained models before and after RoPE rescaling.]{.underline}

[\*\*5.4. Small versus large teacher\*\*]{.underline}

[A common finding is that, to train a small model,]{.underline}

[it is preferable to distill from a smaller teacher.]{.underline}

[\`\`\`]{.underline}

[101 102]{.underline}

[Total training tokens (B)]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Perplexity]{.underline}

[\`\`\`]{.underline}

[Figure 8\| \*\*Small versus large teacher.\*\* Relative]{.underline}

[difference of perplexity when using a small and]{.underline}

[large teacher as a function of the token size of]{.underline}

[training. Smaller numbers means distilling from]{.underline}

[a larger teacher is better.]{.underline}

[We suspect this is because these studies are often]{.underline}

[performed in settings where the regularization ef-]{.underline}

[fect of using a worse teacher surpasses the benefit]{.underline}

[of using a better teacher. We train a student with]{.underline}

[2 teachers of different sizes, one large and one]{.underline}

[small, for different training horizons. In Fig. 8,]{.underline}

[we observe that for short training horizons, the]{.underline}

[smaller teacher is better, but the trend is reversed]{.underline}

[for longer training.]{.underline}

[\*\*5.5. Vision encoder\*\*]{.underline}

[\`\`\`]{.underline}

[Resolution DocVQA InfoVQA TextVQA]{.underline}

[256 31.9 23.1 44.]{.underline}

[448 45.4 31.6 53.]{.underline}

[896 59.8 33.7 58.]{.underline}

[\`\`\`]{.underline}

[Table 7\| \*\*Impact of image encoder input reso-]{.underline}

[lution.\*\* We measure performance using a short]{.underline}

[schedule 2B Gemma model on a few evaluation]{.underline}

[benchmarks to observe the effect of input image]{.underline}

[resolution on vision encoder pre-training.]{.underline}

[\*\*Impact of image resolution.\*\* We use a vision]{.underline}

[encoder based on SigLIP (Zhai et al., 2023). The]{.underline}

[vision encoder is frozen, and only the language]{.underline}

[model is trained. Each image in this multimodal]{.underline}

[data is represented by 256 image tokens from]{.underline}

[the respective vision encoder. The higher resolu-]{.underline}

[tion encoders thus use average pooling to reduce]{.underline}

[their output to 256 tokens. For instance, the 896]{.underline}

[\`\`\`]{.underline}

[resolution encoder has a 4x4 average pooling on]{.underline}

[its output. As shown in Table 7, higher resolution]{.underline}

[encoders perform better than smaller ones.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[DocVQA InfoVQA TextVQA]{.underline}

[4B 72.8 44.1 58.]{.underline}

[4B w/ P&S 81.0 57.0 60.]{.underline}

[Δ (+8.2) (+12.9) (+1.9)]{.underline}

[27B 85.6 59.4 68.]{.underline}

[27B w/ P&S 90.4 76.4 70.]{.underline}

[Δ (+4.8) (+17.0) (+1.6)]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Table 8\| Impact of P&S. 4-shot evaluation re-]{.underline}

[sults on the valid set, with and without P&S on a]{.underline}

[pre-trained checkpoint. Boosts are on tasks asso-]{.underline}

[ciated with images with varying aspect ratios, or]{.underline}

[involving reading text on images.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Pan & Scan. P&S enables capturing images at]{.underline}

[close to their native aspect ratio and image reso-]{.underline}

[lution. In Table 8, we compare our 27B IT model]{.underline}

[with and without P&S. As expected, the ability]{.underline}

[to treat images with close to native resolution]{.underline}

[greatly helps with tasks that require some form]{.underline}

[of reading text on images, which is particularly]{.underline}

[important for visual language models.]{.underline}

[\`\`\`]{.underline}

[\## 6. Memorization and Privacy]{.underline}

[\`\`\`]{.underline}

[Large language models may produce near-copies]{.underline}

[of some text used in training (Biderman et al.,]{.underline}

[2023; Carlini et al., 2021, 2022; Ippolito et al.,]{.underline}

[2022; Nasr et al., 2023). Several prior reports]{.underline}

[have released audits that quantify this risk by]{.underline}

[measuring the memorization rate (Anil et al.,]{.underline}

[2023; Chowdhery et al., 2022; Gemini Team,]{.underline}

[2023, 2024; Gemma Team, 2024a,b; LLaMa]{.underline}

[Team, 2024). This "memorization rate"\^1 is de-]{.underline}

[fined as the ratio of generations from the model]{.underline}

[that match its training data compared to all model]{.underline}

[generations using the following setup. We fol-]{.underline}

[low the methodology described in Gemma Team]{.underline}

[\`\`\`]{.underline}

[(\^1) \"We do not state or imply \[here\] that a model
\"contains\"]{.underline}

[its training data in the sense that there is a copy of that
data]{.underline}

[in the model. Rather, a model memorizes attributes of its]{.underline}

[training data such that in certain cases it is statistically
able]{.underline}

[to generate such training data when following rules and]{.underline}

[using information about features of its training data that
it]{.underline}

[does contain.\"]{.underline}

[\`\`\`]{.underline}

[Gemma 31BGemma 34BGemma 312BGemma 327B Gemma 2 2BGemma 2 9BGemma 2
27BGemini 1.5FlashGemma2BGemma7B]{.underline}

[PaLMSmall]{.underline}

[Model]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[0.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[1]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[10]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[% Memorized]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Total Memorization Rate]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[ExactMemorization TypeApproximate]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Figure 9\|Total memorization rates for both ex-]{.underline}

[act and approximate memorization. Gemma 3]{.underline}

[models memorize significantly less than all prior]{.underline}

[models. \*No results for approximate memoriza-]{.underline}

[tion on these models.]{.underline}

[\`\`\`]{.underline}

[(2024b) to measure it. Specifically, we subsam-]{.underline}

[ple a large portion of training data distributed]{.underline}

[uniformly across different corpora and test for]{.underline}

[discoverable extraction (Nasr et al., 2023) of this]{.underline}

[content using a prefix of length 50 and a suffix of]{.underline}

[length 50. We denote text as either "exactly mem-]{.underline}

[orized" if all tokens in the continuation match]{.underline}

[the source suffix or "approximately memorized"]{.underline}

[if they match up to an edit distance of 10%.]{.underline}

[Figure 9 compares the memorization rates]{.underline}

[across Gemma and Gemini models; these models]{.underline}

[are ordered in reverse chronological order, with]{.underline}

[the newest Gemma 3 models on the left. We find]{.underline}

[that Gemma 3 models memorize long-form text]{.underline}

[at a much lower rate than prior models (note the]{.underline}

[log y-axis). We observe only a marginal differ-]{.underline}

[ence in the memorization rates between the 4B,]{.underline}

[12B, and 27B models, with 1B memorizing less]{.underline}

[than these larger models. Further, we find that a]{.underline}

[larger proportion of text is characterized as ap-]{.underline}

[proximately memorized, with a relative increase]{.underline}

[in approximate memorization compared to exact]{.underline}

[memorization of roughly 24x on average.]{.underline}

[We also study the rate at which the generations]{.underline}

[may contain personal information. To identify po-]{.underline}

[tentially personal information, we use the Google]{.underline}

[Cloud Sensitive Data Protection (SDP) service.\^2]{.underline}

[SDP uses broad detection rules to identify text]{.underline}

[that may contain personal information. SDP is]{.underline}

[(\^2) https://cloud.google.com/sensitive-data-protection]{.underline}

[designed to have high recall and does not con-]{.underline}

[sider the context in which the information may]{.underline}

[appear, which leads to many false positives. Thus,]{.underline}

[we are likely overestimating the true amount of]{.underline}

[potentially personal information contained in the]{.underline}

[outputs classified as memorized. SDP also pro-]{.underline}

[vides broad severity levels: low, medium, and]{.underline}

[high. We classify text as personal if SDP clas-]{.underline}

[sifies it as personal information at any severity]{.underline}

[level. We observed no personal information in]{.underline}

[the outputs characterized as memorization for all]{.underline}

[Gemma 3 models. This indicates a low rate of]{.underline}

[personal data, below our detection thresholds, in]{.underline}

[outputs classified as memorization.]{.underline}

[\## 7. Responsibility, Safety, Security]{.underline}

[\`\`\`]{.underline}

[Responsibility, safety, and security are of utmost]{.underline}

[importance in the development of Gemma mod-]{.underline}

[els. To reduce risks to Gemma 3 users, we have]{.underline}

[continued to integrate enhanced internal safety]{.underline}

[processes that span the development workflow,]{.underline}

[in line with recent Google AI models (Gemini]{.underline}

[Team, 2024). This focuses on safety mitigation at]{.underline}

[training time, and robust and transparent model]{.underline}

[evaluations for the new image-to-text capabilities]{.underline}

[we have introduced.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[7.1. Governance & Assessment]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Our approach to assessing the benefits and risks]{.underline}

[of Gemma is reflective of that outlined for Gemma]{.underline}

[1 (Gemma Team, 2024a), taking into account the]{.underline}

[changes in supported modalities. We continue to]{.underline}

[believe that openness in AI can spread the bene-]{.underline}

[fits of these technologies across society, but must]{.underline}

[be evaluated against the risk of malicious uses]{.underline}

[that can cause harm on both individual and in-]{.underline}

[stitutional levels (Weidinger et al., 2021). Since]{.underline}

[the inaugural Gemma launch, we have seen these]{.underline}

[models drive a number of socially beneficial ap-]{.underline}

[plications, such as our own ShieldGemma 2, a 4B]{.underline}

[image safety classifier built with Gemma 3, which]{.underline}

[provides a ready-made solution for image safety,]{.underline}

[outputting safety labels across dangerous content,]{.underline}

[sexually explicit, and violence categories.]{.underline}

[Releasing Gemma 3 models required specific]{.underline}

[attention to changes in model capabilities and]{.underline}

[\`\`\`]{.underline}

[close monitoring of the evolving risks of existing]{.underline}

[multimodal LLMs (Lin et al., 2024), as well as an]{.underline}

[understanding of the ways in which models are]{.underline}

[being used in the wild. Although we are yet to]{.underline}

[receive any reports of malicious use for Gemma,]{.underline}

[we remain committed to investigating any such]{.underline}

[reporting, and work with the academic and de-]{.underline}

[veloper communities, as well as conduct our own]{.underline}

[monitoring, to flag such cases.]{.underline}

[Despite advancements in capabilities, we be-]{.underline}

[lieve that, given the number of larger powerful]{.underline}

[open models available, this release will have a]{.underline}

[negligible effect on the overall risk landscape.]{.underline}

[\*\*7.2. Safety policies and train-time mitigations\*\*]{.underline}

[A key pillar of Gemma's approach to safety is to]{.underline}

[align fine-tuned models with Google's safety poli-]{.underline}

[cies, in line with Gemini models (Gemini Team,]{.underline}

[2023). They are designed to help prevent our]{.underline}

[models from generating harmful content, i.e.,]{.underline}

[- Child sexual abuse and exploitation]{.underline}

[- Revealing personally identifiable information]{.underline}

[that can lead to harm (e.g., Social Security]{.underline}

[numbers)]{.underline}

[- Hate speech and harassment]{.underline}

[- Dangerous or malicious content (including]{.underline}

[promoting self-harm or instructing in harm-]{.underline}

[ful activities)]{.underline}

[- Sexually explicit content]{.underline}

[- Medical advice that runs contrary to scientific]{.underline}

[or medical consensus]{.underline}

[We undertook considerable safety filtering of our]{.underline}

[pre-training data to reduce the likelihood of our]{.underline}

[pre-trained and fine-tuned checkpoints producing]{.underline}

[harmful content. For fine-tuned models, we also]{.underline}

[use both SFT and RLHF to steer the model away]{.underline}

[from undesirable behavior.]{.underline}

[\*\*7.3. Assurance Evaluations\*\*]{.underline}

[We also run our IT models through a set of base-]{.underline}

[line assurance evaluations to understand the po-]{.underline}

[tential harms that our models can cause. As we]{.underline}

[champion open models, we also recognize that]{.underline}

[the irreversible nature of weight releases requires]{.underline}

[\`\`\`]{.underline}

[rigorous risk assessment. Our internal safety pro-]{.underline}

[cesses are designed accordingly, and for previ-]{.underline}

[ous Gemma models we have also undertaken]{.underline}

[evaluations of capabilities relevant to extreme]{.underline}

[risks (Phuong et al., 2024; Shevlane et al., 2023).]{.underline}

[As we continue to develop and share open mod-]{.underline}

[els, we will follow the heuristic that thoroughly]{.underline}

[evaluating a more capable model often provides]{.underline}

[sufficient assurance for less capable ones. As such,]{.underline}

[we prioritised a streamlined set of evaluations for]{.underline}

[Gemma 3, reserving in-depth dangerous capabil-]{.underline}

[ity assessments for cases where a specific model]{.underline}

[may present a potentially heightened risk (as de-]{.underline}

[scribed below on CBRN evaluations). We balance]{.underline}

[development speed with targeted safety testing,]{.underline}

[ensuring our evaluations are well-focused and]{.underline}

[efficient, while upholding the commitments laid]{.underline}

[out in our Frontier Safety Framework.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Baseline Evaluations]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Baseline assurance captures the model violation]{.underline}

[rate for safety policies, using a large number of]{.underline}

[synthetic adversarial user queries, and human]{.underline}

[raters to label the answers as policy violating or]{.underline}

[not. Overall, Gemma 3 violation rate is signifi-]{.underline}

[cantly low overall on these safety policies.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Chemical, Biological, Radiological and Nuclear]{.underline}

[(CBRN) knowledge]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Owing to enhanced performance on STEM-]{.underline}

[related tasks, we evaluated knowledge relevant]{.underline}

[to biological, radiological, and nuclear risks using]{.underline}

[an internal dataset of closed-ended, knowledge-]{.underline}

[based multiple choice questions. For evaluations]{.underline}

[of chemical knowledge, we employed a closed-]{.underline}

[ended knowledge-based approach on chemical]{.underline}

[hazards developed by Macknight et al. Our eval-]{.underline}

[uation suggests that the knowledge of Gemma 3]{.underline}

[models in these domains is low.]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[7.4. Our approach to responsible open models]{.underline}

[\`\`\`]{.underline}

[\`\`\`]{.underline}

[Designing safe, secure, and responsible applica-]{.underline}

[tions requires a system-level approach, working]{.underline}

[to mitigate risks associated with each specific use]{.underline}

[case and environment. We will continue to adopt]{.underline}

[assessments and safety mitigations proportion-]{.underline}

[ate to the potential risks from our models, and]{.underline}

[\`\`\`]{.underline}

[will only share these with the community when]{.underline}

[we are confident that the benefits significantly]{.underline}

[outweigh the foreseeable risks.]{.underline}

[\## 8. Discussion and Conclusion]{.underline}

[In this work, we have presented Gemma 3, the]{.underline}

[latest addition to the Gemma family of open lan-]{.underline}

[guage models for text, image, and code. In this]{.underline}

[version, we focus on adding image understanding]{.underline}

[and long context while improving multilinguality]{.underline}

[and STEM-related abilities. Our model sizes and]{.underline}

[architectures are designed to be compatible with]{.underline}

[standard hardware, and most of our architecture]{.underline}

[improvements are tailored to fit this hardware]{.underline}

[while maintaining performance.]{.underline}
