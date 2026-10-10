import 'package:flutter/material.dart';
import '../models/match_ad.dart';
import '../models/application.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class MvpVotingCard extends StatelessWidget {
  final MatchAd match;
  final bool isHost;
  final AppState appState;

  const MvpVotingCard({
    super.key,
    required this.match,
    required this.isHost,
    required this.appState,
  });

  void _showScoreInputDialog(BuildContext context) {
    final homeScoreController = TextEditingController(text: '8');
    final awayScoreController = TextEditingController(text: '6');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('⚽ Maç Sonu Skorunu Gir', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kaptan olarak maçın nihai skorunu kaydedin.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: homeScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: 'Yeşil Takım'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: awayScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: 'Siyah Takım'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final h = homeScoreController.text.trim();
                final a = awayScoreController.text.trim();
                if (h.isNotEmpty && a.isNotEmpty) {
                  final scoreStr = 'Yeşil Takım $h - $a Siyah Takım';
                  appState.recordMatchScore(match.id, scoreStr);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Maç skoru kaydedildi: $scoreStr 🏆'), backgroundColor: AppTheme.forestGreen),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = appState.currentUser?.id;
    final acceptedApps = appState
        .getApplicationsForMatch(match.id)
        .where((app) => app.status == ApplicationStatus.accepted)
        .toList();

    final List<Map<String, String>> candidates = [
      {'id': match.hostId, 'name': '${match.hostName} (Kaptan)'},
      ...acceptedApps.map((a) => {'id': a.applicantId, 'name': a.applicantName}),
    ];

    final hasVoted = currentUserId != null && match.mvpVotes.containsKey(currentUserId);
    final myVoteCandidateId = currentUserId != null ? match.mvpVotes[currentUserId] : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Maç Sonu Skoru & MVP Seçimi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.amber),
                  ),
                ],
              ),
              if (isHost)
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => _showScoreInputDialog(context),
                  icon: const Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                  label: Text(
                    (match.finalScore ?? '').isEmpty ? 'Skor Gir' : 'Skoru Düzenle',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if ((match.finalScore ?? '').isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_score, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Maç Skoru: ${match.finalScore}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isHost ? 'Maç bittiğinde skoru girip oyuncularla MVP seçimi yapabilirsiniz.' : 'Kaptan maç skorunu girdiğinde "Maçın Adamı (MVP)" oylaması aktif olacaktır.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Text(
            '🌟 "Maçın Adamı (MVP)" Oy Kullan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 6),
          if (hasVoted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                'Oy kullandınız! En yüksek oyu alan oyuncunun profilinde 🏆 MVP Rozeti parlayacak.',
                style: TextStyle(fontSize: 11, color: Colors.greenAccent.shade200, fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: candidates.map((cand) {
              final candId = cand['id']!;
              final candName = cand['name']!;
              final votesCount = match.mvpVotes.values.where((v) => v == candId).length;
              final isSelectedByMe = myVoteCandidateId == candId;

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(candName, style: TextStyle(fontSize: 12, fontWeight: isSelectedByMe ? FontWeight.bold : FontWeight.normal)),
                    if (votesCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$votesCount Oy',
                          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isSelectedByMe,
                selectedColor: Colors.amber.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.05),
                avatar: Icon(
                  isSelectedByMe ? Icons.stars : Icons.sports_soccer,
                  size: 16,
                  color: isSelectedByMe ? Colors.amber : AppTheme.textMuted,
                ),
                onSelected: (selected) {
                  if (currentUserId == null) return;
                  if (selected) {
                    appState.voteForMVP(match.id, candId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$candName için MVP oyunuz kaydedildi! 🏆'), backgroundColor: AppTheme.forestGreen),
                    );
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
