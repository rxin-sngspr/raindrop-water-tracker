package com.watertracker.water_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.home_widget_layout).apply {
        // Open app on widget click
        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        // Set progress text
        val progress = widgetData.getString("widget_progress", "0 / 2000 ml")
        setTextViewText(R.id.widget_progress, progress)
      }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
