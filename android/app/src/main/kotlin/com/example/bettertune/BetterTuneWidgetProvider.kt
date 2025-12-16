package com.example.bettertune

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import java.io.File

class BetterTuneWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Maps to HomeWidgetService.dart keys
            val title = widgetData.getString("song_title", "No song playing")
            val artist = widgetData.getString("song_artist", "")
            val isPlaying = widgetData.getBoolean("is_playing", false)
            val albumArtPath = widgetData.getString("album_art_path", null)

            views.setTextViewText(R.id.widget_song_title, title)
            views.setTextViewText(R.id.widget_song_artist, artist)

            // Album Art
            if (albumArtPath != null) {
                val imageFile = File(albumArtPath)
                if (imageFile.exists()) {
                    val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                    views.setImageViewBitmap(R.id.widget_album_art, bitmap)
                } else {
                    views.setImageViewResource(R.id.widget_album_art, android.R.drawable.ic_menu_gallery) // Fallback
                }
            } else {
                 views.setImageViewResource(R.id.widget_album_art, android.R.drawable.ic_menu_gallery)
            }


            // Play/Pause Icon
            if (isPlaying) {
                views.setImageViewResource(R.id.widget_play_pause_button, android.R.drawable.ic_media_pause)
            } else {
                views.setImageViewResource(R.id.widget_play_pause_button, R.drawable.ic_play)
            }

            // --- Media Button Intents (Native Control) ---
            // Targeting com.ryanheise.audioservice.MediaButtonReceiver which just_audio_background uses
            val mediaComponent = android.content.ComponentName(context, "com.ryanheise.audioservice.MediaButtonReceiver")

            fun getMediaIntent(keyCode: Int): PendingIntent {
                val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
                intent.component = mediaComponent
                intent.putExtra(Intent.EXTRA_KEY_EVENT, android.view.KeyEvent(android.view.KeyEvent.ACTION_DOWN, keyCode))
                return PendingIntent.getBroadcast(
                    context, 
                    keyCode, // Request code
                    intent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            }

            views.setOnClickPendingIntent(R.id.widget_previous_button, getMediaIntent(android.view.KeyEvent.KEYCODE_MEDIA_PREVIOUS))
            views.setOnClickPendingIntent(R.id.widget_play_pause_button, getMediaIntent(android.view.KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE))
            views.setOnClickPendingIntent(R.id.widget_next_button, getMediaIntent(android.view.KeyEvent.KEYCODE_MEDIA_NEXT))
            
            // For Shuffle/Repeat, native media keys are less standard or require custom actions.
            // Leaving them as Background Broadcasts for now (might work if app alive) or remove if broken.
            // User complained they don't work.
            // Let's rely on Dart callback for these, but acknowledge limitation.
            // OR use custom action via MediaButtonReceiver? No easily.
            // Let's keep existing intent for Shuffle/Repeat but hope the previous fix (vm:entry-point) helps, 
            // OR change them to Open App? simpler to leave as is for now or use Media intent if keycodes exist.
            // KEYCODE_MEDIA_SHUFFLE exists (API 226?) No.
            // Let's stick to HomeWidgetBackgroundIntent for Shuffle/Repeat.
            val shuffleUri = Uri.parse("bettertune://widget_action?action=com.example.bettertune.SHUFFLE")
            val repeatUri = Uri.parse("bettertune://widget_action?action=com.example.bettertune.REPEAT")
            views.setOnClickPendingIntent(R.id.widget_shuffle_button, HomeWidgetBackgroundIntent.getBroadcast(context, shuffleUri))
            views.setOnClickPendingIntent(R.id.widget_repeat_button, HomeWidgetBackgroundIntent.getBroadcast(context, repeatUri))


            // --- Open App Intent (Header) ---
            val appIntent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val appPendingIntent = PendingIntent.getActivity(
                context, 
                0, 
                appIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container_main, appPendingIntent)


            // --- List View Adapter ---
            val serviceIntent = Intent(context, WidgetQueueService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.widget_queue_list, serviceIntent)
            
            // --- Queue Click Template (Open App with Data) ---
            // Instead of Broadcast, we use Activity Intent to Open App and Play
            val listClickIntent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            // The fillInIntent will add data
            val listClickPendingIntent = PendingIntent.getActivity(
                context,
                1, // Distinct request code
                listClickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE // Mutable to allow fillIn? 
                // Actually PendingIntentTemplate should be mutable? 
                // "For a collection widget, you must set a PendingIntent template... The template typically uses FLAG_MUTABLE" 
                // to allow the fillInIntent to merge data (extras).
                // Actually, FLAG_UPDATE_CURRENT is crucial. 
                // With API 31+, IMMUTABLE is default. If we want extras from fillIn, we need MUTABLE.
            )
             if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                views.setPendingIntentTemplate(R.id.widget_queue_list, 
                    PendingIntent.getActivity(
                        context,
                        1,
                        listClickIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                    )
                )
             } else {
                 views.setPendingIntentTemplate(R.id.widget_queue_list, 
                    PendingIntent.getActivity(
                        context,
                        1,
                        listClickIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT
                    )
                )
             }

            
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_queue_list)
        }
    }
}
