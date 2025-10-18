> [Fine-Tune Gemma using Hugging Face Transformers and
> QloRA]{.underline}

[This guide walks you through how to fine-tune Gemma on a custom
text-to-sql dataset using Hugging Face
[Transformers](https://huggingface.co/docs/transformers/index) and
[TRL](https://huggingface.co/docs/trl/index). You will
learn:]{.underline}

-   [What is Quantized Low-Rank Adaptation (QLoRA)]{.underline}

-   [Setup development environment]{.underline}

-   [Create and prepare the fine-tuning dataset]{.underline}

-   [Fine-tune Gemma using TRL and the SFTTrainer]{.underline}

-   [Test Model Inference and generate SQL queries]{.underline}

[**Note:** This guide was created to run on a Google colaboratory
account using a NVIDIA T4 GPU with 16GB and Gemma 1B, but can be adapted
to run on bigger GPUs and bigger models.]{.underline}

## [What is Quantized Low-Rank Adaptation (QLoRA)]{.underline}

[This guide demonstrates the use of [Quantized Low-Rank Adaptation
(QLoRA)](https://arxiv.org/abs/2305.14314), which emerged as a popular
method to efficiently fine-tune LLMs as it reduces computational
resource requirements while maintaining high performance. In QloRA, the
pretrained model is quantized to 4-bit and the weights are frozen. Then
trainable adapter layers (LoRA) are attached and only the adapter layers
are trained. Afterwards, the adapter weights can be merged with the base
model or kept as a separate adapter.]{.underline}

## [Setup development environment]{.underline}

[The first step is to install Hugging Face Libraries, including TRL, and
datasets to fine-tune open model, including different RLHF and alignment
techniques.]{.underline}

-   [\# Install Pytorch & other libraries]{.underline}

-   [%pip install \"torch\>=2.4.0\" tensorboard]{.underline}

-   

-   [\# Install Gemma release branch from Hugging Face]{.underline}

-   [%pip install \"transformers\>=4.51.3\"]{.underline}

-   

-   [\# Install Hugging Face libraries]{.underline}

-   [%pip install \--upgrade \\]{.underline}

-   [\"datasets==3.3.2\" \\]{.underline}

-   [\"accelerate==1.4.0\" \\]{.underline}

-   [\"evaluate==0.4.3\" \\]{.underline}

-   [\"bitsandbytes==0.45.3\" \\]{.underline}

-   [\"trl==0.21.0\" \\]{.underline}

-   [\"peft==0.14.0\" \\]{.underline}

-   [protobuf \\]{.underline}

-   [sentencepiece]{.underline}

-   

-   [\# COMMENT IN: if you are running on a GPU that supports BF16 data
    > type and flash attn, such as NVIDIA L4 or NVIDIA A100]{.underline}

-   [#% pip install flash-attn]{.underline}

*[Note: If you are using a GPU with Ampere architecture (such as NVIDIA
L4) or newer, you can use Flash attention. Flash Attention is a method
that significantly speeds computations up and reduces memory usage from
quadratic to linear in sequence length, leading to acelerating training
up to 3x. Learn more at
[FlashAttention](https://github.com/Dao-AILab/flash-attention/tree/main).]{.underline}*

[Before you can start training, you have to make sure that you accepted
the terms of use for Gemma. You can accept the license on [Hugging
Face](http://huggingface.co/google/gemma-3-1b-pt) by clicking on the
Agree and access repository button on the model page at:
http://huggingface.co/google/gemma-3-1b-pt]{.underline}

[After you have accepted the license, you need a valid Hugging Face
Token to access the model. If you are running inside a Google Colab, you
can securely use your Hugging Face Token using the Colab secrets
otherwise you can set the token as directly in the login method. Make
sure your token has write access too, as you push your model to the Hub
during training.]{.underline}

-   [from google.colab import userdata]{.underline}

-   [from huggingface_hub import login]{.underline}

-   

-   [\# Login into Hugging Face Hub]{.underline}

-   [hf_token = userdata.get(\'HF_TOKEN\') \# If you are running inside
    > a Google Colab]{.underline}

-   [login(hf_token)]{.underline}

## [Create and prepare the fine-tuning dataset]{.underline}

[When fine-tuning LLMs, it is important to know your use case and the
task you want to solve. This helps you create a dataset to fine-tune
your model. If you haven\'t defined your use case yet, you might want to
go back to the drawing board.]{.underline}

[As an example, this guide focuses on the following use
case:]{.underline}

-   [Fine-tune a natural language to SQL model for seamless integration
    > into a data analysis tool. The objective is to significantly
    > reduce the time and expertise required for SQL query generation,
    > enabling even non-technical users to extract meaningful insights
    > from data.]{.underline}

[Text-to-SQL can be a good use case for fine-tuning LLMs, as it is a
complex task that requires a lot of (internal) knowledge about the data
and the SQL language.]{.underline}

[Once you have determined that fine-tuning is the right solution, you
need a dataset to fine-tune. The dataset should be a diverse set of
demonstrations of the task(s) you want to solve. There are several ways
to create such a dataset, including:]{.underline}

-   [Using existing open-source datasets, such as
    > [Spider](https://huggingface.co/datasets/spider)]{.underline}

-   [Using synthetic datasets created by LLMs, such as
    > [Alpaca](https://huggingface.co/datasets/tatsu-lab/alpaca)]{.underline}

-   [Using datasets created by humans, such as
    > [Dolly](https://huggingface.co/datasets/databricks/databricks-dolly-15k).]{.underline}

-   [Using a combination of the methods, such as
    > [Orca](https://huggingface.co/datasets/Open-Orca/OpenOrca)]{.underline}

[Each of the methods has its own advantages and disadvantages and
depends on the budget, time, and quality requirements. For example,
using an existing dataset is the easiest but might not be tailored to
your specific use case, while using domain experts might be the most
accurate but can be time-consuming and expensive. It is also possible to
combine several methods to create an instruction dataset, as shown in
[Orca: Progressive Learning from Complex Explanation Traces of
GPT-4.](https://arxiv.org/abs/2306.02707)]{.underline}

[This guide uses an already existing dataset
([philschmid/gretel-synthetic-text-to-sql](https://huggingface.co/datasets/philschmid/gretel-synthetic-text-to-sql)),
a high quality synthetic Text-to-SQL dataset including natural language
instructions, schema definitions, reasoning and the corresponding SQL
query.]{.underline}

[[Hugging Face TRL](https://huggingface.co/docs/trl/en/index) supports
automatic templating of conversation dataset formats. This means you
only need to convert your dataset into the right json objects, and trl
takes care of templating and putting it into the right
format.]{.underline}

-   [{\"messages\": \[{\"role\": \"system\", \"content\": \"You
    > are\...\"}, {\"role\": \"user\", \"content\": \"\...\"},
    > {\"role\": \"assistant\", \"content\": \"\...\"}\]}]{.underline}

-   [{\"messages\": \[{\"role\": \"system\", \"content\": \"You
    > are\...\"}, {\"role\": \"user\", \"content\": \"\...\"},
    > {\"role\": \"assistant\", \"content\": \"\...\"}\]}]{.underline}

-   [{\"messages\": \[{\"role\": \"system\", \"content\": \"You
    > are\...\"}, {\"role\": \"user\", \"content\": \"\...\"},
    > {\"role\": \"assistant\", \"content\": \"\...\"}\]}]{.underline}

[The
[philschmid/gretel-synthetic-text-to-sql](https://huggingface.co/datasets/philschmid/gretel-synthetic-text-to-sql)
contains over 100k samples. To keep the guide small, it is downsampled
to only use 10,000 samples.]{.underline}

[You can now use the Hugging Face Datasets library to load the dataset
and create a prompt template to combine the natural language
instruction, schema definition and add a system message for your
assistant.]{.underline}

-   [from datasets import load_dataset]{.underline}

-   

-   [\# System message for the assistant]{.underline}

-   [system_message = \"\"\"You are a text to SQL query translator.
    > Users will ask you questions in English and you will generate a
    > SQL query based on the provided SCHEMA.\"\"\"]{.underline}

-   

-   [\# User prompt that combines the user query and the
    > schema]{.underline}

-   [user_prompt = \"\"\"Given the \<USER_QUERY\> and the \<SCHEMA\>,
    > generate the corresponding SQL command to retrieve the desired
    > data, considering the query\'s syntax, semantics, and schema
    > constraints.]{.underline}

-   

-   [\<SCHEMA\>]{.underline}

-   [{context}]{.underline}

-   [\</SCHEMA\>]{.underline}

-   

-   [\<USER_QUERY\>]{.underline}

-   [{question}]{.underline}

-   [\</USER_QUERY\>]{.underline}

-   [\"\"\"]{.underline}

-   [def create_conversation(sample):]{.underline}

-   [return {]{.underline}

-   [\"messages\": \[]{.underline}

-   [\# {\"role\": \"system\", \"content\":
    > system_message},]{.underline}

-   [{\"role\": \"user\", \"content\":
    > user_prompt.format(question=sample\[\"sql_prompt\"\],
    > context=sample\[\"sql_context\"\])},]{.underline}

-   [{\"role\": \"assistant\", \"content\":
    > sample\[\"sql\"\]}]{.underline}

-   [\]]{.underline}

-   [}]{.underline}

-   

-   [\# Load dataset from the hub]{.underline}

-   [dataset = load_dataset(\"philschmid/gretel-synthetic-text-to-sql\",
    > split=\"train\")]{.underline}

-   [dataset = dataset.shuffle().select(range(12500))]{.underline}

-   

-   [\# Convert dataset to OAI messages]{.underline}

-   [dataset = dataset.map(create_conversation,
    > remove_columns=dataset.features,batched=False)]{.underline}

-   [\# split dataset into 10,000 training samples and 2,500 test
    > samples]{.underline}

-   [dataset =
    > dataset.train_test_split(test_size=2500/12500)]{.underline}

-   

-   [\# Print formatted user prompt]{.underline}

-   [print(dataset\[\"train\"\]\[345\]\[\"messages\"\]\[1\]\[\"content\"\])]{.underline}

## [Fine-tune Gemma using TRL and the SFTTrainer]{.underline}

[You are now ready to fine-tune your model. Hugging Face TRL
[SFTTrainer](https://huggingface.co/docs/trl/sft_trainer) makes it
straightforward to supervise fine-tune open LLMs. The SFTTrainer is a
subclass of the Trainer from the transformers library and supports all
the same features, including logging, evaluation, and checkpointing, but
adds additional quality of life features, including:]{.underline}

-   [Dataset formatting, including conversational and instruction
    > formats]{.underline}

-   [Training on completions only, ignoring prompts]{.underline}

-   [Packing datasets for more efficient training]{.underline}

-   [Parameter-efficient fine-tuning (PEFT) support including
    > QloRA]{.underline}

-   [Preparing the model and tokenizer for conversational fine-tuning
    > (such as adding special tokens)]{.underline}

[The following code loads the Gemma model and tokenizer from Hugging
Face and initializes the quantization configuration.]{.underline}

-   [import torch]{.underline}

-   [from transformers import AutoTokenizer, AutoModelForCausalLM,
    > AutoModelForImageTextToText, BitsAndBytesConfig]{.underline}

-   

-   [\# Hugging Face model id]{.underline}

-   [model_id = \"google/gemma-3-1b-pt\" \# or \`google/gemma-3-4b-pt\`,
    > \`google/gemma-3-12b-pt\`, \`google/gemma-3-27b-pt\`]{.underline}

-   

-   [\# Select model class based on id]{.underline}

-   [if model_id == \"google/gemma-3-1b-pt\":]{.underline}

-   [model_class = AutoModelForCausalLM]{.underline}

-   [else:]{.underline}

-   [model_class = AutoModelForImageTextToText]{.underline}

-   

-   [\# Check if GPU benefits from bfloat16]{.underline}

-   [if torch.cuda.get_device_capability()\[0\] \>= 8:]{.underline}

-   [torch_dtype = torch.bfloat16]{.underline}

-   [else:]{.underline}

-   [torch_dtype = torch.float16]{.underline}

-   

-   [\# Define model init arguments]{.underline}

-   [model_kwargs = dict(]{.underline}

-   [attn_implementation=\"eager\", \# Use \"flash_attention_2\" when
    > running on Ampere or newer GPU]{.underline}

-   [torch_dtype=torch_dtype, \# What torch dtype to use, defaults to
    > auto]{.underline}

-   [device_map=\"auto\", \# Let torch decide how to load the
    > model]{.underline}

-   [)]{.underline}

-   

-   [\# BitsAndBytesConfig: Enables 4-bit quantization to reduce model
    > size/memory usage]{.underline}

-   [model_kwargs\[\"quantization_config\"\] =
    > BitsAndBytesConfig(]{.underline}

-   [load_in_4bit=True,]{.underline}

-   [bnb_4bit_use_double_quant=True,]{.underline}

-   [bnb_4bit_quant_type=\'nf4\',]{.underline}

-   [bnb_4bit_compute_dtype=model_kwargs\[\'torch_dtype\'\],]{.underline}

-   [bnb_4bit_quant_storage=model_kwargs\[\'torch_dtype\'\],]{.underline}

-   [)]{.underline}

-   

-   [\# Load model and tokenizer]{.underline}

-   [model = model_class.from_pretrained(model_id,
    > \*\*model_kwargs)]{.underline}

-   [tokenizer = AutoTokenizer.from_pretrained(\"google/gemma-3-1b-it\")
    > \# Load the Instruction Tokenizer to use the official Gemma
    > template]{.underline}

[The SFTTrainer supports a native integration with peft, which makes it
straightforward to efficiently tune LLMs using QLoRA. You only need to
create a LoraConfig and provide it to the trainer.]{.underline}

-   [from peft import LoraConfig]{.underline}

-   

-   [peft_config = LoraConfig(]{.underline}

-   [lora_alpha=16,]{.underline}

-   [lora_dropout=0.05,]{.underline}

-   [r=16,]{.underline}

-   [bias=\"none\",]{.underline}

-   [target_modules=\"all-linear\",]{.underline}

-   [task_type=\"CAUSAL_LM\",]{.underline}

-   [modules_to_save=\[\"lm_head\", \"embed_tokens\"\] \# make sure to
    > save the lm_head and embed_tokens as you train the special
    > tokens]{.underline}

-   [)]{.underline}

[Before you can start your training, you need to define the
hyperparameter you want to use in a SFTConfig instance.]{.underline}

-   [from trl import SFTConfig]{.underline}

-   

-   [args = SFTConfig(]{.underline}

-   [output_dir=\"gemma-text-to-sql\", \# directory to save and
    > repository id]{.underline}

-   [max_length=512, \# max sequence length for model and packing of the
    > dataset]{.underline}

-   [packing=True, \# Groups multiple samples in the dataset into a
    > single sequence]{.underline}

-   [num_train_epochs=3, \# number of training epochs]{.underline}

-   [per_device_train_batch_size=1, \# batch size per device during
    > training]{.underline}

-   [gradient_accumulation_steps=4, \# number of steps before performing
    > a backward/update pass]{.underline}

-   [gradient_checkpointing=True, \# use gradient checkpointing to save
    > memory]{.underline}

-   [optim=\"adamw_torch_fused\", \# use fused adamw
    > optimizer]{.underline}

-   [logging_steps=10, \# log every 10 steps]{.underline}

-   [save_strategy=\"epoch\", \# save checkpoint every
    > epoch]{.underline}

-   [learning_rate=2e-4, \# learning rate, based on QLoRA
    > paper]{.underline}

-   [fp16=True if torch_dtype == torch.float16 else False, \# use
    > float16 precision]{.underline}

-   [bf16=True if torch_dtype == torch.bfloat16 else False, \# use
    > bfloat16 precision]{.underline}

-   [max_grad_norm=0.3, \# max gradient norm based on QLoRA
    > paper]{.underline}

-   [warmup_ratio=0.03, \# warmup ratio based on QLoRA
    > paper]{.underline}

-   [lr_scheduler_type=\"constant\", \# use constant learning rate
    > scheduler]{.underline}

-   [push_to_hub=True, \# push model to hub]{.underline}

-   [report_to=\"tensorboard\", \# report metrics to
    > tensorboard]{.underline}

-   [dataset_kwargs={]{.underline}

-   [\"add_special_tokens\": False, \# We template with special
    > tokens]{.underline}

-   [\"append_concat_token\": True, \# Add EOS token as separator token
    > between examples]{.underline}

-   [}]{.underline}

-   [)]{.underline}

[You now have every building block you need to create your SFTTrainer to
start the training of your model.]{.underline}

-   [from trl import SFTTrainer]{.underline}

-   

-   [\# Create Trainer object]{.underline}

-   [trainer = SFTTrainer(]{.underline}

-   [model=model,]{.underline}

-   [args=args,]{.underline}

-   [train_dataset=dataset\[\"train\"\],]{.underline}

-   [peft_config=peft_config,]{.underline}

-   [processing_class=tokenizer]{.underline}

-   [)]{.underline}

[Start training by calling the train() method.]{.underline}

-   [\# Start training, the model will be automatically saved to the Hub
    > and the output directory]{.underline}

-   [trainer.train()]{.underline}

-   

-   [\# Save the final model again to the Hugging Face Hub]{.underline}

-   [trainer.save_model()]{.underline}

[Before you can test your model, make sure to free the
memory.]{.underline}

-   [\# free the memory again]{.underline}

-   [del model]{.underline}

-   [del trainer]{.underline}

-   [torch.cuda.empty_cache()]{.underline}

[When using QLoRA, you only train adapters and not the full model. This
means when saving the model during training you only save the adapter
weights and not the full model. If you want to save the full model,
which makes it easier to use with serving stacks like vLLM or TGI, you
can merge the adapter weights into the model weights using the
merge_and_unload method and then save the model with the save_pretrained
method. This saves a default model, which can be used for
inference.]{.underline}

[**Note:** It requires more than 30GB of CPU Memory when you want to
merge the adapter into the model. You can skip this and continue with
Test Model Inference.]{.underline}

-   [from peft import PeftModel]{.underline}

-   

-   [\# Load Model base model]{.underline}

-   [model = model_class.from_pretrained(model_id,
    > low_cpu_mem_usage=True)]{.underline}

-   

-   [\# Merge LoRA and base model and save]{.underline}

-   [peft_model = PeftModel.from_pretrained(model,
    > args.output_dir)]{.underline}

-   [merged_model = peft_model.merge_and_unload()]{.underline}

-   [merged_model.save_pretrained(\"merged_model\",
    > safe_serialization=True, max_shard_size=\"2GB\")]{.underline}

-   

-   [processor =
    > AutoTokenizer.from_pretrained(args.output_dir)]{.underline}

-   [processor.save_pretrained(\"merged_model\")]{.underline}

## [Test Model Inference and generate SQL queries]{.underline}

[After the training is done, you\'ll want to evaluate and test your
model. You can load different samples from the test dataset and evaluate
the model on those samples.]{.underline}

[**Note:** Evaluating generative AI models is not a trivial task since
one input can have multiple correct outputs. This guide only focuses on
manual evaluation and vibe checks.]{.underline}

-   [import torch]{.underline}

-   [from transformers import pipeline]{.underline}

-   

-   [model_id = \"gemma-text-to-sql\"]{.underline}

-   

-   [\# Load Model with PEFT adapter]{.underline}

-   [model = model_class.from_pretrained(]{.underline}

-   [model_id,]{.underline}

-   [device_map=\"auto\",]{.underline}

-   [torch_dtype=torch_dtype,]{.underline}

-   [attn_implementation=\"eager\",]{.underline}

-   [)]{.underline}

-   [tokenizer = AutoTokenizer.from_pretrained(model_id)]{.underline}

[Let\'s load a random sample from the test dataset and generate a SQL
command.]{.underline}

-   [from random import randint]{.underline}

-   [import re]{.underline}

-   

-   [\# Load the model and tokenizer into the pipeline]{.underline}

-   [pipe = pipeline(\"text-generation\", model=model,
    > tokenizer=tokenizer)]{.underline}

-   

-   [\# Load a random sample from the test dataset]{.underline}

-   [rand_idx = randint(0, len(dataset\[\"test\"\])-1)]{.underline}

-   [test_sample = dataset\[\"test\"\]\[rand_idx\]]{.underline}

-   

-   [\# Convert as test example into a prompt with the Gemma
    > template]{.underline}

-   [stop_token_ids = \[tokenizer.eos_token_id,
    > tokenizer.convert_tokens_to_ids(\"\<end_of_turn\>\")\]]{.underline}

-   [prompt =
    > pipe.tokenizer.apply_chat_template(test_sample\[\"messages\"\]\[:2\],
    > tokenize=False, add_generation_prompt=True)]{.underline}

-   

-   [\# Generate our SQL query.]{.underline}

-   [outputs = pipe(prompt, max_new_tokens=256, do_sample=False,
    > temperature=0.1, top_k=50, top_p=0.1, eos_token_id=stop_token_ids,
    > disable_compile=True)]{.underline}

-   

-   [\# Extract the user query and original answer]{.underline}

-   [print(f\"Context:\\n\",
    > re.search(r\'\<SCHEMA\>\\n(.\*?)\\n\</SCHEMA\>\',
    > test_sample\[\'messages\'\]\[0\]\[\'content\'\],
    > re.DOTALL).group(1).strip())]{.underline}

-   [print(f\"Query:\\n\",
    > re.search(r\'\<USER_QUERY\>\\n(.\*?)\\n\</USER_QUERY\>\',
    > test_sample\[\'messages\'\]\[0\]\[\'content\'\],
    > re.DOTALL).group(1).strip())]{.underline}

-   [print(f\"Original
    > Answer:\\n{test_sample\[\'messages\'\]\[1\]\[\'content\'\]}\")]{.underline}

-   [print(f\"Generated
    > Answer:\\n{outputs\[0\]\[\'generated_text\'\]\[len(prompt):\].strip()}\")]{.underline}

## [Summary and next steps]{.underline}

[This tutorial covered how to fine-tune a Gemma model using TRL and
QLoRA. Check out the following docs next:]{.underline}

-   [Learn how to [generate text with a Gemma
    > model](https://ai.google.dev/gemma/docs/get_started).]{.underline}

-   [Learn how to [fine-tune Gemma for vision tasks using Hugging Face
    > Transformers](https://ai.google.dev/gemma/docs/core/huggingface_vision_finetune_qlora).]{.underline}

-   [Learn how to [full model fine-tune using Hugging Face
    > Transformers](https://ai.google.dev/gemma/docs/core/huggingface_text_full_finetune).]{.underline}

-   [Learn how to perform [distributed fine-tuning and inference on a
    > Gemma
    > model](https://ai.google.dev/gemma/docs/core/distributed_tuning).]{.underline}

-   [Learn how to [use Gemma open models with Vertex
    > AI](https://cloud.google.com/vertex-ai/docs/generative-ai/open-models/use-gemma).]{.underline}

-   [Learn how to [fine-tune Gemma using KerasNLP and deploy to Vertex
    > AI](https://github.com/GoogleCloudPlatform/vertex-ai-samples/blob/main/notebooks/community/model_garden/model_garden_gemma_kerasnlp_to_vertexai.ipynb).]{.underline}
