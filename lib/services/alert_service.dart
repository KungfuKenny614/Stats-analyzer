import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stats_analyzer/models/alert_models.dart';

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
  bool _isMonitoring = false;

  // Getters
  List<BettingAlert> get alerts => _alerts;
  List<BettingAlert> get unreadAlerts => _alerts.where((a) => !a.isRead && !a.isDismissed).toList();
  List<AlertRule> get activeRules => _rules.where((r) => r.isActive).toList();
  Stream<BettingAlert> get alertStream => _alertController.stream;

  // Initialize
  Future<void> initialize() async {
    // Initialize notifications
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

    // Load saved alerts
    await _loadAlerts();

    // Load rules
    _loadRules();

    // Request permissions
    await _requestPermissions();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // Android
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestPermission();
      }

      // iOS
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

  // Save alerts - FIXED: properly convert to JSON strings
  Future<void> _saveAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert each alert to a JSON string
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

    // Keep only last 100 alerts
    if (_alerts.length > 100) {
      _alerts.removeLast();
    }

    await _saveAlerts();
    _alertController.add(alert);

    // Send notification
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

  // Generate alerts based on rules
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

      // Check if rule applies to this player/stat
      if (rule.playerId != null && rule.playerId != playerId) continue;
      if (rule.statType != null && rule.statType != statType) continue;

      // Check if rule should trigger
      if (rule.shouldTrigger(currentValue, previousValue)) {
        // Generate alert based on rule type
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

  // ===================== SIMULATE REAL-TIME DATA =====================

  // Start monitoring (simulated for now)
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitorTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _simulateAlert();
    });

    print('🔔 Alert monitoring started');
  }

  // Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    print('🔕 Alert monitoring stopped');
  }

  // Simulate alert generation
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

    // Only generate alert ~15% of the time
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

  // Dispose
  void dispose() {
    stopMonitoring();
    _alertController.close();
  }
}
