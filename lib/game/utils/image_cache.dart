import 'dart:ui' as ui;

import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pre-caches emoji images for better performance during gameplay.
class GameImageCache {
  GameImageCache._();

  static final GameImageCache instance = GameImageCache._();

  final Map<PresentType, ui.Picture> _presentPictures = {};
  ui.Picture? _stockingPicture;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Call this before starting the game to pre-render all emojis.
  Future<void> initialize() async {
    if (_initialized) return;

    // Cache all present type emojis
    for (final type in PresentType.values) {
      _presentPictures[type] = _renderEmoji(type.emoji, type.size);
      // Yield to event loop to prevent UI blocking
      await Future<void>.delayed(Duration.zero);
    }

    // Cache stocking emoji
    _stockingPicture = _renderStocking();
    await Future<void>.delayed(Duration.zero);

    _initialized = true;
  }

  ui.Picture _renderEmoji(String emoji, double size) {
    final pictureSize = size * 1.5;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: GoogleFonts.notoColorEmoji(fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset((pictureSize - textPainter.width) / 2, (pictureSize - textPainter.height) / 2));

    return recorder.endRecording();
  }

  ui.Picture _renderStocking() {
    const width = GameDimensions.stockingWidth;
    const height = GameDimensions.stockingHeight;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final renderRect = Rect.fromCenter(center: Offset.zero, width: width, height: height);

    // Draw stocking glow (simple, no blur)
    final glowPaint = Paint()..color = GameColors.stockingRed.withAlpha(40);
    canvas.drawRRect(RRect.fromRectAndRadius(renderRect.inflate(8), const Radius.circular(22)), glowPaint);

    // Draw stocking body with gradient
    final stockingGradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GameColors.stockingRed, GameColors.stockingDark],
      ).createShader(renderRect);

    final stockingPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          renderRect,
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(20),
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(5),
        ),
      );

    canvas.drawPath(stockingPath, stockingGradient);

    // Draw white fur trim at top
    final trimRect = Rect.fromLTWH(renderRect.left - 3, renderRect.top - 5, width + 6, 15);
    final trimPaint = Paint()..color = GameColors.stockingTrim;
    canvas.drawRRect(RRect.fromRectAndRadius(trimRect, const Radius.circular(7)), trimPaint);

    // Draw golden accent line
    final accentPaint = Paint()
      ..color = GameColors.stockingGold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(renderRect.left + 10, renderRect.top + 15),
      Offset(renderRect.right - 10, renderRect.top + 15),
      accentPaint,
    );

    // Draw stocking emoji
    final textPainter = TextPainter(
      text: TextSpan(text: '🧦', style: GoogleFonts.notoColorEmoji(fontSize: 35)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2 + 5));

    return recorder.endRecording();
  }

  /// Get cached picture for a present type.
  ui.Picture? getPresentPicture(PresentType type) => _presentPictures[type];

  /// Get the picture size for a present type (used for centering).
  double getPresentPictureSize(PresentType type) => type.size * 1.5;

  /// Get cached stocking picture.
  ui.Picture? get stockingPicture => _stockingPicture;
}
