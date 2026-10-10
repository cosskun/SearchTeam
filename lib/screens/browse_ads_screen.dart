import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/match_ad.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';

class BrowseAdsScreen extends StatefulWidget {
  const BrowseAdsScreen({super.key});

  @override
  State<BrowseAdsScreen> createState() => _BrowseAdsScreenState();
}

class _BrowseAdsScreenState extends State<BrowseAdsScreen> {
  final _searchController = TextEditingController();
  PositionType? _selectedPosition;
  bool? _selectedFreeFilter; // null = all, true = free, false = paid

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final filteredMatches = appState.getFilteredMatches(
      searchCityOrDistrict: _searchController.text,
      positionFilter: _selectedPosition,
      isFreeFilter: _selectedFreeFilter,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.sports_soccer, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'Halısaha Maç Bul',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Konum, ilçe veya saha adı ara...',
                prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryGreen),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // 2. Filter Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                // Position Filter Label
                const Text('Mevki: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 4),
                // Position Chips
                FilterChip(
                  label: const Text('Hepsi'),
                  selected: _selectedPosition == null,
                  onSelected: (_) => setState(() => _selectedPosition = null),
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                ...PositionType.values.map((pos) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      label: Text(pos.displayName),
                      selected: _selectedPosition == pos,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPosition = selected ? pos : null;
                        });
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryGreen,
                    ),
                  );
                }),
                const SizedBox(width: 12),
                const VerticalDivider(width: 1, thickness: 1),
                const SizedBox(width: 12),

                // Pricing Filter Label
                const Text('Ücret: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 4),
                // Pricing Chips
                FilterChip(
                  label: const Text('Hepsi'),
                  selected: _selectedFreeFilter == null,
                  onSelected: (_) => setState(() => _selectedFreeFilter = null),
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: const Text('Ücretsiz'),
                  selected: _selectedFreeFilter == true,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFreeFilter = selected ? true : null;
                    });
                  },
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: const Text('Ücret Paylaşımlı'),
                  selected: _selectedFreeFilter == false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFreeFilter = selected ? false : null;
                    });
                  },
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. Match List Feed
          Expanded(
            child: filteredMatches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sentiment_dissatisfied, size: 64, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'Aradığınız kriterlere uygun maç bulunamadı.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _selectedPosition = null;
                              _selectedFreeFilter = null;
                            });
                          },
                          child: const Text('Aramayı Sıfırla', style: TextStyle(color: AppTheme.primaryGreen)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredMatches.length,
                    itemBuilder: (context, index) {
                      final match = filteredMatches[index];
                      final isCurrentUserHost = match.hostId == appState.currentUser?.id;
                      return MatchCard(
                        match: match,
                        isCurrentUserHost: isCurrentUserHost,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
