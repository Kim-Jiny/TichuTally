package com.tichutally.app.presentation.util

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream

/** 게임 결과를 워터마크가 포함된 이미지로 렌더링해 공유한다. */
object ResultImageShare {

    fun share(
        context: Context,
        winnerName: String,
        teamAName: String,
        teamAScore: Int,
        teamAColor: Int,
        teamBName: String,
        teamBScore: Int,
        teamBColor: Int,
        winnerColor: Int,
        winsText: String,
        roundsText: String,
        appName: String
    ) {
        val bitmap = render(
            winnerName, teamAName, teamAScore, teamAColor,
            teamBName, teamBScore, teamBColor, winnerColor,
            winsText, roundsText, appName
        )

        val dir = File(context.cacheDir, "images").apply { mkdirs() }
        val file = File(dir, "tichu_result.png")
        FileOutputStream(file).use { bitmap.compress(Bitmap.CompressFormat.PNG, 100, it) }

        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "image/png"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        context.startActivity(Intent.createChooser(intent, appName))
    }

    private fun render(
        winnerName: String,
        teamAName: String,
        teamAScore: Int,
        teamAColor: Int,
        teamBName: String,
        teamBScore: Int,
        teamBColor: Int,
        winnerColor: Int,
        winsText: String,
        roundsText: String,
        appName: String
    ): Bitmap {
        val size = 1080
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        c.drawColor(Color.parseColor("#17181C"))
        val cx = size / 2f

        val bold = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)

        // 트로피
        val trophy = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            textSize = 150f
        }
        c.drawText("🏆", cx, 280f, trophy)

        // 우승 문구
        val winPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = winnerColor
            textAlign = Paint.Align.CENTER
            typeface = bold
            textSize = 80f
        }
        val winText = "$winnerName $winsText"
        while (winPaint.measureText(winText) > size - 100 && winPaint.textSize > 40f) {
            winPaint.textSize -= 4f
        }
        c.drawText(winText, cx, 460f, winPaint)

        // 점수 두 컬럼
        val leftX = 300f
        val rightX = 780f
        val nameY = 620f
        val scoreY = 760f

        val namePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            typeface = bold
            textSize = 44f
        }
        val scorePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            typeface = bold
            textSize = 120f
        }

        namePaint.color = teamAColor
        c.drawText(ellipsize(teamAName, namePaint, 400f), leftX, nameY, namePaint)
        scorePaint.color = teamAColor
        c.drawText("$teamAScore", leftX, scoreY, scorePaint)

        namePaint.color = teamBColor
        c.drawText(ellipsize(teamBName, namePaint, 400f), rightX, nameY, namePaint)
        scorePaint.color = teamBColor
        c.drawText("$teamBScore", rightX, scoreY, scorePaint)

        val vsPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#9AA0A6")
            textAlign = Paint.Align.CENTER
            textSize = 52f
        }
        c.drawText("vs", cx, scoreY - 40f, vsPaint)

        // 라운드 수
        val roundsPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#9AA0A6")
            textAlign = Paint.Align.CENTER
            textSize = 46f
        }
        c.drawText(roundsText, cx, 900f, roundsPaint)

        // 하단 앱 이름 워터마크
        val wmPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#6E7681")
            textAlign = Paint.Align.CENTER
            typeface = bold
            textSize = 48f
            letterSpacing = 0.05f
        }
        c.drawText(appName, cx, 1010f, wmPaint)

        return bmp
    }

    private fun ellipsize(text: String, paint: Paint, maxWidth: Float): String {
        if (paint.measureText(text) <= maxWidth) return text
        var end = text.length
        while (end > 1 && paint.measureText(text.substring(0, end) + "…") > maxWidth) end--
        return text.substring(0, end) + "…"
    }
}
