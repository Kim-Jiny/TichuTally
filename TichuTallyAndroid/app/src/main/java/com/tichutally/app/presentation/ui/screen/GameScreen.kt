package com.tichutally.app.presentation.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tichutally.app.R
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.presentation.ui.components.*
import com.tichutally.app.presentation.ui.theme.AppTheme
import com.tichutally.app.presentation.viewmodel.GameViewModel

@Composable
fun GameScreen(
    viewModel: GameViewModel = viewModel()
) {
    val state by viewModel.state.collectAsState()
    val colors = AppTheme.colors
    var showNewGameDialog by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.surfaceLight)
            .statusBarsPadding()
    ) {
        // 상단 - New Game 버튼 (우측 상단)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .padding(top = 8.dp)
        ) {
            IconButton(
                onClick = { showNewGameDialog = true },
                modifier = Modifier.align(Alignment.TopEnd)
            ) {
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
                modifier = Modifier
                    .weight(1f)
                    .height(100.dp)
            )
            TeamScoreCard(
                teamType = TeamType.TEAM_B,
                score = state.teamBScore,
                isWinner = state.winner == TeamType.TEAM_B,
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
                onAddRound = { viewModel.addRound() }
            )

            // Score History Card
            ScoreHistoryCard(
                rounds = state.rounds,
                scores = state.roundScores,
                onDeleteRound = { viewModel.deleteRound(it) }
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

    // New Game Confirmation Dialog
    if (showNewGameDialog) {
        AlertDialog(
            onDismissRequest = { showNewGameDialog = false },
            title = {
                Text(stringResource(R.string.new_game))
            },
            text = {
                Text(stringResource(R.string.new_game_confirm))
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showNewGameDialog = false
                        viewModel.newGame()
                    }
                ) {
                    Text(
                        text = stringResource(R.string.confirm),
                        color = colors.failureColor
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { showNewGameDialog = false }) {
                    Text(stringResource(R.string.cancel))
                }
            }
        )
    }

    // Winner Dialog
    if (state.showWinnerDialog && state.winner != null) {
        val winnerName = if (state.winner == TeamType.TEAM_A) {
            stringResource(R.string.team_a)
        } else {
            stringResource(R.string.team_b)
        }

        AlertDialog(
            onDismissRequest = { viewModel.dismissWinnerDialog() },
            title = {
                Text(stringResource(R.string.game_over))
            },
            text = {
                Text(
                    text = "${stringResource(R.string.winner_message, winnerName)}\n\n" +
                            "${stringResource(R.string.final_score)}\n" +
                            "${stringResource(R.string.team_a)}: ${state.teamAScore}${stringResource(R.string.points_suffix)}\n" +
                            "${stringResource(R.string.team_b)}: ${state.teamBScore}${stringResource(R.string.points_suffix)}",
                    textAlign = TextAlign.Center
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    viewModel.dismissWinnerDialog()
                    viewModel.newGame()
                }) {
                    Text(stringResource(R.string.new_game))
                }
            },
            dismissButton = {
                TextButton(onClick = { viewModel.dismissWinnerDialog() }) {
                    Text(stringResource(R.string.confirm))
                }
            }
        )
    }
}
