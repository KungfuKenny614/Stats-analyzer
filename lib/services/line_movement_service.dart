import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LineMovementService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'line_movement.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE odds_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            market_id TEXT,
            line REAL,
            over_odds REAL,
            under_odds REAL,
            timestamp TEXT,
            sportsbook TEXT
          )
        ''');
      },
    );
  }

  static Future<void> saveOdds(String marketId, double line, double overOdds, double underOdds, String sportsbook) async {
    final db = await database;
    await db.insert('odds_history', {
      'market_id': marketId,
      'line': line,
      'over_odds': overOdds,
      'under_odds': underOdds,
      'timestamp': DateTime.now().toIso8601String(),
      'sportsbook': sportsbook,
    });
  }

  static Future<List<Map<String, dynamic>>> getOddsHistory(String marketId, {int limit = 24}) async {
    final db = await database;
    return await db.query(
      'odds_history',
      where: 'market_id = ?',
      whereArgs: [marketId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  static Future<void> clearHistory() async {
    final db = await database;
    await db.delete('odds_history');
  }
}
