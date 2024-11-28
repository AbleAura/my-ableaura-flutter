package com.example.my_ableaura

import android.content.Context
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class InstallReferrerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "install_referrer")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInstallReferrer" -> {
                val referrerClient = InstallReferrerClient.newBuilder(context).build()
                referrerClient.startConnection(object : InstallReferrerStateListener {
                    override fun onInstallReferrerSetupFinished(responseCode: Int) {
                        when (responseCode) {
                            InstallReferrerClient.InstallReferrerResponse.OK -> {
                                try {
                                    val response = referrerClient.installReferrer
                                    val referrerUrl = response.installReferrer
                                    val installBeginTimestamp = response.installBeginTimestampSeconds
                                    val referrerClickTimestamp = response.referrerClickTimestampSeconds

                                    val resultMap = mapOf(
                                        "referrer" to referrerUrl,
                                        "installBeginTimestamp" to installBeginTimestamp,
                                        "referrerClickTimestamp" to referrerClickTimestamp
                                    )
                                    
                                    referrerClient.endConnection()
                                    result.success(resultMap)
                                } catch (e: Exception) {
                                    referrerClient.endConnection()
                                    result.error("ERROR", e.message, null)
                                }
                            }
                            InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED -> {
                                referrerClient.endConnection()
                                result.error("NOT_SUPPORTED", "Install referrer is not supported", null)
                            }
                            InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE -> {
                                referrerClient.endConnection()
                                result.error("UNAVAILABLE", "Install referrer service is unavailable", null)
                            }
                            else -> {
                                referrerClient.endConnection()
                                result.error("UNKNOWN", "Unknown error", null)
                            }
                        }
                    }

                    override fun onInstallReferrerServiceDisconnected() {
                        result.error("DISCONNECTED", "Install referrer service disconnected", null)
                    }
                })
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}