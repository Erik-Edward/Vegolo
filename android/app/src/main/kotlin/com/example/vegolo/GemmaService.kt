package com.example.vegolo

import android.content.Context
import android.os.SystemClock
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
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

        if (variantId.isNullOrBlank() || modelPath.isNullOrBlank()) {
            result.error(
                "invalid_args",
                "variantId and modelPath are required to load a model.",
                null,
            )
            return
        }

        Log.i(TAG, "Requested to load Gemma variant $variantId at $modelPath")

        // TODO(ai-phase-2): Validate existence of model/tokenizer files.
        // TODO(ai-phase-2): Initialise LiteRT-LM interpreter and KV cache.
        activeVariantId = variantId
        isLoaded.set(true)

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
        val timeoutMillis = call.argument<Int>("timeoutMillis") ?: DEFAULT_TIMEOUT_MS

        Log.i(
            TAG,
            "generate() invoked for variant=$activeVariantId, maxTokens=$maxTokens, timeout=$timeoutMillis",
        )

        val startNanos = SystemClock.elapsedRealtimeNanos()
        // TODO(ai-phase-2): Execute LiteRT-LM inference and stream/collect tokens.
        val latencyMillis = (SystemClock.elapsedRealtimeNanos() - startNanos) / 1_000_000

        result.success(
            mapOf(
                "text" to "",
                "latencyMs" to latencyMillis,
                "reason" to "not_implemented",
                "echo" to prompt.take(64),
            ),
        )
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
