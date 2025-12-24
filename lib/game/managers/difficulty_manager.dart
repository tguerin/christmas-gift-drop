import 'dart:math';

import 'package:christmas_gift_drop/game/managers/score_manager.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';

class DifficultyManager {
  DifficultyManager(this.scoreManager);

  final ScoreManager scoreManager;
  final Random _random = Random();

  DifficultyLevel _currentLevel = DifficultySettings.levels[0];
  double _windDirection = 0;
  double _windTimer = 0;

  DifficultyLevel get currentLevel => _currentLevel;

  double get windForce =>
      _currentLevel.hasWind ? _windDirection * _currentLevel.windStrength * PhysicsConstants.maxWindForce : 0;

  void updateDifficulty() {
    _currentLevel = DifficultySettings.getLevel(scoreManager.score);
  }

  void update(double dt) {
    if (_currentLevel.hasWind) {
      _windTimer += dt;
      // Wind changes direction smoothly using sine wave
      _windDirection = sin(_windTimer * 0.5);
    }
  }

  double get spawnChance => _currentLevel.spawnChance;
  double get fallSpeedMultiplier => _currentLevel.fallSpeedMultiplier;

  PresentType getRandomPresentType() {
    final available = _currentLevel.availablePresents;
    return available[_random.nextInt(available.length)];
  }

  void reset() {
    _currentLevel = DifficultySettings.levels[0];
    _windDirection = 0;
    _windTimer = 0;
  }
}
