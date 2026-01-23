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
import android.util.Log

class MainActivity : FlutterActivity() {

    private val TAG = "BundaCare_Alarm"
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
                        Log.d(TAG, "MethodChannel: scheduleMealAlarms called")
                        scheduleAllMealAlarms()
                        result.success("Alarms scheduled successfully")
                    } catch (e: Exception) {
                        Log.e(TAG, "Schedule error: ${e.message}")
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
                        Log.d(TAG, "MethodChannel: syncMealSchedules called with ${schedulesJson.length} chars")
                        
                        // Use commit() to ensure it's written before scheduling
                        val success = sharedPreferences.edit().putString("schedules", schedulesJson).commit()
                        Log.d(TAG, "Sync to SharedPreferences: $success")

                        // Re-schedule all alarms after sync
                        scheduleAllMealAlarms()
                        result.success("Meal schedules synced successfully")
                    } catch (e: Exception) {
                        Log.e(TAG, "Sync error: ${e.message}")
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
        Log.d(TAG, "scheduleAllMealAlarms: started")
        // Cancel all existing alarms first
        cancelAllMealAlarms()

        // Load meal schedules from SharedPreferences
        val schedulesJson = sharedPreferences.getString("schedules", "[]") ?: "[]"
        Log.d(TAG, "Loading schedules from prefs: $schedulesJson")

        try {
            val schedules = JSONArray(schedulesJson)
            Log.d(TAG, "Found ${schedules.length()} schedules to set")

            for (i in 0 until schedules.length()) {
                val schedule = schedules.getJSONObject(i)
                val mealId = schedule.getInt("id")
                val hour = schedule.getInt("hour")
                val minute = schedule.getInt("minute")
                val isEnabled = schedule.getBoolean("is_enabled")

                Log.d(TAG, "Checking schedule $mealId: $hour:$minute (enabled=$isEnabled)")
                if (isEnabled) {
                    scheduleMealAlarm(mealId, hour, minute)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "JSON/Scheduling error: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun scheduleMealAlarm(mealId: Int, hour: Int, minute: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(this, MealNotificationReceiver::class.java).apply {
            action = "com.example.bunda_care.ACTION_MEAL_NOTIFICATION"
            putExtra("meal_id", mealId)
            putExtra("hour", hour)
            putExtra("minute", minute)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            mealId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val now = Calendar.getInstance()
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
    
        // Only move to tomorrow if the time is ACTUALLY in the past.
        if (calendar.before(now)) {
            Log.d(TAG, "Time $hour:$minute has passed today, scheduling for tomorrow")
            calendar.add(Calendar.DAY_OF_MONTH, 1)
        } else {
            Log.d(TAG, "Time $hour:$minute is future, scheduling for today")
        }

        Log.d(TAG, "Setting exact alarm for meal $mealId at ${calendar.time}")

        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
            Log.d(TAG, "Alarm set successfully for $mealId")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set alarm for $mealId: ${e.message}")
        }
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
