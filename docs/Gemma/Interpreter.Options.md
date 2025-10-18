[Interpreter.Options]{.underline}

[public static class **Interpreter.Options**]{.underline}

[An options class for controlling runtime interpreter
behavior.]{.underline}

### [Public Constructors]{.underline}

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     [[Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options#Options())()]{.underline}
  -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     [[Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options#Options(org.tensorflow.lite.InterpreterApi.Options))([InterpreterApi.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/InterpreterApi.Options)
     options)]{.underline}

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### [Public Methods]{.underline}

+-------------+--------------------------------------------------------+
| [[Interpr   | [[addDel                                               |
| eter.Option | egate](https://ai.google.dev/edge/api/tflite/java/org/ |
| s]{.underli | tensorflow/lite/Interpreter.Options#addDelegate(org.te |
| ne}](https: | nsorflow.lite.Delegate))([Delegate](https://ai.google. |
| //ai.google | dev/edge/api/tflite/java/org/tensorflow/lite/Delegate) |
| .dev/edge/a | delegate)]{.underline}                                 |
| pi/tflite/j |                                                        |
| ava/org/ten | [Adds a                                                |
| sorflow/lit | [Delegate](https://ai.google.                          |
| e/Interpret | dev/edge/api/tflite/java/org/tensorflow/lite/Delegate) |
| er.Options) | to be applied during interpreter                       |
|             | creation.]{.underline}                                 |
+=============+========================================================+
| [[Interpr   | [[addDelegateFactory](https://ai.google.dev            |
| eter.Option | /edge/api/tflite/java/org/tensorflow/lite/Interpreter. |
| s]{.underli | Options#addDelegateFactory(org.tensorflow.lite.Delegat |
| ne}](https: | eFactory))([DelegateFactory](https://ai.google.dev/edg |
| //ai.google | e/api/tflite/java/org/tensorflow/lite/DelegateFactory) |
| .dev/edge/a | delegateFactory)]{.underline}                          |
| pi/tflite/j |                                                        |
| ava/org/ten | [Adds a                                                |
| sorflow/lit | [DelegateFactory](https://ai.google.dev/edg            |
| e/Interpret | e/api/tflite/java/org/tensorflow/lite/DelegateFactory) |
| er.Options) | which will be invoked to apply its created             |
|             | [Delegate](https://ai.google.                          |
|             | dev/edge/api/tflite/java/org/tensorflow/lite/Delegate) |
|             | during interpreter creation.]{.underline}              |
+-------------+--------------------------------------------------------+
| [[Interpr   | [[setAllowBufferHandleOutput](https://ai.google.d      |
| eter.Option | ev/edge/api/tflite/java/org/tensorflow/lite/Interprete |
| s]{.underli | r.Options#setAllowBufferHandleOutput(boolean))(boolean |
| ne}](https: | allow)]{.underline}                                    |
| //ai.google |                                                        |
| .dev/edge/a | [Advanced: Set if buffer handle output is              |
| pi/tflite/j | allowed.]{.underline}                                  |
| ava/org/ten |                                                        |
| sorflow/lit |                                                        |
| e/Interpret |                                                        |
| er.Options) |                                                        |
+-------------+--------------------------------------------------------+
| [[Interpr   | [[setAllowFp16PrecisionForFp32](https://ai.google.dev  |
| eter.Option | /edge/api/tflite/java/org/tensorflow/lite/Interpreter. |
| s]{.underli | Options#setAllowFp16PrecisionForFp32(boolean))(boolean |
| ne}](https: | allow)]{.underline}                                    |
| //ai.google |                                                        |
| .dev/edge/a | *[This method is deprecated. Prefer using              |
| pi/tflite/j | [NnApiDelegate.Options#setAllowFp16(boolean            |
| ava/org/ten | enable)](https://github.com/tensorflow/tensorflow/     |
| sorflow/lit | blob/5dc7f6981fdaf74c8c5be41f393df705841fb7c5/tensorfl |
| e/Interpret | ow/lite/delegates/nnapi/java/src/main/java/org/tensorf |
| er.Options) | low/lite/nnapi/NnApiDelegate.java#L127).]{.underline}* |
+-------------+--------------------------------------------------------+
| [[Interpr   | [[setCancellable](https:/                              |
| eter.Option | /ai.google.dev/edge/api/tflite/java/org/tensorflow/lit |
| s]{.underli | e/Interpreter.Options#setCancellable(boolean))(boolean |
| ne}](https: | allow)]{.underline}                                    |
| //ai.google |                                                        |
| .dev/edge/a | [Advanced: Set if the interpreter is able to be        |
| pi/tflite/j | cancelled.]{.underline}                                |
| ava/org/ten |                                                        |
| sorflow/lit |                                                        |
| e/Interpret |                                                        |
| er.Options) |                                                        |
+-------------+--------------------------------------------------------+
| [[Interpr   | [[setNumThreads                                        |
| eter.Option | ](https://ai.google.dev/edge/api/tflite/java/org/tenso |
| s]{.underli | rflow/lite/Interpreter.Options#setNumThreads(int))(int |
| ne}](https: | numThreads)]{.underline}                               |
| //ai.google |                                                        |
| .dev/edge/a | [Sets the number of threads to be used for ops that    |
| pi/tflite/j | support multi-threading.]{.underline}                  |
| ava/org/ten |                                                        |
| sorflow/lit |                                                        |
| e/Interpret |                                                        |
| er.Options) |                                                        |
+-------------+--------------------------------------------------------+
| [[Interpr   | [[setRuntime](https://ai.google.dev/                   |
| eter.Option | edge/api/tflite/java/org/tensorflow/lite/Interpreter.O |
| s]{.underli | ptions#setRuntime(org.tensorflow.lite.InterpreterApi.O |
| ne}](https: | ptions.TfLiteRuntime))([InterpreterApi.Options.TfLiteR |
| //ai.google | untime](https://ai.google.dev/edge/api/tflite/java/org |
| .dev/edge/a | /tensorflow/lite/InterpreterApi.Options.TfLiteRuntime) |
| pi/tflite/j | runtime)]{.underline}                                  |
| ava/org/ten |                                                        |
| sorflow/lit | [Specify where to get the TF Lite runtime              |
| e/Interpret | implementation from.]{.underline}                      |
| er.Options) |                                                        |
+-------------+--------------------------------------------------------+
| [[Interpr   | [[setUseNNAPI](http                                    |
| eter.Option | s://ai.google.dev/edge/api/tflite/java/org/tensorflow/ |
| s]{.underli | lite/Interpreter.Options#setUseNNAPI(boolean))(boolean |
| ne}](https: | useNNAPI)]{.underline}                                 |
| //ai.google |                                                        |
| .dev/edge/a | [Sets whether to use NN API (if available) for op      |
| pi/tflite/j | execution.]{.underline}                                |
| ava/org/ten |                                                        |
| sorflow/lit |                                                        |
| e/Interpret |                                                        |
| er.Options) |                                                        |
+-------------+--------------------------------------------------------+
| [[Interpr   | [[setUseXNNPACK](https:                                |
| eter.Option | //ai.google.dev/edge/api/tflite/java/org/tensorflow/li |
| s]{.underli | te/Interpreter.Options#setUseXNNPACK(boolean))(boolean |
| ne}](https: | useXNNPACK)]{.underline}                               |
| //ai.google |                                                        |
| .dev/edge/a | [Enable or disable an optimized set of CPU kernels     |
| pi/tflite/j | (provided by XNNPACK).]{.underline}                    |
| ava/org/ten |                                                        |
| sorflow/lit |                                                        |
| e/Interpret |                                                        |
| er.Options) |                                                        |
+-------------+--------------------------------------------------------+

### [Inherited Methods]{.underline}

[From class
[org.tensorflow.lite.InterpreterApi.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/InterpreterApi.Options)]{.underline}

+------------------------+---------------------------------------------+
| [[InterpreterAp        | [[addDelegat                                |
| i.Options]{.underline} | e](https://ai.google.dev/edge/api/tflite/ja |
| ](https://ai.google.de | va/org/tensorflow/lite/InterpreterApi.Optio |
| v/edge/api/tflite/java | ns#addDelegate(org.tensorflow.lite.Delegate |
| /org/tensorflow/lite/I | ))([Delegate](https://ai.google.dev/edge/ap |
| nterpreterApi.Options) | i/tflite/java/org/tensorflow/lite/Delegate) |
|                        | delegate)]{.underline}                      |
|                        |                                             |
|                        | [Adds a                                     |
|                        | [Delegate](https://ai.google.dev/edge/ap    |
|                        | i/tflite/java/org/tensorflow/lite/Delegate) |
|                        | to be applied during interpreter            |
|                        | creation.]{.underline}                      |
+========================+=============================================+
| [[InterpreterAp        | [[ad                                        |
| i.Options]{.underline} | dDelegateFactory](https://ai.google.dev/edg |
| ](https://ai.google.de | e/api/tflite/java/org/tensorflow/lite/Inter |
| v/edge/api/tflite/java | preterApi.Options#addDelegateFactory(org.te |
| /org/tensorflow/lite/I | nsorflow.lite.DelegateFactory))([DelegateFa |
| nterpreterApi.Options) | ctory](https://ai.google.dev/edge/api/tflit |
|                        | e/java/org/tensorflow/lite/DelegateFactory) |
|                        | delegateFactory)]{.underline}               |
|                        |                                             |
|                        | [Adds a                                     |
|                        | [DelegateFa                                 |
|                        | ctory](https://ai.google.dev/edge/api/tflit |
|                        | e/java/org/tensorflow/lite/DelegateFactory) |
|                        | which will be invoked to apply its created  |
|                        | [Delegate](https://ai.google.dev/edge/ap    |
|                        | i/tflite/java/org/tensorflow/lite/Delegate) |
|                        | during interpreter creation.]{.underline}   |
+------------------------+---------------------------------------------+
| [[ValidatedAccel       | [[getAccelerationConf                       |
| erationConfig]{.underl | ig](https://ai.google.dev/edge/api/tflite/j |
| ine}](https://ai.googl | ava/org/tensorflow/lite/InterpreterApi.Opti |
| e.dev/edge/api/tflite/ | ons#getAccelerationConfig())()]{.underline} |
| java/org/tensorflow/li |                                             |
| te/acceleration/Valida | [Return the acceleration                    |
| tedAccelerationConfig) | configuration.]{.underline}                 |
+------------------------+---------------------------------------------+
| [[List                 | [[getDelegateFactor                         |
| ](https://developer.an | ies](https://ai.google.dev/edge/api/tflite/ |
| droid.com/reference/ja | java/org/tensorflow/lite/InterpreterApi.Opt |
| va/util/List.html)\<[D | ions#getDelegateFactories())()]{.underline} |
| elegateFactory](https: |                                             |
| //ai.google.dev/edge/a | [Returns the list of delegate factories     |
| pi/tflite/java/org/ten | that have been registered via               |
| sorflow/lite/DelegateF | addDelegateFactory).]{.underline}           |
| actory)\>]{.underline} |                                             |
+------------------------+---------------------------------------------+
| [[List](https:         | [[g                                         |
| //developer.android.co | etDelegates](https://ai.google.dev/edge/api |
| m/reference/java/util/ | /tflite/java/org/tensorflow/lite/Interprete |
| List.html)\<[Delegate] | rApi.Options#getDelegates())()]{.underline} |
| (https://ai.google.dev |                                             |
| /edge/api/tflite/java/ | [Returns the list of delegates intended to  |
| org/tensorflow/lite/De | be applied during interpreter creation that |
| legate)\>]{.underline} | have been registered via                    |
|                        | addDelegate.]{.underline}                   |
+------------------------+---------------------------------------------+
| [int]{.underline}      | [[get                                       |
|                        | NumThreads](https://ai.google.dev/edge/api/ |
|                        | tflite/java/org/tensorflow/lite/Interpreter |
|                        | Api.Options#getNumThreads())()]{.underline} |
|                        |                                             |
|                        | [Returns the number of threads to be used   |
|                        | for ops that support                        |
|                        | multi-threading.]{.underline}               |
+------------------------+---------------------------------------------+
| [[InterpreterApi.Opti  | [[getRuntime](https://ai.google.dev/edge/a  |
| ons.TfLiteRuntime]{.un | pi/tflite/java/org/tensorflow/lite/Interpre |
| derline}](https://ai.g | terApi.Options#getRuntime())()]{.underline} |
| oogle.dev/edge/api/tfl |                                             |
| ite/java/org/tensorflo | [Return where to get the TF Lite runtime    |
| w/lite/InterpreterApi. | implementation from.]{.underline}           |
| Options.TfLiteRuntime) |                                             |
+------------------------+---------------------------------------------+
| [boolean]{.underline}  | [                                           |
|                        | [getUseNNAPI](https://ai.google.dev/edge/ap |
|                        | i/tflite/java/org/tensorflow/lite/Interpret |
|                        | erApi.Options#getUseNNAPI())()]{.underline} |
|                        |                                             |
|                        | [Returns whether to use NN API (if          |
|                        | available) for op execution.]{.underline}   |
+------------------------+---------------------------------------------+
| [boolean]{.underline}  | [[get                                       |
|                        | UseXNNPACK](https://ai.google.dev/edge/api/ |
|                        | tflite/java/org/tensorflow/lite/Interpreter |
|                        | Api.Options#getUseXNNPACK())()]{.underline} |
+------------------------+---------------------------------------------+
| [boolean]{.underline}  | [[isC                                       |
|                        | ancellable](https://ai.google.dev/edge/api/ |
|                        | tflite/java/org/tensorflow/lite/Interpreter |
|                        | Api.Options#isCancellable())()]{.underline} |
|                        |                                             |
|                        | [Advanced: Returns whether the interpreter  |
|                        | is able to be cancelled.]{.underline}       |
+------------------------+---------------------------------------------+
| [[InterpreterAp        | [[setAccelerationConfig](http               |
| i.Options]{.underline} | s://ai.google.dev/edge/api/tflite/java/org/ |
| ](https://ai.google.de | tensorflow/lite/InterpreterApi.Options#setA |
| v/edge/api/tflite/java | ccelerationConfig(org.tensorflow.lite.accel |
| /org/tensorflow/lite/I | eration.ValidatedAccelerationConfig))([Vali |
| nterpreterApi.Options) | datedAccelerationConfig](https://ai.google. |
|                        | dev/edge/api/tflite/java/org/tensorflow/lit |
|                        | e/acceleration/ValidatedAccelerationConfig) |
|                        | config)]{.underline}                        |
|                        |                                             |
|                        | [Specify the acceleration                   |
|                        | configuration.]{.underline}                 |
+------------------------+---------------------------------------------+
| [[InterpreterAp        | [[setCa                                     |
| i.Options]{.underline} | ncellable](https://ai.google.dev/edge/api/t |
| ](https://ai.google.de | flite/java/org/tensorflow/lite/InterpreterA |
| v/edge/api/tflite/java | pi.Options#setCancellable(boolean))(boolean |
| /org/tensorflow/lite/I | allow)]{.underline}                         |
| nterpreterApi.Options) |                                             |
|                        | [Advanced: Set if the interpreter is able   |
|                        | to be cancelled.]{.underline}               |
+------------------------+---------------------------------------------+
| [[InterpreterAp        | [[setNumThreads](https://ai.google.dev/e    |
| i.Options]{.underline} | dge/api/tflite/java/org/tensorflow/lite/Int |
| ](https://ai.google.de | erpreterApi.Options#setNumThreads(int))(int |
| v/edge/api/tflite/java | numThreads)]{.underline}                    |
| /org/tensorflow/lite/I |                                             |
| nterpreterApi.Options) | [Sets the number of threads to be used for  |
|                        | ops that support                            |
|                        | multi-threading.]{.underline}               |
+------------------------+---------------------------------------------+
| [[InterpreterAp        | [[setRun                                    |
| i.Options]{.underline} | time](https://ai.google.dev/edge/api/tflite |
| ](https://ai.google.de | /java/org/tensorflow/lite/InterpreterApi.Op |
| v/edge/api/tflite/java | tions#setRuntime(org.tensorflow.lite.Interp |
| /org/tensorflow/lite/I | reterApi.Options.TfLiteRuntime))([Interpret |
| nterpreterApi.Options) | erApi.Options.TfLiteRuntime](https://ai.goo |
|                        | gle.dev/edge/api/tflite/java/org/tensorflow |
|                        | /lite/InterpreterApi.Options.TfLiteRuntime) |
|                        | runtime)]{.underline}                       |
|                        |                                             |
|                        | [Specify where to get the TF Lite runtime   |
|                        | implementation from.]{.underline}           |
+------------------------+---------------------------------------------+
| [[InterpreterAp        | [                                           |
| i.Options]{.underline} | [setUseNNAPI](https://ai.google.dev/edge/ap |
| ](https://ai.google.de | i/tflite/java/org/tensorflow/lite/Interpret |
| v/edge/api/tflite/java | erApi.Options#setUseNNAPI(boolean))(boolean |
| /org/tensorflow/lite/I | useNNAPI)]{.underline}                      |
| nterpreterApi.Options) |                                             |
|                        | [Sets whether to use NN API (if available)  |
|                        | for op execution.]{.underline}              |
+------------------------+---------------------------------------------+
| [[InterpreterAp        | [[set                                       |
| i.Options]{.underline} | UseXNNPACK](https://ai.google.dev/edge/api/ |
| ](https://ai.google.de | tflite/java/org/tensorflow/lite/Interpreter |
| v/edge/api/tflite/java | Api.Options#setUseXNNPACK(boolean))(boolean |
| /org/tensorflow/lite/I | useXNNPACK)]{.underline}                    |
| nterpreterApi.Options) |                                             |
|                        | [Enable or disable an optimized set of CPU  |
|                        | kernels (provided by XNNPACK).]{.underline} |
+------------------------+---------------------------------------------+

[From class java.lang.Object]{.underline}

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [boolean]{.underline}                                                                     [equals([Object](https://developer.android.com/reference/java/lang/Object.html)
                                                                                            arg0)]{.underline}
  ----------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------
  [final                                                                                    [getClass()]{.underline}
  [Class](https://developer.android.com/reference/java/lang/Class.html)\<?\>]{.underline}   

  [int]{.underline}                                                                         [hashCode()]{.underline}

  [final void]{.underline}                                                                  [notify()]{.underline}

  [final void]{.underline}                                                                  [notifyAll()]{.underline}

  [[String]{.underline}](https://developer.android.com/reference/java/lang/String.html)     [toString()]{.underline}

  [final void]{.underline}                                                                  [wait(long arg0, int arg1)]{.underline}

  [final void]{.underline}                                                                  [wait(long arg0)]{.underline}

  [final void]{.underline}                                                                  [wait()]{.underline}
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## [Public Constructors]{.underline}

#### [public **Options** ()]{.underline} 

#### [public **Options** ([InterpreterApi.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/InterpreterApi.Options) options)]{.underline} 

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [options]{.underline}                                     
  --------------------------------------------------------- -------------

  -----------------------------------------------------------------------

## [Public Methods]{.underline}

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **addDelegate** ([Delegate](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Delegate) delegate)]{.underline} 

[Adds a
[Delegate](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Delegate)
to be applied during interpreter creation.]{.underline}

[Delegates added here are applied before any delegates created from a
[DelegateFactory](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/DelegateFactory)
that was added with
[addDelegateFactory(DelegateFactory)](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/InterpreterApi.Options#addDelegateFactory(org.tensorflow.lite.DelegateFactory)).]{.underline}

[Note that TF Lite in Google Play Services (see
[setRuntime(InterpreterApi.Options.TfLiteRuntime)](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/InterpreterApi.Options#setRuntime(org.tensorflow.lite.InterpreterApi.Options.TfLiteRuntime)))
does not support external (developer-provided) delegates, and adding a
[Delegate](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Delegate)
other than
[ERROR(/NnApiDelegate)](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options)
here is not allowed when using TF Lite in Google Play
Services.]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [delegate]{.underline}                                     
  ---------------------------------------------------------- ------------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **addDelegateFactory** ([DelegateFactory](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/DelegateFactory) delegateFactory)]{.underline} 

[Adds a
[DelegateFactory](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/DelegateFactory)
which will be invoked to apply its created
[Delegate](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Delegate)
during interpreter creation.]{.underline}

[Delegates from a delegated factory that was added here are applied
after any delegates added with
[addDelegate(Delegate)](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/InterpreterApi.Options#addDelegate(org.tensorflow.lite.Delegate)).]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [delegateFactory]{.underline}                                  
  -------------------------------------------------------------- --------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **setAllowBufferHandleOutput** (boolean allow)]{.underline} 

[Advanced: Set if buffer handle output is allowed.]{.underline}

[When a
[Delegate](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Delegate)
supports hardware acceleration, the interpreter will make the data of
output tensors available in the CPU-allocated tensor buffers by default.
If the client can consume the buffer handle directly (e.g. reading
output from OpenGL texture), it can set this flag to false, avoiding the
copy of data to the CPU buffer. The delegate documentation should
indicate whether this is supported and how it can be used.]{.underline}

[WARNING: This is an experimental interface that is subject to
change.]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [allow]{.underline}                                   
  ----------------------------------------------------- -----------------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **setAllowFp16PrecisionForFp32** (boolean allow)]{.underline} 

[**This method is deprecated**.\
Prefer using [NnApiDelegate.Options#setAllowFp16(boolean
enable)](https://github.com/tensorflow/tensorflow/blob/5dc7f6981fdaf74c8c5be41f393df705841fb7c5/tensorflow/lite/delegates/nnapi/java/src/main/java/org/tensorflow/lite/nnapi/NnApiDelegate.java#L127).]{.underline}

[Sets whether to allow float16 precision for FP32 calculation when
possible. Defaults to false (disallow).]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [allow]{.underline}                                   
  ----------------------------------------------------- -----------------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **setCancellable** (boolean allow)]{.underline} 

[Advanced: Set if the interpreter is able to be cancelled.]{.underline}

[Interpreters may have an experimental API
[setCancelled(boolean)](https://www.tensorflow.org/lite/api_docs/java/org/tensorflow/lite/Interpreter#setCancelled(boolean)).
If this interpreter is cancellable and such a method is invoked, a
cancellation flag will be set to true. The interpreter will check the
flag between Op invocations, and if it\'s true, the interpreter will
stop execution. The interpreter will remain a cancelled state until
explicitly \"uncancelled\" by setCancelled(false).]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [allow]{.underline}                                   
  ----------------------------------------------------- -----------------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **setNumThreads** (int numThreads)]{.underline} 

[Sets the number of threads to be used for ops that support
multi-threading.]{.underline}

[numThreads should be &gt;= -1. Setting numThreads to 0 has the effect
of disabling multithreading, which is equivalent to setting numThreads
to 1. If unspecified, or set to the value -1, the number of threads used
will be implementation-defined and platform-dependent.]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [numThreads]{.underline}                                      
  ------------------------------------------------------------- ---------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **setRuntime** ([InterpreterApi.Options.TfLiteRuntime](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/InterpreterApi.Options.TfLiteRuntime) runtime)]{.underline} 

[Specify where to get the TF Lite runtime implementation
from.]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [runtime]{.underline}                                     
  --------------------------------------------------------- -------------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **setUseNNAPI** (boolean useNNAPI)]{.underline} 

[Sets whether to use NN API (if available) for op execution. Defaults to
false (disabled).]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [useNNAPI]{.underline}                                      
  ----------------------------------------------------------- -----------

  -----------------------------------------------------------------------

#### [public [Interpreter.Options](https://ai.google.dev/edge/api/tflite/java/org/tensorflow/lite/Interpreter.Options) **setUseXNNPACK** (boolean useXNNPACK)]{.underline} 

[Enable or disable an optimized set of CPU kernels (provided by
XNNPACK). Enabled by default.]{.underline}

##### **[Parameters]{.underline}**

  -----------------------------------------------------------------------
  [useXNNPACK]{.underline}
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
