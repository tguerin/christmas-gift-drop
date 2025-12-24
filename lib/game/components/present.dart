import 'dart:math';

import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:christmas_gift_drop/game/utils/image_cache.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class PresentComponent extends BodyComponent<StockingFillerGame> {
  PresentComponent({required this.presentType, required this.spawnX, required this.fallSpeed});

  final PresentType presentType;
  final double spawnX;
  final double fallSpeed;

  double _rotation = 0;
  double _rotationSpeed = 0;
  double _wobblePhase = 0;
  bool _caught = false;
  bool _missed = false;

  late final Paint _glowPaint;

  StockingFillerGame get gameRef => game;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final random = Random();
    _rotationSpeed = (random.nextDouble() - 0.5) * 2;
    _wobblePhase = random.nextDouble() * pi * 2;

    // Cache the glow paint
    _glowPaint = Paint()..color = _getGlowColor().withAlpha(50);
  }

  @override
  Body createBody() {
    final size = presentType.size;

    final bodyDef = BodyDef(type: BodyType.kinematic, position: Vector2(spawnX, GameDimensions.presentSpawnY));

    final body = world.createBody(bodyDef)..createFixture(FixtureDef(CircleShape()..radius = size / 2, isSensor: true));

    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_caught || _missed || !isLoaded) return;

    _rotation += _rotationSpeed * dt;

    // Calculate horizontal movement from wind
    var horizontalSpeed = 0.0;
    final windForce = gameRef.difficultyManager.windForce;
    if (windForce.abs() > 0.1) {
      horizontalSpeed += windForce * 0.5;
    }

    // Add slight wobble for star type
    if (presentType == PresentType.star) {
      _wobblePhase += dt * 3;
      horizontalSpeed += sin(_wobblePhase) * 30;
    }

    // Set velocity directly for predictable movement
    body.linearVelocity = Vector2(horizontalSpeed, fallSpeed);

    // Check if present is near bottom of screen
    final stockingBounds = gameRef.stocking.bounds;
    if (stockingBounds == null) return;

    final presentY = body.position.y;
    final presentX = body.position.x;
    final presentRadius = presentType.size / 2;

    // Check collision with stocking
    if (presentY + presentRadius > stockingBounds.top && presentY - presentRadius < stockingBounds.bottom) {
      if (presentX > stockingBounds.left && presentX < stockingBounds.right) {
        // Present caught!
        _caught = true;
        gameRef.presentCaught(this);
        return;
      }
    }

    // Check if present missed (went past stocking)
    if (presentY > gameRef.size.y + 50) {
      _missed = true;
      gameRef.presentMissed(this);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_caught) return;

    final cachedPicture = GameImageCache.instance.getPresentPicture(presentType);
    if (cachedPicture == null) return;

    final pictureSize = GameImageCache.instance.getPresentPictureSize(presentType);

    canvas
      ..save()
      // Rotate around center
      ..rotate(_rotation)
      // Draw simple glow (no blur for performance)
      ..drawCircle(Offset.zero, presentType.size / 2 + 6, _glowPaint)
      // Offset to center the picture then draw
      ..translate(-pictureSize / 2, -pictureSize / 2)
      ..drawPicture(cachedPicture)
      ..restore();
  }

  Color _getGlowColor() {
    switch (presentType) {
      case PresentType.gift:
        return GameColors.presentRed;
      case PresentType.ribbon:
        return GameColors.presentPurple;
      case PresentType.star:
        return GameColors.scoreGold;
      case PresentType.tree:
        return GameColors.presentGreen;
      case PresentType.snowflake:
        return GameColors.presentBlue;
      case PresentType.bomb:
        return Colors.orange;
    }
  }
}
