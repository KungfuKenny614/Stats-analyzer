import 'dart:convert';
import 'package:http/http.dart' as http;

class InjuryData {
  final String playerName;
  final String team;
  final String injuryType;
  final String status; // 'Day-to-Day', '10-Day IL', etc.
  final DateTime? expectedReturn;

  InjuryData({
    required this.playerName,
    required this.team,
    required this.injuryType,
    required this.status,
    this.expectedReturn,
  });
}

class InjuriesService {
  // Mock data for now – replace with real API later
  static Future<List<InjuryData>> fetchTeamInjuries(String teamName) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return some mock injuries based on team
    final mock = {
      'Los Angeles Dodgers': [
        InjuryData(playerName: 'Mookie Betts', team: 'LAD', injuryType: 'Finger', status: 'Day-to-Day'),
        InjuryData(playerName: 'Clayton Kershaw', team: 'LAD', injuryType: 'Elbow', status: '60-Day IL'),
      ],
      'New York Yankees': [
        InjuryData(playerName: 'Aaron Judge', team: 'NYY', injuryType: 'Toe', status: 'Day-to-Day'),
      ],
      'Boston Red Sox': [
        InjuryData(playerName: 'Chris Sale', team: 'BOS', injuryType: 'Shoulder', status: '15-Day IL'),
      ],
    };
    return mock[teamName] ?? [];
  }
}
