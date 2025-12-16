package com.example.bettertune

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val CHANNEL = "com.example.bettertune/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    // Widget will be updated from Dart side using home_widget
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetIntent(intent)
    }

    private fun handleWidgetIntent(intent: Intent?) {
        // Handle Action from Widget (Deep link style or Extras)
        val action = intent?.getStringExtra("action")
        val songId = intent?.getStringExtra("songId")
        
        if (action == "play_queue_item" && songId != null) {
            // Send to Dart via MethodChannel
            io.flutter.plugin.common.MethodChannel(
                flutterEngine!!.dartExecutor.binaryMessenger,
                CHANNEL
            ).invokeMethod("playSongById", songId)
        }
        
        // Also support data URI if we used that
        val data = intent?.data
        if (data != null && data.toString().startsWith("bettertune://play_song/")) {
             val id = data.lastPathSegment
             if (id != null) {
                  io.flutter.plugin.common.MethodChannel(
                    flutterEngine!!.dartExecutor.binaryMessenger,
                    CHANNEL
                ).invokeMethod("playSongById", id)
             }
        }
    }
}
