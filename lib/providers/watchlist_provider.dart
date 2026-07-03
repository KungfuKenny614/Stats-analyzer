import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WatchlistProvider extends ChangeNotifier {
  static const String _watchlistKey = 'watchlist';
  List<Map<String, dynamic>> _items = [];

  WatchlistProvider() { _loadWatchlist(); }
  List<Map<String, dynamic>> get items => _items;
  bool contains(String playerId) => _items.any((item) => item['id'] == playerId);

  Future<void> _loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_watchlistKey);
    if (data != null) {
      try { _items = List<Map<String, dynamic>>.from(jsonDecode(data)); } catch (_) { _items = []; }
    } else { _items = []; }
    notifyListeners();
  }

  Future<void> _saveWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_watchlistKey, jsonEncode(_items));
  }

  void addItem(Map<String, dynamic> player) {
    if (contains(player['id'])) return;
    _items.add(player);
    _saveWatchlist();
    notifyListeners();
  }

  void removeItem(String playerId) {
    _items.removeWhere((item) => item['id'] == playerId);
    _saveWatchlist();
    notifyListeners();
  }

  void toggleItem(Map<String, dynamic> player) {
    if (contains(player['id'])) removeItem(player['id']);
    else addItem(player);
  }
}
