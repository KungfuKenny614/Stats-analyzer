import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class ArbitrageScanner {
  static List<Map<String, dynamic>> scan(List<MLBNormalizedMarket> markets) {
    final opportunities = <Map<String, dynamic>>[];

    for (int i = 0; i < markets.length; i++) {
      for (int j = i + 1; j < markets.length; j++) {
        final m1 = markets[i];
        final m2 = markets[j];

        if (m1.marketType != m2.marketType) continue;
        if (m1.playerId == m2.playerId) continue;

        // Over on m1, under on m2
        final over1 = m1.bestOverOdds;
        final under2 = m2.bestUnderOdds;
        final implied1 = _implied(over1);
        final implied2 = _implied(under2);
        final total = implied1 + implied2;

        if (total < 1.0) {
          final profit = (1 - total) * 100;
          opportunities.add({
            'type': 'Over/Under',
            'player1': m1.playerName,
            'player2': m2.playerName,
            'book1': m1.bestOverBook,
            'book2': m2.bestUnderBook,
            'odds1': over1,
            'odds2': under2,
            'profit': profit,
            'implied': total,
          });
        }

        // Under on m1, over on m2
        final over2 = m2.bestOverOdds;
        final under1 = m1.bestUnderOdds;
        final implied3 = _implied(over2);
        final implied4 = _implied(under1);
        final total2 = implied3 + implied4;

        if (total2 < 1.0) {
          final profit = (1 - total2) * 100;
          opportunities.add({
            'type': 'Over/Under (reverse)',
            'player1': m2.playerName,
            'player2': m1.playerName,
            'book1': m2.bestOverBook,
            'book2': m1.bestUnderBook,
            'odds1': over2,
            'odds2': under1,
            'profit': profit,
            'implied': total2,
          });
        }
      }
    }

    opportunities.sort((a, b) => b['profit'].compareTo(a['profit']));
    return opportunities;
  }

  static double _implied(double odds) {
    if (odds > 0) return 100 / (odds + 100);
    return -odds / (-odds + 100);
  }
}
