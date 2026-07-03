import 'dart:math';
import 'package:stats_analyzer/models/mlb_models.dart';
import 'package:stats_analyzer/models/advanced_stats.dart';

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  final Random _random = Random();

  // Simple neural network simulation
  Map<String, dynamic> predict({
    required MLBPlayer player,
    required AdvancedStats stats,
    required String statType,
  }) {
    // Extract features
    final features = _extractFeatures(player, stats, statType);
    
    // Run prediction (simulated neural network)
    final prediction = _runPrediction(features);
    
    // Calculate confidence
    final confidence = _calculateConfidence(prediction, features);
    
    // Calculate EV
    final ev = _calculateEV(prediction['probability'], 0.5);
    
    return {
      'predictedValue': prediction['value'],
      'confidence': confidence,
      'probability': prediction['probability'],
      'ev': ev,
      'features': features,
      'recommendation': ev > 3 ? 'Over ⬆️' : ev < -3 ? 'Under ⬇️' : 'Neutral ⚖️',
    };
  }

  Map<String, double> _extractFeatures(MLBPlayer player, AdvancedStats stats, String statType) {
    return {
      'avg': player.avg,
      'ops': player.ops,
      'hr': player.hr.toDouble(),
      'rbi': player.rbi.toDouble(),
      'hits': player.hits.toDouble(),
      'games': player.games.toDouble(),
      'barrelRate': stats.barrelRate ?? 0.1,
      'hardHitRate': stats.hardHitRate ?? 0.3,
      'exitVelocity': stats.avgExitVelocity ?? 85.0,
      'launchAngle': stats.avgLaunchAngle ?? 10.0,
      'sweetSpotRate': stats.sweetSpotRate ?? 0.3,
      'chaseRate': stats.chaseRate ?? 0.2,
      'whiffRate': stats.whiffRate ?? 0.15,
      'kRate': stats.kRate ?? 0.2,
      'bbRate': stats.bbRate ?? 0.08,
      'gbRate': stats.gbRate ?? 0.4,
      'fbRate': stats.fbRate ?? 0.3,
      'ldRate': stats.ldRate ?? 0.2,
    };
  }

  Map<String, dynamic> _runPrediction(Map<String, double> features) {
    // Simulated neural network
    double value = 0.5;
    double probability = 0.5;
    
    // Weighted sum of features
    value += features['avg']! * 0.5;
    value += features['ops']! * 0.3;
    value += features['barrelRate']! * 0.2;
    value += features['hardHitRate']! * 0.15;
    value += features['exitVelocity']! / 100 * 0.1;
    
    // Add some randomness
    value += (_random.nextDouble() - 0.5) * 0.2;
    
    // Clamp
    value = value.clamp(0.3, 2.5);
    
    // Calculate probability (0-1)
    probability = 0.3 + (value - 0.5) * 0.2 + _random.nextDouble() * 0.1;
    probability = probability.clamp(0.1, 0.9);
    
    return {
      'value': value,
      'probability': probability,
    };
  }

  double _calculateConfidence(Map<String, dynamic> prediction, Map<String, double> features) {
    // Higher confidence when features are strong
    double confidence = 0.5;
    confidence += features['avg']! * 0.2;
    confidence += features['ops']! * 0.15;
    confidence += features['barrelRate']! * 0.1;
    confidence += features['hardHitRate']! * 0.1;
    confidence += prediction['probability'] * 0.1;
    
    // More games = more confidence
    confidence += (features['games']! / 162) * 0.1;
    
    return confidence.clamp(0.1, 0.95);
  }

  double _calculateEV(double probability, double impliedProbability) {
    return (probability - impliedProbability) * 100;
  }

  // Get feature importance
  Map<String, double> getFeatureImportance() {
    return {
      'avg': 0.18,
      'ops': 0.15,
      'barrelRate': 0.12,
      'hardHitRate': 0.11,
      'exitVelocity': 0.10,
      'launchAngle': 0.08,
      'sweetSpotRate': 0.07,
      'chaseRate': 0.05,
      'whiffRate': 0.04,
      'kRate': 0.03,
      'bbRate': 0.03,
      'gbRate': 0.02,
      'fbRate': 0.01,
      'ldRate': 0.01,
    };
  }

  // Generate AI insight
  String generateInsight(MLBPlayer player, AdvancedStats stats) {
    final insights = <String>[];
    
    // Barrel rate insight
    if ((stats.barrelRate ?? 0) > 0.15) {
      insights.add('🔥 Elite barrel rate - consistently hitting the ball hard');
    } else if ((stats.barrelRate ?? 0) < 0.05) {
      insights.add('⚠️ Low barrel rate - struggling to make quality contact');
    }
    
    // Exit velocity insight
    if ((stats.avgExitVelocity ?? 0) > 92) {
      insights.add('💪 Excellent exit velocity - hitting the ball very hard');
    }
    
    // Plate discipline
    if ((stats.chaseRate ?? 0) < 0.2) {
      insights.add('👁️ Excellent plate discipline - doesn\'t chase bad pitches');
    }
    
    // K rate
    if ((stats.kRate ?? 0) < 0.15) {
      insights.add('🎯 Low strikeout rate - makes consistent contact');
    }
    
    // BB rate
    if ((stats.bbRate ?? 0) > 0.1) {
      insights.add('📋 Good walk rate - patient at the plate');
    }
    
    // Sweet spot
    if ((stats.sweetSpotRate ?? 0) > 0.35) {
      insights.add('🎯 Excellent sweet spot rate - consistently barreling the ball');
    }
    
    if (insights.isEmpty) {
      return '📊 Average player - consistent but not exceptional';
    }
    
    return insights.join(' | ');
  }
}
