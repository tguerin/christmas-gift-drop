import 'package:christmas_gift_drop/game/components/background.dart';
import 'package:christmas_gift_drop/game/components/present.dart';
import 'package:christmas_gift_drop/game/components/spawner.dart';
import 'package:christmas_gift_drop/game/components/stocking.dart';
import 'package:christmas_gift_drop/game/managers/difficulty_manager.dart';
import 'package:christmas_gift_drop/game/managers/score_manager.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:flame/components.dart' show Anchor, FpsTextComponent, TextPaint;
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

enum GameState { menu, playing, gameOver }

class StockingFillerGame extends Forge2DGame with HasKeyboardHandlerComponents, PanDetector {
  StockingFillerGame() : super(gravity: Vector2(0, PhysicsConstants.gravity), zoom: 1);

  late StockingComponent stocking;
  late PresentSpawner spawner;
  late BackgroundComponent background;
  late DifficultyManager difficultyManager;
  late ScoreManager scoreManager;

  GameState gameState = GameState.menu;

  // Callbacks for UI updates
  VoidCallback? onScoreChanged;
  VoidCallback? onGameOver;
  VoidCallback? onGameStateChanged;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize managers
    scoreManager = ScoreManager();
    await scoreManager.loadHighScore();

    difficultyManager = DifficultyManager(scoreManager);

    // Add background
    background = BackgroundComponent();
    await add(background);

    // Create stocking but don't add yet (wait for game start)
    stocking = StockingComponent();

    // Create spawner
    spawner = PresentSpawner(this);

    // Set camera to view the game area
    camera.viewfinder.anchor = Anchor.topLeft;

    // Add FPS counter in top right
    add(
      FpsTextComponent(
        position: Vector2(size.x - 10, 10),
        anchor: Anchor.topRight,
        textRenderer: TextPaint(style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  Future<void> startGame() async {
    if (gameState == GameState.playing) return;

    gameState = GameState.playing;
    scoreManager.reset();

    // Clear any existing presents
    children.whereType<PresentComponent>().forEach((p) => p.removeFromParent());

    // Add stocking if not already added and wait for it to load
    if (!stocking.isMounted) {
      await add(stocking);
    }
    if (stocking.isLoaded) {
      stocking.reset();
    }

    // Add spawner if not already added
    if (!spawner.isMounted) {
      await add(spawner);
    }
    spawner.reset();

    onGameStateChanged?.call();
    onScoreChanged?.call();

    // Hide overlays
    overlays
      ..remove('gameOver')
      ..remove('startScreen')
      ..add('hud');
  }

  void endGame() {
    if (gameState != GameState.playing) return;

    gameState = GameState.gameOver;
    scoreManager.saveHighScore();

    spawner.stop();

    onGameOver?.call();
    onGameStateChanged?.call();

    // Show game over overlay
    overlays.add('gameOver');
  }

  void presentCaught(PresentComponent present) {
    if (gameState != GameState.playing) return;

    final presentType = present.presentType;

    // Bomb causes instant game over
    if (presentType == PresentType.bomb) {
      endGame();
      return;
    }

    scoreManager.addPoints(presentType.points);
    difficultyManager.updateDifficulty();

    onScoreChanged?.call();

    // Remove the present
    present.removeFromParent();
  }

  void presentMissed(PresentComponent present) {
    if (gameState != GameState.playing) return;

    // Bombs are good to miss!
    if (present.presentType == PresentType.bomb) {
      present.removeFromParent();
      return;
    }

    // Missing a present ends the game
    endGame();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (gameState == GameState.playing) {
      stocking.moveHorizontally(info.delta.global.x);
    }
  }

  @override
  Color backgroundColor() => GameColors.backgroundTop;

  Vector2 get gameSize => Vector2(size.x, size.y);

  double get screenWidth => size.x;
  double get screenHeight => size.y;
}
