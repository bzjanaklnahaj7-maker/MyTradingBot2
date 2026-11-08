package com.example.alking

import android.content.Context
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import java.util.UUID

class NativeBridge(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.example.alking/native_bridge"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDeviceInfo" -> {
                // إرجاع معلومات الجهاز الحقيقية
                val deviceInfo = mapOf(
                    "brand" to Build.BRAND,
                    "model" to Build.MODEL,
                    "device" to Build.DEVICE,
                    "manufacturer" to Build.MANUFACTURER,
                    "version" to Build.VERSION.RELEASE,
                    "sdk" to Build.VERSION.SDK_INT,
                    "isPhysicalDevice" to !isEmulator()
                )
                result.success(deviceInfo)
            }
            "getAndroidId" -> {
                // إرجاع معرف الأندرويد الفريد
                val androidId = Settings.Secure.getString(
                    context.contentResolver,
                    Settings.Secure.ANDROID_ID
                )
                result.success(androidId)
            }
            "generateUUID" -> {
                result.success(UUID.randomUUID().toString())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // التحقق مما إذا كان الجهاز محاكياً أم لا
    private fun isEmulator(): Boolean {
        return (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.PRODUCT.contains("sdk_google")
                || Build.PRODUCT.contains("google_sdk")
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("sdk_x86")
                || Build.PRODUCT.contains("vbox86p")
                || Build.PRODUCT.contains("emulator")
                || Build.PRODUCT.contains("simulator")
    }
}
