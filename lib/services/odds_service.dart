import 'dart:convert';
import 'package:http/http.dart' as http;

class OddsService {
  static const String baseUrl = 'https://api.the-odds-api.com/v4';
  // Replace with your actual API key from https://the-odds-api.com/
  static const String apiKey = '5e32aeb55b4b76d695abaf7822a71d29';

  static Future<Map<String, Map<String, String>>> fetchMLBOdds() async {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final url = '$baseUrl/sports/baseball_mlb/odds/?apiKey=$apiKey&regions=us&markets=h2h,spreads,totals&date=$date';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final oddsMap = <String, Map<String, String>>{};
        for (final game in data) {
          final id = game['id'].toString();
          final homeTeam = game['home_team'] ?? '';
          final awayTeam = game['away_team'] ?? '';
          final bookmakers = game['bookmakers'] as List? ?? [];
          if (bookmakers.isNotEmpty) {
            final book = bookmakers.first;
            final markets = book['markets'] as List? ?? [];
            final h2h = markets.firstWhere((m) => m['key'] == 'h2h', orElse: () => {});
            final spreads = markets.firstWhere((m) => m['key'] == 'spreads', orElse: () => {});
            final totals = markets.firstWhere((m) => m['key'] == 'totals', orElse: () => {});
            // Extract odds strings
            final h2hOdds = h2h['outcomes'] as List? ?? [];
            final awayOdds = h2hOdds.firstWhere((o) => o['name'] == awayTeam, orElse: () => {})['price']?.toString() ?? '--';
            final homeOdds = h2hOdds.firstWhere((o) => o['name'] == homeTeam, orElse: () => {})['price']?.toString() ?? '--';
            final spreadOutcomes = spreads['outcomes'] as List? ?? [];
            final awaySpread = spreadOutcomes.firstWhere((o) => o['name'] == awayTeam, orElse: () => {})['point']?.toString() ?? '';
            final homeSpread = spreadOutcomes.firstWhere((o) => o['name'] == homeTeam, orElse: () => {})['point']?.toString() ?? '';
            final totalOutcomes = totals['outcomes'] as List? ?? [];
            final over = totalOutcomes.firstWhere((o) => o['name'] == 'Over', orElse: () => {})['price']?.toString() ?? '';
            final under = totalOutcomes.firstWhere((o) => o['name'] == 'Under', orElse: () => {})['price']?.toString() ?? '';
            final totalPoint = totalOutcomes.isNotEmpty ? totalOutcomes.first['point']?.toString() ?? '8.5' : '8.5';
            oddsMap[id] = {
              'away_ml': awayOdds,
              'home_ml': homeOdds,
              'away_spread': awaySpread,
              'home_spread': homeSpread,
              'over_odds': over,
              'under_odds': under,
              'total_line': totalPoint,
            };
          }
        }
        return oddsMap;
      }
      return {};
    } catch (e) {
      print('Error fetching odds: $e');
      return {};
    }
  }
}
