import 'dart:ui';

import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({required this.game, super.key});

  final StockingFillerGame game;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: AnimationDurations.gameOverFade);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.game.scoreManager.score;
    final highScore = widget.game.scoreManager.highScore;
    final isNewHighScore = widget.game.scoreManager.isNewHighScore;
    final maxCombo = widget.game.scoreManager.maxCombo;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10 * _fadeAnimation.value, sigmaY: 10 * _fadeAnimation.value),
            child: ColoredBox(
              color: GameColors.overlayDark,
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildContent(score, highScore, isNewHighScore: isNewHighScore, maxCombo: maxCombo),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(int score, int highScore, {required bool isNewHighScore, required int maxCombo}) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GameColors.glassFrost, GameColors.glassFrost.withAlpha(10)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GameColors.glassEdge, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30, spreadRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game Over Title
          Text(
            'GAME OVER',
            style: GoogleFonts.pressStart2p(
              fontSize: 28,
              color: GameColors.stockingRed,
              shadows: [Shadow(color: GameColors.stockingRed.withAlpha(128), blurRadius: 20)],
            ),
          ),

          const SizedBox(height: 32),

          // Score
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎁', style: GoogleFonts.notoColorEmoji(fontSize: 40)),
              const SizedBox(width: 12),
              Text(
                '$score',
                style: GoogleFonts.pressStart2p(
                  fontSize: 48,
                  color: GameColors.scoreGold,
                  shadows: [Shadow(color: GameColors.scoreGold.withAlpha(150), blurRadius: 15)],
                ),
              ),
            ],
          ),

          if (isNewHighScore) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: GameColors.scoreGold.withAlpha(50),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GameColors.scoreGold),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('NEW HIGH SCORE!', style: GoogleFonts.pressStart2p(fontSize: 10, color: GameColors.scoreGold)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildStatRow('🏆 Best', '$highScore'),
                const SizedBox(height: 8),
                _buildStatRow('🔥 Max Combo', 'x$maxCombo'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Play Again Button
          _buildPlayAgainButton(),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white70)),
        const SizedBox(width: 24),
        Text(value, style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white)),
      ],
    );
  }

  Widget _buildPlayAgainButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.game.startGame();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [GameColors.stockingRed, GameColors.stockingDark]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: GameColors.stockingRed.withAlpha(150), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎮', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text('PLAY AGAIN', style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
