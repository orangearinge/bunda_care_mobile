package com.example.bunda_care

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

class MealNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        val mealId = intent?.getIntExtra("meal_id", -1) ?: return
        if (mealId == -1) return

        // Load meal schedule data from SharedPreferences
        val sharedPrefs = context?.getSharedPreferences("meal_schedules", Context.MODE_PRIVATE)
        val schedulesJson = sharedPrefs?.getString("schedules", "[]") ?: "[]"

        try {
            val schedules = JSONArray(schedulesJson)

            for (i in 0 until schedules.length()) {
                val schedule = schedules.getJSONObject(i)
                if (schedule.getInt("id") == mealId) {
                    showNotification(context, schedule)
                    break
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showNotification(context: Context?, schedule: JSONObject) {
        val notificationManager = context?.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "meal_channel",
                "Meal Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for meal times"
                enableVibration(true)
                setShowBadge(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Get meal type and message
        val mealType = schedule.getString("meal_type")
        val customMessage = schedule.optString("custom_message", "")
        val message = if (customMessage.isNotEmpty()) customMessage else getDefaultMessage(mealType)

        // Create notification
        val notification = NotificationCompat.Builder(context, "meal_channel")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("🍽️ Pengingat Makan")
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .build()

        // Show notification
        val notificationId = schedule.getInt("id")
        notificationManager.notify(notificationId, notification)
    }

    private fun getDefaultMessage(mealType: String): String {
        return when (mealType) {
            "sarapan" -> "Waktunya sarapan, Bunda! Jaga energi untuk hari ini."
            "makan_siang" -> "Saatnya makan siang yang sehat!"
            "makan_malam" -> "Makan malam seimbang untuk kesehatan Bunda."
            else -> "Waktunya makan!"
        }
    }
}