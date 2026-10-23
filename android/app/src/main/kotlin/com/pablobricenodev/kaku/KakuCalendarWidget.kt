package com.pablobricenodev.kaku

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.text.format.DateFormat
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import java.text.DateFormatSymbols
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

class KakuCalendarWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { render(context, manager, it) }
        manager.notifyAppWidgetViewDataChanged(ids, R.id.cal_events)
        scheduleMidnight(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context, manager: AppWidgetManager, id: Int, newOptions: Bundle,
    ) = render(context, manager, id)

    override fun onDisabled(context: Context) {
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
            .cancel(broadcast(context, ACTION_MIDNIGHT, "kaku://widget/midnight"))
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_SELECT -> intent.data?.lastPathSegment?.let { CalState.select(context, it) }
            ACTION_PREV -> CalState.shiftMonth(context, -1)
            ACTION_NEXT -> CalState.shiftMonth(context, 1)
            ACTION_TODAY -> CalState.goToday(context)
            ACTION_MIDNIGHT -> Unit
            else -> { super.onReceive(context, intent); return }
        }
        val mgr = AppWidgetManager.getInstance(context)
        onUpdate(context, mgr, mgr.getAppWidgetIds(ComponentName(context, KakuCalendarWidget::class.java)))
    }

    private fun render(context: Context, manager: AppWidgetManager, id: Int) {
        val cal = CalData.load(context)
        val st = CalState.current(context)
        val opts = manager.getAppWidgetOptions(id)
        val w = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
        val h = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
        val wide = w >= WIDE_DP   // 4×2 o mayor: aparece el panel de eventos
        val tall = h >= TALL_DP   // alto suficiente para letra grande y puntos
        val small = !wide && !tall // 2×2: sin puntos, días con eventos en color de acento

        val gridDp = if (wide) (w - 24) * 0.6f else (w - 16).toFloat()
        val cellDp = gridDp / 7f
        val maxDaySp = if (tall) 15f else 12f
        val daySp = ((cellDp - 6f) / 1.15f).coerceIn(8f, maxDaySp)
        val headSp = when { tall -> 15f; wide -> 13f; else -> 12f }
        val shortTitle = wide && gridDp < 200f
        val loc = cal.locale
        val pkg = context.packageName
        val v = RemoteViews(pkg, R.layout.widget_calendar)

        v.setTextViewText(R.id.cal_title, monthTitle(loc, st.year, st.month, shortTitle))
        v.setTextViewTextSize(R.id.cal_title, TypedValue.COMPLEX_UNIT_SP, headSp)
        v.setOnClickPendingIntent(R.id.cal_title, broadcast(context, ACTION_TODAY, "kaku://widget/today"))
        v.setOnClickPendingIntent(R.id.cal_prev, broadcast(context, ACTION_PREV, "kaku://widget/prev"))
        v.setOnClickPendingIntent(R.id.cal_next, broadcast(context, ACTION_NEXT, "kaku://widget/next"))

        val labels = weekdayLabels(loc, cal.firstDow)
        WEEKDAYS.forEachIndexed { i, rid ->
            v.setTextViewText(rid, labels[i])
            v.setTextViewTextSize(rid, TypedValue.COMPLEX_UNIT_SP, daySp - 1)
        }

        v.removeAllViews(R.id.cal_grid)
        val first = Calendar.getInstance().apply { clear(); set(st.year, st.month - 1, 1) }
        val offset = (first[Calendar.DAY_OF_WEEK] - 1 - cal.firstDow + 7) % 7
        val dim = first.getActualMaximum(Calendar.DAY_OF_MONTH)
        val rows = (offset + dim + 6) / 7
        val today = CalState.todayKey()
        val cellLayout = if (tall) R.layout.cal_cell_l else R.layout.cal_cell

        for (r in 0 until rows) {
            val row = RemoteViews(pkg, R.layout.cal_row)
            for (c in 0 until 7) {
                val day = r * 7 + c - offset + 1
                val cell = RemoteViews(pkg, cellLayout)
                if (day in 1..dim) {
                    val key = CalState.dayKey(st.year, st.month, day)
                    cell.setTextViewText(R.id.cell_day, day.toString())
                    cell.setTextViewTextSize(R.id.cell_day, TypedValue.COMPLEX_UNIT_SP, daySp)

                    val ev = cal.events(key)
                    var planned = false; var overdue = false; var note = false
                    for (i in 0 until ev.length()) {
                        when (ev.getJSONObject(i).optString("k")) {
                            "p" -> if (key < today) overdue = true else planned = true
                            "n" -> note = true
                        }
                    }
                    val spent = cal.hasSpent(key)

                    if (small) {
                        cell.setViewVisibility(R.id.cell_dots, View.GONE)
                        if (spent || planned || overdue || note) cell.setTextColor(R.id.cell_day, ACCENT)
                    } else {
                        cell.setViewVisibility(R.id.dot_spent, if (spent) View.VISIBLE else View.GONE)
                        cell.setViewVisibility(R.id.dot_planned, if (planned || overdue) View.VISIBLE else View.GONE)
                        cell.setImageViewResource(
                            R.id.dot_planned,
                            if (overdue) R.drawable.dot_overdue else R.drawable.dot_planned,
                        )
                        cell.setViewVisibility(R.id.dot_note, if (note) View.VISIBLE else View.GONE)
                    }

                    when {
                        key == today -> {
                            cell.setInt(R.id.cell_day, "setBackgroundResource", R.drawable.bg_today)
                            cell.setTextColor(R.id.cell_day, Color.WHITE)
                        }
                        key == st.selected ->
                            cell.setInt(R.id.cell_day, "setBackgroundResource", R.drawable.bg_selected)
                    }
                    cell.setOnClickPendingIntent(
                        R.id.cell_root,
                        broadcast(context, ACTION_SELECT, "kaku://widget/day/$key"),
                    )
                } else {
                    cell.setViewVisibility(R.id.cell_dots, View.GONE)
                }
                row.addView(R.id.cal_row, cell)
            }
            v.addView(R.id.cal_grid, row)
        }

        v.setViewVisibility(R.id.cal_events_panel, if (wide) View.VISIBLE else View.GONE)
        if (wide) {
            v.setTextViewText(R.id.cal_day_label, dayLabel(loc, st.selected))
            v.setTextViewTextSize(R.id.cal_day_label, TypedValue.COMPLEX_UNIT_SP, if (tall) 14f else 12f)
            v.setTextViewText(R.id.cal_empty, cal.emptyText)
            val svc = Intent(context, CalendarEventsService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME)) // una por widget
            }
            v.setRemoteAdapter(R.id.cal_events, svc)
            v.setEmptyView(R.id.cal_events, R.id.cal_empty)
            v.setPendingIntentTemplate(R.id.cal_events, openAppTemplate(context))
        }
        manager.updateAppWidget(id, v)
    }

    private fun broadcast(context: Context, action: String, uri: String): PendingIntent {
        val i = Intent(context, KakuCalendarWidget::class.java).setAction(action).setData(Uri.parse(uri))
        return PendingIntent.getBroadcast(
            context, 0, i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun openAppTemplate(context: Context): PendingIntent {
        // Sin datos: cada evento pone los suyos (tab=calendar&date=…)
        val i = Intent(Intent.ACTION_VIEW).setPackage(context.packageName)
        val mutable = if (Build.VERSION.SDK_INT >= 31) PendingIntent.FLAG_MUTABLE else 0
        return PendingIntent.getActivity(
            context, 0, i,
            PendingIntent.FLAG_UPDATE_CURRENT or mutable or Intent.FILL_IN_DATA,
        )
    }

    // Alarma inexacta: no necesita permisos ni declaración en Play Console
    private fun scheduleMidnight(context: Context) {
        val c = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).setAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP, c.timeInMillis,
            broadcast(context, ACTION_MIDNIGHT, "kaku://widget/midnight"),
        )
    }

    private fun monthTitle(loc: Locale, y: Int, m: Int, short: Boolean): String {
        val cal = Calendar.getInstance().apply { clear(); set(y, m - 1, 1) }
        val skeleton = if (short) "yMMM" else "yMMMM"
        return SimpleDateFormat(DateFormat.getBestDateTimePattern(loc, skeleton), loc)
            .format(cal.time).replaceFirstChar { it.titlecase(loc) }
    }

    private fun dayLabel(loc: Locale, key: String): String {
        val cal = Calendar.getInstance().apply {
            clear()
            set(key.substring(0, 4).toInt(), key.substring(5, 7).toInt() - 1, key.substring(8, 10).toInt())
        }
        return SimpleDateFormat(DateFormat.getBestDateTimePattern(loc, "EEEdMMM"), loc)
            .format(cal.time).replaceFirstChar { it.titlecase(loc) }
    }

    private fun weekdayLabels(loc: Locale, firstDow: Int): List<String> {
        val names = DateFormatSymbols.getInstance(loc).shortWeekdays // 1 = domingo
        return (0 until 7).map { i -> names[(firstDow + i) % 7 + 1].trim().take(1).uppercase(loc) }
    }

    companion object {
        const val ACTION_SELECT = "kaku.widget.SELECT"
        const val ACTION_PREV = "kaku.widget.PREV"
        const val ACTION_NEXT = "kaku.widget.NEXT"
        const val ACTION_TODAY = "kaku.widget.TODAY"
        const val ACTION_MIDNIGHT = "kaku.widget.MIDNIGHT"

        private const val WIDE_DP = 240
        private const val TALL_DP = 180
        private val ACCENT = Color.parseColor("#6C5CE7") // ← igual que cal_accent

        private val WEEKDAYS = intArrayOf(
            R.id.cal_wd0, R.id.cal_wd1, R.id.cal_wd2, R.id.cal_wd3,
            R.id.cal_wd4, R.id.cal_wd5, R.id.cal_wd6,
        )
    }
}