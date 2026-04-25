package com.ognitipodiinsegnamento

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        var flutterEngine: FlutterEngine? = null
        const val PLAYER_CHANNEL = "com.ognitipodiinsegnamento/player_control"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MainActivity.flutterEngine = flutterEngine

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AudioServiceChannel.CHANNEL
        ).setMethodCallHandler(AudioServiceChannel(this))
    }

    override fun onDestroy() {
        val serviceIntent = Intent(this, AudioPlayerService::class.java).apply {
            action = AudioPlayerService.ACTION_STOP
        }
        startService(serviceIntent)
        MainActivity.flutterEngine = null
        super.onDestroy()
    }
}