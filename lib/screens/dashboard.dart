import 'package:flutter/material.dart';
import 'package:stats_analyzer/models/mlb_models.dart';
import 'package:stats_analyzer/services/mlb_api_service.dart';
import 'package:stats_analyzer/config/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stats_analyzer/screens/alerts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const InsightsTab(),
    const ScreenerTab(),
    const WatchlistTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_rounded),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Screener',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ===================== HOME TAB =====================

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final MLBApiService _apiService = MLBApiService();
  List<MLBGame> _games = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final games = await _apiService.fetchTodayGames();
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final formattedDate = '${today.month}/${today.day}/${today.year}';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.diamond_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'DiamondEdge',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadGames,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGames,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_getTimeOfDay()}! 👋',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MLB Games for $formattedDate',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (_games.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_games.length} Games',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                _buildLoadingShimmer()
              else if (_error.isNotEmpty)
                _buildErrorWidget()
              else if (_games.isEmpty)
                _buildEmptyWidget()
              else
                _buildGamesList(),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load games',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadGames,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.sports_baseball_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No games today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back tomorrow for MLB games',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    return Column(
      children: [
        if (_games.where((g) => g.isLive).isNotEmpty) ...[
          const Text(
            'LIVE GAMES 🔴',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ..._games.where((g) => g.isLive).map((game) => _buildGameCard(game, isLive: true)),
          const SizedBox(height: 16),
        ],

        if (_games.where((g) => g.isFinal).isNotEmpty) ...[
          const Text(
            'FINAL SCORES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ..._games.where((g) => g.isFinal).map((game) => _buildGameCard(game, isLive: false)),
          const SizedBox(height: 16),
        ],

        if (_games.where((g) => !g.isLive && !g.isFinal).isNotEmpty) ...[
          const Text(
            'UPCOMING GAMES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          ..._games.where((g) => !g.isLive && !g.isFinal).map((game) => _buildGameCard(game, isLive: false)),
        ],
      ],
    );
  }

  Widget _buildGameCard(MLBGame game, {required bool isLive}) {
    final theme = Theme.of(context);
    final awayAbbr = game.awayTeam.length >= 3 ? game.awayTeam.substring(0, 3) : game.awayTeam;
    final homeAbbr = game.homeTeam.length >= 3 ? game.homeTeam.substring(0, 3) : game.homeTeam;
    final awayLogo = MLBApiService.getLogoForAbbreviation(awayAbbr);
    final homeLogo = MLBApiService.getLogoForAbbreviation(homeAbbr);

    return GestureDetector(
      onTap: () {
        // Navigate to player list (bottom sheet)
        _showPlayersBottomSheet(context, game);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive ? Colors.red : Colors.grey.shade300,
            width: isLive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: awayLogo,
                  width: 30,
                  height: 30,
                  placeholder: (context, url) => const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.sports_baseball_rounded,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    game.awayTeam,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  game.awayScore.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: homeLogo,
                  width: 30,
                  height: 30,
                  placeholder: (context, url) => const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.sports_baseball_rounded,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    game.homeTeam,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  game.homeScore.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLive ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isLive)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isLive ? 'LIVE' : (game.inning.isEmpty ? 'Scheduled' : 'Final'),
                        style: TextStyle(
                          color: isLive ? Colors.red : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Tap for players',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  if (game.inning.isNotEmpty && !isLive)
                    Text(
                      game.inning,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayersBottomSheet(BuildContext context, MLBGame game) {
    final samplePlayers = [
      {'name': 'Shohei Ohtani', 'pos': 'DH', 'avg': 0.322, 'ops': 1.03},
      {'name': 'Aaron Judge', 'pos': 'RF', 'avg': 0.289, 'ops': 0.952},
      {'name': 'Mookie Betts', 'pos': 'RF', 'avg': 0.295, 'ops': 0.895},
      {'name': 'Freddie Freeman', 'pos': '1B', 'avg': 0.341, 'ops': 0.922},
      {'name': 'Bryce Harper', 'pos': '1B', 'avg': 0.287, 'ops': 0.894},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.sports_baseball_rounded, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${game.awayTeam} vs ${game.homeTeam}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a player to see AI predictions and stats',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: samplePlayers.length,
                itemBuilder: (context, index) {
                  final player = samplePlayers[index];
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to player detail
                      Navigator.pushNamed(
                        context,
                        '/player',
                        arguments: MLBPlayer(
                          id: index + 1,
                          fullName: player['name'] as String,
                          team: index % 2 == 0 ? game.awayTeam : game.homeTeam,
                          position: player['pos'] as String,
                          avg: player['avg'] as double,
                          ops: player['ops'] as double,
                          hr: 10 + index * 3,
                          rbi: 20 + index * 5,
                          hits: 50 + index * 8,
                          games: 80 + index * 5,
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        (player['name'] as String).split(' ').map((e) => e[0]).join(''),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    title: Text(player['name'] as String),
                    subtitle: Text('${player['pos']} · AVG: ${player['avg']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (player['ops'] as double) > 0.900 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'OPS: ${player['ops']}',
                        style: TextStyle(
                          color: (player['ops'] as double) > 0.900 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== OTHER TABS =====================

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
      ),
      body: const Center(
        child: Text('AI Insights Coming Soon'),
      ),
    );
  }
}

class ScreenerTab extends StatelessWidget {
  const ScreenerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stat Screener'),
      ),
      body: const Center(
        child: Text('Stat Screener Coming Soon'),
      ),
    );
  }
}

class WatchlistTab extends StatelessWidget {
  const WatchlistTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: const Center(
        child: Text('Watchlist Coming Soon'),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Coming Soon'),
      ),
    );
  }
}
