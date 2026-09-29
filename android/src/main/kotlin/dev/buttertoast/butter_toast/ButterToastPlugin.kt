package dev.buttertoast.butter_toast

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

/** Gives Dart the app's launcher icon as PNG bytes. */
class ButterToastPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "butter_toast")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "appIcon" -> {
                val size = (call.argument<Int>("size") ?: 96).coerceIn(16, 512)
                result.success(appIconPng(size))
            }
            else -> result.notImplemented()
        }
    }

    /** The launcher icon drawn at [size] pixels, or null if it can't be read. */
    private fun appIconPng(size: Int): ByteArray? = try {
        val drawable = context.packageManager.getApplicationIcon(context.applicationInfo)
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            drawable is AdaptiveIconDrawable
        ) {
            // An adaptive icon is 108dp with the visible part in the middle
            // 72dp; draw it larger so the visible part fills the bitmap, like
            // the launcher shows it.
            val pad = size / 4
            drawable.setBounds(-pad, -pad, size + pad, size + pad)
        } else {
            drawable.setBounds(0, 0, size, size)
        }
        drawable.draw(canvas)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        bitmap.recycle()
        stream.toByteArray()
    } catch (e: Exception) {
        null
    }
}
