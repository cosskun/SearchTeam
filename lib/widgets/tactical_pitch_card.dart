import 'package:flutter/material.dart';
import '../models/match_ad.dart';
import '../models/application.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class TacticalPitchCard extends StatelessWidget {
  final MatchAd match;
  final bool isHost;
  final AppState appState;

  const TacticalPitchCard({
    super.key,
    required this.match,
    required this.isHost,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    final List<Application> acceptedApps = appState
        .getApplicationsForMatch(match.id)
        .where((app) => app.status == ApplicationStatus.accepted)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2417),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Saha İçi Kadro Dizilişi & Etiketleme',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isHost) ...[
                const SizedBox(width: 6),
                const Text('(Dokun & etiketle)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Pitch diagram layout
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3822),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 1,
                    color: Colors.white24,
                  ),
                ),
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                  ),
                ),
                _buildPositionNode(context, 'Kaleci', const Alignment(0.0, 0.75), acceptedApps),
                _buildPositionNode(context, 'Defans (Sol)', const Alignment(-0.6, 0.3), acceptedApps),
                _buildPositionNode(context, 'Defans (Sağ)', const Alignment(0.6, 0.3), acceptedApps),
                _buildPositionNode(context, 'Orta Saha', const Alignment(0.0, -0.2), acceptedApps),
                _buildPositionNode(context, 'Forvet', const Alignment(0.0, -0.75), acceptedApps),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionNode(BuildContext context, String posKey, Alignment align, List<Application> acceptedApps) {
    final assignedUserId = match.tacticalRoster[posKey];
    final assignedUserIndex = appState.users.indexWhere((u) => u.id == assignedUserId);
    final assignedUser = assignedUserIndex != -1 ? appState.users[assignedUserIndex] : null;

    return Align(
      alignment: align,
      child: GestureDetector(
        onTap: () {
          if (!isHost) return;
          _showAssignPlayerModal(context, posKey, acceptedApps);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: assignedUser != null ? AppTheme.primaryGreen : Colors.black54,
              child: Icon(
                assignedUser != null ? Icons.person : Icons.add_circle_outline,
                size: 14,
                color: assignedUser != null ? Colors.black : Colors.white70,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                assignedUser != null ? assignedUser.name : posKey,
                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignPlayerModal(BuildContext context, String posKey, List<Application> acceptedApps) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('$posKey Mevkiine Oyuncu Etiketle', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
              const SizedBox(height: 12),
              if (acceptedApps.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Henüz kabul edilmiş oyuncu bulunmuyor. Başvuruları kabul ettikten sonra kadroya atayabilirsiniz.', style: TextStyle(color: AppTheme.textMuted)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: acceptedApps.length,
                  itemBuilder: (context, index) {
                    final app = acceptedApps[index];
                    return ListTile(
                      leading: const Icon(Icons.person, color: AppTheme.primaryGreen),
                      title: Text(app.applicantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        appState.updateTacticalRoster(match.id, posKey, app.applicantId);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${app.applicantName} -> $posKey kadroya etiketlendi!'), backgroundColor: AppTheme.primaryGreen),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
