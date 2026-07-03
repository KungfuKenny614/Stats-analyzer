import 'package:flutter/material.dart';

// ===================== ALERT TYPES =====================

enum AlertType {
  oddsMovement,
  evOpportunity,
  hotStreak,
  injuryUpdate,
  lineupChange,
  weatherAlert,
  custom,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

// ===================== ALERT MODEL =====================

class BettingAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String? playerName;
  final String? playerId;
  final String? gameId;
  final double? currentValue;
  final double? previousValue;
  final double? threshold;
  final double? ev;
  final DateTime timestamp;
  bool isRead;
  bool isDismissed;

  BettingAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    this.playerName,
    this.playerId,
    this.gameId,
    this.currentValue,
    this.previousValue,
    this.threshold,
    this.ev,
    required this.timestamp,
    this.isRead = false,
    this.isDismissed = false,
  });

  // Getters
  Color get severityColor {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.deepPurple;
    }
  }

  IconData get icon {
    switch (type) {
      case AlertType.oddsMovement:
        return Icons.trending_up_rounded;
      case AlertType.evOpportunity:
        return Icons.money_rounded;
      case AlertType.hotStreak:
        return Icons.local_fire_department_rounded;
      case AlertType.injuryUpdate:
        return Icons.medical_services_rounded;
      case AlertType.lineupChange:
        return Icons.swap_horiz_rounded;
      case AlertType.weatherAlert:
        return Icons.wb_sunny_rounded;
      case AlertType.custom:
        return Icons.notifications_active_rounded;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return timestamp.toLocal().toString().substring(0, 10);
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'severity': severity.toString(),
    'title': title,
    'description': description,
    'playerName': playerName,
    'playerId': playerId,
    'gameId': gameId,
    'currentValue': currentValue,
    'previousValue': previousValue,
    'threshold': threshold,
    'ev': ev,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'isDismissed': isDismissed,
  };

  factory BettingAlert.fromJson(Map<String, dynamic> json) {
    return BettingAlert(
      id: json['id'],
      type: AlertType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AlertType.custom,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
      title: json['title'],
      description: json['description'],
      playerName: json['playerName'],
      playerId: json['playerId'],
      gameId: json['gameId'],
      currentValue: json['currentValue'],
      previousValue: json['previousValue'],
      threshold: json['threshold'],
      ev: json['ev'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      isDismissed: json['isDismissed'] ?? false,
    );
  }
}

// ===================== ALERT RULE =====================

class AlertRule {
  final String id;
  final String name;
  final AlertType type;
  final AlertSeverity severity;
  final String? playerId;
  final String? statType;
  final double? threshold;
  final String? condition; // 'above', 'below', 'between'
  final double? minValue;
  final double? maxValue;
  final bool isActive;
  final DateTime createdAt;
  final List<String>? sportsbooks;

  AlertRule({
    required this.id,
    required this.name,
    required this.type,
    required this.severity,
    this.playerId,
    this.statType,
    this.threshold,
    this.condition,
    this.minValue,
    this.maxValue,
    this.isActive = true,
    required this.createdAt,
    this.sportsbooks,
  });

  // Check if this rule should trigger
  bool shouldTrigger(double currentValue, double? previousValue) {
    if (!isActive) return false;

    switch (condition) {
      case 'above':
        return currentValue > (threshold ?? 0);
      case 'below':
        return currentValue < (threshold ?? 0);
      case 'between':
        if (minValue != null && maxValue != null) {
          return currentValue >= minValue! && currentValue <= maxValue!;
        }
        return false;
      case 'movement':
        if (previousValue != null) {
          final percentChange = ((currentValue - previousValue) / previousValue) * 100;
          return percentChange.abs() > (threshold ?? 10);
        }
        return false;
      default:
        return false;
    }
  }
}

// ===================== PRE-BUILT RULES =====================

class PrebuiltAlertRules {
  static List<AlertRule> get defaultRules {
    final now = DateTime.now();

    return [
      AlertRule(
        id: 'ev_alert',
        name: '🔥 EV+ Opportunity',
        type: AlertType.evOpportunity,
        severity: AlertSeverity.high,
        condition: 'above',
        threshold: 5.0,
        createdAt: now,
      ),
      AlertRule(
        id: 'odds_movement',
        name: '📈 Significant Odds Movement',
        type: AlertType.oddsMovement,
        severity: AlertSeverity.medium,
        condition: 'movement',
        threshold: 10.0,
        createdAt: now,
      ),
      AlertRule(
        id: 'hot_streak',
        name: '🔥 Hot Streak Detection',
        type: AlertType.hotStreak,
        severity: AlertSeverity.high,
        condition: 'above',
        threshold: 70.0,
        createdAt: now,
      ),
    ];
  }
}
