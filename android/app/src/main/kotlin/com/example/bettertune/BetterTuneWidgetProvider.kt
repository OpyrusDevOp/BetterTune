package com.example.bettertune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

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

            views.setTextViewText(R.id.widget_song_title, title)
            views.setTextViewText(R.id.widget_song_artist, artist)

            // Play/Pause Icon
            if (isPlaying) {
                views.setImageViewResource(R.id.widget_play_pause_button, R.drawable.ic_play) // TODO: Should be pause icon, but user didn't provide one? Using play for now or standard.
                // Wait, user provided ic_play.xml. Did they provide ic_pause? 
                // User only created: widget_background, widget_album_art_background, ic_skip_previous, ic_skip_next, widget_preview.
                // Step 388/390 I created ic_play.
                // I should use android.R.drawable.ic_media_pause for now if they didn't provide custom pause.
                views.setImageViewResource(R.id.widget_play_pause_button, android.R.drawable.ic_media_pause)
            } else {
                views.setImageViewResource(R.id.widget_play_pause_button, R.drawable.ic_play)
            }

            // Button Intents
            // URI scheme matches what HomeWidgetService expects: widget_action host with action param
            val prevUri = Uri.parse("bettertune://widget_action?action=com.example.bettertune.PREVIOUS")
            val playUri = Uri.parse("bettertune://widget_action?action=com.example.bettertune.PLAY_PAUSE")
            val nextUri = Uri.parse("bettertune://widget_action?action=com.example.bettertune.NEXT")

            val prevIntent = HomeWidgetBackgroundIntent.getBroadcast(context, prevUri)
            val playIntent = HomeWidgetBackgroundIntent.getBroadcast(context, playUri)
            val nextIntent = HomeWidgetBackgroundIntent.getBroadcast(context, nextUri)

            views.setOnClickPendingIntent(R.id.widget_previous_button, prevIntent)
            views.setOnClickPendingIntent(R.id.widget_play_pause_button, playIntent)
            views.setOnClickPendingIntent(R.id.widget_next_button, nextIntent)

            // List View Adapter
            // References WidgetQueueService which user created
            val serviceIntent = Intent(context, WidgetQueueService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.widget_queue_list, serviceIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_queue_list)
        }
    }
}
