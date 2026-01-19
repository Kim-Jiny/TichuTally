package com.tichutally.app.presentation.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tichutally.app.R
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.presentation.ui.components.*
import com.tichutally.app.presentation.ui.theme.SurfaceLight
import com.tichutally.app.presentation.viewmodel.GameViewModel

@Composable
fun GameScreen(
    viewModel: GameViewModel = viewModel()
) {
    val state by viewModel.state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(SurfaceLight)
            .statusBarsPadding()
    ) {
        // 상단 고정 - Team Score Cards
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .padding(top = 16.dp, bottom = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            TeamScoreCard(
                teamType = TeamType.TEAM_A,
                score = state.teamAScore,
                isWinner = state.winner == TeamType.TEAM_A,
                modifier = Modifier
                    .weight(1f)
                    .height(130.dp)
            )
            TeamScoreCard(
                teamType = TeamType.TEAM_B,
                score = state.teamBScore,
                isWinner = state.winner == TeamType.TEAM_B,
                modifier = Modifier
                    .weight(1f)
                    .height(130.dp)
            )
        }

        // 스크롤 가능한 영역
        Column(
            modifier = Modifier
                .fillMaxSize()
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

            // New Game Button
            TextButton(
                onClick = { viewModel.newGame() },
                modifier = Modifier.align(Alignment.CenterHorizontally)
            ) {
                Text(
                    text = stringResource(R.string.new_game),
                    color = Color(0xFFE53935),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            // Bottom spacing
            Spacer(modifier = Modifier.height(16.dp))
        }
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
