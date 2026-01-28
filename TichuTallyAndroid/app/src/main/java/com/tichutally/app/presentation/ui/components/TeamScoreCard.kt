package com.tichutally.app.presentation.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.R
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.presentation.ui.theme.AppTheme

@Composable
fun TeamScoreCard(
    teamType: TeamType,
    score: Int,
    isWinner: Boolean,
    modifier: Modifier = Modifier
) {
    val colors = AppTheme.colors
    val teamColor = if (teamType == TeamType.TEAM_A) colors.teamAColor else colors.teamBColor
    val teamColorLight = if (teamType == TeamType.TEAM_A) colors.teamAColorLight else colors.teamBColorLight
    val teamColorMedium = if (teamType == TeamType.TEAM_A) colors.teamAColorMedium else colors.teamBColorMedium
    val teamName = if (teamType == TeamType.TEAM_A) {
        stringResource(R.string.team_a)
    } else {
        stringResource(R.string.team_b)
    }

    val scale by animateFloatAsState(
        targetValue = if (isWinner) 1.02f else 1f,
        animationSpec = tween(300),
        label = "scale"
    )

    val borderColor by animateColorAsState(
        targetValue = if (isWinner) teamColor else Color.Transparent,
        animationSpec = tween(300),
        label = "borderColor"
    )

    Box(
        modifier = modifier
            .scale(scale)
            .shadow(
                elevation = if (isWinner) 12.dp else 6.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = teamColor.copy(alpha = if (isWinner) 0.3f else 0.1f),
                spotColor = teamColor.copy(alpha = if (isWinner) 0.3f else 0.1f)
            )
            .clip(RoundedCornerShape(16.dp))
            .background(
                Brush.verticalGradient(
                    colors = if (isWinner) {
                        listOf(teamColorLight, teamColorMedium)
                    } else {
                        listOf(colors.cardBackgroundElevated, teamColorLight)
                    }
                )
            )
            .then(
                if (isWinner) {
                    Modifier.border(3.dp, teamColor, RoundedCornerShape(16.dp))
                } else {
                    Modifier.border(1.dp, teamColorLight, RoundedCornerShape(16.dp))
                }
            )
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Team name
            Text(
                text = teamName,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = teamColor
            )

            Spacer(modifier = Modifier.height(2.dp))

            // Score
            Text(
                text = "$score",
                fontSize = 44.sp,
                fontWeight = FontWeight.Bold,
                color = teamColor
            )

            // Points label
            Text(
                text = stringResource(R.string.points_suffix),
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                color = colors.textSecondary
            )

            // Winner indicator
            if (isWinner) {
                Spacer(modifier = Modifier.height(4.dp))
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .background(teamColor)
                        .padding(horizontal = 8.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = "WIN",
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        letterSpacing = 1.sp
                    )
                }
            }
        }
    }
}
