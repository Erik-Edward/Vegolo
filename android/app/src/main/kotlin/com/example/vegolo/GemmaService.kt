package com.example.vegolo

import android.content.Context
import android.os.SystemClock
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Lightweight bridge that will host the LiteRT-LM interpreter once Phase 2 wires
 * in the native Gemma runtime. The current implementation only exposes stubbed
 * responses and telemetry-safe logging to unblock Flutter scaffolding.
 */
class GemmaService(
    private val applicationContext: Context,
    binaryMessenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
    private val isLoaded = AtomicBoolean(false)
    private var activeVariantId: String? = null
    private val executor = Executors.newSingleThreadExecutor()

    // Placeholder for native runtime once wired.
    private var activeModelPath: String? = null
    private var activeTokenizerPath: String? = null
    private var loadOptions: LoadOptions = LoadOptions()

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_LOAD -> handleLoad(call, result)
            METHOD_UNLOAD -> handleUnload(result)
            METHOD_IS_READY -> handleIsReady(result)
            METHOD_GENERATE -> handleGenerate(call, result)
            else -> result.notImplemented()
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
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

        // Validate files exist to fail fast before costly init.
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
            val tFile = File(tokenizerPath)
            if (!tFile.exists() || !tFile.isFile) {
                Log.w(TAG, "Tokenizer file not found at $tokenizerPath — continuing (optional)")
            }
        }

        this.loadOptions = LoadOptions.fromMap(options)
        Log.i(
            TAG,
            "Load options => threads=${loadOptions.numThreads}, nnapi=${loadOptions.useNnapi}, timeout=${loadOptions.defaultTimeoutMs}ms",
        )

        // TODO(ai-phase-2): Validate existence of model/tokenizer files.
        // TODO(ai-phase-2): Initialise LiteRT-LM interpreter and KV cache.
        activeVariantId = variantId
        isLoaded.set(true)
        activeModelPath = modelPath
        activeTokenizerPath = tokenizerPath

        result.success(
            mapOf(
                "status" to "loaded",
                "variantId" to variantId,
                "modelPath" to modelPath,
                "tokenizerPath" to tokenizerPath,
            ),
        )
    }

    private fun handleUnload(result: MethodChannel.Result) {
        if (!isLoaded.get()) {
            result.success(mapOf("status" to "idle"))
            return
        }

        Log.i(TAG, "Unloading Gemma variant $activeVariantId")
        // TODO(ai-phase-2): Release interpreter resources and KV cache.
        activeVariantId = null
        isLoaded.set(false)

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
        val maxTokens = call.argument<Int>("maxTokens") ?: 0
        val timeoutMillis = call.argument<Int>("timeoutMillis") ?: (loadOptions.defaultTimeoutMs ?: DEFAULT_TIMEOUT_MS)

        Log.i(
            TAG,
            "generate() invoked for variant=$activeVariantId, maxTokens=$maxTokens, timeout=$timeoutMillis",
        )

        val startNanos = SystemClock.elapsedRealtimeNanos()

        val future: Future<Map<String, Any?>> = executor.submit<Map<String, Any?>> {
            // TODO(ai-phase-2): Replace with real LiteRT-LM call and token loop.
            Thread.sleep(1) // Yield once.
            mapOf(
                "text" to "",
                "reason" to "not_implemented",
                "echo" to prompt.take(64),
            )
        }

        try {
            val core = future.get(timeoutMillis.toLong(), java.util.concurrent.TimeUnit.MILLISECONDS)
            val latencyMillis = (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000
            result.success(core + mapOf("latencyMs" to latencyMillis))
        } catch (to: java.util.concurrent.TimeoutException) {
            future.cancel(true)
            result.success(
                mapOf(
                    "text" to "",
                    "latencyMs" to (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000,
                    "reason" to "timeout",
                    "echo" to prompt.take(64),
                ),
            )
        } catch (ex: Exception) {
            Log.e(TAG, "generate() failure", ex)
            result.success(
                mapOf(
                    "text" to "",
                    "latencyMs" to (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000,
                    "reason" to "error:${ex.javaClass.simpleName}",
                    "echo" to prompt.take(64),
                ),
            )
        }
    }

    data class LoadOptions(
        val numThreads: Int? = null,
        val useNnapi: Boolean? = null,
        val defaultTimeoutMs: Int? = null,
    ) {
        companion object {
            fun fromMap(map: Map<String, Any?>?): LoadOptions {
                if (map == null) return LoadOptions()
                val threads = (map["numThreads"] as? Number)?.toInt()
                val nnapi = (map["useNnapi"] as? Boolean)
                val timeout = (map["defaultTimeoutMs"] as? Number)?.toInt()
                return LoadOptions(numThreads = threads, useNnapi = nnapi, defaultTimeoutMs = timeout)
            }
        }
    }

    companion object {
        private const val TAG = "VegoloGemmaService"
        private const val DEFAULT_TIMEOUT_MS = 250

        const val CHANNEL_NAME = "vegolo/gemma"
        const val METHOD_LOAD = "loadVariant"
        const val METHOD_UNLOAD = "unload"
        const val METHOD_IS_READY = "isReady"
        const val METHOD_GENERATE = "generate"
    }
}
