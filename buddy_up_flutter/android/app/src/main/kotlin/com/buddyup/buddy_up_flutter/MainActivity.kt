package com.buddyup.buddy_up_flutter

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  companion object {
    private const val CHANNEL = "com.buddyup.fit/screen_guard"
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "secure" -> {
            runOnUiThread {
              window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE,
              )
            }
            result.success(null)
          }
          "unsecure" -> {
            runOnUiThread { window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE) }
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }
}
