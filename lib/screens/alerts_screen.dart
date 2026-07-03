import 'package:flutter/material.dart';
import 'package:stats_analyzer/models/alert_models.dart';
import 'package:stats_analyzer/services/alert_service.dart';
import 'package:stats_analyzer/config/theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();
  bool _isMonitoring = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _alertService.initialize();
    _alertService.startMonitoring();
    setState(() {
      _isMonitoring = true;
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _alertService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final alerts = _alertService.alerts;
    final unreadCount = _alertService.unreadAlerts.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Betting Alerts'),
            const Spacer(),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMonitoring ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            onPressed: () {
              setState(() {
                _isMonitoring = !_isMonitoring;
                if (_isMonitoring) {
                  _alertService.startMonitoring();
                } else {
                  _alertService.stopMonitoring();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: () {
              _alertService.clearAllAlerts();
              setState(() {});
            },
          ),
        ],
      ),
      body: alerts.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertCard(alert, context);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Alerts Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alerts will appear here when there are\nbetting opportunities or important updates',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _alertService.addAlert(
                BettingAlert(
                  id: 'test_${DateTime.now().millisecondsSinceEpoch}',
                  type: AlertType.evOpportunity,
                  severity: AlertSeverity.high,
                  title: '🔥 EV+ Opportunity Test',
                  description: 'Shohei Ohtani Total Bases O1.5 shows 8.5% EV',
                  playerName: 'Shohei Ohtani',
                  ev: 8.5,
                  timestamp: DateTime.now(),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.flash_on_rounded),
            label: const Text('Test Alert'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BettingAlert alert, BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (!alert.isRead) {
            _alertService.markAsRead(alert.id);
            setState(() {});
          }
        },
        onLongPress: () {
          _alertService.dismissAlert(alert.id);
          setState(() {});
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: alert.severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  alert.icon,
                  color: alert.severityColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: TextStyle(
                              fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: alert.severityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            alert.severity.toString().split('.').last,
                            style: TextStyle(
                              color: alert.severityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          alert.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                        if (alert.ev != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: alert.ev! > 5 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'EV: ${alert.ev!.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: alert.ev! > 5 ? Colors.green : Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (alert.playerName != null)
                          Text(
                            '👤 ${alert.playerName}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: () {
                  _alertService.dismissAlert(alert.id);
                  setState(() {});
                },
                color: Colors.grey[500],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
