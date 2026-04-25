package com.ognitipodiinsegnamento

import android.app.*
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.core.app.NotificationCompat
import androidx.media.app.NotificationCompat.MediaStyle
import io.flutter.plugin.common.MethodChannel

class AudioPlayerService : Service() {

    companion object {
        const val CHANNEL_ID = "audio_playback_channel"
        const val NOTIFICATION_ID = 1
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        const val ACTION_PAUSE = "ACTION_PAUSE"
        const val ACTION_PLAY = "ACTION_PLAY"
        const val ACTION_UPDATE_POSITION = "ACTION_UPDATE_POSITION"
        const val EXTRA_TITLE = "EXTRA_TITLE"
        const val EXTRA_IS_PLAYING = "EXTRA_IS_PLAYING"
        const val EXTRA_POSITION = "EXTRA_POSITION"
        const val EXTRA_DURATION = "EXTRA_DURATION"
    }

    private lateinit var mediaSession: MediaSessionCompat
    private var wakeLock: PowerManager.WakeLock? = null
    private var currentTitle: String = ""
    private var isCurrentlyPlaying: Boolean = false
    private var ignoraCallbackMediaSession: Boolean = false
    private var currentPositionMs: Long = 0L
    private var currentDurationMs: Long = 0L

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        val mediaButtonIntent = Intent(Intent.ACTION_MEDIA_BUTTON)
        mediaButtonIntent.setClass(this, AudioPlayerService::class.java)
        val pendingMediaButtonIntent = PendingIntent.getService(
            this, 0, mediaButtonIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        mediaSession = MediaSessionCompat(this, "OgniTipoInsegnamento", null, pendingMediaButtonIntent).apply {
            setFlags(
                MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS or
                        MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
            )
            setCallback(object : MediaSessionCompat.Callback() {
                override fun onPlay() {
                    if (ignoraCallbackMediaSession) return
                    sendToFlutter("play")
                    isCurrentlyPlaying = true
                    updateNotification()
                }
                override fun onPause() {
                    if (ignoraCallbackMediaSession) return
                    sendToFlutter("pause")
                    isCurrentlyPlaying = false
                    updateNotification()
                }
                override fun onSeekTo(pos: Long) {
                    if (ignoraCallbackMediaSession) return
                    val engine = MainActivity.flutterEngine ?: return
                    android.os.Handler(mainLooper).post {
                        MethodChannel(
                            engine.dartExecutor.binaryMessenger,
                            MainActivity.PLAYER_CHANNEL
                        ).invokeMethod("seekTo", pos)
                    }
                    currentPositionMs = pos
                    updateMediaSession(currentTitle, isCurrentlyPlaying, pos, currentDurationMs)
                }
            })
            isActive = true
        }

        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "OgniTipoInsegnamento::AudioWakeLock"
        )
    }

    private fun sendToFlutter(action: String) {
        val engine = MainActivity.flutterEngine ?: return
        android.os.Handler(mainLooper).post {
            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                MainActivity.PLAYER_CHANNEL
            ).invokeMethod(action, null)
        }
    }

    private fun updateNotification() {
        val notification = buildNotification(currentTitle, isCurrentlyPlaying)
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, notification)
        if (isCurrentlyPlaying) {
            if (wakeLock?.isHeld == false) wakeLock?.acquire()
        } else {
            if (wakeLock?.isHeld == true) wakeLock?.release()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: currentTitle
        val isPlaying = intent?.getBooleanExtra(EXTRA_IS_PLAYING, true) ?: true
        val positionMs = intent?.getLongExtra(EXTRA_POSITION, currentPositionMs) ?: currentPositionMs
        val durationMs = intent?.getLongExtra(EXTRA_DURATION, currentDurationMs) ?: currentDurationMs

        when (intent?.action) {
            ACTION_START, ACTION_PLAY, ACTION_PAUSE -> {
                currentTitle = title
                isCurrentlyPlaying = isPlaying
                currentPositionMs = positionMs
                currentDurationMs = durationMs
                ignoraCallbackMediaSession = true
                if (isPlaying) {
                    if (wakeLock?.isHeld == false) wakeLock?.acquire()
                } else {
                    if (wakeLock?.isHeld == true) wakeLock?.release()
                }
                updateMediaSession(title, isPlaying, positionMs, durationMs)
                val notification = buildNotification(title, isPlaying)
                startForeground(NOTIFICATION_ID, notification)
                android.os.Handler(mainLooper).postDelayed({
                    ignoraCallbackMediaSession = false
                }, 500)
            }
            ACTION_UPDATE_POSITION -> {
                currentPositionMs = positionMs
                currentDurationMs = durationMs
                updateMediaSession(currentTitle, isCurrentlyPlaying, positionMs, durationMs)
            }
            ACTION_STOP -> {
                if (wakeLock?.isHeld == true) wakeLock?.release()
                mediaSession.isActive = false
                stopForeground(true)
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun updateMediaSession(title: String, isPlaying: Boolean, positionMs: Long, durationMs: Long) {
        val metadata = MediaMetadataCompat.Builder()
            .putString(MediaMetadataCompat.METADATA_KEY_TITLE, title)
            .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, "Ellero Balzani")
            .putString(MediaMetadataCompat.METADATA_KEY_ALBUM, "Ogni tipo di insegnamento")
            .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, durationMs)
            .build()
        mediaSession.setMetadata(metadata)

        val state = if (isPlaying) PlaybackStateCompat.STATE_PLAYING
        else PlaybackStateCompat.STATE_PAUSED
        val playbackState = PlaybackStateCompat.Builder()
            .setState(state, positionMs, 1f)
            .setActions(
                PlaybackStateCompat.ACTION_PLAY or
                        PlaybackStateCompat.ACTION_PAUSE or
                        PlaybackStateCompat.ACTION_PLAY_PAUSE or
                        PlaybackStateCompat.ACTION_SEEK_TO
            )
            .build()
        mediaSession.setPlaybackState(playbackState)
    }

    private fun buildNotification(title: String, isPlaying: Boolean): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val playPauseIcon = if (isPlaying) android.R.drawable.ic_media_pause
        else android.R.drawable.ic_media_play
        val playPauseAction = if (isPlaying) ACTION_PAUSE else ACTION_PLAY
        val playPauseLabel = if (isPlaying) "Pausa" else "Play"

        val playPausePendingIntent = PendingIntent.getService(
            this, 1,
            Intent(this, AudioPlayerService::class.java).apply {
                action = playPauseAction
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_IS_PLAYING, !isPlaying)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Large icon con il logo dell'app
        val largeIcon = BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText("Ellero Balzani")
            .setSubText("Ogni tipo di insegnamento")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setLargeIcon(largeIcon)
            .setContentIntent(pendingIntent)
            .setOngoing(isPlaying)
            .addAction(playPauseIcon, playPauseLabel, playPausePendingIntent)
            .setStyle(
                MediaStyle()
                    .setMediaSession(mediaSession.sessionToken)
                    .setShowActionsInCompactView(0)
            )
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setColorized(true)
            .setColor(0xFF4A0072.toInt())
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Riproduzione audio",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Notifica riproduzione podcast"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        if (wakeLock?.isHeld == true) wakeLock?.release()
        mediaSession.release()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}