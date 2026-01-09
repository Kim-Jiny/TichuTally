package com.tichutally.app.presentation.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.R
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.presentation.ui.theme.*

@Composable
fun TeamScoreCard(
    teamType: TeamType,
    score: Int,
    isWinner: Boolean,
    modifier: Modifier = Modifier
) {
    val teamColor = if (teamType == TeamType.TEAM_A) TeamAColor else TeamBColor
    val bgColor = if (teamType == TeamType.TEAM_A) TeamAColorLight else TeamBColorLight
    val teamName = if (teamType == TeamType.TEAM_A) {
        stringResource(R.string.team_a)
    } else {
        stringResource(R.string.team_b)
    }

    Box(
        modifier = modifier
            .background(
                color = if (isWinner) bgColor.copy(alpha = 0.5f) else bgColor,
                shape = RoundedCornerShape(12.dp)
            )
            .then(
                if (isWinner) {
                    Modifier.border(3.dp, teamColor, RoundedCornerShape(12.dp))
                } else {
                    Modifier
                }
            )
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = teamName,
                fontSize = 18.sp,
                fontWeight = FontWeight.Medium,
                color = teamColor
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "$score",
                fontSize = 48.sp,
                fontWeight = FontWeight.Bold,
                color = teamColor
            )
            Text(
                text = stringResource(R.string.points_suffix),
                fontSize = 14.sp,
                color = Color.Gray
            )
        }
    }
}
