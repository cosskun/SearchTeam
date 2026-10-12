import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../models/match_ad.dart';
import '../models/application.dart';
import '../theme/app_theme.dart';
import 'match_details_screen.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final myApplications = appState.getMyApplications();
    final myMatches = appState.getMyMatches();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maçlarım & Başvurular', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(text: 'Oyuncu Başvurularım'),
              Tab(text: 'Açtığım İlanlar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: My Player Applications
            _buildApplicationsTab(context, myApplications, appState),

            // Tab 2: My Match Ads
            _buildMyMatchesTab(context, myMatches, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsTab(BuildContext context, List<Application> applications, AppState appState) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Henüz hiçbir maça başvurmadınız.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        // Find matching match details
        final matchIdx = appState.matches.indexWhere((m) => m.id == app.matchId);
        if (matchIdx == -1) return const SizedBox.shrink();
        final match = appState.matches[matchIdx];

        final formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(match.dateTime);

        Color statusColor = Colors.amber;
        String statusText = 'Onay Bekliyor';
        IconData statusIcon = Icons.hourglass_empty;

        if (app.status == ApplicationStatus.accepted) {
          statusColor = Colors.greenAccent;
          statusText = 'Kabul Edildi';
          statusIcon = Icons.check_circle;
        } else if (app.status == ApplicationStatus.rejected) {
          statusColor = Colors.redAccent;
          statusText = 'Reddedildi';
          statusIcon = Icons.cancel;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailsScreen(matchId: match.id),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Date
                  Text(match.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${match.district} - ${match.locationName}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 10),

                  // Status line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        match.isFree ? 'Ücretsiz' : '${match.price.toInt()} TL',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyMatchesTab(BuildContext context, List<MatchAd> matches, AppState appState) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Açtığınız bir ilan bulunmuyor.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(match.dateTime);
        final appCount = appState.getApplicationsForMatch(match.id).length;
        final pendingCount = appState.getApplicationsForMatch(match.id)
            .where((app) => app.status == ApplicationStatus.pending)
            .length;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailsScreen(matchId: match.id),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          match.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: match.status == MatchStatus.active
                              ? AppTheme.primaryGreen.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: match.status == MatchStatus.active
                                ? AppTheme.primaryGreen.withOpacity(0.3)
                                : Colors.white10,
                          ),
                        ),
                        child: Text(
                          match.status == MatchStatus.active ? 'Aktif' : 'Tamamlandı',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: match.status == MatchStatus.active ? AppTheme.primaryGreen : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${match.district} - ${match.locationName}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 10),

                  // Counts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '$appCount Başvuru ($pendingCount bekleyen)',
                          style: TextStyle(
                            color: pendingCount > 0 ? AppTheme.primaryGreen : AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Aranan: ${match.requiredPosition.displayName} (${match.spotsNeeded} spot)',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
