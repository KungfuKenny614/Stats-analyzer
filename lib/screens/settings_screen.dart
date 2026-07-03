import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/theme_provider.dart';
import 'package:stats_analyzer/providers/auth_provider.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(DSSpacing.lg),
        children: [
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: const Text('Account'),
                  subtitle: Text(authProvider.userEmail),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: DSColors.negative),
                  title: const Text('Sign Out', style: TextStyle(color: DSColors.negative)),
                  onTap: () async {
                    await authProvider.signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          Center(child: Text('DiamondEdge v2.4.1', style: DSTypography.caption)),
        ],
      ),
    );
  }
}
