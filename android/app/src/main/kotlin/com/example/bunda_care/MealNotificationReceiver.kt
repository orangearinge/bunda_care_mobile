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

import android.app.AlarmManager
import android.app.PendingIntent
import java.util.Calendar

import android.util.Log

class MealNotificationReceiver : BroadcastReceiver() {

    private val TAG = "BundaCare_Receiver"

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d(TAG, "onReceive: intent action = ${intent?.action}")
        if (context == null) return

        if (intent?.action == Intent.ACTION_BOOT_COMPLETED || 
            intent?.action == "android.intent.action.QUICKBOOT_POWERON") {
            rescheduleAllAlarms(context)
            return
        }

        val mealId = intent?.getIntExtra("meal_id", -1) ?: -1
        Log.d(TAG, "onReceive: mealId = $mealId")
        if (mealId == -1) return

        // Extract scheduling details for rescheduling
        val hour = intent?.getIntExtra("hour", -1) ?: -1
        val minute = intent?.getIntExtra("minute", -1) ?: -1
        Log.d(TAG, "onReceive: hour = $hour, minute = $minute")

        // Load meal schedule data from SharedPreferences
        val sharedPrefs = context.getSharedPreferences("meal_schedules", Context.MODE_PRIVATE)
        val schedulesJson = sharedPrefs.getString("schedules", "[]") ?: "[]"
        Log.d(TAG, "onReceive: schedulesJson = $schedulesJson")

        try {
            val schedules = JSONArray(schedulesJson)

            for (i in 0 until schedules.length()) {
                val schedule = schedules.getJSONObject(i)
                if (schedule.getInt("id") == mealId) {
                    val isEnabled = schedule.getBoolean("is_enabled")
                    Log.d(TAG, "onReceive: Found schedule $mealId, isEnabled = $isEnabled")
                    // verify if enabled before showing (double check)
                   if (isEnabled) {
                       showNotification(context, schedule)
                   }
                   break
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "onReceive: JSON error: ${e.message}")
            e.printStackTrace()
        }

        // Reschedule for the next day if we have valid time data
        if (hour != -1 && minute != -1) {
            // Calculate time for tomorrow
            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                add(Calendar.DAY_OF_MONTH, 1)
            }
            scheduleAlarmExact(context, mealId, hour, minute, calendar.timeInMillis)
        }
    }

    private fun rescheduleAllAlarms(context: Context) {
        val sharedPrefs = context.getSharedPreferences("meal_schedules", Context.MODE_PRIVATE)
        val schedulesJson = sharedPrefs.getString("schedules", "[]") ?: "[]"
        val now = Calendar.getInstance()

        try {
            val schedules = JSONArray(schedulesJson)

            for (i in 0 until schedules.length()) {
                val schedule = schedules.getJSONObject(i)
                val mealId = schedule.getInt("id")
                val hour = schedule.getInt("hour")
                val minute = schedule.getInt("minute")
                val isEnabled = schedule.getBoolean("is_enabled")

                if (isEnabled) {
                    val calendar = Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, hour)
                        set(Calendar.MINUTE, minute)
                        set(Calendar.SECOND, 0)
                        set(Calendar.MILLISECOND, 0)
                        
                        // Smart scheduling:
                        // Only bump to tomorrow if this specific alarm time has ALREADY passed.
                        // This allows testing by setting a time 1 min in the future.
                        if (before(now)) {
                             add(Calendar.DAY_OF_MONTH, 1)
                        }
                    }
                    scheduleAlarmExact(context, mealId, hour, minute, calendar.timeInMillis)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun scheduleAlarmExact(context: Context, mealId: Int, hour: Int, minute: Int, timeInMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(context, MealNotificationReceiver::class.java).apply {
            action = "com.example.bunda_care.ACTION_MEAL_NOTIFICATION"
            putExtra("meal_id", mealId)
            putExtra("hour", hour)
            putExtra("minute", minute)
        }
        
        Log.d(TAG, "Rescheduling meal $mealId for $hour:$minute")

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            mealId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                timeInMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                timeInMillis,
                pendingIntent
            )
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