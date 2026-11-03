package com.nananeko.car_expenses

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createChannels()
    }

    // Channels used by push notifications: release ones (see the FCM meta-data
    // in AndroidManifest.xml) and the calendar's, apart so that either can be
    // silenced alone. Creating an existing channel is a no-op.
    private fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        val channels = listOf(
            "updates" to R.string.notification_channel_updates,
            "appointments" to R.string.notification_channel_appointments,
        )
        for ((id, name) in channels) {
            manager.createNotificationChannel(
                NotificationChannel(id, getString(name), NotificationManager.IMPORTANCE_HIGH),
            )
        }
    }
}
