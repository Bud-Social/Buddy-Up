package com.buddyup.buddy_up_flutter

import android.os.Bundle
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  companion object {
    private const val CHANNEL = "com.buddyup.fit/screen_guard"
    private const val AUDIO_CHANNEL = "com.buddyup.fit/audio"
  }
  private val players = mutableMapOf<String, MediaPlayer>()

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
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "playLoop" -> {
            val key = call.argument<String>("key") ?: "ring"
            val asset = call.argument<String>("asset") ?: "assets/ringtones/incoming_ring.wav"
            playAsset(key, asset, call.argument<Boolean>("alarm") == true)
            result.success(null)
          }
          "playFile" -> {
            playFile(call.argument<String>("key") ?: "alarm", call.argument<String>("path") ?: "")
            result.success(null)
          }
          "stop" -> {
            stopAudio(call.argument<String>("key") ?: "ring")
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun attributes(alarm: Boolean): AudioAttributes = AudioAttributes.Builder()
    .setUsage(if (alarm) AudioAttributes.USAGE_ALARM else AudioAttributes.USAGE_VOICE_COMMUNICATION)
    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
    .build()

  private fun playAsset(key: String, asset: String, alarm: Boolean) {
    stopAudio(key)
    try {
      val afd = assets.openFd("flutter_assets/$asset")
      val player = MediaPlayer()
      player.setAudioAttributes(attributes(alarm))
      player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
      afd.close()
      player.isLooping = true
      player.setOnPreparedListener { it.start() }
      player.prepareAsync()
      players[key] = player
    } catch (_: Exception) { }
  }

  private fun playFile(key: String, path: String) {
    stopAudio(key)
    if (path.isBlank()) return
    try {
      val player = MediaPlayer()
      player.setAudioAttributes(attributes(true))
      player.setDataSource(path)
      player.isLooping = true
      player.setOnPreparedListener { it.start() }
      player.prepareAsync()
      players[key] = player
    } catch (_: Exception) { }
  }

  private fun stopAudio(key: String) {
    players.remove(key)?.let { try { it.stop() } catch (_: Exception) {}; it.release() }
  }

  override fun onDestroy() {
    players.keys.toList().forEach { stopAudio(it) }
    super.onDestroy()
  }
}
