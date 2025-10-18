> Fine-Tune Gemma for Vision Tasks using Hugging Face Transformers and
> QLoRA

This guide walks you through how to fine-tune Gemma on a custom image
and text dataset for a vision task (generating product descriptions)
using Hugging Face
[[Transformers]{.underline}](https://huggingface.co/docs/transformers/index)
and [[TRL]{.underline}](https://huggingface.co/docs/trl/index). You will
learn:

-   What is Quantized Low-Rank Adaptation (QLoRA)

-   Setup development environment

-   Create and prepare the fine-tuning dataset for vision tasks

-   Fine-tune Gemma using TRL and the SFTTrainer

-   Test Model Inference and generate product descriptions from images
    > and text.

**Note:** This guide requires a GPU which support bfloat16 data type
such as NVIDIA L4 or NVIDIA A100 and more than 16GB of memory.

## What is Quantized Low-Rank Adaptation (QLoRA)

This guide demonstrates the use of [[Quantized Low-Rank Adaptation
(QLoRA)]{.underline}](https://arxiv.org/abs/2305.14314), which emerged
as a popular method to efficiently fine-tune LLMs as it reduces
computational resource requirements while maintaining high performance.
In QloRA, the pretrained model is quantized to 4-bit and the weights are
frozen. Then trainable adapter layers (LoRA) are attached and only the
adapter layers are trained. Afterwards, the adapter weights can be
merged with the base model or kept as a separate adapter.

## Setup development environment

The first step is to install Hugging Face Libraries, including TRL, and
datasets to fine-tune the open model.

-   \# Install Pytorch & other libraries

-   %pip install \"torch\>=2.4.0\" tensorboard torchvision

-   

-   \# Install Gemma release branch from Hugging Face

-   %pip install \"transformers\>=4.51.3\"

-   

-   \# Install Hugging Face libraries

-   %pip install \--upgrade \\

-   \"datasets==3.3.2\" \\

-   \"accelerate==1.4.0\" \\

-   \"evaluate==0.4.3\" \\

-   \"bitsandbytes==0.45.3\" \\

-   \"trl==0.15.2\" \\

-   \"peft==0.14.0\" \\

-   \"pillow==11.1.0\" \\

-   protobuf \\

-   sentencepiece

Before you can start training, you have to make sure that you accepted
the terms of use for Gemma. You can accept the license on [[Hugging
Face]{.underline}](http://huggingface.co/google/gemma-3-4b-pt) by
clicking on the Agree and access repository button on the model page at:
http://huggingface.co/google/gemma-3-4b-pt (or the appropriate model
page for the vision-capable Gemma model you are using).

After you have accepted the license, you need a valid Hugging Face Token
to access the model. If you are running inside a Google Colab, you can
securely use your Hugging Face Token using Colab secrets; otherwise, you
can set the token directly in the login method. Make sure your token has
write access too, as you push your model to the Hub during training.

-   from google.colab import userdata

-   from huggingface_hub import login

-   

-   \# Login into Hugging Face Hub

-   hf_token = userdata.get(\'HF_TOKEN\') \# If you are running inside a
    > Google Colab

-   login(hf_token)

## Create and prepare the fine-tuning dataset

When fine-tuning LLMs, it is important to know your use case and the
task you want to solve. This helps you create a dataset to fine-tune
your model. If you haven\'t defined your use case yet, you might want to
go back to the drawing board.

As an example, this guide focuses on the following use case:

-   Fine-tuning a Gemma model to generate concise, SEO-optimized product
    > descriptions for an ecommerce platform, specifically tailored for
    > mobile search.

This guide uses the
[[philschmid/amazon-product-descriptions-vlm]{.underline}](https://huggingface.co/datasets/philschmid/amazon-product-descriptions-vlm)
dataset, a dataset of Amazon product descriptions, including product
images and categories.

Hugging Face TRL supports multimodal conversations. The important piece
is the \"image\" role, which tells the processing class that it should
load the image. The structure should follow:

-   {\"messages\": \[{\"role\": \"system\", \"content\": \[{\"type\":
    > \"text\", \"text\":\"You are\...\"}\]}, {\"role\": \"user\",
    > \"content\": \[{\"type\": \"text\", \"text\": \"\...\"},
    > {\"type\": \"image\"}\]}, {\"role\": \"assistant\", \"content\":
    > \[{\"type\": \"text\", \"text\": \"\...\"}\]}\]}

-   {\"messages\": \[{\"role\": \"system\", \"content\": \[{\"type\":
    > \"text\", \"text\":\"You are\...\"}\]}, {\"role\": \"user\",
    > \"content\": \[{\"type\": \"text\", \"text\": \"\...\"},
    > {\"type\": \"image\"}\]}, {\"role\": \"assistant\", \"content\":
    > \[{\"type\": \"text\", \"text\": \"\...\"}\]}\]}

-   {\"messages\": \[{\"role\": \"system\", \"content\": \[{\"type\":
    > \"text\", \"text\":\"You are\...\"}\]}, {\"role\": \"user\",
    > \"content\": \[{\"type\": \"text\", \"text\": \"\...\"},
    > {\"type\": \"image\"}\]}, {\"role\": \"assistant\", \"content\":
    > \[{\"type\": \"text\", \"text\": \"\...\"}\]}\]}

You can now use the Hugging Face Datasets library to load the dataset
and create a prompt template to combine the image, product name, and
category, and add a system message. The dataset includes images
asPil.Image objects.

-   from datasets import load_dataset

-   from PIL import Image

-   

-   \# System message for the assistant

-   system_message = \"You are an expert product description writer for
    > Amazon.\"

-   

-   \# User prompt that combines the user query and the schema

-   user_prompt = \"\"\"Create a Short Product description based on the
    > provided \<PRODUCT\> and \<CATEGORY\> and image.

-   Only return description. The description should be SEO optimized and
    > for a better mobile search experience.

-   

-   \<PRODUCT\>

-   {product}

-   \</PRODUCT\>

-   

-   \<CATEGORY\>

-   {category}

-   \</CATEGORY\>

-   \"\"\"

-   

-   \# Convert dataset to OAI messages

-   def format_data(sample):

-   return {

-   \"messages\": \[

-   {

-   \"role\": \"system\",

-   \"content\": \[{\"type\": \"text\", \"text\": system_message}\],

-   },

-   {

-   \"role\": \"user\",

-   \"content\": \[

-   {

-   \"type\": \"text\",

-   \"text\": user_prompt.format(

-   product=sample\[\"Product Name\"\],

-   category=sample\[\"Category\"\],

-   ),

-   },

-   {

-   \"type\": \"image\",

-   \"image\": sample\[\"image\"\],

-   },

-   \],

-   },

-   {

-   \"role\": \"assistant\",

-   \"content\": \[{\"type\": \"text\", \"text\":
    > sample\[\"description\"\]}\],

-   },

-   \],

-   }

-   

-   def process_vision_info(messages: list\[dict\]) -\>
    > list\[Image.Image\]:

-   image_inputs = \[\]

-   \# Iterate through each conversation

-   for msg in messages:

-   \# Get content (ensure it\'s a list)

-   content = msg.get(\"content\", \[\])

-   if not isinstance(content, list):

-   content = \[content\]

-   

-   \# Check each content element for images

-   for element in content:

-   if isinstance(element, dict) and (

-   \"image\" in element or element.get(\"type\") == \"image\"

-   ):

-   \# Get the image and convert to RGB

-   if \"image\" in element:

-   image = element\[\"image\"\]

-   else:

-   image = element

-   image_inputs.append(image.convert(\"RGB\"))

-   return image_inputs

-   

-   \# Load dataset from the hub

-   dataset =
    > load_dataset(\"philschmid/amazon-product-descriptions-vlm\",
    > split=\"train\")

-   

-   \# Convert dataset to OAI messages

-   \# need to use list comprehension to keep Pil.Image type, .mape
    > convert image to bytes

-   dataset = \[format_data(sample) for sample in dataset\]

-   

-   print(dataset\[345\]\[\"messages\"\])

## Fine-tune Gemma using TRL and the SFTTrainer

You are now ready to fine-tune your model. Hugging Face TRL
[[SFTTrainer]{.underline}](https://huggingface.co/docs/trl/sft_trainer)
makes it straightforward to supervise fine-tune open LLMs. The
SFTTrainer is a subclass of the Trainer from the transformers library
and supports all the same features, including logging, evaluation, and
checkpointing, but adds additional quality of life features, including:

-   Dataset formatting, including conversational and instruction formats

-   Training on completions only, ignoring prompts

-   Packing datasets for more efficient training

-   Parameter-efficient fine-tuning (PEFT) support including QloRA

-   Preparing the model and tokenizer for conversational fine-tuning
    > (such as adding special tokens)

The following code loads the Gemma model and tokenizer from Hugging Face
and initializes the quantization configuration.

-   import torch

-   from transformers import AutoProcessor, AutoModelForImageTextToText,
    > BitsAndBytesConfig

-   

-   \# Hugging Face model id

-   model_id = \"google/gemma-3-4b-pt\" \# or \`google/gemma-3-12b-pt\`,
    > \`google/gemma-3-27-pt\`

-   

-   \# Check if GPU benefits from bfloat16

-   if torch.cuda.get_device_capability()\[0\] \< 8:

-   raise ValueError(\"GPU does not support bfloat16, please use a GPU
    > that supports bfloat16.\")

-   

-   \# Define model init arguments

-   model_kwargs = dict(

-   attn_implementation=\"eager\", \# Use \"flash_attention_2\" when
    > running on Ampere or newer GPU

-   torch_dtype=torch.bfloat16, \# What torch dtype to use, defaults to
    > auto

-   device_map=\"auto\", \# Let torch decide how to load the model

-   )

-   

-   \# BitsAndBytesConfig int-4 config

-   model_kwargs\[\"quantization_config\"\] = BitsAndBytesConfig(

-   load_in_4bit=True,

-   bnb_4bit_use_double_quant=True,

-   bnb_4bit_quant_type=\"nf4\",

-   bnb_4bit_compute_dtype=model_kwargs\[\"torch_dtype\"\],

-   bnb_4bit_quant_storage=model_kwargs\[\"torch_dtype\"\],

-   )

-   

-   \# Load model and tokenizer

-   model = AutoModelForImageTextToText.from_pretrained(model_id,
    > \*\*model_kwargs)

-   processor = AutoProcessor.from_pretrained(\"google/gemma-3-4b-it\")

The SFTTrainer supports a built-in integration with peft, which makes it
straightforward to efficiently tune LLMs using QLoRA. You only need to
create a LoraConfig and provide it to the trainer.

-   from peft import LoraConfig

-   

-   peft_config = LoraConfig(

-   lora_alpha=16,

-   lora_dropout=0.05,

-   r=16,

-   bias=\"none\",

-   target_modules=\"all-linear\",

-   task_type=\"CAUSAL_LM\",

-   modules_to_save=\[

-   \"lm_head\",

-   \"embed_tokens\",

-   \],

-   )

Before you can start your training, you need to define the
hyperparameter you want to use in a SFTConfig and a custom collate_fn to
handle the vision processing. The collate_fn converts the messages with
text and images into a format that the model can understand.

-   from trl import SFTConfig

-   

-   args = SFTConfig(

-   output_dir=\"gemma-product-description\", \# directory to save and
    > repository id

-   num_train_epochs=1, \# number of training epochs

-   per_device_train_batch_size=1, \# batch size per device during
    > training

-   gradient_accumulation_steps=4, \# number of steps before performing
    > a backward/update pass

-   gradient_checkpointing=True, \# use gradient checkpointing to save
    > memory

-   optim=\"adamw_torch_fused\", \# use fused adamw optimizer

-   logging_steps=5, \# log every 5 steps

-   save_strategy=\"epoch\", \# save checkpoint every epoch

-   learning_rate=2e-4, \# learning rate, based on QLoRA paper

-   bf16=True, \# use bfloat16 precision

-   max_grad_norm=0.3, \# max gradient norm based on QLoRA paper

-   warmup_ratio=0.03, \# warmup ratio based on QLoRA paper

-   lr_scheduler_type=\"constant\", \# use constant learning rate
    > scheduler

-   push_to_hub=True, \# push model to hub

-   report_to=\"tensorboard\", \# report metrics to tensorboard

-   gradient_checkpointing_kwargs={

-   \"use_reentrant\": False

-   }, \# use reentrant checkpointing

-   dataset_text_field=\"\", \# need a dummy field for collator

-   dataset_kwargs={\"skip_prepare_dataset\": True}, \# important for
    > collator

-   )

-   args.remove_unused_columns = False \# important for collator

-   

-   \# Create a data collator to encode text and image pairs

-   def collate_fn(examples):

-   texts = \[\]

-   images = \[\]

-   for example in examples:

-   image_inputs = process_vision_info(example\[\"messages\"\])

-   text = processor.apply_chat_template(

-   example\[\"messages\"\], add_generation_prompt=False, tokenize=False

-   )

-   texts.append(text.strip())

-   images.append(image_inputs)

-   

-   \# Tokenize the texts and process the images

-   batch = processor(text=texts, images=images, return_tensors=\"pt\",
    > padding=True)

-   

-   \# The labels are the input_ids, and we mask the padding tokens and
    > image tokens in the loss computation

-   labels = batch\[\"input_ids\"\].clone()

-   

-   \# Mask image tokens

-   image_token_id = \[

-   processor.tokenizer.convert_tokens_to_ids(

-   processor.tokenizer.special_tokens_map\[\"boi_token\"\]

-   )

-   \]

-   \# Mask tokens for not being used in the loss computation

-   labels\[labels == processor.tokenizer.pad_token_id\] = -100

-   labels\[labels == image_token_id\] = -100

-   labels\[labels == 262144\] = -100

-   

-   batch\[\"labels\"\] = labels

-   return batch

You now have every building block you need to create your SFTTrainer to
start the training of your model.

-   from trl import SFTTrainer

-   

-   trainer = SFTTrainer(

-   model=model,

-   args=args,

-   train_dataset=dataset,

-   peft_config=peft_config,

-   processing_class=processor,

-   data_collator=collate_fn,

-   )

Start training by calling the train() method.

-   \# Start training, the model will be automatically saved to the Hub
    > and the output directory

-   trainer.train()

-   

-   \# Save the final model again to the Hugging Face Hub

-   trainer.save_model()

Before you can test your model, make sure to free the memory.

-   \# free the memory again

-   del model

-   del trainer

-   torch.cuda.empty_cache()

When using QLoRA, you only train adapters and not the full model. This
means when saving the model during training you only save the adapter
weights and not the full model. If you want to save the full model,
which makes it easier to use with serving stacks like vLLM or TGI, you
can merge the adapter weights into the model weights using the
merge_and_unload method and then save the model with the save_pretrained
method. This saves a default model, which can be used for inference.

**Note:** It requires more than 30GB of CPU Memory when you want to
merge the adapter into the model. You can skip this and continue with
Test Model Inference.

-   from peft import PeftModel

-   

-   \# Load Model base model

-   model = AutoModelForImageTextToText.from_pretrained(model_id,
    > low_cpu_mem_usage=True)

-   

-   \# Merge LoRA and base model and save

-   peft_model = PeftModel.from_pretrained(model, args.output_dir)

-   merged_model = peft_model.merge_and_unload()

-   merged_model.save_pretrained(\"merged_model\",
    > safe_serialization=True, max_shard_size=\"2GB\")

-   

-   processor = AutoProcessor.from_pretrained(args.output_dir)

-   processor.save_pretrained(\"merged_model\")

## Test Model Inference and generate product descriptions

After the training is done, you\'ll want to evaluate and test your
model. You can load different samples from the test dataset and evaluate
the model on those samples.

**Note:** Evaluating Generative AI models is not a trivial task since
one input can have multiple correct outputs. This guide only focuses on
manual evaluation and vibe checks.

-   import torch

-   

-   \# Load Model with PEFT adapter

-   model = AutoModelForImageTextToText.from_pretrained(

-   args.output_dir,

-   device_map=\"auto\",

-   torch_dtype=torch.bfloat16,

-   attn_implementation=\"eager\",

-   )

-   processor = AutoProcessor.from_pretrained(args.output_dir)

You can test inference by providing a product name, category and image.
The sample includes a marvel action figure.

-   import requests

-   from PIL import Image

-   

-   \# Test sample with Product Name, Category and Image

-   sample = {

-   \"product_name\": \"Hasbro Marvel Avengers-Serie Marvel Assemble
    > Titan-Held, Iron Man, 30,5 cm Actionfigur\",

-   \"category\": \"Toys & Games \| Toy Figures & Playsets \| Action
    > Figures\",

-   \"image\":
    > Image.open(requests.get(\"https://m.media-amazon.com/images/I/81+7Up7IWyL.\_AC_SY300_SX300\_.jpg\",
    > stream=True).raw).convert(\"RGB\")

-   }

-   

-   def generate_description(sample, model, processor):

-   \# Convert sample into messages and then apply the chat template

-   messages = \[

-   {\"role\": \"system\", \"content\": \[{\"type\": \"text\", \"text\":
    > system_message}\]},

-   {\"role\": \"user\", \"content\": \[

-   {\"type\": \"image\",\"image\": sample\[\"image\"\]},

-   {\"type\": \"text\", \"text\":
    > user_prompt.format(product=sample\[\"product_name\"\],
    > category=sample\[\"category\"\])},

-   \]},

-   \]

-   text = processor.apply_chat_template(

-   messages, tokenize=False, add_generation_prompt=True

-   )

-   \# Process the image and text

-   image_inputs = process_vision_info(messages)

-   \# Tokenize the text and process the images

-   inputs = processor(

-   text=\[text\],

-   images=image_inputs,

-   padding=True,

-   return_tensors=\"pt\",

-   )

-   \# Move the inputs to the device

-   inputs = inputs.to(model.device)

-   

-   \# Generate the output

-   stop_token_ids = \[processor.tokenizer.eos_token_id,
    > processor.tokenizer.convert_tokens_to_ids(\"\<end_of_turn\>\")\]

-   generated_ids = model.generate(\*\*inputs, max_new_tokens=256,
    > top_p=1.0, do_sample=True, temperature=0.8,
    > eos_token_id=stop_token_ids, disable_compile=True)

-   \# Trim the generation and decode the output to text

-   generated_ids_trimmed = \[out_ids\[len(in_ids) :\] for in_ids,
    > out_ids in zip(inputs.input_ids, generated_ids)\]

-   output_text = processor.batch_decode(

-   generated_ids_trimmed, skip_special_tokens=True,
    > clean_up_tokenization_spaces=False

-   )

-   return output_text\[0\]

-   

-   \# generate the description

-   description = generate_description(sample, model, processor)

-   print(description)

## Summary and next steps

This tutorial covered how to fine-tune a Gemma model for vision tasks
using TRL and QLoRA, specifically for generating product descriptions.
Check out the following docs next:

-   Learn how to [[generate text with a Gemma
    > model]{.underline}](https://ai.google.dev/gemma/docs/get_started).

-   Learn how to [[fine-tune Gemma for text tasks using Hugging Face
    > Transformers]{.underline}](https://ai.google.dev/gemma/docs/core/huggingface_text_finetune_qlora).

-   Learn how to [[full model fine-tune using Hugging Face
    > Transformers]{.underline}](https://ai.google.dev/gemma/docs/core/huggingface_text_full_finetune).

-   Learn how to perform [[distributed fine-tuning and inference on a
    > Gemma
    > model]{.underline}](https://ai.google.dev/gemma/docs/core/distributed_tuning).

-   Learn how to [[use Gemma open models with Vertex
    > AI]{.underline}](https://cloud.google.com/vertex-ai/docs/generative-ai/open-models/use-gemma).

-   Learn how to [[fine-tune Gemma using KerasNLP and deploy to Vertex
    > AI]{.underline}](https://github.com/GoogleCloudPlatform/vertex-ai-samples/blob/main/notebooks/community/model_garden/model_garden_gemma_kerasnlp_to_vertexai.ipynb).

```{=html}
<!-- -->
```
-   
