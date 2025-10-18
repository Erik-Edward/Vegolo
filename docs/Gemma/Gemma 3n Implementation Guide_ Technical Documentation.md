This document organizes the authoritative technical information required
for implementing Gemma 3n on-device reasoning, adhering to the requested
format and including direct links for your engineering team.

### **Gemma 3n Implementation Guide: Technical Documentation**

  ---------------------------------------------------------------------------------------------------------------------------------------------------
  **Topic**                  **Summary**            **Authoritative   **Key Snippets (API Calls/Flags/Settings)**       **Notable Caveats
                                                    Link(s)**                                                           (Device/Delegate/Version)**
  -------------------------- ---------------------- ----------------- ------------------------------------------------- -----------------------------
  **Tokenizer + Prompt       Gemma uses a           Gemma Instruction \- **Max Context:** Gemma 3n supports **32K token LiteRT-LM handles underlying
  Contract for Gemma 3/3n**  SentencePiece          Fine-tuning Guide context**.^2^ - **Stop Tokens:** Generation must  tokenization; the application
                             tokenizer.             (Hugging Face)    terminate upon **tokenizer.eos_token_id** or      layer (Flutter BLoC/native
                             Instruction-tuned      ^1^; Gemma 3n     **\<end_of_turn\>**.^1^ - **Template Structure:** bridge) must ensure the input
                             models require strict  Model Features    Conversational roles (e.g., {\"role\": \"user\",  string adheres to the correct
                             adherence to the chat  ^2^               \"content\": \"\...\"}) must be used, which are   prompt structure and must
                             template structure                       converted by the tokenizer\'s                     enforce a safe max sequence
                             utilizing specific                       apply_chat_template.^1^                           length (e.g., 4096 tokens) to
                             role-based delimiters                                                                      prevent OOM errors.^3^
                             (system, user) and                                                                         
                             control tokens                                                                             
                             (\<start_of_turn\>,                                                                        
                             \<end_of_turn\>) for                                                                       
                             consistent                                                                                 
                             performance.                                                                               

  **LiteRT / LiteRT-LM for   LiteRT-LM (MediaPipe   MediaPipe GenAI   \- **Dependency:** implementation                 Optimized for high-end
  Android**                  GenAI LLM Inference    LLM Inference API \'com.google.mediapipe:tasks-genai:0.10.27\' ^4^  Android devices (e.g., Pixel
                             API) is the            (Android Guide)   (Example version). - **Initialization:**          8, Samsung S23 or later).^4^
                             specialized C++        ^3^; LiteRT-LM    LlmInference.LlmInferenceOptions.builder() ^7^ -  NNAPI delegate performance is
                             pipeline required for  Architecture ^5^; **Model Loading:**                                often highly variable and can
                             stateful inference and MediaPipe         .setModelPath(absoluteModelFilePath) (Mandatory   be significantly lower than
                             efficient Key-Value    Delegates ^7^     for mmap loading).^4^ - **Delegate Baseline:**    XNNPACK.^8^
                             (KV) Cache management                    .setDelegate(LlmInference.Delegate.XNNPACK).^7^   
                             in autoregressive LLM                                                                      
                             generation. It is                                                                          
                             accessed via the                                                                           
                             high-level Android                                                                         
                             Kotlin/Java API.                                                                           

  **tflite_flutter (If not   The tflite_flutter     TFLite Flutter    \- **Options:** Interpreter.Options() supports    **Crucial Caveat:** Standard
  using LiteRT-LM)**         package enables access Package Overview  setting numThreads and delegates via plugins.^12^ tflite_flutter interpreters
                             to the standard        ^9^; TFLite                                                         lack the built-in C++
                             TensorFlow Lite        Flutter                                                             pipeline needed for **KV
                             interpreter, allowing  Integration Guide                                                   Cache management** and
                             the use of basic       ^10^; LiteRT-LM                                                     session cloning required for
                             delegates              necessity                                                           fast autoregressive LLM
                             (NNAPI/XNNPACK) and    explanation ^5^                                                     decoding, making it
                             thread counts, but it                                                                      inefficient or unusable for
                             is not designed for                                                                        generation tasks.^5^
                             complex, stateful LLM                                                                      
                             generation pipelines.                                                                      

  **Quantization             Maximum performance    LiteRT            \- **Weight Type:** Per-axis (Per-channel) INT8   Without a representative
  (LiteRT/TFLite) for Gemma  relies on **Full       Quantization      weights with zero-point = 0.^14^ -                dataset, the model reverts to
  3/LLMs**                   Integer Quantization   Overview (PTQ)    **Calibration:** Requires providing a             less efficient Dynamic Range
                             (FIQ)**, achieving     ^13^; LiteRT INT8 RepresentativeDataset (generator function) during Quantization, losing
                             INT8 weights and INT8  Specification     conversion.^15^ - **Dataset Size:** Approximately significant CPU speedup.^13^
                             activations. This      ^14^;             **100 data points** are suggested for calibration Per-channel weight
                             demands using          Representative    accuracy.^15^                                     quantization is necessary to
                             per-axis/per-channel   Dataset Guide                                                       maintain LLM accuracy.^14^
                             quantization for       ^15^                                                                
                             weights and                                                                                
                             calibrating the model                                                                      
                             using a representative                                                                     
                             dataset for                                                                                
                             activations.                                                                               

  **Core ML Integration      The PyTorch/TensorFlow Hugging Face Core \- **Conversion:**                                ML Program is the preferred
  (Phase 2.2)**              checkpoint must be     ML Exporters      coremltools.convert(source_model) (Outputs ML     modern format.^19^ Conversion
                             converted using the    ^18^; Core ML     Program by default in v7.0+).^19^ - **Compute     to the Core ML format is
                             coremltools exporter   Tools ML Program  Units:** Set to coremltools.ComputeUnit.ALL or    typically most stable when
                             (often via Hugging     Conversion ^19^;  CPUAndGPUAndNeuralEngine for optimal ANE          executed on macOS.^18^
                             Face Exporters) into   Compute Unit      utilization.^20^ - **Numerical Stability Check:** 
                             the **ML Program**     Settings ^20^;    If accuracy issues arise, set compute_precision   
                             format. Execution      Numerical         to Float 32 during conversion.^22^                
                             should leverage all    Debugging ^21^                                                      
                             available hardware                                                                         
                             (CPU, GPU, ANE) for                                                                        
                             maximal throughput.                                                                        

  **Model Packaging &        For the large model    Play Asset        \- **Download Status:** Use native APIs (e.g.,    Loading large models requires
  Delivery**                 file (e.g., 529MB for  Delivery (PAD)    Java/Kotlin getPackLocations()) to retrieve the   bridging the Flutter
                             Gemma 3 1B quantized   Native            absolute file path of the downloaded asset.^24^ - application to the native
                             ^23^), **Android Play  Integration ^24^; **Integrity:** Perform a **SHA-256 Checksum**     Play Core libraries (PAD/ODR)
                             Asset Delivery (PAD)** Benefits of Mmap  verification on the downloaded file after         to retrieve the absolute disk
                             and **iOS On-Demand    Loading ^26^; iOS transfer.^25^ - **Loading:** Native LiteRT-LM     path, as standard AssetBundle
                             Resources (ODR)** are  ODR Size Guidance must be initialized with the absolute file path   loading does not permit
                             the native             ^27^              for **\$\\text{mmap}\$** loading.^26^             \$\\text{mmap}\$.^28^
                             distribution                                                                               
                             mechanisms. Crucially,                                                                     
                             the model must be                                                                          
                             loaded via **Memory                                                                        
                             Mapping                                                                                    
                             (\$\\text{mmap}\$)**                                                                       
                             from a stable disk                                                                         
                             path for fast load                                                                         
                             times and improved                                                                         
                             memory efficiency.                                                                         

  **Compliance/Licensing**   Gemma 3n is licensed   Gemma Terms of    \- **Required Notice:** All distributions         You must provide all
                             for responsible        Use (Section 3:   (excluding hosted services) must include a        third-party recipients of the
                             commercial use.^2^ The Distribution)     \"Notice\" text file with the exact text:         Model Derivative (the
                             distribution of the    ^31^; Gemma 3n    **\"Gemma is provided under and subject to the    end-user) with a copy of the
                             model binary (\"Model  Commercial Use    Gemma Terms of Use found at ai. google.           full Gemma Terms of Use.^31^
                             Derivatives\") within  ^2^; Prohibited   dev/gemma/terms\"**.^31^ - **PUP:** Ensure the    
                             the Vegolo app must    Use Policy ^31^   model\'s application adheres to the Prohibited    
                             include the mandated                     Use Policy (e.g., no content that facilitates     
                             Notice text and                          illegal activities or circumvents safety          
                             provide the full Terms                   filters).^31^                                     
                             of Use to the                                                                              
                             end-user.                                                                                  
  ---------------------------------------------------------------------------------------------------------------------------------------------------
