package com.example.bettertune

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import android.net.Uri

class WidgetQueueService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return WidgetQueueFactory(applicationContext, intent)
    }
}

class WidgetQueueFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var queueItems: List<QueueItem> = emptyList()

    data class QueueItem(
        val id: String,
        val title: String,
        val artist: String
    )

    override fun onCreate() {
        loadQueueData()
    }

    override fun onDataSetChanged() {
        loadQueueData()
    }

    private fun loadQueueData() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val queueDataString = widgetData.getString("queue_data", null)
        
        if (queueDataString != null) {
            try {
                val jsonArray = JSONArray(queueDataString)
                val items = mutableListOf<QueueItem>()
                
                // Removed limit or increased it, showing all available in json
                for (i in 0 until jsonArray.length()) { 
                    val item = jsonArray.getJSONObject(i)
                    items.add(
                        QueueItem(
                            id = item.getString("id"),
                            title = item.getString("title"),
                            artist = item.getString("artist")
                        )
                    )
                }
                
                queueItems = items
            } catch (e: Exception) {
                e.printStackTrace()
                queueItems = emptyList()
            }
        } else {
            queueItems = emptyList()
        }
    }

    override fun onDestroy() {
        queueItems = emptyList()
    }

    override fun getCount(): Int = queueItems.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_queue_item)
        
        if (position < queueItems.size) {
            val item = queueItems[position]
            views.setTextViewText(R.id.queue_item_title, item.title)
            views.setTextViewText(R.id.queue_item_artist, item.artist)
            
            // Highlight current song
            val widgetData = HomeWidgetPlugin.getData(context)
            val currentSongId = widgetData.getString("current_song_id", "")
            
            if (item.id == currentSongId) {
                views.setTextColor(R.id.queue_item_title, android.graphics.Color.parseColor("#00A4DC"))
            } else {
                views.setTextColor(R.id.queue_item_title, android.graphics.Color.WHITE)
            }

            // Fill In Intent for Click Interaction
            val fillInIntent = Intent().apply {
                putExtra("action", "play_queue_item")
                putExtra("songId", item.id)
                // We also set a data URI to make it unique if helpful, but extras merge too.
                data = Uri.parse("bettertune://play_song/${item.id}") 
            }
            views.setOnClickFillInIntent(R.id.queue_item_root, fillInIntent)
        }
        
        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}