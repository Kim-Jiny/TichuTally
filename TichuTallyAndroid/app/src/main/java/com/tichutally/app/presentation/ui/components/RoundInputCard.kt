package com.tichutally.app.presentation.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.R
import com.tichutally.app.domain.model.Player
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.domain.model.TichuType
import com.tichutally.app.presentation.ui.theme.AppTheme
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
    modifier: Modifier = Modifier,
    addButtonText: String? = null
) {
    val colors = AppTheme.colors

    Card(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 8.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.1f),
                spotColor = Color.Black.copy(alpha = 0.1f)
            ),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = colors.cardBackgroundElevated)
    ) {
        Column(
            modifier = Modifier
                .padding(10.dp)
                .fillMaxWidth()
        ) {
            // Tichu Section
            SectionHeader(title = stringResource(R.string.tichu_section_title))

            Spacer(modifier = Modifier.height(2.dp))

            // Tichu Call Rows with card background — 팀당 2명(A1/A2, B1/B2) 개별 콜
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(colors.surfaceLight)
                    .padding(6.dp)
            ) {
                val teamAPlayers = Player.allPlayers.filter { it.team == TeamType.TEAM_A }
                val teamBPlayers = Player.allPlayers.filter { it.team == TeamType.TEAM_B }
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        teamAPlayers.forEach { player ->
                            TichuCallRow(
                                player = player,
                                callInput = tichuCalls[player],
                                onCallChanged = { type, success ->
                                    onTichuCallChanged(player, type, success)
                                }
                            )
                        }
                    }
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        teamBPlayers.forEach { player ->
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
            }

            Spacer(modifier = Modifier.height(6.dp))

            // One-Two Finish
            SectionHeader(title = stringResource(R.string.one_two_finish))

            Spacer(modifier = Modifier.height(2.dp))

            OneTwoFinishSelector(
                selectedTeam = if (oneTwoFinish) oneTwoFinishTeam else null,
                onSelectionChanged = { team ->
                    onOneTwoFinishChanged(team != null, team)
                }
            )

            Spacer(modifier = Modifier.height(6.dp))

            // Card Score
            SectionHeader(title = stringResource(R.string.card_score))

            Spacer(modifier = Modifier.height(2.dp))

            // Score Display with gradient background
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                        Brush.horizontalGradient(
                            colors = listOf(
                                colors.teamAColorLight,
                                colors.cardBackgroundElevated,
                                colors.teamBColorLight
                            )
                        )
                    )
                    .padding(vertical = 6.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    // Calculate displayed scores based on 1-2 finish
                    val displayedTeamAScore = when {
                        oneTwoFinish && oneTwoFinishTeam == TeamType.TEAM_A -> 200
                        oneTwoFinish && oneTwoFinishTeam == TeamType.TEAM_B -> 0
                        else -> teamACardScore
                    }
                    val displayedTeamBScore = when {
                        oneTwoFinish && oneTwoFinishTeam == TeamType.TEAM_A -> 0
                        oneTwoFinish && oneTwoFinishTeam == TeamType.TEAM_B -> 200
                        else -> 100 - teamACardScore
                    }

                    // Team A Score
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.width(70.dp)
                    ) {
                        Text(
                            text = stringResource(R.string.team_a_short),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.teamAColor
                        )
                        Text(
                            text = "$displayedTeamAScore",
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.teamAColor
                        )
                    }

                    Text(
                        text = ":",
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textSecondary,
                        modifier = Modifier.padding(horizontal = 12.dp)
                    )

                    // Team B Score
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.width(70.dp)
                    ) {
                        Text(
                            text = stringResource(R.string.team_b_short),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.teamBColor
                        )
                        Text(
                            text = "$displayedTeamBScore",
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.teamBColor
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(2.dp))

            // Custom Slider
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .background(colors.teamAColorLight),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = stringResource(R.string.team_a_short),
                        fontWeight = FontWeight.Bold,
                        color = colors.teamAColor,
                        fontSize = 12.sp
                    )
                }

                Slider(
                    value = teamACardScore.toFloat(),
                    onValueChange = { value ->
                        val snapped = ((value / 5).roundToInt() * 5).coerceIn(-25, 125)
                        onTeamAScoreChanged(snapped)
                    },
                    valueRange = -25f..125f,
                    enabled = !oneTwoFinish && isEnabled,
                    modifier = Modifier
                        .weight(1f)
                        .padding(horizontal = 8.dp),
                    colors = SliderDefaults.colors(
                        thumbColor = if (teamACardScore >= 50) colors.teamAColor else colors.teamBColor,
                        activeTrackColor = colors.teamAColor,
                        inactiveTrackColor = colors.teamBColor.copy(alpha = 0.3f),
                        disabledThumbColor = colors.textHint,
                        disabledActiveTrackColor = colors.textHint,
                        disabledInactiveTrackColor = colors.textHint.copy(alpha = 0.3f)
                    )
                )

                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .background(colors.teamBColorLight),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = stringResource(R.string.team_b_short),
                        fontWeight = FontWeight.Bold,
                        color = colors.teamBColor,
                        fontSize = 12.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Add Round Button
            Button(
                onClick = onAddRound,
                enabled = isEnabled,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(42.dp)
                    .shadow(
                        elevation = if (isEnabled) 4.dp else 0.dp,
                        shape = RoundedCornerShape(10.dp),
                        ambientColor = colors.successColor.copy(alpha = 0.3f),
                        spotColor = colors.successColor.copy(alpha = 0.3f)
                    ),
                colors = ButtonDefaults.buttonColors(
                    containerColor = colors.successColor,
                    disabledContainerColor = colors.textHint
                ),
                shape = RoundedCornerShape(10.dp)
            ) {
                Text(
                    text = addButtonText ?: stringResource(R.string.add_round),
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String) {
    val colors = AppTheme.colors
    Text(
        text = title,
        fontSize = 12.sp,
        fontWeight = FontWeight.SemiBold,
        color = colors.textSecondary
    )
}

@Composable
private fun OneTwoFinishSelector(
    selectedTeam: TeamType?,
    onSelectionChanged: (TeamType?) -> Unit
) {
    val colors = AppTheme.colors

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
            val chipColor = when {
                !isSelected -> colors.surfaceLight
                team == TeamType.TEAM_A -> colors.teamAColorLight
                team == TeamType.TEAM_B -> colors.teamBColorLight
                else -> colors.surfaceLight
            }
            val textColor = when {
                !isSelected -> colors.textSecondary
                team == TeamType.TEAM_A -> colors.teamAColor
                team == TeamType.TEAM_B -> colors.teamBColor
                else -> colors.textPrimary
            }
            val borderColor = when {
                !isSelected -> Color.Transparent
                team == TeamType.TEAM_A -> colors.teamAColor
                team == TeamType.TEAM_B -> colors.teamBColor
                else -> colors.textSecondary
            }

            FilterChip(
                selected = isSelected,
                onClick = { onSelectionChanged(team) },
                label = {
                    Text(
                        text = label,
                        fontSize = 13.sp,
                        fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
                    )
                },
                modifier = Modifier.weight(1f),
                colors = FilterChipDefaults.filterChipColors(
                    containerColor = colors.surfaceLight,
                    selectedContainerColor = chipColor,
                    labelColor = textColor,
                    selectedLabelColor = textColor
                ),
                border = FilterChipDefaults.filterChipBorder(
                    enabled = true,
                    selected = isSelected,
                    borderColor = Color.Transparent,
                    selectedBorderColor = borderColor,
                    borderWidth = 0.dp,
                    selectedBorderWidth = 2.dp
                ),
                shape = RoundedCornerShape(8.dp)
            )
        }
    }
}
