package com.tichutally.app.presentation.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.R
import com.tichutally.app.domain.model.Player
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.domain.model.TichuType
import com.tichutally.app.presentation.ui.theme.*
import com.tichutally.app.presentation.viewmodel.TichuCallInput
import kotlin.math.roundToInt

@Composable
fun RoundInputCard(
    teamACardScore: Int,
    oneTwoFinish: Boolean,
    oneTwoFinishTeam: TeamType?,
    tichuCalls: Map<Player, TichuCallInput>,
    isEnabled: Boolean,
    onTeamAScoreChanged: (Int) -> Unit,
    onOneTwoFinishChanged: (Boolean, TeamType?) -> Unit,
    onTichuCallChanged: (Player, TichuType?, Boolean) -> Unit,
    onAddRound: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFFF5F5F5))
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            // Title
            Text(
                text = stringResource(R.string.round_input_title),
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Tichu Section
            Text(
                text = stringResource(R.string.tichu_section_title),
                fontSize = 13.sp,
                color = Color.Gray
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Tichu Call Rows
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                // Team A players
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Player.allPlayers.filter { it.team == TeamType.TEAM_A }.forEach { player ->
                        TichuCallRow(
                            player = player,
                            callInput = tichuCalls[player],
                            onCallChanged = { type, success ->
                                onTichuCallChanged(player, type, success)
                            }
                        )
                    }
                }
                // Team B players
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Player.allPlayers.filter { it.team == TeamType.TEAM_B }.forEach { player ->
                        TichuCallRow(
                            player = player,
                            callInput = tichuCalls[player],
                            onCallChanged = { type, success ->
                                onTichuCallChanged(player, type, success)
                            }
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // One-Two Finish
            Text(
                text = stringResource(R.string.one_two_finish),
                fontSize = 13.sp,
                color = Color.Gray
            )

            Spacer(modifier = Modifier.height(6.dp))

            OneTwoFinishSelector(
                selectedTeam = if (oneTwoFinish) oneTwoFinishTeam else null,
                onSelectionChanged = { team ->
                    onOneTwoFinishChanged(team != null, team)
                }
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Card Score
            Text(
                text = stringResource(R.string.card_score),
                fontSize = 13.sp,
                color = Color.Gray
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Score Display
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "$teamACardScore",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = TeamAColor
                )
                Text(
                    text = " : ",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "${100 - teamACardScore}",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = TeamBColor
                )
            }

            // Slider
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("A", fontWeight = FontWeight.Bold, color = TeamAColor)
                Slider(
                    value = teamACardScore.toFloat(),
                    onValueChange = { value ->
                        val snapped = ((value / 5).roundToInt() * 5).coerceIn(0, 100)
                        onTeamAScoreChanged(snapped)
                    },
                    valueRange = 0f..100f,
                    enabled = !oneTwoFinish && isEnabled,
                    modifier = Modifier
                        .weight(1f)
                        .padding(horizontal = 8.dp)
                )
                Text("B", fontWeight = FontWeight.Bold, color = TeamBColor)
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Add Round Button
            Button(
                onClick = onAddRound,
                enabled = isEnabled,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                colors = ButtonDefaults.buttonColors(containerColor = SuccessColor),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text(
                    text = stringResource(R.string.add_round),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@Composable
private fun OneTwoFinishSelector(
    selectedTeam: TeamType?,
    onSelectionChanged: (TeamType?) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        listOf(
            null to stringResource(R.string.none),
            TeamType.TEAM_A to stringResource(R.string.team_a),
            TeamType.TEAM_B to stringResource(R.string.team_b)
        ).forEach { (team, label) ->
            val isSelected = selectedTeam == team
            FilterChip(
                selected = isSelected,
                onClick = { onSelectionChanged(team) },
                label = { Text(label) },
                modifier = Modifier.weight(1f)
            )
        }
    }
}
