package com.example.vegolo

import android.content.Context
import android.os.SystemClock
import android.util.Log
import com.google.common.util.concurrent.ListenableFuture
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInference.LlmInferenceOptions
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession.LlmInferenceSessionOptions
import com.google.mediapipe.tasks.genai.llminference.ProgressListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Android bridge for Gemma running on LiteRT-LM (MediaPipe Tasks).
 *
 * This class validates downloaded assets from the Dart side, instantiates the
 * `LlmInference` engine, and performs synchronous text generation. Results are
 * marshalled back through a MethodChannel.
 */
class GemmaService(
    private val applicationContext: Context,
    binaryMessenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
    private val streamChannel = EventChannel(binaryMessenger, STREAM_CHANNEL_NAME)
    private val isLoaded = AtomicBoolean(false)
    private val executor = Executors.newSingleThreadExecutor()

    private var activeVariantId: String? = null
    private var activeModelPath: String? = null
    private var activeTokenizerPath: String? = null
    private var loadOptions: LoadOptions = LoadOptions()
    private var llmInference: LlmInference? = null
    private var streamSink: EventChannel.EventSink? = null
    private var streamId: String? = null
    private var streamFuture: ListenableFuture<String>? = null
    private var streamSession: LlmInferenceSession? = null
    private var streamBuffer = StringBuilder()
    private var streamStartNanos: Long = 0L
    private var streamTtftMs: Long? = null
    private val streamLock = Any()

    init {
        channel.setMethodCallHandler(this)
        streamChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_LOAD -> handleLoad(call, result)
            METHOD_UNLOAD -> handleUnload(result)
            METHOD_IS_READY -> handleIsReady(result)
            METHOD_GENERATE -> handleGenerate(call, result)
            METHOD_GENERATE_STREAM -> handleGenerateStream(call, result)
            METHOD_CANCEL_STREAM -> handleCancelStream(call, result)
            else -> result.notImplemented()
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        streamChannel.setStreamHandler(null)
        cancelActiveStream("disposed")
        closeEngine()
        executor.shutdownNow()
    }

    private fun handleLoad(call: MethodCall, result: MethodChannel.Result) {
        val variantId = call.argument<String>("variantId")
        val modelPath = call.argument<String>("modelPath")
        val tokenizerPath = call.argument<String>("tokenizerPath")
        val options = call.argument<Map<String, Any?>>("options")

        if (variantId.isNullOrBlank() || modelPath.isNullOrBlank()) {
            result.error(
                "invalid_args",
                "variantId and modelPath are required to load a model.",
                null,
            )
            return
        }

        Log.i(TAG, "Requested to load Gemma variant $variantId at $modelPath")

        val modelFile = File(modelPath)
        if (!modelFile.exists() || !modelFile.isFile) {
            result.error(
                "missing_model",
                "Model file not found at $modelPath",
                null,
            )
            return
        }

        if (!tokenizerPath.isNullOrBlank()) {
            val tokenizerFile = File(tokenizerPath)
            if (!tokenizerFile.exists() || !tokenizerFile.isFile) {
                Log.w(TAG, "Tokenizer file not found at $tokenizerPath — continuing (optional)")
            }
        }

        loadOptions = LoadOptions.fromMap(options)
        Log.i(
            TAG,
            "Load options => threads=${loadOptions.numThreads}, backend=${loadOptions.useNnapi}, timeout=${loadOptions.defaultTimeoutMs}",
        )

        try {
            initialiseEngine(modelPath)
        } catch (error: Exception) {
            Log.e(TAG, "Failed to initialise LlmInference", error)
            closeEngine()
            isLoaded.set(false)
            activeVariantId = null
            result.error("load_failed", error.message, null)
            return
        }

        activeVariantId = variantId
        activeModelPath = modelPath
        activeTokenizerPath = tokenizerPath
        isLoaded.set(true)

        result.success(
            mapOf(
                "status" to "loaded",
                "variantId" to variantId,
                "modelPath" to modelPath,
                "tokenizerPath" to tokenizerPath,
                "options" to options.orEmpty(),
            ),
        )
    }

    private fun handleUnload(result: MethodChannel.Result) {
        if (!isLoaded.get()) {
            result.success(mapOf("status" to "idle"))
            return
        }

        Log.i(TAG, "Unloading Gemma variant $activeVariantId")
        closeEngine()
        isLoaded.set(false)
        activeVariantId = null
        activeModelPath = null
        activeTokenizerPath = null

        result.success(mapOf("status" to "unloaded"))
    }

    private fun handleIsReady(result: MethodChannel.Result) {
        result.success(
            mapOf(
                "loaded" to isLoaded.get(),
                "variantId" to activeVariantId,
            ),
        )
    }

    private fun handleGenerate(call: MethodCall, result: MethodChannel.Result) {
        if (!isLoaded.get()) {
            result.error(
                "not_loaded",
                "Gemma model is not loaded; call loadVariant first.",
                null,
            )
            return
        }

        val prompt = call.argument<String>("prompt") ?: ""
        val generationConfig = buildGenerationConfig(call)
        val timeoutMillis = call.argument<Int>("timeoutMillis")
            ?: (loadOptions.defaultTimeoutMs ?: DEFAULT_TIMEOUT_MS)

        Log.i(
            TAG,
            "generate() invoked for variant=$activeVariantId timeout=$timeoutMillis config=$generationConfig",
        )

        val startNanos = SystemClock.elapsedRealtimeNanos()

        val future: Future<Map<String, Any?>> = executor.submit<Map<String, Any?>> {
            val engine = llmInference ?: throw IllegalStateException("Inference engine not ready")
            val sessionOptions = buildSessionOptions(generationConfig)
            val session = LlmInferenceSession.createFromOptions(engine, sessionOptions)
            var ttftMs: Long? = null
            val buffer = StringBuilder()
            try {
                session.addQueryChunk(prompt)
                val asyncFuture = session.generateResponseAsync(
                    ProgressListener<String> { partial, _ ->
                        if (partial != null) {
                            if (partial.length >= buffer.length) {
                                buffer.setLength(0)
                                buffer.append(partial)
                            }
                            if (ttftMs == null && partial.isNotEmpty()) {
                                ttftMs = (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000
                            }
                        }
                    },
                )
                val text = asyncFuture.get(timeoutMillis.toLong(), TimeUnit.MILLISECONDS) ?: ""
                mapOf(
                    "text" to text,
                    "reason" to "success",
                    "echo" to prompt.take(64),
                    "ttftMs" to ttftMs,
                )
            } catch (timeout: java.util.concurrent.TimeoutException) {
                session.cancelGenerateResponseAsync()
                throw timeout
            } finally {
                try {
                    session.close()
                } catch (closeError: Exception) {
                    Log.w(TAG, "Failed to close LlmInferenceSession cleanly", closeError)
                }
            }
        }

        try {
            val core = future.get(timeoutMillis.toLong(), TimeUnit.MILLISECONDS)
            val latencyMillis = (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000
            result.success(core + mapOf("latencyMs" to latencyMillis))
        } catch (timeout: java.util.concurrent.TimeoutException) {
            future.cancel(true)
            result.success(
                mapOf(
                    "text" to "",
                    "reason" to "timeout",
                    "latencyMs" to (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000,
                    "echo" to prompt.take(64),
                ),
            )
        } catch (error: Exception) {
            future.cancel(true)
            Log.e(TAG, "generate() failure", error)
            result.success(
                mapOf(
                    "text" to "",
                    "reason" to "error:${error.javaClass.simpleName}",
                    "latencyMs" to (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000,
                    "echo" to prompt.take(64),
                ),
            )
        }
    }

    private fun initialiseEngine(modelPath: String) {
        val builder = LlmInferenceOptions.builder()
            .setModelPath(modelPath)

        loadOptions.defaultMaxTokens?.let { builder.setMaxTokens(it) }

        closeEngine()
        llmInference = LlmInference.createFromOptions(applicationContext, builder.build())
    }

    private fun startStreamingGeneration(
        streamId: String,
        sink: EventChannel.EventSink,
        prompt: String,
        generationConfig: GenerationConfig,
        timeoutMillis: Int,
    ) {
        val engine = llmInference
        if (engine == null) {
            sink.error(
                "not_loaded",
                "Inference engine not ready when streaming was requested.",
                null,
            )
            resetStream()
            return
        }

        val sessionOptions = buildSessionOptions(generationConfig)
        val session = LlmInferenceSession.createFromOptions(engine, sessionOptions)

        synchronized(streamLock) {
            streamSession = session
            streamFuture = null
            streamBuffer = StringBuilder()
            streamStartNanos = SystemClock.elapsedRealtimeNanos()
            streamTtftMs = null
        }

        try {
            session.addQueryChunk(prompt)
        } catch (error: Exception) {
            Log.e(TAG, "Failed to add prompt chunk for stream $streamId", error)
            sink.error("prompt_failure", error.message, null)
            cancelActiveStream("error")
            return
        }

        val future = session.generateResponseAsync(
            ProgressListener<String> { partial, done ->
                handleStreamProgress(streamId, partial ?: "", done)
            },
        )

        synchronized(streamLock) {
            streamFuture = future
        }

        try {
            val output = future.get(timeoutMillis.toLong(), TimeUnit.MILLISECONDS) ?: ""
            handleStreamCompletion(streamId, output, "success")
        } catch (cancelled: java.util.concurrent.CancellationException) {
            Log.i(TAG, "Stream $streamId cancelled")
            // Cancellation is handled via cancelActiveStream.
        } catch (timeout: java.util.concurrent.TimeoutException) {
            session.cancelGenerateResponseAsync()
            handleStreamTimeout(streamId)
        } catch (error: Exception) {
            Log.e(TAG, "Stream generation failed for $streamId", error)
            handleStreamError(streamId, error)
        } finally {
            closeStreamSession()
        }
    }

    private fun handleStreamProgress(streamId: String, partial: String, done: Boolean) {
        val sink = synchronized(streamLock) { streamSink } ?: return
        val payload = synchronized(streamLock) {
            val previousLength = streamBuffer.length
            val delta = if (partial.length >= previousLength) {
                val diff = partial.substring(previousLength)
                streamBuffer.setLength(0)
                streamBuffer.append(partial)
                diff
            } else {
                streamBuffer.setLength(0)
                streamBuffer.append(partial)
                partial
            }
            if (streamTtftMs == null && partial.isNotEmpty()) {
                streamTtftMs =
                    (SystemClock.elapsedRealtimeNanos() - streamStartNanos) / 1_000_000
            }
            val elapsedMs =
                ((SystemClock.elapsedRealtimeNanos() - streamStartNanos) / 1_000_000).toInt()
            mapOf(
                "streamId" to streamId,
                "text" to streamBuffer.toString(),
                "delta" to delta,
                "done" to done,
                "timestampMs" to elapsedMs,
                "ttftMs" to streamTtftMs,
            )
        }
        sink.success(payload)
    }

    private fun handleStreamCompletion(streamId: String, text: String, reason: String) {
        val sink = synchronized(streamLock) { streamSink } ?: return
        val latency = ((SystemClock.elapsedRealtimeNanos() - streamStartNanos) / 1_000_000).toInt()
        val ttft = synchronized(streamLock) { streamTtftMs }
        Log.i(TAG, "Stream $streamId completed (reason=$reason, latency=${latency}ms, ttft=${ttft})")
        sink.success(
            mapOf(
                "streamId" to streamId,
                "text" to text,
                "delta" to "",
                "done" to true,
                "timestampMs" to latency,
                "latencyMs" to latency,
                "ttftMs" to ttft,
                "reason" to reason,
            ),
        )
        sink.endOfStream()
        resetStream()
    }

    private fun handleStreamTimeout(streamId: String) {
        val sink = synchronized(streamLock) { streamSink } ?: return
        val text = synchronized(streamLock) { streamBuffer.toString() }
        val latency = ((SystemClock.elapsedRealtimeNanos() - streamStartNanos) / 1_000_000).toInt()
        val ttft = synchronized(streamLock) { streamTtftMs }
        Log.w(TAG, "Stream $streamId timed out after ${latency}ms (ttft=${ttft})")
        sink.success(
            mapOf(
                "streamId" to streamId,
                "text" to text,
                "delta" to "",
                "done" to true,
                "timestampMs" to latency,
                "latencyMs" to latency,
                "ttftMs" to ttft,
                "reason" to "timeout",
            ),
        )
        sink.endOfStream()
        resetStream()
    }

    private fun handleStreamError(streamId: String, error: Exception) {
        val sink = synchronized(streamLock) { streamSink } ?: return
        val latency = ((SystemClock.elapsedRealtimeNanos() - streamStartNanos) / 1_000_000).toInt()
        Log.e(TAG, "Stream $streamId failed after ${latency}ms", error)
        sink.success(
            mapOf(
                "streamId" to streamId,
                "text" to "",
                "delta" to "",
                "done" to true,
                "timestampMs" to latency,
                "latencyMs" to latency,
                "ttftMs" to synchronized(streamLock) { streamTtftMs },
                "reason" to "error:${error.javaClass.simpleName}",
            ),
        )
        sink.endOfStream()
        resetStream()
    }

    private fun cancelActiveStream(reason: String) {
        val future = synchronized(streamLock) { streamFuture }
        val session = synchronized(streamLock) { streamSession }
        val sink = synchronized(streamLock) { streamSink }
        val id = synchronized(streamLock) { streamId }

        if (future == null || sink == null || id == null) {
            resetStream()
            return
        }

        Log.i(TAG, "Cancelling stream $id (reason=$reason)")

        future.cancel(true)
        try {
            session?.cancelGenerateResponseAsync()
        } catch (error: Exception) {
            Log.w(TAG, "Error cancelling stream session", error)
        }
        closeStreamSession()

        val latency = ((SystemClock.elapsedRealtimeNanos() - streamStartNanos) / 1_000_000).toInt()
        val text = synchronized(streamLock) { streamBuffer.toString() }
        val ttft = synchronized(streamLock) { streamTtftMs }
        sink.success(
            mapOf(
                "streamId" to id,
                "text" to text,
                "delta" to "",
                "done" to true,
                "timestampMs" to latency,
                "latencyMs" to latency,
                "ttftMs" to ttft,
                "reason" to reason,
            ),
        )
        sink.endOfStream()
        resetStream()
    }

    private fun closeStreamSession() {
        try {
            streamSession?.close()
        } catch (error: Exception) {
            Log.w(TAG, "Error closing stream session", error)
        } finally {
            synchronized(streamLock) {
                streamSession = null
            }
        }
    }

    private fun resetStream() {
        synchronized(streamLock) {
            streamFuture = null
            streamSession = null
            streamBuffer = StringBuilder()
            streamTtftMs = null
            streamId = null
            streamSink = null
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val args = arguments as? Map<*, *>
        val requestedId = args?.get("streamId") as? String
        if (requestedId.isNullOrBlank()) {
            events.error("invalid_args", "streamId is required to start Gemma streaming.", null)
            return
        }

        synchronized(streamLock) {
            if (streamSink != null) {
                events.error("stream_busy", "Another Gemma stream listener is already active.", null)
                return
            }
            streamSink = events
            streamId = requestedId
            streamBuffer = StringBuilder()
            streamTtftMs = null
        }
    }

    override fun onCancel(arguments: Any?) {
        cancelActiveStream("listener_cancelled")
    }

    private fun handleGenerateStream(call: MethodCall, result: MethodChannel.Result) {
        val currentSink = synchronized(streamLock) { streamSink }
        val currentStreamId = synchronized(streamLock) { streamId }
        val requestedStreamId = call.argument<String>("streamId")

        if (requestedStreamId.isNullOrBlank()) {
            result.error("invalid_args", "streamId is required for generateStream", null)
            return
        }
        if (!isLoaded.get()) {
            result.error("not_loaded", "Gemma model is not loaded; call loadVariant first.", null)
            return
        }
        if (currentSink == null || currentStreamId != requestedStreamId) {
            result.error(
                "stream_not_ready",
                "No active EventChannel listener for streamId=$requestedStreamId",
                null,
            )
            return
        }
        synchronized(streamLock) {
            if (streamFuture != null) {
                result.error("stream_busy", "A generation stream is already running.", null)
                return
            }
        }

        val prompt = call.argument<String>("prompt") ?: ""
        val generationConfig = buildGenerationConfig(call)
        val timeoutMillis = call.argument<Int>("timeoutMillis")
            ?: (loadOptions.defaultTimeoutMs ?: DEFAULT_TIMEOUT_MS)

        Log.i(
            TAG,
            "generateStream() invoked id=$requestedStreamId timeout=$timeoutMillis config=$generationConfig",
        )

        executor.execute {
            startStreamingGeneration(
                streamId = requestedStreamId,
                sink = currentSink,
                prompt = prompt,
                generationConfig = generationConfig,
                timeoutMillis = timeoutMillis,
            )
        }

        result.success(mapOf("status" to "started", "streamId" to requestedStreamId))
    }

    private fun handleCancelStream(call: MethodCall, result: MethodChannel.Result) {
        val requestedStreamId = call.argument<String>("streamId")
        val currentStreamId = synchronized(streamLock) { streamId }
        if (requestedStreamId == null || currentStreamId != requestedStreamId) {
            result.error(
                "invalid_stream",
                "No active stream with id=$requestedStreamId",
                null,
            )
            return
        }

        cancelActiveStream("cancelled")
        result.success(mapOf("status" to "cancelled", "streamId" to requestedStreamId))
    }

    private fun buildGenerationConfig(call: MethodCall): GenerationConfig {
        fun MethodCall.intArg(key: String): Int? =
            (argument<Any?>(key) as? Number)?.toInt()

        fun MethodCall.floatArg(key: String): Float? =
            (argument<Any?>(key) as? Number)?.toFloat()

        return GenerationConfig(
            maxTokens = call.intArg("maxTokens") ?: loadOptions.defaultMaxTokens,
            topK = call.intArg("topK") ?: loadOptions.defaultTopK,
            topP = call.floatArg("topP") ?: loadOptions.defaultTopP,
            temperature = call.floatArg("temperature") ?: loadOptions.defaultTemperature,
            randomSeed = call.intArg("randomSeed") ?: loadOptions.defaultRandomSeed,
        )
    }

    private fun buildSessionOptions(config: GenerationConfig): LlmInferenceSessionOptions {
        val builder = LlmInferenceSessionOptions.builder()
        config.topK?.let { builder.setTopK(it) }
        config.topP?.let { builder.setTopP(it) }
        config.temperature?.let { builder.setTemperature(it) }
        config.randomSeed?.let { builder.setRandomSeed(it) }
        return builder.build()
    }

    private fun closeEngine() {
        try {
            llmInference?.close()
        } catch (error: Exception) {
            Log.w(TAG, "Error closing LlmInference", error)
        } finally {
            llmInference = null
        }
    }

    data class LoadOptions(
        val numThreads: Int? = null,
        val useNnapi: Boolean? = null,
        val defaultTimeoutMs: Int? = null,
        val defaultMaxTokens: Int? = null,
        val defaultTopK: Int? = null,
        val defaultTopP: Float? = null,
        val defaultTemperature: Float? = null,
        val defaultRandomSeed: Int? = null,
    ) {
        companion object {
            fun fromMap(map: Map<String, Any?>?): LoadOptions {
                if (map == null) return LoadOptions()

                fun Map<String, Any?>.intOption(key: String) = (this[key] as? Number)?.toInt()
                fun Map<String, Any?>.floatOption(key: String) = (this[key] as? Number)?.toFloat()

                return LoadOptions(
                    numThreads = map.intOption("numThreads"),
                    useNnapi = map["useNnapi"] as? Boolean,
                    defaultTimeoutMs = map.intOption("defaultTimeoutMs"),
                    defaultMaxTokens = map.intOption("maxTokens"),
                    defaultTopK = map.intOption("topK"),
                    defaultTopP = map.floatOption("topP"),
                    defaultTemperature = map.floatOption("temperature"),
                    defaultRandomSeed = map.intOption("randomSeed"),
                )
            }
        }
    }

    data class GenerationConfig(
        val maxTokens: Int? = null,
        val topK: Int? = null,
        val topP: Float? = null,
        val temperature: Float? = null,
        val randomSeed: Int? = null,
    )

    companion object {
        private const val TAG = "VegoloGemmaService"
        private const val DEFAULT_TIMEOUT_MS = 250

        const val CHANNEL_NAME = "vegolo/gemma"
        const val STREAM_CHANNEL_NAME = "vegolo/gemma_stream"
        const val METHOD_LOAD = "loadVariant"
        const val METHOD_UNLOAD = "unload"
        const val METHOD_IS_READY = "isReady"
        const val METHOD_GENERATE = "generate"
        const val METHOD_GENERATE_STREAM = "generateStream"
        const val METHOD_CANCEL_STREAM = "cancelStream"
    }
}
