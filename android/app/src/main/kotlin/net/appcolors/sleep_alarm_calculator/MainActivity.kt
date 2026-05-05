package net.appcolors.sleep_alarm_calculator

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.AlarmClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "sleep_calculator/alarm"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openDefaultAlarm" -> {
                        val hour   = call.argument<Int>("hour")   ?: return@setMethodCallHandler result.error("INVALID", "hour missing", null)
                        val minute = call.argument<Int>("minute") ?: return@setMethodCallHandler result.error("INVALID", "minute missing", null)
                        val label  = call.argument<String>("label") ?: "Sleep Alarm"
                        result.success(openDefaultAlarm(hour, minute, label))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Opens the phone's default clock app with the alarm time pre-filled.
     *
     * Layer 1 — implicit ACTION_SET_ALARM (works on stock / Google / Samsung).
     * Layer 2 — queryIntentActivities to find any registered handler dynamically
     *            (catches OEM clocks like Transsion that need explicit targeting).
     * Layer 3 — getLaunchIntentForPackage fallback for 21 known OEM packages.
     *
     * Returns "opened", "opened_launcher", or "not_found".
     */
    private fun openDefaultAlarm(hour: Int, minute: Int, label: String): String {
        val alarmExtras: Intent.() -> Unit = {
            putExtra(AlarmClock.EXTRA_HOUR, hour)
            putExtra(AlarmClock.EXTRA_MINUTES, minute)
            putExtra(AlarmClock.EXTRA_MESSAGE, label)
            putExtra(AlarmClock.EXTRA_SKIP_UI, false)
            putExtra(AlarmClock.EXTRA_VIBRATE, true)
        }

        // Layer 1 — standard implicit intent
        try {
            startActivity(Intent(AlarmClock.ACTION_SET_ALARM).apply(alarmExtras))
            return "opened"
        } catch (_: ActivityNotFoundException) {
        } catch (_: SecurityException) {}

        // Layer 2 — discover handler via PackageManager (e.g. Transsion clock)
        val probe = Intent(AlarmClock.ACTION_SET_ALARM)
        val handlers = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(probe, PackageManager.ResolveInfoFlags.of(0L))
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(probe, 0)
        }
        handlers.firstOrNull()?.activityInfo?.let { info ->
            try {
                startActivity(Intent(AlarmClock.ACTION_SET_ALARM).apply {
                    setClassName(info.packageName, info.name)
                    apply(alarmExtras)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                })
                return "opened"
            } catch (_: Exception) {}
        }

        // Layer 3 — open known OEM clock app launcher directly
        val clockPackages = listOf(
            "com.transsion.deskclock",
            "com.miui.clock",
            "com.google.android.deskclock",
            "com.android.deskclock",
            "com.samsung.android.app.clockpackage",
            "com.vivo.alarmclock",
            "com.coloros.alarmclock",
            "com.oppo.alarmclock",
            "com.oneplus.deskclock",
            "net.oneplus.deskclock",
            "com.huawei.deskclock",
            "com.bbk.deskclock",
            "com.realme.deskclock",
            "com.asus.deskclock",
            "com.lge.clock",
            "com.motorola.alarmclock",
            "com.sonyericsson.organizer",
            "com.sonymobile.deskclock",
            "com.zte.deskclock",
            "com.lenovo.deskclock",
            "com.nokia.deskclock",
            "com.tcl.clock"
        )
        for (pkg in clockPackages) {
            packageManager.getLaunchIntentForPackage(pkg)?.let { launch ->
                try {
                    startActivity(launch)
                    return "opened_launcher"
                } catch (_: Exception) {}
            }
        }

        return "not_found"
    }
}
