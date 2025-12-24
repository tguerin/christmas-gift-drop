import 'dart:ui';

import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HudOverlay extends StatefulWidget {
  const HudOverlay({required this.game, super.key});

  final StockingFillerGame game;

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    widget.game.onScoreChanged = _onScoreChanged;
  }

  void _onScoreChanged() {
    if (mounted) {
      setState(() {
        _displayedScore = widget.game.scoreManager.score;
      });
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High Score (left)
            _buildHighScoreBadge(),

            // Current Score (center)
            _buildScoreDisplay(),

            // Combo (right)
            _buildComboBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.2);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: GameColors.hudBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GameColors.glassEdge),
          boxShadow: [BoxShadow(color: GameColors.scoreGold.withAlpha(40), blurRadius: 20, spreadRadius: 2)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎁', style: GoogleFonts.notoColorEmoji(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '$_displayedScore',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24,
                    color: GameColors.scoreGold,
                    shadows: [Shadow(color: GameColors.scoreGold.withAlpha(128), blurRadius: 10)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighScoreBadge() {
    final highScore = widget.game.scoreManager.highScore;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.glassEdge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏆', style: GoogleFonts.notoColorEmoji(fontSize: 16)),
          const SizedBox(width: 6),
          Text('$highScore', style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildComboBadge() {
    final combo = widget.game.scoreManager.combo;

    if (combo < 3) {
      return const SizedBox(width: 60);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.comboOrange.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.comboOrange, width: 2),
        boxShadow: [BoxShadow(color: GameColors.comboOrange.withAlpha(100), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: GoogleFonts.notoColorEmoji(fontSize: 16)),
          const SizedBox(width: 4),
          Text('x$combo', style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}
