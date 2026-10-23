package com.pablobricenodev.kaku

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService

class CalendarEventsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory = Factory(applicationContext)

    private class Factory(private val ctx: Context) : RemoteViewsFactory {
        private class Item(val title: String, val amount: String, val marker: Int)

        private var items: List<Item> = emptyList()
        private var selected = ""

        override fun onCreate() {}
        override fun onDestroy() {}

        override fun onDataSetChanged() {
            selected = CalState.current(ctx).selected
            val arr = CalData.load(ctx).events(selected)
            val past = selected < CalState.todayKey()
            items = (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                val kind = o.optString("k")
                Item(
                    title = (if (kind == "d") "✓ " else "") + o.optString("t"),
                    amount = o.optString("a"),
                    marker = when (kind) {
                        "p" -> if (past) R.drawable.dot_overdue else R.drawable.dot_planned
                        "d" -> R.drawable.dot_done
                        "x" -> R.drawable.dot_skipped
                        else -> R.drawable.dot_note
                    },
                )
            }
        }

        override fun getCount() = items.size

        override fun getViewAt(position: Int): RemoteViews {
            val rv = RemoteViews(ctx.packageName, R.layout.cal_event_item)
            val item = items.getOrNull(position) ?: return rv
            rv.setTextViewText(R.id.ev_title, item.title)
            rv.setTextViewText(R.id.ev_amount, item.amount)
            rv.setViewVisibility(R.id.ev_amount, if (item.amount.isEmpty()) View.GONE else View.VISIBLE)
            rv.setImageViewResource(R.id.ev_marker, item.marker)
            // Tocar un evento abre la app en ese día
            rv.setOnClickFillInIntent(
                R.id.ev_root,
                Intent().setData(Uri.parse("kaku://app/personal?tab=calendar&date=$selected")),
            )
            return rv
        }

        override fun getLoadingView(): RemoteViews? = null
        override fun getViewTypeCount() = 1
        override fun getItemId(position: Int) = position.toLong()
        override fun hasStableIds() = false
    }
}