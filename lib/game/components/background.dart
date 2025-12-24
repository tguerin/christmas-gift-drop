import 'dart:math';

import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Star {
  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
    required this.twinklePhase,
  });

  double x;
  double y;
  double size;
  double brightness;
  double twinkleSpeed;
  double twinklePhase;
}

class Snowflake {
  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.wobblePhase,
    required this.wobbleSpeed,
  });

  double x;
  double y;
  double size;
  double speed;
  double wobblePhase;
  double wobbleSpeed;
}

class BackgroundComponent extends Component with HasGameReference<StockingFillerGame> {
  final List<Star> _stars = [];
  final List<Snowflake> _snowflakes = [];
  final Random _random = Random();
  double _time = 0;

  // Cached paints for performance
  late Paint _backgroundPaint;
  late Paint _groundPaint;
  final Paint _snowPaint = Paint()..color = Colors.white.withAlpha(200);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeStars();
    _initializeSnowflakes();
    _initializePaints();
  }

  void _initializePaints() {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    _backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GameColors.backgroundTop, GameColors.backgroundBottom],
      ).createShader(Rect.fromLTWH(0, 0, screenWidth, screenHeight));

    _groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.white.withAlpha(15)],
      ).createShader(Rect.fromLTWH(0, screenHeight - 100, screenWidth, 100));
  }

  void _initializeStars() {
    _stars.clear();
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    // Create 60 stars
    for (var i = 0; i < 60; i++) {
      _stars.add(
        Star(
          x: _random.nextDouble() * screenWidth,
          y: _random.nextDouble() * screenHeight * 0.7,
          size: _random.nextDouble() * 2 + 1,
          brightness: _random.nextDouble() * 0.5 + 0.5,
          twinkleSpeed: _random.nextDouble() * 2 + 1,
          twinklePhase: _random.nextDouble() * pi * 2,
        ),
      );
    }
  }

  void _initializeSnowflakes() {
    _snowflakes.clear();
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    // Create 40 snowflakes
    for (var i = 0; i < 40; i++) {
      _snowflakes.add(
        Snowflake(
          x: _random.nextDouble() * screenWidth,
          y: _random.nextDouble() * screenHeight,
          size: _random.nextDouble() * 2 + 1.5,
          speed: _random.nextDouble() * 25 + 15,
          wobblePhase: _random.nextDouble() * pi * 2,
          wobbleSpeed: _random.nextDouble() * 2 + 1,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    // Update snowflakes
    for (final snowflake in _snowflakes) {
      snowflake
        ..y += snowflake.speed * dt
        ..x += sin(_time * snowflake.wobbleSpeed + snowflake.wobblePhase) * 0.3;

      // Reset snowflake if it goes off screen
      if (snowflake.y > screenHeight) {
        snowflake
          ..y = -10
          ..x = _random.nextDouble() * screenWidth;
      }
      if (snowflake.x < 0) snowflake.x = screenWidth;
      if (snowflake.x > screenWidth) snowflake.x = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    // Draw gradient background
    canvas.drawRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight), _backgroundPaint);

    // Draw stars with simple twinkling (no blur)
    for (final star in _stars) {
      final twinkle = sin(_time * star.twinkleSpeed + star.twinklePhase);
      final alpha = ((star.brightness + twinkle * 0.3) * 255).clamp(80, 255).toInt();

      final starPaint = Paint()..color = GameColors.starColor.withAlpha(alpha);
      canvas.drawCircle(Offset(star.x, star.y), star.size, starPaint);
    }

    // Draw snowflakes (no blur)
    for (final snowflake in _snowflakes) {
      canvas.drawCircle(Offset(snowflake.x, snowflake.y), snowflake.size, _snowPaint);
    }

    // Draw subtle ground gradient
    canvas.drawRect(Rect.fromLTWH(0, screenHeight - 100, screenWidth, 100), _groundPaint);
  }
}
