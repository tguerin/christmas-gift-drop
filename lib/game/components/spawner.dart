import 'dart:math';

import 'package:christmas_gift_drop/game/components/present.dart';
import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:flame/components.dart';

class PresentSpawner extends Component {
  PresentSpawner(this.game);

  final StockingFillerGame game;
  final Random _random = Random();

  double _spawnTimer = 0;
  final double _spawnInterval = 0.5;
  bool _active = false;

  void start() {
    _active = true;
    _spawnTimer = 0;
  }

  void stop() {
    _active = false;
  }

  void reset() {
    _active = true;
    _spawnTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_active || game.gameState != GameState.playing) return;

    _spawnTimer += dt;

    // Update difficulty manager
    game.difficultyManager.update(dt);

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _trySpawnPresent();
    }
  }

  void _trySpawnPresent() {
    final spawnChance = game.difficultyManager.spawnChance;

    if (_random.nextDouble() < spawnChance * 10) {
      _spawnPresent();
    }
  }

  void _spawnPresent() {
    final screenWidth = game.size.x;
    final presentType = game.difficultyManager.getRandomPresentType();

    // Random X position with padding
    final padding = presentType.size;
    final spawnX = padding + _random.nextDouble() * (screenWidth - padding * 2);

    // Calculate fall speed based on difficulty
    const baseSpeed = PhysicsConstants.baseFallSpeed;
    final difficultyMultiplier = game.difficultyManager.fallSpeedMultiplier;
    final typeMultiplier = presentType.speedMultiplier;
    final fallSpeed = baseSpeed * difficultyMultiplier * typeMultiplier;

    final present = PresentComponent(presentType: presentType, spawnX: spawnX, fallSpeed: fallSpeed);

    game.add(present);
  }
}
