package com.tyrAds.tyrads

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "com.tyrAds.tyrads"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
                call, result ->
            when (call.method) {

                "campaign" -> {
                    result.success(getCampaignData())
                }
                "group" -> {

                    result.success(getCreateGroupData())
                }
                "add" -> {

                    result.success(getCreateAddData())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getCampaignData(): String {

        return "For each ad campaign that you create , "+
                "you can control how much you're willing to"+
                " spend on clicks and conversions , which networks and "+
                "geographical locations you want your ads to"+
                "show on , and more .";
    }

    private fun getCreateGroupData(): String {

        return "For each ad that you create , "+
                "show on , and more .";
    }

    private fun getCreateAddData(): String {

        return "Try out different ad text to see what brings in the"+
                "most customers , and learn how to enhance your"+
                "ads using features like ad extensions . If you run"+
                "into any problems with your ads , find out how to"+
                "tell if they're running and how to resolve approval"+
                "issues .";
    }
}
