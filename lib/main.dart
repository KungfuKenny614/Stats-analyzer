import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/auth_provider.dart';
import 'package:stats_analyzer/providers/app_state.dart';
import 'package:stats_analyzer/providers/theme_provider.dart';
import 'package:stats_analyzer/providers/watchlist_provider.dart';
import 'package:stats_analyzer/screens/login_screen.dart';
import 'package:stats_analyzer/screens/research_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppState()..loadData()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'DiamondEdge Research',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              fontFamily: 'Inter',
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1A73E8),
                secondary: Color(0xFF1A73E8),
                surface: Color(0xFFFFFFFF),
                background: Color(0xFFF8F9FA),
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: const Color(0xFFE0E0E0).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintStyle: const TextStyle(
                  color: Color(0xFF9AA0A6),
                  fontSize: 14,
                ),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              fontFamily: 'Inter',
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF3D8BFF),
                secondary: Color(0xFF3D8BFF),
                surface: Color(0xFF1E1E1E),
                background: Color(0xFF121212),
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: const Color(0xFF333333).withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintStyle: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                ),
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/dashboard': (context) => const ResearchDashboard(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.isAuthenticated) {
      return const ResearchDashboard();
    }
    return const LoginScreen();
  }
}
