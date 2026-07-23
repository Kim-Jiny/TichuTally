package com.tichutally.app.presentation.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.R
import com.tichutally.app.data.GameHistoryEntry
import com.tichutally.app.data.GameStats
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.presentation.ui.theme.AppTheme
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun RecordsScreen(
    history: List<GameHistoryEntry>,
    onBack: () -> Unit,
    onClearHistory: () -> Unit
) {
    val colors = AppTheme.colors
    var selectedTab by remember { mutableIntStateOf(0) }
    var showClearConfirm by remember { mutableStateOf(false) }
    val stats = remember(history) { GameStats.from(history) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.surfaceLight)
            .statusBarsPadding()
    ) {
        // Top bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = stringResource(R.string.cancel),
                    tint = colors.textSecondary
                )
            }
            Text(
                text = stringResource(R.string.records),
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = colors.textPrimary,
                modifier = Modifier.weight(1f)
            )
            if (history.isNotEmpty()) {
                IconButton(onClick = { showClearConfirm = true }) {
                    Icon(
                        imageVector = Icons.Default.Delete,
                        contentDescription = stringResource(R.string.clear_history),
                        tint = colors.textSecondary
                    )
                }
            }
        }

        TabRow(
            selectedTabIndex = selectedTab,
            containerColor = colors.surfaceLight,
            contentColor = colors.textPrimary
        ) {
            Tab(
                selected = selectedTab == 0,
                onClick = { selectedTab = 0 },
                text = { Text(stringResource(R.string.tab_history)) }
            )
            Tab(
                selected = selectedTab == 1,
                onClick = { selectedTab = 1 },
                text = { Text(stringResource(R.string.tab_stats)) }
            )
        }

        when (selectedTab) {
            0 -> HistoryTab(history)
            else -> StatsTab(stats)
        }
    }

    if (showClearConfirm) {
        AlertDialog(
            onDismissRequest = { showClearConfirm = false },
            title = { Text(stringResource(R.string.clear_history)) },
            text = { Text(stringResource(R.string.clear_history_confirm)) },
            confirmButton = {
                TextButton(onClick = {
                    showClearConfirm = false
                    onClearHistory()
                }) { Text(stringResource(R.string.confirm)) }
            },
            dismissButton = {
                TextButton(onClick = { showClearConfirm = false }) {
                    Text(stringResource(R.string.cancel))
                }
            }
        )
    }
}

@Composable
private fun HistoryTab(history: List<GameHistoryEntry>) {
    val colors = AppTheme.colors
    if (history.isEmpty()) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(
                text = stringResource(R.string.no_history),
                color = colors.textHint,
                fontSize = 15.sp
            )
        }
        return
    }
    val dateFormat = remember { SimpleDateFormat("yyyy.MM.dd HH:mm", Locale.getDefault()) }
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        items(history) { entry ->
            HistoryRow(entry, dateFormat)
        }
    }
}

@Composable
private fun HistoryRow(entry: GameHistoryEntry, dateFormat: SimpleDateFormat) {
    val colors = AppTheme.colors
    Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = colors.cardBackgroundElevated),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = dateFormat.format(Date(entry.completedAt)),
                    fontSize = 12.sp,
                    color = colors.textHint
                )
                Spacer(Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "${entry.teamAScore}",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.teamAColor
                    )
                    Text(
                        text = " : ",
                        fontSize = 18.sp,
                        color = colors.textSecondary
                    )
                    Text(
                        text = "${entry.teamBScore}",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.teamBColor
                    )
                    Spacer(Modifier.width(10.dp))
                    Text(
                        text = stringResource(R.string.rounds_count, entry.roundCount),
                        fontSize = 12.sp,
                        color = colors.textHint
                    )
                }
            }
            WinnerBadge(entry.winner)
        }
    }
}

@Composable
private fun WinnerBadge(winner: TeamType?) {
    val colors = AppTheme.colors
    val (label, color) = when (winner) {
        TeamType.TEAM_A -> stringResource(R.string.team_a_short) to colors.teamAColor
        TeamType.TEAM_B -> stringResource(R.string.team_b_short) to colors.teamBColor
        null -> stringResource(R.string.draw) to colors.textHint
    }
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(color.copy(alpha = 0.15f))
            .padding(horizontal = 12.dp, vertical = 6.dp)
    ) {
        Text(text = label, color = color, fontWeight = FontWeight.Bold, fontSize = 14.sp)
    }
}

@Composable
private fun StatsTab(stats: GameStats) {
    val colors = AppTheme.colors
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        item { StatRow(stringResource(R.string.stat_total_games), "${stats.totalGames}") }
        item {
            StatRow(
                stringResource(R.string.stat_win_rate),
                "${stringResource(R.string.team_a_short)} ${pct(stats.teamAWinRate)} · " +
                    "${stringResource(R.string.team_b_short)} ${pct(stats.teamBWinRate)}"
            )
        }
        item { StatRow(stringResource(R.string.stat_avg_rounds), oneDecimal(stats.avgRounds)) }
        item {
            StatRow(
                stringResource(R.string.stat_small_tichu),
                "${stats.smallTichuSuccess}/${stats.smallTichuAttempts} (${pct(stats.smallTichuRate)})"
            )
        }
        item {
            StatRow(
                stringResource(R.string.stat_large_tichu),
                "${stats.largeTichuSuccess}/${stats.largeTichuAttempts} (${pct(stats.largeTichuRate)})",
                valueColor = colors.largeTichuColor
            )
        }
        item { StatRow(stringResource(R.string.stat_one_two), "${stats.oneTwoFinishCount}") }
        item { StatRow(stringResource(R.string.stat_highest_score), "${stats.highestScore}") }
    }
}

@Composable
private fun StatRow(label: String, value: String, valueColor: Color? = null) {
    val colors = AppTheme.colors
    Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = colors.cardBackgroundElevated),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 14.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(text = label, fontSize = 15.sp, color = colors.textSecondary)
            Text(
                text = value,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = valueColor ?: colors.textPrimary
            )
        }
    }
}

private fun pct(rate: Double): String = "${(rate * 100).toInt()}%"
private fun oneDecimal(v: Double): String = String.format(Locale.getDefault(), "%.1f", v)
