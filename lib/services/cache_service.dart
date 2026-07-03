import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stats_analyzer/models/mlb_models.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class CacheService {
  static const String _gamesKey = 'cached_games';
  static const String _marketsKey = 'cached_markets';
  static const String _analyticsKey = 'cached_analytics';
  static const String _timestampKey = 'cache_timestamp';

  Future<void> cacheGames(List<MLBGame> games) async {
    final prefs = await SharedPreferences.getInstance();
    final json = games.map((g) => g.toJson()).toList();
    await prefs.setString(_gamesKey, jsonEncode(json));
    await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
  }

  Future<List<MLBGame>> getCachedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_gamesKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((j) => MLBGame.fromJson(j)).toList();
  }

  Future<void> cacheMarkets(List<MLBNormalizedMarket> markets) async {
    final prefs = await SharedPreferences.getInstance();
    final json = markets.map((m) => m.toJson()).toList();
    await prefs.setString(_marketsKey, jsonEncode(json));
  }

  Future<List<MLBNormalizedMarket>> getCachedMarkets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_marketsKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((j) => MLBNormalizedMarket.fromJson(j)).toList();
  }

  Future<void> cacheAnalytics(List<MLBAnalyticsResult> analytics) async {
    final prefs = await SharedPreferences.getInstance();
    final json = analytics.map((a) => a.toJson()).toList();
    await prefs.setString(_analyticsKey, jsonEncode(json));
  }

  Future<List<MLBAnalyticsResult>> getCachedAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_analyticsKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((j) => MLBAnalyticsResult.fromJson(j)).toList();
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_timestampKey);
    if (timestampStr == null) return false;
    final timestamp = DateTime.parse(timestampStr);
    return DateTime.now().difference(timestamp).inHours < 1;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gamesKey);
    await prefs.remove(_marketsKey);
    await prefs.remove(_analyticsKey);
    await prefs.remove(_timestampKey);
  }
}
