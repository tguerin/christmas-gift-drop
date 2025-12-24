import 'dart:ui';

/// Game dimensions
class GameDimensions {
  const GameDimensions._();

  static const double gameWidth = 400;
  static const double gameHeight = 800;
  static const double aspectRatio = gameWidth / gameHeight;

  // Stocking
  static const double stockingWidth = 80;
  static const double stockingHeight = 60;
  static const double stockingBottomOffset = 60;

  // Presents
  static const double presentSize = 40;
  static const double presentSpawnY = -50;
}

/// Game colors - Deep night sky theme
class GameColors {
  const GameColors._();

  // Background gradient
  static const Color backgroundTop = Color(0xFF0a1628);
  static const Color backgroundBottom = Color(0xFF1a365d);

  // Stars
  static const Color starColor = Color(0xFFFFD700);
  static const Color starGlow = Color(0x40FFD700);

  // Stocking
  static const Color stockingRed = Color(0xFFDC143C);
  static const Color stockingDark = Color(0xFF8B0000);
  static const Color stockingTrim = Color(0xFFF5F5DC);
  static const Color stockingGold = Color(0xFFFFD700);

  // UI
  static const Color hudBackground = Color(0x40000000);
  static const Color hudText = Color(0xFFFFFFFF);
  static const Color scoreGold = Color(0xFFFFD700);
  static const Color comboOrange = Color(0xFFFF6B35);

  // Overlays
  static const Color overlayDark = Color(0xCC000000);
  static const Color glassFrost = Color(0x20FFFFFF);
  static const Color glassEdge = Color(0x40FFFFFF);

  // Presents
  static const Color presentRed = Color(0xFFE74C3C);
  static const Color presentGreen = Color(0xFF27AE60);
  static const Color presentBlue = Color(0xFF3498DB);
  static const Color presentPurple = Color(0xFF9B59B6);
}

/// Present types and their properties
enum PresentType {
  gift(emoji: '🎁', points: 1, speedMultiplier: 1, size: 40),
  ribbon(emoji: '🎀', points: 1, speedMultiplier: 1.3, size: 35),
  star(emoji: '⭐', points: 2, speedMultiplier: 0.8, size: 45),
  tree(emoji: '🎄', points: 1, speedMultiplier: 0.7, size: 50),
  snowflake(emoji: '❄️', points: 3, speedMultiplier: 0.6, size: 40),
  bomb(emoji: '💣', points: -1, speedMultiplier: 1.5, size: 35);

  const PresentType({required this.emoji, required this.points, required this.speedMultiplier, required this.size});

  final String emoji;
  final int points;
  final double speedMultiplier;
  final double size;
}

/// Difficulty settings per level
class DifficultyLevel {
  const DifficultyLevel({
    required this.minScore,
    required this.spawnChance,
    required this.fallSpeedMultiplier,
    required this.availablePresents,
    this.hasWind = false,
    this.windStrength = 0,
  });

  final int minScore;
  final double spawnChance;
  final double fallSpeedMultiplier;
  final List<PresentType> availablePresents;
  final bool hasWind;
  final double windStrength;
}

class DifficultySettings {
  const DifficultySettings._();

  static const List<DifficultyLevel> levels = [
    // Level 1: Score 0-10
    DifficultyLevel(
      minScore: 0,
      spawnChance: 0.03,
      fallSpeedMultiplier: 1,
      availablePresents: [PresentType.gift, PresentType.ribbon],
    ),
    // Level 2: Score 11-25
    DifficultyLevel(
      minScore: 11,
      spawnChance: 0.04,
      fallSpeedMultiplier: 1.2,
      availablePresents: [PresentType.gift, PresentType.ribbon, PresentType.star],
    ),
    // Level 3: Score 26-50
    DifficultyLevel(
      minScore: 26,
      spawnChance: 0.05,
      fallSpeedMultiplier: 1.4,
      availablePresents: [PresentType.gift, PresentType.ribbon, PresentType.star, PresentType.tree],
      hasWind: true,
      windStrength: 0.5,
    ),
    // Level 4: Score 51-100
    DifficultyLevel(
      minScore: 51,
      spawnChance: 0.06,
      fallSpeedMultiplier: 1.6,
      availablePresents: [
        PresentType.gift,
        PresentType.ribbon,
        PresentType.star,
        PresentType.tree,
        PresentType.snowflake,
      ],
      hasWind: true,
      windStrength: 1,
    ),
    // Level 5: Score 100+
    DifficultyLevel(
      minScore: 100,
      spawnChance: 0.07,
      fallSpeedMultiplier: 1.8,
      availablePresents: PresentType.values,
      hasWind: true,
      windStrength: 1.5,
    ),
  ];

  static DifficultyLevel getLevel(int score) {
    for (var i = levels.length - 1; i >= 0; i--) {
      if (score >= levels[i].minScore) {
        return levels[i];
      }
    }
    return levels[0];
  }
}

/// Physics constants
class PhysicsConstants {
  const PhysicsConstants._();

  static const double gravity = 15;
  static const double presentDensity = 1;
  static const double presentFriction = 0.3;
  static const double presentRestitution = 0.4;

  static const double stockingDensity = 10;
  static const double stockingFriction = 0.8;

  static const double baseFallSpeed = 150;
  static const double maxWindForce = 50;
}

/// Animation durations
class AnimationDurations {
  const AnimationDurations._();

  static const Duration scorePopup = Duration(milliseconds: 300);
  static const Duration gameOverFade = Duration(milliseconds: 500);
  static const Duration catchParticles = Duration(milliseconds: 400);
  static const Duration screenShake = Duration(milliseconds: 200);
}
