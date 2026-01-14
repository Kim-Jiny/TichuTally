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
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 8.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.1f),
                spotColor = Color.Black.copy(alpha = 0.1f)
            ),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackgroundElevated)
    ) {
        Column(
            modifier = Modifier
                .padding(20.dp)
                .fillMaxWidth()
        ) {
            // Title with accent bar
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .width(4.dp)
                        .height(20.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(TeamAColor, TeamBColor)
                            )
                        )
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = stringResource(R.string.round_input_title),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Tichu Section
            SectionHeader(title = stringResource(R.string.tichu_section_title))

            Spacer(modifier = Modifier.height(12.dp))

            // Tichu Call Rows with card background
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(SurfaceLight)
                    .padding(12.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    // Team A players
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
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
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
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
            }

            Spacer(modifier = Modifier.height(20.dp))

            // One-Two Finish
            SectionHeader(title = stringResource(R.string.one_two_finish))

            Spacer(modifier = Modifier.height(10.dp))

            OneTwoFinishSelector(
                selectedTeam = if (oneTwoFinish) oneTwoFinishTeam else null,
                onSelectionChanged = { team ->
                    onOneTwoFinishChanged(team != null, team)
                }
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Card Score
            SectionHeader(title = stringResource(R.string.card_score))

            Spacer(modifier = Modifier.height(12.dp))

            // Score Display with gradient background
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(
                        Brush.horizontalGradient(
                            colors = listOf(
                                TeamAColorLight,
                                Color.White,
                                TeamBColorLight
                            )
                        )
                    )
                    .padding(vertical = 16.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    // Team A Score
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.width(80.dp)
                    ) {
                        Text(
                            text = "A",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = TeamAColor
                        )
                        Text(
                            text = "$teamACardScore",
                            fontSize = 36.sp,
                            fontWeight = FontWeight.Bold,
                            color = TeamAColor
                        )
                    }

                    Text(
                        text = ":",
                        fontSize = 36.sp,
                        fontWeight = FontWeight.Bold,
                        color = TextSecondary,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )

                    // Team B Score
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.width(80.dp)
                    ) {
                        Text(
                            text = "B",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = TeamBColor
                        )
                        Text(
                            text = "${100 - teamACardScore}",
                            fontSize = 36.sp,
                            fontWeight = FontWeight.Bold,
                            color = TeamBColor
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Custom Slider
            val sliderAlpha = if (oneTwoFinish || !isEnabled) 0.4f else 1f

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(TeamAColorLight),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "A",
                        fontWeight = FontWeight.Bold,
                        color = TeamAColor,
                        fontSize = 14.sp
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
                        .padding(horizontal = 12.dp),
                    colors = SliderDefaults.colors(
                        thumbColor = if (teamACardScore >= 50) TeamAColor else TeamBColor,
                        activeTrackColor = TeamAColor,
                        inactiveTrackColor = TeamBColor.copy(alpha = 0.3f),
                        disabledThumbColor = TextHint,
                        disabledActiveTrackColor = TextHint,
                        disabledInactiveTrackColor = TextHint.copy(alpha = 0.3f)
                    )
                )

                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(TeamBColorLight),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "B",
                        fontWeight = FontWeight.Bold,
                        color = TeamBColor,
                        fontSize = 14.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Add Round Button with gradient
            Button(
                onClick = onAddRound,
                enabled = isEnabled,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .shadow(
                        elevation = if (isEnabled) 6.dp else 0.dp,
                        shape = RoundedCornerShape(12.dp),
                        ambientColor = SuccessColor.copy(alpha = 0.3f),
                        spotColor = SuccessColor.copy(alpha = 0.3f)
                    ),
                colors = ButtonDefaults.buttonColors(
                    containerColor = SuccessColor,
                    disabledContainerColor = TextHint
                ),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(
                    text = stringResource(R.string.add_round),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String) {
    Text(
        text = title,
        fontSize = 13.sp,
        fontWeight = FontWeight.SemiBold,
        color = TextSecondary,
        letterSpacing = 0.5.sp
    )
}

@Composable
private fun OneTwoFinishSelector(
    selectedTeam: TeamType?,
    onSelectionChanged: (TeamType?) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        listOf(
            null to stringResource(R.string.none),
            TeamType.TEAM_A to stringResource(R.string.team_a),
            TeamType.TEAM_B to stringResource(R.string.team_b)
        ).forEach { (team, label) ->
            val isSelected = selectedTeam == team
            val chipColor = when {
                !isSelected -> SurfaceLight
                team == TeamType.TEAM_A -> TeamAColorLight
                team == TeamType.TEAM_B -> TeamBColorLight
                else -> SurfaceLight
            }
            val textColor = when {
                !isSelected -> TextSecondary
                team == TeamType.TEAM_A -> TeamAColor
                team == TeamType.TEAM_B -> TeamBColor
                else -> TextPrimary
            }
            val borderColor = when {
                !isSelected -> Color.Transparent
                team == TeamType.TEAM_A -> TeamAColor
                team == TeamType.TEAM_B -> TeamBColor
                else -> TextSecondary
            }

            FilterChip(
                selected = isSelected,
                onClick = { onSelectionChanged(team) },
                label = {
                    Text(
                        text = label,
                        fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
                    )
                },
                modifier = Modifier.weight(1f),
                colors = FilterChipDefaults.filterChipColors(
                    containerColor = SurfaceLight,
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
                shape = RoundedCornerShape(10.dp)
            )
        }
    }
}
