package com.tichutally.app.presentation.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.R
import com.tichutally.app.domain.model.Round
import com.tichutally.app.domain.model.RoundScore
import com.tichutally.app.domain.model.TichuType
import com.tichutally.app.presentation.ui.theme.*

@Composable
fun ScoreHistoryCard(
    rounds: List<Round>,
    scores: List<RoundScore>,
    onDeleteRound: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 6.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = Color.Black.copy(alpha = 0.08f),
                spotColor = Color.Black.copy(alpha = 0.08f)
            ),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackgroundElevated)
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            // Title with icon
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .width(4.dp)
                        .height(20.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(TextSecondary)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = stringResource(R.string.round_history),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (rounds.isEmpty()) {
                // Empty state
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(120.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(SurfaceLight),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "No Records",
                            color = TextHint,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Medium
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = stringResource(R.string.no_records),
                            color = TextHint,
                            fontSize = 13.sp
                        )
                    }
                }
            } else {
                // Header row
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                        .background(SurfaceLight)
                        .padding(horizontal = 12.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Spacer(modifier = Modifier.width(28.dp))
                    Text(
                        text = "#",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = TextSecondary,
                        modifier = Modifier.width(28.dp),
                        textAlign = TextAlign.Center
                    )
                    Text(
                        text = "A",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = TeamAColor,
                        modifier = Modifier.width(50.dp),
                        textAlign = TextAlign.Center
                    )
                    Text(
                        text = "B",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = TeamBColor,
                        modifier = Modifier.width(50.dp),
                        textAlign = TextAlign.Center
                    )
                    Text(
                        text = "Details",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = TextSecondary,
                        modifier = Modifier.weight(1f)
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Round list
                LazyColumn(
                    modifier = Modifier.heightIn(max = 240.dp),
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    itemsIndexed(rounds) { index, round ->
                        RoundHistoryItem(
                            round = round,
                            score = scores.getOrNull(index) ?: RoundScore(0, 0),
                            isEven = index % 2 == 0,
                            onDelete = { onDeleteRound(index) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun RoundHistoryItem(
    round: Round,
    score: RoundScore,
    isEven: Boolean,
    onDelete: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(if (isEven) Color.Transparent else SurfaceLight.copy(alpha = 0.5f))
            .padding(horizontal = 12.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Delete button
        Icon(
            imageVector = Icons.Default.Close,
            contentDescription = "Delete",
            tint = TextHint,
            modifier = Modifier
                .size(20.dp)
                .clip(RoundedCornerShape(4.dp))
                .clickable { onDelete() }
        )

        Spacer(modifier = Modifier.width(8.dp))

        // Round number badge
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(RoundedCornerShape(6.dp))
                .background(TextSecondary.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "${round.roundNumber}",
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = TextSecondary
            )
        }

        Spacer(modifier = Modifier.width(4.dp))

        // Team A score
        ScoreBadge(
            score = score.teamADisplay,
            color = TeamAColor,
            bgColor = TeamAColorLight
        )

        // Team B score
        ScoreBadge(
            score = score.teamBDisplay,
            color = TeamBColor,
            bgColor = TeamBColorLight
        )

        Spacer(modifier = Modifier.width(8.dp))

        // Details
        val details = buildDetailTags(round)
        Row(
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.weight(1f)
        ) {
            details.forEach { (text, color) ->
                DetailTag(text = text, color = color)
            }
        }
    }
}

@Composable
private fun ScoreBadge(
    score: String,
    color: Color,
    bgColor: Color
) {
    Box(
        modifier = Modifier
            .width(50.dp)
            .clip(RoundedCornerShape(6.dp))
            .background(bgColor)
            .padding(vertical = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = score,
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
    }
}

@Composable
private fun DetailTag(
    text: String,
    color: Color
) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(4.dp))
            .background(color.copy(alpha = 0.1f))
            .padding(horizontal = 6.dp, vertical = 2.dp)
    ) {
        Text(
            text = text,
            fontSize = 10.sp,
            fontWeight = FontWeight.SemiBold,
            color = color
        )
    }
}

private fun buildDetailTags(round: Round): List<Pair<String, Color>> {
    val tags = mutableListOf<Pair<String, Color>>()

    if (round.isOneTwoFinish && round.oneTwoFinishTeam != null) {
        val color = if (round.oneTwoFinishTeam.name == "TEAM_A") TeamAColor else TeamBColor
        tags.add("${round.oneTwoFinishTeam.shortName} 1-2" to color)
    }

    round.tichuCalls.forEach { call ->
        val typeStr = if (call.type == TichuType.LARGE) "L" else "S"
        val resultStr = if (call.isSuccess) "O" else "X"
        val color = when {
            call.type == TichuType.LARGE && call.isSuccess -> LargeTichuColor
            call.type == TichuType.LARGE && !call.isSuccess -> FailureColor
            call.isSuccess -> SuccessColor
            else -> FailureColor
        }
        tags.add("${call.player.displayName}$typeStr$resultStr" to color)
    }

    return tags
}
