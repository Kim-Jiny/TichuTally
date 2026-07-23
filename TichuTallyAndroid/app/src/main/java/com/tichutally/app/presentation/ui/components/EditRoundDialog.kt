package com.tichutally.app.presentation.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.tichutally.app.R
import com.tichutally.app.domain.model.Player
import com.tichutally.app.domain.model.Round
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.domain.model.TichuType
import com.tichutally.app.presentation.ui.theme.AppTheme
import com.tichutally.app.presentation.viewmodel.TichuCallInput

@Composable
fun EditRoundDialog(
    round: Round,
    onSave: (teamACardScore: Int, isOneTwoFinish: Boolean, oneTwoFinishTeam: TeamType?, tichuCalls: Map<Player, TichuCallInput>) -> Unit,
    onDismiss: () -> Unit
) {
    val colors = AppTheme.colors
    var cardScore by remember { mutableIntStateOf(round.teamACardScore) }
    var oneTwo by remember { mutableStateOf(round.isOneTwoFinish) }
    var oneTwoTeam by remember { mutableStateOf(round.oneTwoFinishTeam) }
    var calls by remember {
        mutableStateOf(round.tichuCalls.associate { it.player to TichuCallInput(it.type, it.isSuccess) })
    }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.92f)
                .wrapContentHeight(),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = colors.cardBackgroundElevated)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(12.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = stringResource(R.string.round_number, round.roundNumber),
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textPrimary
                    )
                    TextButton(onClick = onDismiss) {
                        Text(stringResource(R.string.cancel), color = colors.textSecondary)
                    }
                }

                RoundInputCard(
                    teamACardScore = cardScore,
                    oneTwoFinish = oneTwo,
                    oneTwoFinishTeam = oneTwoTeam,
                    tichuCalls = calls,
                    isEnabled = true,
                    onTeamAScoreChanged = { cardScore = it },
                    onOneTwoFinishChanged = { enabled, team ->
                        oneTwo = enabled
                        oneTwoTeam = team
                    },
                    onTichuCallChanged = { player, type, isSuccess ->
                        val newCalls = calls.toMutableMap()
                        if (type != null) {
                            newCalls[player] = TichuCallInput(type, isSuccess)
                            if (isSuccess) {
                                Player.allPlayers.filter { it != player }.forEach { other ->
                                    newCalls[other]?.let { call ->
                                        if (call.type != null) newCalls[other] = call.copy(isSuccess = false)
                                    }
                                }
                            }
                        } else {
                            newCalls.remove(player)
                        }
                        calls = newCalls
                    },
                    onAddRound = {
                        onSave(cardScore, oneTwo, oneTwoTeam, calls)
                        onDismiss()
                    },
                    addButtonText = stringResource(R.string.save)
                )
            }
        }
    }
}
