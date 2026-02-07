import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stats.dart';

class StatsService {
  static const String _key = 'wordle_stats';

  Future<GameStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return const GameStats();
    return GameStats.fromJson(jsonDecode(json));
  }

  Future<void> saveStats(GameStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(stats.toJson()));
  }
}
