import 'package:flutter/material.dart';
import 'package:stats_analyzer/models/mlb_models.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';
import 'package:stats_analyzer/services/mlb_api_service.dart';
import 'package:stats_analyzer/services/mlb_outlier_engine.dart';

class AppState extends ChangeNotifier {
  final MLBApiService _apiService = MLBApiService();
  final MLBOutlierEngine _engine = MLBOutlierEngine();
  
  // Data
  List<MLBGame> _games = [];
  List<MLBNormalizedMarket> _markets = [];
  List<MLBAnalyticsResult> _analytics = [];
  
  // UI State
  int _selectedNavIndex = 0;
  String _selectedTab = 'Overview';
  String _searchQuery = '';
  String _selectedLeague = 'MLB';
  String _selectedMarket = 'All';
  String _selectedBook = 'All';
  double _minEV = 0;
  double _minHitRate = 0;
  String _movementFilter = 'All';
  bool _showInjuryOnly = false;
  int _selectedRowIndex = -1;
  
  // Loading state
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<MLBGame> get games => _games;
  List<MLBNormalizedMarket> get markets => _markets;
  List<MLBAnalyticsResult> get analytics => _analytics;
  int get selectedNavIndex => _selectedNavIndex;
  String get selectedTab => _selectedTab;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get selectedRowIndex => _selectedRowIndex;
  String get selectedLeague => _selectedLeague;
  
  // Filtered markets
  List<MLBNormalizedMarket> get filteredMarkets {
    return _markets.where((market) {
      // Search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!market.playerName.toLowerCase().contains(query) &&
            !market.team.toLowerCase().contains(query) &&
            !market.marketType.toLowerCase().contains(query)) {
          return false;
        }
      }
      // Market type
      if (_selectedMarket != 'All' && market.marketType != _selectedMarket) {
        return false;
      }
      // Min EV
      final analytics = getAnalyticsForMarket(market);
      if (_minEV > 0 && (analytics?.ev ?? 0) < _minEV) {
        return false;
      }
      // Min Hit Rate
      if (_minHitRate > 0 && (analytics?.hitRate ?? 0) < _minHitRate) {
        return false;
      }
      return true;
    }).toList();
  }

  // Get analytics for a market
  MLBAnalyticsResult? getAnalyticsForMarket(MLBNormalizedMarket market) {
    try {
      return _analytics.firstWhere((a) => a.marketId == market.playerId);
    } catch (e) {
      return null;
    }
  }

  // Get selected player name
  String get selectedPlayerName {
    if (_selectedRowIndex >= 0 && _selectedRowIndex < _markets.length) {
      return _markets[_selectedRowIndex].playerName;
    }
    return 'Select a prop';
  }

  // Get selected analytics
  MLBAnalyticsResult? get selectedAnalytics {
    if (_selectedRowIndex >= 0 && _selectedRowIndex < _markets.length) {
      return getAnalyticsForMarket(_markets[_selectedRowIndex]);
    }
    return null;
  }

  // ========================================================================
  // ACTIONS
  // ========================================================================

  Future<void> loadData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // 1. Fetch today's games
      _games = await _apiService.fetchTodayGames();
      
      if (_games.isEmpty) {
        _loadSampleData();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Generate markets from games
      _markets = await _apiService.generateMarketsFromGames(_games);
      
      if (_markets.isEmpty) {
        _loadSampleData();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 3. Generate analytics for each market
      _analytics = _markets.map((market) {
        final projection = market.line + (DateTime.now().millisecondsSinceEpoch % 100 / 100 - 0.5) * 2;
        final ev = (projection / market.line - 1) * 100;
        final hitRate = 0.3 + (DateTime.now().millisecondsSinceEpoch % 50) / 100;
        return MLBAnalyticsResult(
          marketId: market.playerId,
          playerName: market.playerName,
          marketType: market.marketType,
          line: market.line,
          ev: ev,
          arbitrageProfit: 0.0,
          hitRate: hitRate,
          splits: {
            'Home': 0.5 + (DateTime.now().millisecondsSinceEpoch % 30) / 100,
            'Away': 0.5 + (DateTime.now().millisecondsSinceEpoch % 40) / 100,
          },
          hardHitRate: 0.3 + (DateTime.now().millisecondsSinceEpoch % 20) / 100,
          barrelRate: 0.1 + (DateTime.now().millisecondsSinceEpoch % 15) / 100,
          avgExitVelocity: 85 + (DateTime.now().millisecondsSinceEpoch % 15),
          recommendation: ev > 5 ? '🔥 Strong BUY' : ev > 1 ? '✅ BUY' : '⚖️ NEUTRAL',
        );
      }).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _loadSampleData();
      notifyListeners();
    }
  }

  void _loadSampleData() {
    _markets = _engine.generateSampleMLBMarkets();
    _analytics = _markets.map((market) {
      final stats = _engine.generateSampleMLBStats(market.playerId, market.playerName, market.team);
      return _engine.analyzeMLBMarket(
        marketId: market.playerId,
        market: market,
        stats: stats,
        modelProjection: market.line + (DateTime.now().millisecondsSinceEpoch % 100 / 100 - 0.5) * 2,
        sharpPercentage: 0.3 + (DateTime.now().millisecondsSinceEpoch % 100 / 100) * 0.4,
        publicPercentage: 0.3 + (DateTime.now().millisecondsSinceEpoch % 100 / 100) * 0.4,
        previousLine: market.line - 0.5,
        previousOdds: -110 + (DateTime.now().millisecondsSinceEpoch % 50),
      );
    }).toList();
  }

  // Navigation
  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMarketFilter(String market) {
    _selectedMarket = market;
    notifyListeners();
  }

  void setMinEV(double ev) {
    _minEV = ev;
    notifyListeners();
  }

  void setMinHitRate(double rate) {
    _minHitRate = rate;
    notifyListeners();
  }

  void selectRow(int index) {
    _selectedRowIndex = index;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await loadData();
  }
}
