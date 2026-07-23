package com.tichutally.app.presentation.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import android.view.HapticFeedbackConstants
import androidx.compose.ui.graphics.toArgb
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tichutally.app.R
import com.tichutally.app.presentation.util.ResultImageShare
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.presentation.ui.components.*
import com.tichutally.app.presentation.ui.theme.AppTheme
import com.tichutally.app.presentation.viewmodel.GameViewModel

@Composable
fun GameScreen(
    viewModel: GameViewModel = viewModel(),
    onOpenRecords: () -> Unit = {}
) {
    val state by viewModel.state.collectAsState()
    val colors = AppTheme.colors
    var showNewGameDialog by remember { mutableStateOf(false) }
    var showSettingsDialog by remember { mutableStateOf(false) }

    val teamADisplayName = state.teamAName.ifBlank { stringResource(R.string.team_a) }
    val teamBDisplayName = state.teamBName.ifBlank { stringResource(R.string.team_b) }

    val context = LocalContext.current
    val view = LocalView.current

    // 게임 종료 시 햅틱 피드백
    LaunchedEffect(state.showWinnerDialog) {
        if (state.showWinnerDialog) {
            view.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
        }
    }

    val shareResult: () -> Unit = {
        val winnerIsA = state.winner == TeamType.TEAM_A
        ResultImageShare.share(
            context = context,
            winnerName = if (winnerIsA) teamADisplayName else teamBDisplayName,
            teamAName = teamADisplayName,
            teamAScore = state.teamAScore,
            teamAColor = colors.teamAColor.toArgb(),
            teamBName = teamBDisplayName,
            teamBScore = state.teamBScore,
            teamBColor = colors.teamBColor.toArgb(),
            winnerColor = (if (winnerIsA) colors.teamAColor else colors.teamBColor).toArgb(),
            winsText = context.getString(R.string.wins),
            roundsText = context.getString(R.string.rounds_count, state.rounds.size),
            appName = context.getString(R.string.app_name)
        )
    }

    Box(modifier = Modifier.fillMaxSize()) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.surfaceLight)
            .statusBarsPadding()
    ) {
        // 상단 바 - 설정 버튼 (좌측) / 라운드 표시 (중앙) / 새 게임 버튼 (우측)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp)
                .padding(top = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 설정 / 기록 버튼 (좌측)
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = { showSettingsDialog = true }) {
                    Icon(
                        imageVector = Icons.Default.Settings,
                        contentDescription = stringResource(R.string.settings),
                        tint = colors.textSecondary
                    )
                }
                IconButton(onClick = onOpenRecords) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.List,
                        contentDescription = stringResource(R.string.records),
                        tint = colors.textSecondary
                    )
                }
            }

            // 라운드 표시 (중앙)
            Text(
                text = stringResource(R.string.round_number, state.currentRound),
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = colors.textSecondary
            )

            // 새 게임 버튼 (우측)
            IconButton(onClick = { showNewGameDialog = true }) {
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = stringResource(R.string.new_game),
                    tint = colors.textSecondary
                )
            }
        }

        // Team Score Cards
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .padding(bottom = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            TeamScoreCard(
                teamType = TeamType.TEAM_A,
                score = state.teamAScore,
                isWinner = state.winner == TeamType.TEAM_A,
                teamName = teamADisplayName,
                modifier = Modifier
                    .weight(1f)
                    .height(100.dp)
            )
            TeamScoreCard(
                teamType = TeamType.TEAM_B,
                score = state.teamBScore,
                isWinner = state.winner == TeamType.TEAM_B,
                teamName = teamBDisplayName,
                modifier = Modifier
                    .weight(1f)
                    .height(100.dp)
            )
        }

        // 스크롤 가능한 영역
        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp)
                .padding(top = 8.dp, bottom = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Round Input Card
            RoundInputCard(
                teamACardScore = state.currentTeamACardScore,
                oneTwoFinish = state.currentOneTwoFinish,
                oneTwoFinishTeam = state.currentOneTwoFinishTeam,
                tichuCalls = state.currentTichuCalls,
                isEnabled = !state.isGameOver,
                onTeamAScoreChanged = { viewModel.setTeamACardScore(it) },
                onOneTwoFinishChanged = { enabled, team ->
                    viewModel.setOneTwoFinish(enabled, team)
                },
                onTichuCallChanged = { player, type, success ->
                    viewModel.setTichuCall(player, type, success)
                },
                onAddRound = {
                    view.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
                    viewModel.addRound()
                }
            )

            // Score History Card
            ScoreHistoryCard(
                rounds = state.rounds,
                scores = state.roundScores,
                onDeleteRound = {
                    view.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
                    viewModel.deleteRound(it)
                }
            )

            // Bottom spacing
            Spacer(modifier = Modifier.height(16.dp))
        }

        // 하단 고정 - AdMob 배너 광고
        AdBanner(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
        )
    }

        // 라운드 삭제 실행취소 스낵바
        if (state.showUndoDelete) {
            Snackbar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .navigationBarsPadding()
                    .padding(16.dp),
                action = {
                    TextButton(onClick = { viewModel.undoDelete() }) {
                        Text(stringResource(R.string.undo))
                    }
                }
            ) {
                Text(stringResource(R.string.round_deleted))
            }
            LaunchedEffect(state.showUndoDelete) {
                kotlinx.coroutines.delay(4000)
                viewModel.dismissUndo()
            }
        }
    }

    // Settings Dialog
    if (showSettingsDialog) {
        SettingsDialog(
            currentTargetScore = state.targetScore,
            currentThemeMode = state.themeMode,
            currentTeamAName = state.teamAName,
            currentTeamBName = state.teamBName,
            onTargetScoreChanged = { viewModel.setTargetScore(it) },
            onThemeModeChanged = { viewModel.setThemeMode(it) },
            onTeamNamesChanged = { a, b -> viewModel.setTeamNames(a, b) },
            onDismiss = { showSettingsDialog = false }
        )
    }

    // New Game Confirmation Dialog
    if (showNewGameDialog) {
        NewGameDialog(
            currentTeamAScore = state.teamAScore,
            currentTeamBScore = state.teamBScore,
            roundCount = state.rounds.size,
            onConfirm = {
                showNewGameDialog = false
                viewModel.newGame()
            },
            onDismiss = { showNewGameDialog = false }
        )
    }

    // Winner Dialog
    if (state.showWinnerDialog && state.winner != null) {
        WinnerDialog(
            winner = state.winner!!,
            winnerName = if (state.winner == TeamType.TEAM_A) teamADisplayName else teamBDisplayName,
            onShare = shareResult,
            teamAScore = state.teamAScore,
            teamBScore = state.teamBScore,
            onNewGame = {
                viewModel.dismissWinnerDialog()
                viewModel.newGame()
            },
            onDismiss = { viewModel.dismissWinnerDialog() }
        )
    }
}
