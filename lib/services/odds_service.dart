cat > lib/services/odds_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;

class OddsService {
  static const String baseUrl = 'https://api.the-odds-api.com/v4';
  static const String apiKey = 5e32aeb55b4b76; // Replace with your API key

  // Fetch MLB odds for today's games
  Future<List<Map<String, dynamic>>> fetchMLBOdds() async {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day>
    final url =
        '$baseUrl/sports/baseball_mlb/odds/?apiKey=$apiKey&regions=us&markets=h>

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch odds: ${response.statusCode}');
        return [];
      }
    } catch
