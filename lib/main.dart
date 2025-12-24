import 'package:christmas_gift_drop/game/overlays/game_over.dart';
import 'package:christmas_gift_drop/game/overlays/hud.dart';
import 'package:christmas_gift_drop/game/overlays/start_screen.dart';
import 'package:christmas_gift_drop/game/stocking_filler_game.dart';
import 'package:christmas_gift_drop/game/utils/constants.dart';
import 'package:christmas_gift_drop/game/utils/image_cache.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).ignore();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameColors.backgroundTop,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const StockingFillerApp());
}

class StockingFillerApp extends StatelessWidget {
  const StockingFillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stocking Filler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: GameColors.stockingRed, brightness: Brightness.dark),
        textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    // Pre-load fonts to avoid flash of unstyled text
    await GoogleFonts.pendingFonts([
      GoogleFonts.quicksand(),
      GoogleFonts.quicksand(fontWeight: FontWeight.w500),
      GoogleFonts.pressStart2p(),
      GoogleFonts.notoColorEmoji(),
    ]);

    // Pre-cache all game images before starting
    await GameImageCache.instance.initialize();

    if (mounted) {
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const GamePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundTop,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🧦', style: GoogleFonts.notoColorEmoji(fontSize: 60)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: GameColors.stockingRed),
            const SizedBox(height: 20),
            Text('Loading Christmas Spirit...', style: GoogleFonts.quicksand(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late StockingFillerGame _game;

  @override
  void initState() {
    super.initState();
    _game = StockingFillerGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(child: _buildGameContainer(constraints));
        },
      ),
    );
  }

  Widget _buildGameContainer(BoxConstraints constraints) {
    // Calculate game size maintaining aspect ratio
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    // Target aspect ratio (9:16 for mobile-first)
    const targetAspectRatio = 9 / 16;
    final screenAspectRatio = screenWidth / screenHeight;

    double gameWidth;
    double gameHeight;

    if (screenAspectRatio > targetAspectRatio) {
      // Screen is wider than target - constrain by height
      gameHeight = screenHeight;
      gameWidth = gameHeight * targetAspectRatio;
    } else {
      // Screen is taller than target - constrain by width
      gameWidth = screenWidth;
      gameHeight = gameWidth / targetAspectRatio;
    }

    // For very wide screens (web), add decorative borders
    final isWideScreen = screenWidth > 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left decoration for wide screens
        if (isWideScreen) _buildSideDecoration(isLeft: true),

        // Game container
        Container(
          width: gameWidth.clamp(0, 500),
          height: gameHeight,
          decoration: BoxDecoration(
            boxShadow: isWideScreen
                ? [BoxShadow(color: GameColors.stockingRed.withAlpha(50), blurRadius: 50, spreadRadius: 10)]
                : null,
            border: isWideScreen ? Border.all(color: GameColors.glassEdge, width: 2) : null,
            borderRadius: isWideScreen ? BorderRadius.circular(20) : null,
          ),
          child: ClipRRect(
            borderRadius: isWideScreen ? BorderRadius.circular(20) : BorderRadius.zero,
            child: GameWidget<StockingFillerGame>(
              game: _game,
              overlayBuilderMap: {
                'startScreen': (context, game) => StartScreenOverlay(game: game),
                'hud': (context, game) => HudOverlay(game: game),
                'gameOver': (context, game) => GameOverOverlay(game: game),
              },
              initialActiveOverlays: const ['startScreen'],
              loadingBuilder: (context) => const ColoredBox(
                color: GameColors.backgroundTop,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🧦', style: TextStyle(fontSize: 60)),
                      SizedBox(height: 20),
                      CircularProgressIndicator(color: GameColors.stockingRed),
                    ],
                  ),
                ),
              ),
              errorBuilder: (context, error) => ColoredBox(
                color: GameColors.backgroundTop,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('😢', style: GoogleFonts.notoColorEmoji(fontSize: 60)),
                      const SizedBox(height: 20),
                      Text(
                        'Oops! Something went wrong',
                        style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right decoration for wide screens
        if (isWideScreen) _buildSideDecoration(isLeft: false),
      ],
    );
  }

  Widget _buildSideDecoration({required bool isLeft}) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingEmoji(isLeft ? '🎄' : '⭐'),
          _buildFloatingEmoji(isLeft ? '🎁' : '🎀'),
          _buildFloatingEmoji(isLeft ? '❄️' : '🎄'),
          _buildFloatingEmoji(isLeft ? '⭐' : '🎁'),
          _buildFloatingEmoji(isLeft ? '🎀' : '❄️'),
        ],
      ),
    );
  }

  Widget _buildFloatingEmoji(String emoji) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(opacity: 0.5, child: Text(emoji, style: GoogleFonts.notoColorEmoji(fontSize: 30)));
      },
    );
  }
}
