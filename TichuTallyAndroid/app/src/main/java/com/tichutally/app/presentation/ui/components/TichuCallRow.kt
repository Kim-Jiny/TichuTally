package com.tichutally.app.presentation.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.R
import com.tichutally.app.domain.model.Player
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.domain.model.TichuType
import com.tichutally.app.presentation.ui.theme.AppTheme
import com.tichutally.app.presentation.viewmodel.TichuCallInput

@Composable
fun TichuCallRow(
    player: Player,
    callInput: TichuCallInput?,
    onCallChanged: (TichuType?, Boolean) -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = AppTheme.colors
    val teamColor = if (player.team == TeamType.TEAM_A) colors.teamAColor else colors.teamBColor
    val teamColorLight = if (player.team == TeamType.TEAM_A) colors.teamAColorLight else colors.teamBColorLight
    val selectedType = callInput?.type
    val isSuccess = callInput?.isSuccess ?: false

    Row(
        modifier = modifier.height(36.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        // Player name badge
        Box(
            modifier = Modifier
                .widthIn(min = 28.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(teamColorLight)
                .padding(horizontal = 6.dp, vertical = 3.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = player.displayName,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                color = teamColor
            )
        }

        // Small Tichu button
        TichuButton(
            text = stringResource(R.string.small_tichu),
            isSelected = selectedType == TichuType.SMALL,
            selectedColor = colors.teamAColor,
            onClick = {
                if (selectedType == TichuType.SMALL) {
                    onCallChanged(null, false)
                } else {
                    onCallChanged(TichuType.SMALL, isSuccess)
                }
            }
        )

        // Large Tichu button
        TichuButton(
            text = stringResource(R.string.large_tichu),
            isSelected = selectedType == TichuType.LARGE,
            selectedColor = colors.largeTichuColor,
            onClick = {
                if (selectedType == TichuType.LARGE) {
                    onCallChanged(null, false)
                } else {
                    onCallChanged(TichuType.LARGE, isSuccess)
                }
            }
        )

        // Success/Fail toggle button
        SuccessToggleButton(
            isEnabled = selectedType != null,
            isSuccess = isSuccess,
            onClick = {
                if (selectedType != null) {
                    onCallChanged(selectedType, !isSuccess)
                }
            }
        )
    }
}

@Composable
fun TeamTichuCallRow(
    teamType: TeamType,
    callInput: TichuCallInput?,
    onCallChanged: (TichuType?, Boolean) -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = AppTheme.colors
    val teamColor = if (teamType == TeamType.TEAM_A) colors.teamAColor else colors.teamBColor
    val teamColorLight = if (teamType == TeamType.TEAM_A) colors.teamAColorLight else colors.teamBColorLight
    val teamName = if (teamType == TeamType.TEAM_A) "A" else "B"
    val selectedType = callInput?.type
    val isSuccess = callInput?.isSuccess ?: false

    Row(
        modifier = modifier.height(36.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        // Team name badge
        Box(
            modifier = Modifier
                .widthIn(min = 28.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(teamColorLight)
                .padding(horizontal = 8.dp, vertical = 3.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = teamName,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = teamColor
            )
        }

        // Small Tichu button
        TichuButton(
            text = stringResource(R.string.small_tichu),
            isSelected = selectedType == TichuType.SMALL,
            selectedColor = colors.teamAColor,
            onClick = {
                if (selectedType == TichuType.SMALL) {
                    onCallChanged(null, false)
                } else {
                    onCallChanged(TichuType.SMALL, isSuccess)
                }
            }
        )

        // Large Tichu button
        TichuButton(
            text = stringResource(R.string.large_tichu),
            isSelected = selectedType == TichuType.LARGE,
            selectedColor = colors.largeTichuColor,
            onClick = {
                if (selectedType == TichuType.LARGE) {
                    onCallChanged(null, false)
                } else {
                    onCallChanged(TichuType.LARGE, isSuccess)
                }
            }
        )

        // Success/Fail toggle button
        SuccessToggleButton(
            isEnabled = selectedType != null,
            isSuccess = isSuccess,
            onClick = {
                if (selectedType != null) {
                    onCallChanged(selectedType, !isSuccess)
                }
            }
        )
    }
}

@Composable
private fun TichuButton(
    text: String,
    isSelected: Boolean,
    selectedColor: Color,
    onClick: () -> Unit
) {
    val colors = AppTheme.colors
    val backgroundColor by animateColorAsState(
        targetValue = if (isSelected) selectedColor else Color.Transparent,
        animationSpec = tween(200),
        label = "bgColor"
    )
    val borderColor by animateColorAsState(
        targetValue = if (isSelected) selectedColor else colors.textHint,
        animationSpec = tween(200),
        label = "borderColor"
    )
    val textColor by animateColorAsState(
        targetValue = if (isSelected) Color.White else selectedColor,
        animationSpec = tween(200),
        label = "textColor"
    )

    Box(
        modifier = Modifier
            .size(28.dp)
            .shadow(
                elevation = if (isSelected) 2.dp else 0.dp,
                shape = RoundedCornerShape(6.dp),
                ambientColor = selectedColor.copy(alpha = 0.2f),
                spotColor = selectedColor.copy(alpha = 0.2f)
            )
            .clip(RoundedCornerShape(6.dp))
            .background(backgroundColor)
            .border(
                width = if (isSelected) 0.dp else 1.dp,
                color = borderColor,
                shape = RoundedCornerShape(6.dp)
            )
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = rememberRipple(bounded = true, color = selectedColor),
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            color = textColor
        )
    }
}

@Composable
private fun SuccessToggleButton(
    isEnabled: Boolean,
    isSuccess: Boolean,
    onClick: () -> Unit
) {
    val colors = AppTheme.colors
    val backgroundColor by animateColorAsState(
        targetValue = when {
            !isEnabled -> Color.Transparent
            isSuccess -> colors.successColor
            else -> colors.failureColor
        },
        animationSpec = tween(200),
        label = "bgColor"
    )
    val borderColor by animateColorAsState(
        targetValue = when {
            !isEnabled -> colors.textHint
            isSuccess -> colors.successColor
            else -> colors.failureColor
        },
        animationSpec = tween(200),
        label = "borderColor"
    )
    val textColor by animateColorAsState(
        targetValue = when {
            !isEnabled -> colors.textHint
            else -> Color.White
        },
        animationSpec = tween(200),
        label = "textColor"
    )

    val text = when {
        !isEnabled -> "-"
        isSuccess -> "O"
        else -> "X"
    }

    Box(
        modifier = Modifier
            .size(28.dp)
            .shadow(
                elevation = if (isEnabled) 2.dp else 0.dp,
                shape = RoundedCornerShape(6.dp),
                ambientColor = backgroundColor.copy(alpha = 0.3f),
                spotColor = backgroundColor.copy(alpha = 0.3f)
            )
            .clip(RoundedCornerShape(6.dp))
            .background(backgroundColor)
            .border(
                width = if (isEnabled) 0.dp else 1.dp,
                color = borderColor,
                shape = RoundedCornerShape(6.dp)
            )
            .clickable(enabled = isEnabled, onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            color = textColor
        )
    }
}
