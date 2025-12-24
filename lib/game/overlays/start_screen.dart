import 'dart:math';

import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreenOverlay extends StatefulWidget {
  const StartScreenOverlay({required this.game, super.key});

  final StockingFillerGame game;

  @override
  State<StartScreenOverlay> createState() => _StartScreenOverlayState();
}

class _StartScreenOverlayState extends State<StartScreenOverlay> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highScore = widget.game.scoreManager.highScore;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameColors.backgroundTop, GameColors.backgroundBottom],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Floating decorations
            ..._buildFloatingDecorations(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Title with floating animation
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(offset: Offset(0, _floatAnimation.value), child: child);
                    },
                    child: _buildTitle(),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  Text(
                    '🎄 Catch the presents! 🎄',
                    style: GoogleFonts.quicksand(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),

                  const Spacer(),

                  // High Score
                  if (highScore > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: GameColors.hudBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GameColors.glassEdge),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Text(
                            'High Score: $highScore',
                            style: GoogleFonts.pressStart2p(fontSize: 12, color: GameColors.scoreGold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // Play Button
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.stockingRed.withAlpha((150 * _glowAnimation.value).toInt()),
                              blurRadius: 30 * _glowAnimation.value,
                              spreadRadius: 5 * _glowAnimation.value,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: _buildPlayButton(),
                  ),

                  const Spacer(),

                  // Instructions
                  _buildInstructions(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Stocking emoji
        Text('🧦', style: GoogleFonts.notoColorEmoji(fontSize: 80)),
        const SizedBox(height: 16),
        // Game title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [GameColors.scoreGold, GameColors.stockingRed, GameColors.scoreGold],
          ).createShader(bounds),
          child: Text('STOCKING', style: GoogleFonts.pressStart2p(fontSize: 32, color: Colors.white, letterSpacing: 4)),
        ),
        Text(
          'FILLER',
          style: GoogleFonts.pressStart2p(
            fontSize: 32,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [Shadow(color: GameColors.stockingRed.withAlpha(150), blurRadius: 20)],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.game.overlays.remove('startScreen');
          widget.game.startGame();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [GameColors.stockingRed, GameColors.stockingDark]),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: GameColors.stockingTrim, width: 3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎮', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Text('PLAY', style: GoogleFonts.pressStart2p(fontSize: 20, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.glassEdge),
      ),
      child: Column(
        children: [
          Text('HOW TO PLAY', style: GoogleFonts.pressStart2p(fontSize: 10, color: GameColors.scoreGold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInstructionItem('👆', 'Drag to move'),
              const SizedBox(width: 24),
              _buildInstructionItem('🎁', 'Catch presents'),
              const SizedBox(width: 24),
              _buildInstructionItem('💣', 'Avoid bombs!'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String emoji, String text) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(text, style: GoogleFonts.quicksand(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  List<Widget> _buildFloatingDecorations() {
    final random = Random(42);
    final decorations = ['🎁', '⭐', '🎄', '❄️', '🎀'];

    return List.generate(12, (index) {
      final emoji = decorations[index % decorations.length];
      final left = random.nextDouble() * 300 + 20;
      final top = random.nextDouble() * 600 + 50;
      final size = random.nextDouble() * 20 + 20;
      final delay = random.nextDouble() * 2;

      return Positioned(
        left: left,
        top: top,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: (2000 + delay * 1000).toInt()),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: 0.3,
              child: Transform.translate(
                offset: Offset(0, sin(value * pi * 2) * 10),
                child: Text(emoji, style: TextStyle(fontSize: size)),
              ),
            );
          },
        ),
      );
    });
  }
}
