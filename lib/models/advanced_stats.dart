// ===================== ADVANCED STATISTICS =====================

class AdvancedStats {
  // Expected stats
  final double? xBA;      // Expected Batting Average
  final double? xSLG;     // Expected Slugging Percentage
  final double? xOBP;     // Expected On-Base Percentage
  final double? xwOBA;    // Expected Weighted On-Base Average
  
  // Quality of contact
  final double? hardHitRate;   // % of batted balls over 95mph
  final double? barrelRate;    // % of batted balls with optimal exit velocity/launch angle
  final double? avgExitVelocity;
  final double? avgLaunchAngle;
  final double? sweetSpotRate; // % of batted balls with 8-32 degree launch angle
  
  // Plate discipline
  final double? chaseRate;     // % of pitches swung at outside zone
  final double? whiffRate;     // % of swings without contact
  final double? zoneContactRate; // % of contact in strike zone
  final double? firstPitchStrikeRate;
  
  // Pitching advanced
  final double? kRate;
  final double? bbRate;
  final double? gbRate;        // Ground ball rate
  final double? fbRate;        // Fly ball rate
  final double? ldRate;        // Line drive rate
  final double? hrPerFlyBall;
  
  // Splits
  final Map<String, double>? vsLeft;
  final Map<String, double>? vsRight;
  final Map<String, double>? homeAway;
  final Map<String, double>? dayNight;

  AdvancedStats({
    this.xBA,
    this.xSLG,
    this.xOBP,
    this.xwOBA,
    this.hardHitRate,
    this.barrelRate,
    this.avgExitVelocity,
    this.avgLaunchAngle,
    this.sweetSpotRate,
    this.chaseRate,
    this.whiffRate,
    this.zoneContactRate,
    this.firstPitchStrikeRate,
    this.kRate,
    this.bbRate,
    this.gbRate,
    this.fbRate,
    this.ldRate,
    this.hrPerFlyBall,
    this.vsLeft,
    this.vsRight,
    this.homeAway,
    this.dayNight,
  });

  // Calculate EV value
  double get evValue {
    // Combine metrics to estimate value
    double value = 0.5;
    if (barrelRate != null) value += barrelRate! * 0.2;
    if (hardHitRate != null) value += hardHitRate! * 0.15;
    if (sweetSpotRate != null) value += sweetSpotRate! * 0.1;
    if (xBA != null) value += (xBA! - 0.250) * 2;
    return value.clamp(0, 1);
  }

  // Quality rating
  String get qualityRating {
    final score = evValue;
    if (score > 0.7) return 'Elite 🔥';
    if (score > 0.6) return 'Excellent ⭐';
    if (score > 0.5) return 'Good ✅';
    if (score > 0.4) return 'Average 📊';
    return 'Below Average ⚠️';
  }

  Map<String, dynamic> toJson() => {
    'xBA': xBA,
    'xSLG': xSLG,
    'xOBP': xOBP,
    'xwOBA': xwOBA,
    'hardHitRate': hardHitRate,
    'barrelRate': barrelRate,
    'avgExitVelocity': avgExitVelocity,
    'avgLaunchAngle': avgLaunchAngle,
    'sweetSpotRate': sweetSpotRate,
    'chaseRate': chaseRate,
    'whiffRate': whiffRate,
    'zoneContactRate': zoneContactRate,
    'firstPitchStrikeRate': firstPitchStrikeRate,
    'kRate': kRate,
    'bbRate': bbRate,
    'gbRate': gbRate,
    'fbRate': fbRate,
    'ldRate': ldRate,
    'hrPerFlyBall': hrPerFlyBall,
    'vsLeft': vsLeft,
    'vsRight': vsRight,
    'homeAway': homeAway,
    'dayNight': dayNight,
  };

  factory AdvancedStats.fromJson(Map<String, dynamic> json) {
    return AdvancedStats(
      xBA: json['xBA']?.toDouble(),
      xSLG: json['xSLG']?.toDouble(),
      xOBP: json['xOBP']?.toDouble(),
      xwOBA: json['xwOBA']?.toDouble(),
      hardHitRate: json['hardHitRate']?.toDouble(),
      barrelRate: json['barrelRate']?.toDouble(),
      avgExitVelocity: json['avgExitVelocity']?.toDouble(),
      avgLaunchAngle: json['avgLaunchAngle']?.toDouble(),
      sweetSpotRate: json['sweetSpotRate']?.toDouble(),
      chaseRate: json['chaseRate']?.toDouble(),
      whiffRate: json['whiffRate']?.toDouble(),
      zoneContactRate: json['zoneContactRate']?.toDouble(),
      firstPitchStrikeRate: json['firstPitchStrikeRate']?.toDouble(),
      kRate: json['kRate']?.toDouble(),
      bbRate: json['bbRate']?.toDouble(),
      gbRate: json['gbRate']?.toDouble(),
      fbRate: json['fbRate']?.toDouble(),
      ldRate: json['ldRate']?.toDouble(),
      hrPerFlyBall: json['hrPerFlyBall']?.toDouble(),
      vsLeft: json['vsLeft']?.cast<String, double>(),
      vsRight: json['vsRight']?.cast<String, double>(),
      homeAway: json['homeAway']?.cast<String, double>(),
      dayNight: json['dayNight']?.cast<String, double>(),
    );
  }
}

// ===================== COMPARISON RESULT =====================

class ComparisonResult {
  final String player1Name;
  final String player2Name;
  final Map<String, double> advantages;
  final Map<String, String> categories;
  final double overallAdvantage;

  ComparisonResult({
    required this.player1Name,
    required this.player2Name,
    required this.advantages,
    required this.categories,
    required this.overallAdvantage,
  });

  String get advantageText {
    if (overallAdvantage > 0.1) return '$player1Name is better 📈';
    if (overallAdvantage < -0.1) return '$player2Name is better 📈';
    return 'Even matchup ⚖️';
  }
}
