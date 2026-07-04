import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stats_analyzer/models/alert_models.dart';
import 'package:stats_analyzer/services/arbitrage_scanner.dart';
import 'package:stats_analyzer/providers/app_state.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final List<BettingAlert> _alerts = [];
  final List<AlertRule> _rules = [];
  final StreamController<BettingAlert> _alertController =
      StreamController<BettingAlert>.broadcast();

  Timer? _monitorTimer;
  Timer? _arbitrageTimer;
  bool _isMonitoring = false;

  // Getters
  List<BettingAlert> get alerts => _alerts;
  List<BettingAlert> get unreadAlerts => _alerts.where((a) => !a.isRead && !a.isDismissed).toList();
  List<AlertRule> get activeRules => _rules.where((r) => r.isActive).toList();
  Stream<BettingAlert> get alertStream => _alertController.stream;

  // Initialize
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    await _loadAlerts();
    _loadRules();
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestPermission();
      }
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  // Load saved alerts
  Future<void> _loadAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('alerts') ?? [];
      _alerts.clear();
      for (final json in alertsJson) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          _alerts.add(BettingAlert.fromJson(data));
        } catch (e) {
          // Skip invalid alerts
        }
      }
    } catch (e) {
      print('Error loading alerts: $e');
    }
  }

  // Save alerts
  Future<void> _saveAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> alertsJson = _alerts.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList('alerts', alertsJson);
    } catch (e) {
      print('Error saving alerts: $e');
    }
  }

  // Load rules
  void _loadRules() {
    _rules.clear();
    _rules.addAll(PrebuiltAlertRules.defaultRules);
  }

  // Add alert
  Future<void> addAlert(BettingAlert alert) async {
    _alerts.insert(0, alert);
    if (_alerts.length > 100) {
      _alerts.removeLast();
    }
    await _saveAlerts();
    _alertController.add(alert);
    await _sendNotification(alert);
  }

  // Mark alert as read
  Future<void> markAsRead(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index].isRead = true;
      await _saveAlerts();
    }
  }

  // Dismiss alert
  Future<void> dismissAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index].isDismissed = true;
      await _saveAlerts();
    }
  }

  // Clear all alerts
  Future<void> clearAllAlerts() async {
    _alerts.clear();
    await _saveAlerts();
  }

  // Send notification
  Future<void> _sendNotification(BettingAlert alert) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'betting_alerts',
        'Betting Alerts',
        channelDescription: 'Real-time betting alerts and opportunities',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(alert.description),
        color: alert.severityColor,
      );

      final iosDetails = DarwinNotificationDetails(
        subtitle: alert.title,
        sound: 'default',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        alert.id.hashCode,
        alert.title,
        alert.description,
        details,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // ===================== ALERT GENERATION =====================

  Future<void> checkAndGenerateAlerts({
    required String playerName,
    required String playerId,
    required String statType,
    required double currentValue,
    double? previousValue,
    double? ev,
    Map<String, dynamic>? context,
  }) async {
    for (final rule in _rules) {
      if (!rule.isActive) continue;
      if (rule.playerId != null && rule.playerId != playerId) continue;
      if (rule.statType != null && rule.statType != statType) continue;

      if (rule.shouldTrigger(currentValue, previousValue)) {
        final alert = _generateAlertFromRule(
          rule: rule,
          playerName: playerName,
          playerId: playerId,
          statType: statType,
          currentValue: currentValue,
          previousValue: previousValue,
          ev: ev,
          context: context,
        );
        await addAlert(alert);
      }
    }
  }

  BettingAlert _generateAlertFromRule({
    required AlertRule rule,
    required String playerName,
    required String playerId,
    required String statType,
    required double currentValue,
    double? previousValue,
    double? ev,
    Map<String, dynamic>? context,
  }) {
    String title;
    String description;

    switch (rule.type) {
      case AlertType.evOpportunity:
        title = '🔥 EV+ Opportunity Detected!';
        description = '$playerName $statType O${currentValue.toStringAsFixed(1)} shows ${ev?.toStringAsFixed(1)}% EV';
        break;
      case AlertType.oddsMovement:
        final percentChange = previousValue != null
            ? ((currentValue - previousValue) / previousValue * 100)
            : 0;
        title = '📈 Significant Odds Movement';
        description = '$playerName $statType moved from ${previousValue?.toStringAsFixed(1)} to ${currentValue.toStringAsFixed(1)} (${percentChange.toStringAsFixed(1)}%)';
        break;
      case AlertType.hotStreak:
        title = '🔥 Hot Streak Alert!';
        description = '$playerName has hit in ${currentValue.toStringAsFixed(0)}% of recent games';
        break;
      default:
        title = '⚡ Alert: $playerName';
        description = '$playerName $statType is at ${currentValue.toStringAsFixed(2)}';
    }

    return BettingAlert(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      type: rule.type,
      severity: rule.severity,
      title: title,
      description: description,
      playerName: playerName,
      playerId: playerId,
      currentValue: currentValue,
      previousValue: previousValue,
      ev: ev,
      timestamp: DateTime.now(),
    );
  }

  // ===================== ARBITRAGE SCANNING =====================

  void startArbitrageScanning(AppState appState) {
    _arbitrageTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final opportunities = ArbitrageScanner.scan(appState.filteredMarkets);
      for (final opp in opportunities) {
        if ((opp['profit'] as double) > 1.0) {
          _sendArbitrageNotification(opp);
        }
      }
    });
  }

  void stopArbitrageScanning() {
    _arbitrageTimer?.cancel();
    _arbitrageTimer = null;
  }

  void _sendArbitrageNotification(Map<String, dynamic> opp) {
    addAlert(BettingAlert(
      id: 'arb_${DateTime.now().millisecondsSinceEpoch}',
      type: AlertType.custom,
      severity: AlertSeverity.high,
      title: '🔥 Arbitrage Opportunity!',
      description: '${opp['player1']} vs ${opp['player2']} with ${(opp['profit'] as double).toStringAsFixed(2)}% profit',
      ev: opp['profit'],
      timestamp: DateTime.now(),
    ));
  }

  // ===================== SIMULATE REAL-TIME DATA =====================

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _monitorTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _simulateAlert();
    });
    print('🔔 Alert monitoring started');
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    print('🔕 Alert monitoring stopped');
  }

  void _simulateAlert() {
    final players = [
      'Shohei Ohtani',
      'Aaron Judge',
      'Mookie Betts',
      'Freddie Freeman',
      'Bryce Harper',
    ];

    final stats = ['Total Bases', 'Home Runs', 'RBI', 'Hits'];
    final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000;

    if (random > 0.15) return;

    final playerIndex = (random * players.length).toInt();
    final statIndex = (random * stats.length).toInt();

    final playerName = players[playerIndex % players.length];
    final statType = stats[statIndex % stats.length];
    final currentValue = 0.5 + (random % 3);
    final previousValue = currentValue - (random % 1);
    final ev = (random % 15) + 1;

    checkAndGenerateAlerts(
      playerName: playerName,
      playerId: 'player_$playerIndex',
      statType: statType,
      currentValue: currentValue,
      previousValue: previousValue,
      ev: ev,
    );
  }

  void dispose() {
    stopMonitoring();
    stopArbitrageScanning();
    _alertController.close();
  }
}
