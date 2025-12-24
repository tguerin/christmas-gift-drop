import 'dart:ui';

import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:christmas_gift_drop/game/utils/image_cache.dart';
import 'package:flame/components.dart' hide Vector2;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';

class StockingComponent extends BodyComponent<StockingFillerGame> with KeyboardHandler, ContactCallbacks {
  static const double _width = GameDimensions.stockingWidth;
  static const double _height = GameDimensions.stockingHeight;

  double _targetX = 0;
  double _velocity = 0;
  bool _moveLeft = false;
  bool _moveRight = false;

  StockingFillerGame get gameRef => game;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _targetX = (gameRef.size.x - _width) / 2;
  }

  @override
  Body createBody() {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    final startX = (screenWidth - _width) / 2;
    final startY = screenHeight - GameDimensions.stockingBottomOffset - _height;

    _targetX = startX;

    final bodyDef = BodyDef(
      type: BodyType.kinematic,
      position: Vector2(startX + _width / 2, startY + _height / 2),
      fixedRotation: true,
    );

    final body = world.createBody(bodyDef);

    // Create the stocking shape - a rounded rectangle
    final shape = PolygonShape()..setAsBox(_width / 2, _height / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(
      shape,
      density: PhysicsConstants.stockingDensity,
      friction: PhysicsConstants.stockingFriction,
      isSensor: true,
    );

    body.createFixture(fixtureDef);

    return body;
  }

  void moveHorizontally(double deltaX) {
    _targetX += deltaX;
    _clampPosition();
  }

  void _clampPosition() {
    final maxX = gameRef.size.x - _width;
    _targetX = _targetX.clamp(0, maxX);
  }

  void reset() {
    _targetX = (gameRef.size.x - _width) / 2;
    _velocity = 0;

    if (!isLoaded) return;

    final screenHeight = gameRef.size.y;
    final startY = screenHeight - GameDimensions.stockingBottomOffset - _height;

    body.setTransform(Vector2(_targetX + _width / 2, startY + _height / 2), 0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle keyboard input
    if (_moveLeft) {
      _targetX -= 400 * dt;
    }
    if (_moveRight) {
      _targetX += 400 * dt;
    }
    _clampPosition();

    // Smooth movement with velocity-based approach
    final currentX = body.position.x - _width / 2;
    final diff = _targetX - currentX;
    _velocity = diff * 10; // Smooth interpolation

    body.linearVelocity = Vector2(_velocity, 0);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _moveLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA);
    _moveRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD);
    return true;
  }

  @override
  void render(Canvas canvas) {
    final cachedPicture = GameImageCache.instance.stockingPicture;
    if (cachedPicture != null) {
      canvas.drawPicture(cachedPicture);
    }
  }

  // Get bounding box for collision detection
  Rect? get bounds {
    if (!isLoaded) return null;
    final pos = body.position;
    return Rect.fromCenter(center: Offset(pos.x, pos.y), width: _width, height: _height);
  }
}
