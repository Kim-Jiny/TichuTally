package com.tichutally.app.presentation.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tichutally.app.domain.model.Player
import com.tichutally.app.domain.model.TeamType
import com.tichutally.app.domain.model.TichuType
import com.tichutally.app.presentation.ui.theme.*
import com.tichutally.app.presentation.viewmodel.TichuCallInput

@Composable
fun TichuCallRow(
    player: Player,
    callInput: TichuCallInput?,
    onCallChanged: (TichuType?, Boolean) -> Unit,
    modifier: Modifier = Modifier
) {
    val teamColor = if (player.team == TeamType.TEAM_A) TeamAColor else TeamBColor
    val selectedType = callInput?.type
    val isSuccess = callInput?.isSuccess ?: false

    Row(
        modifier = modifier.height(36.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        // Player name
        Text(
            text = player.displayName,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
            color = teamColor,
            modifier = Modifier.width(32.dp)
        )

        // Small Tichu button
        TichuButton(
            text = "S",
            isSelected = selectedType == TichuType.SMALL,
            selectedColor = TeamAColor,
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
            text = "L",
            isSelected = selectedType == TichuType.LARGE,
            selectedColor = Color(0xFFFF9800),
            onClick = {
                if (selectedType == TichuType.LARGE) {
                    onCallChanged(null, false)
                } else {
                    onCallChanged(TichuType.LARGE, isSuccess)
                }
            }
        )

        // Success/Fail button
        SuccessButton(
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
    Box(
        modifier = Modifier
            .size(28.dp)
            .background(
                color = if (isSelected) selectedColor else Color.Transparent,
                shape = RoundedCornerShape(4.dp)
            )
            .border(
                width = 1.dp,
                color = if (isSelected) selectedColor else Color.LightGray,
                shape = RoundedCornerShape(4.dp)
            )
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            color = if (isSelected) Color.White else selectedColor
        )
    }
}

@Composable
private fun SuccessButton(
    isEnabled: Boolean,
    isSuccess: Boolean,
    onClick: () -> Unit
) {
    val (bgColor, textColor, text) = when {
        !isEnabled -> Triple(Color.Transparent, Color.LightGray, "-")
        isSuccess -> Triple(SuccessColor, Color.White, "O")
        else -> Triple(FailureColor, Color.White, "X")
    }

    Box(
        modifier = Modifier
            .size(28.dp)
            .background(
                color = bgColor,
                shape = RoundedCornerShape(4.dp)
            )
            .border(
                width = 1.dp,
                color = if (isEnabled) bgColor else Color.LightGray,
                shape = RoundedCornerShape(4.dp)
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
