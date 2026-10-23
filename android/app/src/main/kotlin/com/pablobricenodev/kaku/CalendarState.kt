package com.pablobricenodev.kaku

import android.content.Context
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar
import java.util.Locale

class CalData(raw: String?) {
    private val root = try { JSONObject(raw ?: "{}") } catch (e: Exception) { JSONObject() }
    private val days = root.optJSONObject("days") ?: JSONObject()
    val locale: Locale =
        if (root.has("lang")) Locale.forLanguageTag(root.getString("lang")) else Locale.getDefault()
    val firstDow = root.optInt("firstDow", 1) // 0 = domingo
    val minYm = root.optString("min", "0000-00")
    val maxYm = root.optString("max", "9999-99")
    val emptyText = root.optString("empty", "")

    fun hasSpent(key: String) = days.optJSONObject(key)?.optInt("s", 0) == 1
    fun events(key: String): JSONArray = days.optJSONObject(key)?.optJSONArray("e") ?: JSONArray()

    companion object {
        fun load(ctx: Context) =
            CalData(HomeWidgetPlugin.getData(ctx).getString("calw_data", null))
    }
}

object CalState {
    private const val K_YM = "calw_ym"
    private const val K_SEL = "calw_sel"
    private const val K_FOR = "calw_for"

    class Shown(val year: Int, val month: Int, val selected: String)

    fun dayKey(y: Int, m: Int, d: Int) = "%04d-%02d-%02d".format(Locale.ROOT, y, m, d)
    fun monthKey(y: Int, m: Int) = "%04d-%02d".format(Locale.ROOT, y, m)

    fun todayKey(): String {
        val c = Calendar.getInstance()
        return dayKey(c[Calendar.YEAR], c[Calendar.MONTH] + 1, c[Calendar.DAY_OF_MONTH])
    }

    private fun prefs(ctx: Context) = HomeWidgetPlugin.getData(ctx)

    private fun store(ctx: Context, ym: String, sel: String) {
        prefs(ctx).edit()
            .putString(K_YM, ym).putString(K_SEL, sel).putString(K_FOR, todayKey())
            .apply()
    }

    fun current(ctx: Context): Shown {
        val today = todayKey()
        val p = prefs(ctx)
        if (p.getString(K_FOR, null) != today) store(ctx, today.substring(0, 7), today)
        val ym = p.getString(K_YM, today.substring(0, 7)) ?: today.substring(0, 7)
        val sel = p.getString(K_SEL, today) ?: today
        return Shown(ym.substring(0, 4).toInt(), ym.substring(5, 7).toInt(), sel)
    }

    fun select(ctx: Context, key: String) {
        if (key.length == 10) store(ctx, key.substring(0, 7), key)
    }

    fun goToday(ctx: Context) {
        val t = todayKey()
        store(ctx, t.substring(0, 7), t)
    }

    fun shiftMonth(ctx: Context, delta: Int) {
        val s = current(ctx)
        val c = Calendar.getInstance().apply { clear(); set(s.year, s.month - 1 + delta, 1) }
        val ym = monthKey(c[Calendar.YEAR], c[Calendar.MONTH] + 1)
        val data = CalData.load(ctx)
        if (ym < data.minYm || ym > data.maxYm) return
        val today = todayKey()
        store(ctx, ym, if (ym == today.substring(0, 7)) today else "$ym-01")
    }
}