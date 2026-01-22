package com.example.bunda_care

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.bunda_care/meal_notifications"
    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sharedPreferences = getSharedPreferences("meal_schedules", Context.MODE_PRIVATE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleMealAlarms" -> {
                    try {
                        scheduleAllMealAlarms()
                        result.success("Alarms scheduled successfully")
                    } catch (e: Exception) {
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                "cancelMealAlarm" -> {
                    try {
                        val mealId = call.argument<Int>("mealId") ?: 0
                        cancelMealAlarm(mealId)
                        result.success("Alarm cancelled successfully")
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                "syncMealSchedules" -> {
                    try {
                        val schedulesJson = call.argument<String>("schedules") ?: "[]"
                        sharedPreferences.edit().putString("schedules", schedulesJson).apply()

                        // Re-schedule all alarms after sync
                        scheduleAllMealAlarms()
                        result.success("Meal schedules synced successfully")
                    } catch (e: Exception) {
                        result.error("SYNC_ERROR", e.message, null)
                    }
                }
                "updateMealSchedules" -> {
                    try {
                        // Re-schedule all alarms when meal schedules are updated
                        scheduleAllMealAlarms()
                        result.success("Meal schedules updated successfully")
                    } catch (e: Exception) {
                        result.error("UPDATE_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun scheduleAllMealAlarms() {
        // Cancel all existing alarms first
        cancelAllMealAlarms()

        // Load meal schedules from SharedPreferences
        val schedulesJson = sharedPreferences.getString("schedules", "[]") ?: "[]"

        try {
            val schedules = JSONArray(schedulesJson)

            for (i in 0 until schedules.length()) {
                val schedule = schedules.getJSONObject(i)
                val mealId = schedule.getInt("id")
                val mealType = schedule.getString("meal_type")
                val hour = schedule.getInt("hour")
                val minute = schedule.getInt("minute")
                val isEnabled = schedule.getBoolean("is_enabled")

                if (isEnabled) {
                    scheduleMealAlarm(mealId, hour, minute)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun scheduleMealAlarm(mealId: Int, hour: Int, minute: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(this, MealNotificationReceiver::class.java).apply {
            putExtra("meal_id", mealId)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            mealId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)

            // If the time has already passed today, schedule for tomorrow
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_MONTH, 1)
            }
        }

        // Use setRepeating for daily alarms
        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            AlarmManager.INTERVAL_DAY, // Repeat every day
            pendingIntent
        )
    }

    private fun cancelMealAlarm(mealId: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, MealNotificationReceiver::class.java)

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            mealId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
    }

    private fun cancelAllMealAlarms() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // Cancel alarms for meal IDs 1, 2, 3 (sarapan, makan_siang, makan_malam)
        for (mealId in 1..3) {
            val intent = Intent(this, MealNotificationReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                mealId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }
    }
}
