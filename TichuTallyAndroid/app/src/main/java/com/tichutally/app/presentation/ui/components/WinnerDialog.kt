package com.tichutally.app.presentation.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.tichutally.app.R
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.presentation.ui.theme.AppTheme

@Composable
fun WinnerDialog(
    winner: TeamType,
    teamAScore: Int,
    teamBScore: Int,
    onNewGame: () -> Unit,
    onDismiss: () -> Unit
) {
    val colors = AppTheme.colors
    val winnerColor = if (winner == TeamType.TEAM_A) colors.teamAColor else colors.teamBColor
    val winnerColorLight = if (winner == TeamType.TEAM_A) colors.teamAColorLight else colors.teamBColorLight
    val winnerName = if (winner == TeamType.TEAM_A) stringResource(R.string.team_a) else stringResource(R.string.team_b)

    // 애니메이션
    val infiniteTransition = rememberInfiniteTransition(label = "trophy")
    val scale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(600, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse
        ),
        label = "scale"
    )

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.85f)
                .wrapContentHeight(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = colors.cardBackgroundElevated)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // 트로피 아이콘
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .scale(scale)
                        .clip(CircleShape)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(
                                    winnerColor,
                                    winnerColor.copy(alpha = 0.7f)
                                )
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "🏆",
                        fontSize = 40.sp
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Game Over 텍스트
                Text(
                    text = stringResource(R.string.game_over),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium,
                    color = colors.textSecondary
                )

                Spacer(modifier = Modifier.height(4.dp))

                // 우승팀 이름
                Text(
                    text = "$winnerName ${stringResource(R.string.wins)}",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = winnerColor
                )

                Spacer(modifier = Modifier.height(24.dp))

                // 점수 표시
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(colors.surfaceLight)
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Team A 점수
                    ScoreColumn(
                        teamName = stringResource(R.string.team_a),
                        score = teamAScore,
                        color = colors.teamAColor,
                        isWinner = winner == TeamType.TEAM_A
                    )

                    // VS
                    Text(
                        text = stringResource(R.string.vs),
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Medium,
                        color = colors.textHint
                    )

                    // Team B 점수
                    ScoreColumn(
                        teamName = stringResource(R.string.team_b),
                        score = teamBScore,
                        color = colors.teamBColor,
                        isWinner = winner == TeamType.TEAM_B
                    )
                }

                Spacer(modifier = Modifier.height(24.dp))

                // 버튼들
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // 닫기 버튼
                    OutlinedButton(
                        onClick = onDismiss,
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = colors.textSecondary
                        )
                    ) {
                        Text(
                            text = stringResource(R.string.confirm),
                            fontWeight = FontWeight.Medium
                        )
                    }

                    // 새 게임 버튼
                    Button(
                        onClick = onNewGame,
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = winnerColor
                        )
                    ) {
                        Text(
                            text = stringResource(R.string.new_game),
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ScoreColumn(
    teamName: String,
    score: Int,
    color: Color,
    isWinner: Boolean
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = teamName,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            color = color
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "$score",
            fontSize = if (isWinner) 32.sp else 24.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        if (isWinner) {
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = stringResource(R.string.winner),
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                color = color,
                letterSpacing = 1.sp
            )
        }
    }
}
