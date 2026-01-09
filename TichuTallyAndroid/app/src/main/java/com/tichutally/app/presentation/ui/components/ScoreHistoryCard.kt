package com.tichutally.app.presentation.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
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
import com.tichutally.app.domain.model.Round
import com.tichutally.app.domain.model.RoundScore
import com.tichutally.app.domain.model.TichuType
import com.tichutally.app.presentation.ui.theme.*

@Composable
fun ScoreHistoryCard(
    rounds: List<Round>,
    scores: List<RoundScore>,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = stringResource(R.string.round_history),
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(modifier = Modifier.height(8.dp))

            if (rounds.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(100.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = stringResource(R.string.no_records),
                        color = Color.LightGray,
                        fontSize = 14.sp
                    )
                }
            } else {
                LazyColumn(
                    modifier = Modifier.heightIn(max = 200.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    itemsIndexed(rounds) { index, round ->
                        RoundHistoryItem(
                            round = round,
                            score = scores.getOrNull(index) ?: RoundScore(0, 0)
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
    score: RoundScore
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "${stringResource(R.string.round_prefix)}${round.roundNumber}",
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.width(30.dp)
        )

        Text(
            text = score.teamADisplay,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = TeamAColor,
            modifier = Modifier.width(50.dp)
        )

        Text(
            text = "/",
            fontSize = 14.sp,
            color = Color.Gray
        )

        Text(
            text = score.teamBDisplay,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = TeamBColor,
            modifier = Modifier.width(50.dp)
        )

        Spacer(modifier = Modifier.width(8.dp))

        // Details
        val details = buildString {
            if (round.isOneTwoFinish && round.oneTwoFinishTeam != null) {
                append("${round.oneTwoFinishTeam.shortName} 1-2")
            }
            round.tichuCalls.forEach { call ->
                if (isNotEmpty()) append(", ")
                val typeStr = if (call.type == TichuType.LARGE) "L" else "S"
                val resultStr = if (call.isSuccess) "O" else "X"
                append("${call.player.displayName}$typeStr$resultStr")
            }
        }

        Text(
            text = details,
            fontSize = 11.sp,
            color = Color.Gray
        )
    }
}
