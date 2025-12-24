import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _highScoreKey = 'stocking_filler_high_score';

  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  int _maxCombo = 0;

  int get score => _score;
  int get highScore => _highScore;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  bool get isNewHighScore => _score > _highScore && _score > 0;

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> saveHighScore() async {
    if (_score > _highScore) {
      _highScore = _score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, _highScore);
    }
  }

  void addPoints(int points) {
    _score += points;
    if (points > 0) {
      _combo++;
      if (_combo > _maxCombo) {
        _maxCombo = _combo;
      }
    }
  }

  void breakCombo() {
    _combo = 0;
  }

  void reset() {
    _score = 0;
    _combo = 0;
    _maxCombo = 0;
  }
}
