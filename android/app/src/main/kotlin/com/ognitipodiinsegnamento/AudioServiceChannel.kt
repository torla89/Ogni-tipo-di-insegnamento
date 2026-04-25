package com.ognitipodiinsegnamento

import android.app.DownloadManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AudioServiceChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.ognitipodiinsegnamento/audio_service"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startService" -> {
                val title = call.argument<String>("title") ?: ""
                val isPlaying = call.argument<Boolean>("isPlaying") ?: true
                val serviceIntent = Intent(context, AudioPlayerService::class.java).apply {
                    action = AudioPlayerService.ACTION_START
                    putExtra(AudioPlayerService.EXTRA_TITLE, title)
                    putExtra(AudioPlayerService.EXTRA_IS_PLAYING, isPlaying)
                }
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                result.success(null)
            }
            "updateService" -> {
                val title = call.argument<String>("title") ?: ""
                val isPlaying = call.argument<Boolean>("isPlaying") ?: true
                val serviceIntent = Intent(context, AudioPlayerService::class.java).apply {
                    action = if (isPlaying) AudioPlayerService.ACTION_PLAY else AudioPlayerService.ACTION_PAUSE
                    putExtra(AudioPlayerService.EXTRA_TITLE, title)
                    putExtra(AudioPlayerService.EXTRA_IS_PLAYING, isPlaying)
                }
                context.startService(serviceIntent)
                result.success(null)
            }
            "updatePosition" -> {
                val positionMs = call.argument<Int>("positionMs")?.toLong() ?: 0L
                val durationMs = call.argument<Int>("durationMs")?.toLong() ?: 0L
                val serviceIntent = Intent(context, AudioPlayerService::class.java).apply {
                    action = AudioPlayerService.ACTION_UPDATE_POSITION
                    putExtra(AudioPlayerService.EXTRA_POSITION, positionMs)
                    putExtra(AudioPlayerService.EXTRA_DURATION, durationMs)
                }
                context.startService(serviceIntent)
                result.success(null)
            }
            "stopService" -> {
                val serviceIntent = Intent(context, AudioPlayerService::class.java).apply {
                    action = AudioPlayerService.ACTION_STOP
                }
                context.startService(serviceIntent)
                result.success(null)
            }
            "downloadPodcast" -> {
                val url = call.argument<String>("url") ?: ""
                val filename = call.argument<String>("filename") ?: ""
                val title = call.argument<String>("title") ?: ""
                val request = DownloadManager.Request(Uri.parse(url))
                    .setTitle(title)
                    .setDescription("Download podcast")
                    .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                    .setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, filename)
                    .setAllowedOverMetered(true)
                    .setAllowedOverRoaming(true)
                val dm = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
                dm.enqueue(request)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}