import 'package:flutter/material.dart';
import 'package:stats_analyzer/config/premium_theme.dart';

class PremiumFilterPanel extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChange;
  final Map<String, dynamic> initialFilters;

  const PremiumFilterPanel({
    super.key,
    required this.onFilterChange,
    this.initialFilters = const {},
  });

  @override
  State<PremiumFilterPanel> createState() => _PremiumFilterPanelState();
}

class _PremiumFilterPanelState extends State<PremiumFilterPanel> {
  String _selectedLeague = 'MLB';
  String _selectedMarket = 'All';
  String _selectedBook = 'All';
  double _minEV = 0;
  double _minHitRate = 0;
  String _movementFilter = 'All';
  bool _showInjuryOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedLeague = widget.initialFilters['league'] ?? 'MLB';
    _selectedMarket = widget.initialFilters['market'] ?? 'All';
    _selectedBook = widget.initialFilters['book'] ?? 'All';
    _minEV = widget.initialFilters['minEV'] ?? 0;
    _minHitRate = widget.initialFilters['minHitRate'] ?? 0;
  }

  void _applyFilters() {
    widget.onFilterChange({
      'league': _selectedLeague,
      'market': _selectedMarket,
      'book': _selectedBook,
      'minEV': _minEV,
      'minHitRate': _minHitRate,
      'movement': _movementFilter,
      'injuryOnly': _showInjuryOnly,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        border: Border(
          right: BorderSide(
            color: PremiumTheme.divider.withOpacity(0.5),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PremiumTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Filters',
                  style: PremiumTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedLeague = 'MLB';
                      _selectedMarket = 'All';
                      _selectedBook = 'All';
                      _minEV = 0;
                      _minHitRate = 0;
                      _movementFilter = 'All';
                      _showInjuryOnly = false;
                    });
                    _applyFilters();
                  },
                  child: Text(
                    'Clear All',
                    style: PremiumTheme.labelMedium.copyWith(
                      color: PremiumTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PremiumTheme.spacingLg),
            
            // League
            _buildFilterGroup(
              title: 'League',
              children: [
                _buildFilterChip('MLB', _selectedLeague == 'MLB', () {
                  setState(() {
                    _selectedLeague = 'MLB';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('NBA', _selectedLeague == 'NBA', () {
                  setState(() {
                    _selectedLeague = 'NBA';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('NFL', _selectedLeague == 'NFL', () {
                  setState(() {
                    _selectedLeague = 'NFL';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('NHL', _selectedLeague == 'NHL', () {
                  setState(() {
                    _selectedLeague = 'NHL';
                    _applyFilters();
                  });
                }),
              ],
            ),
            
            const SizedBox(height: PremiumTheme.spacingXl),
            
            // Market
            _buildFilterGroup(
              title: 'Market',
              children: [
                _buildFilterChip('All', _selectedMarket == 'All', () {
                  setState(() {
                    _selectedMarket = 'All';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('Hits', _selectedMarket == 'Hits', () {
                  setState(() {
                    _selectedMarket = 'Hits';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('Total Bases', _selectedMarket == 'Total Bases', () {
                  setState(() {
                    _selectedMarket = 'Total Bases';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('Home Runs', _selectedMarket == 'Home Runs', () {
                  setState(() {
                    _selectedMarket = 'Home Runs';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('RBI', _selectedMarket == 'RBI', () {
                  setState(() {
                    _selectedMarket = 'RBI';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('Strikeouts', _selectedMarket == 'Strikeouts', () {
                  setState(() {
                    _selectedMarket = 'Strikeouts';
                    _applyFilters();
                  });
                }),
              ],
            ),
            
            const SizedBox(height: PremiumTheme.spacingXl),
            
            // Sportsbook
            _buildFilterGroup(
              title: 'Sportsbook',
              children: [
                _buildFilterChip('All', _selectedBook == 'All', () {
                  setState(() {
                    _selectedBook = 'All';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('FanDuel', _selectedBook == 'FanDuel', () {
                  setState(() {
                    _selectedBook = 'FanDuel';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('DraftKings', _selectedBook == 'DraftKings', () {
                  setState(() {
                    _selectedBook = 'DraftKings';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('BetMGM', _selectedBook == 'BetMGM', () {
                  setState(() {
                    _selectedBook = 'BetMGM';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('Caesars', _selectedBook == 'Caesars', () {
                  setState(() {
                    _selectedBook = 'Caesars';
                    _applyFilters();
                  });
                }),
              ],
            ),
            
            const SizedBox(height: PremiumTheme.spacingXl),
            
            // EV Slider
            Text(
              'Minimum EV',
              style: PremiumTheme.labelMedium,
            ),
            const SizedBox(height: PremiumTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                    ),
                    child: Slider(
                      value: _minEV,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      label: '${_minEV.toStringAsFixed(1)}%',
                      onChanged: (value) {
                        setState(() {
                          _minEV = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: PremiumTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumTheme.spacingMd,
                    vertical: PremiumTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumTheme.surfaceVariant,
                    borderRadius: PremiumTheme.radiusMd,
                  ),
                  child: Text(
                    '${_minEV.toStringAsFixed(1)}%',
                    style: PremiumTheme.titleSmall,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: PremiumTheme.spacingLg),
            
            // Hit Rate Slider
            Text(
              'Minimum Hit Rate',
              style: PremiumTheme.labelMedium,
            ),
            const SizedBox(height: PremiumTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                    ),
                    child: Slider(
                      value: _minHitRate,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      label: '${(_minHitRate * 100).toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _minHitRate = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: PremiumTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumTheme.spacingMd,
                    vertical: PremiumTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumTheme.surfaceVariant,
                    borderRadius: PremiumTheme.radiusMd,
                  ),
                  child: Text(
                    '${(_minHitRate * 100).toInt()}%',
                    style: PremiumTheme.titleSmall,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: PremiumTheme.spacingLg),
            
            // Movement Filter
            Text(
              'Line Movement',
              style: PremiumTheme.labelMedium,
            ),
            const SizedBox(height: PremiumTheme.spacingSm),
            Wrap(
              spacing: PremiumTheme.spacingSm,
              children: [
                _buildFilterChip('All', _movementFilter == 'All', () {
                  setState(() {
                    _movementFilter = 'All';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('📈 Up', _movementFilter == 'Up', () {
                  setState(() {
                    _movementFilter = 'Up';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('📉 Down', _movementFilter == 'Down', () {
                  setState(() {
                    _movementFilter = 'Down';
                    _applyFilters();
                  });
                }),
                _buildFilterChip('➡️ Stable', _movementFilter == 'Stable', () {
                  setState(() {
                    _movementFilter = 'Stable';
                    _applyFilters();
                  });
                }),
              ],
            ),
            
            const SizedBox(height: PremiumTheme.spacingLg),
            
            // Injury Filter
            Row(
              children: [
                AnimatedContainer(
                  duration: PremiumTheme.animationFast,
                  decoration: BoxDecoration(
                    color: _showInjuryOnly 
                        ? PremiumTheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: PremiumTheme.radiusMd,
                  ),
                  child: Checkbox(
                    value: _showInjuryOnly,
                    onChanged: (value) {
                      setState(() {
                        _showInjuryOnly = value ?? false;
                      });
                      _applyFilters();
                    },
                    activeColor: PremiumTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: PremiumTheme.radiusSm,
                    ),
                  ),
                ),
                Text(
                  'Show only injury-impacted',
                  style: PremiumTheme.bodyMedium,
                ),
                const Spacer(),
                if (_showInjuryOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumTheme.spacingSm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumTheme.warningSurface,
                      borderRadius: PremiumTheme.radiusSm,
                    ),
                    child: Text(
                      'Active',
                      style: PremiumTheme.labelSmall.copyWith(
                        color: PremiumTheme.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PremiumTheme.labelMedium,
        ),
        const SizedBox(height: PremiumTheme.spacingSm),
        Wrap(
          spacing: PremiumTheme.spacingSm,
          runSpacing: PremiumTheme.spacingSm,
          children: children,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return AnimatedContainer(
      duration: PremiumTheme.animationFast,
      decoration: BoxDecoration(
        color: selected ? PremiumTheme.primary : PremiumTheme.surfaceVariant,
        borderRadius: PremiumTheme.radiusMd,
        border: Border.all(
          color: selected 
              ? PremiumTheme.primary.withOpacity(0.5)
              : Colors.transparent,
        ),
        boxShadow: selected ? PremiumTheme.shadowSm : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: PremiumTheme.radiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumTheme.spacingMd,
              vertical: PremiumTheme.spacingSm,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected 
                    ? PremiumTheme.textInverse
                    : PremiumTheme.textSecondary,
                fontSize: 12,
                fontWeight: selected 
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
