import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/app_state.dart';
import '../models/match_ad.dart';
import '../models/application.dart';
import '../theme/app_theme.dart';
import 'chat_room_screen.dart';
import 'public_profile_screen.dart';
import '../widgets/tactical_pitch_card.dart';
import '../widgets/mvp_voting_card.dart';

class MatchDetailsScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailsScreen({super.key, required this.matchId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final _reviewCommentController = TextEditingController();
  double _reviewRating = 5.0;

  @override
  void dispose() {
    _reviewCommentController.dispose();
    super.dispose();
  }

  void _showCancelMatchDialog(BuildContext context, AppState appState, String matchId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('İlanı İptal Et', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          content: const Text('Bu maç ilanını yayından kaldırmak istediğinize emin misiniz? Yapılan tüm başvurular iptal edilecektir.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                appState.cancelMatchAd(matchId);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Pop screen back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('İlan başarıyla yayından kaldırıldı!'), backgroundColor: Colors.redAccent),
                );
              },
              child: const Text('Evet, İptal Et'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTacticalPitchCard(BuildContext context, AppState appState, MatchAd match, bool isHost) {
    final List<Application> acceptedApps = appState.getApplicationsForMatch(match.id)
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sports_soccer, color: AppTheme.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Saha İçi Kadro Dizilişi & Etiketleme',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
              if (isHost)
                const Text('(Dokun ve etiketle)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
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
                _buildPositionNode(context, appState, match, 'Kaleci', const Alignment(0.0, 0.75), acceptedApps, isHost),
                _buildPositionNode(context, appState, match, 'Defans (Sol)', const Alignment(-0.6, 0.3), acceptedApps, isHost),
                _buildPositionNode(context, appState, match, 'Defans (Sağ)', const Alignment(0.6, 0.3), acceptedApps, isHost),
                _buildPositionNode(context, appState, match, 'Orta Saha', const Alignment(0.0, -0.2), acceptedApps, isHost),
                _buildPositionNode(context, appState, match, 'Forvet', const Alignment(0.0, -0.75), acceptedApps, isHost),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionNode(BuildContext context, AppState appState, MatchAd match, String posKey, Alignment align, List<Application> acceptedApps, bool isHost) {
    final assignedUserId = match.tacticalRoster[posKey];
    final assignedUserIndex = appState.users.indexWhere((u) => u.id == assignedUserId);
    final assignedUser = assignedUserIndex != -1 ? appState.users[assignedUserIndex] : null;

    return Align(
      alignment: align,
      child: GestureDetector(
        onTap: () {
          if (!isHost) return;
          _showAssignPlayerModal(context, appState, match, posKey, acceptedApps);
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

  void _showAssignPlayerModal(BuildContext context, AppState appState, MatchAd match, String posKey, List<Application> acceptedApps) {
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

  void _showReviewDialog(BuildContext context, String applicantId, String applicantName, String matchTitle) {
    _reviewRating = 5.0;
    _reviewCommentController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: Text(
            '$applicantName Oyuncusunu Puanla',
            style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Oyuncunun centilmenliğini, kondisyonunu ve maçtaki katkısını Google Yorumları tarzında değerlendirin.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _reviewRating = rating;
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _reviewCommentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Yorumunuz',
                    hintText: 'Oyuncu hakkında geri bildirim yazın...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_reviewCommentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen bir yorum yazın')),
                  );
                  return;
                }
                
                final appState = Provider.of<AppState>(context, listen: false);
                appState.submitReview(
                  matchId: widget.matchId,
                  matchTitle: matchTitle,
                  revieweeId: applicantId,
                  rating: _reviewRating,
                  comment: _reviewCommentController.text.trim(),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$applicantName başarıyla puanlandı!')),
                );
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  void _showScoreInputDialog(BuildContext context, AppState appState, MatchAd match) {
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

  Widget _buildScoreAndMVPSection(BuildContext context, AppState appState, MatchAd match, bool isHost) {
    final currentUserId = appState.currentUser?.id;
    final acceptedApps = appState.getApplicationsForMatch(match.id)
        .where((app) => app.status == ApplicationStatus.accepted)
        .toList();

    // Candidates list (Host + Accepted applicants)
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
                  onPressed: () => _showScoreInputDialog(context, appState, match),
                  icon: const Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                  label: Text(
                    (match.finalScore == null || match.finalScore!.isEmpty) ? 'Skor Gir' : 'Skoru Düzenle',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (match.finalScore != null && match.finalScore!.isNotEmpty) ...[
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

  IconData _getPositionIcon(PositionType position) {
    switch (position) {
      case PositionType.kaleci:
        return Icons.pan_tool;
      case PositionType.defans:
        return Icons.shield;
      case PositionType.ortaSaha:
        return Icons.adjust;
      case PositionType.forvet:
        return Icons.sports_soccer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final matchIndex = appState.matches.indexWhere((m) => m.id == widget.matchId);
    
    if (matchIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('İlan Detayı')),
        body: const Center(child: Text('İlan bulunamadı.')),
      );
    }

    final match = appState.matches[matchIndex];
    final isHost = match.hostId == appState.currentUser?.id;
    final formattedDate = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(match.dateTime);
    final formattedTime = DateFormat('HH:mm').format(match.dateTime);

    // Get applications for this match
    final applications = appState.getApplicationsForMatch(match.id);
    
    // Check current user's application status
    Application? myApplication;
    if (!isHost && appState.currentUser != null) {
      final index = appState.applications.indexWhere(
        (app) => app.matchId == match.id && app.applicantId == appState.currentUser!.id
      );
      if (index != -1) {
        myApplication = appState.applications[index];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maç Detayı', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isHost && match.status == MatchStatus.active)
            IconButton(
              tooltip: 'İlanı İptal Et / Sil',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _showCancelMatchDialog(context, appState, match.id),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Mock Map Header View
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2D1F), Color(0xFF071B12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Stack(
                children: [
                  // Vector Grid Styling
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                        itemCount: 40,
                        itemBuilder: (c, i) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryGreen, width: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Soccer field mockup lines
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Map pin elements
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: AppTheme.primaryGreen,
                          size: 40,
                          shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.primaryGreen, width: 0.5),
                          ),
                          child: Text(
                            match.locationName,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Distance/Navigation Indicator
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.directions_run, color: AppTheme.primaryGreen, size: 14),
                          const SizedBox(width: 4),
                          const Text('Konumuna 3.2 km', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    match.title,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),

                  // Detail Pills (Position, Weather, Pricing)
                  Row(
                    children: [
                      // Position Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(_getPositionIcon(match.requiredPosition), size: 16, color: AppTheme.primaryGreen),
                            const SizedBox(width: 6),
                            Text(
                              match.requiredPosition.displayName,
                              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Weather Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          match.weatherText,
                          style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Price Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: match.isFree ? Colors.green.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          match.isFree ? 'ÜCRETSİZ MAÇ' : '${match.price.toInt()} TL',
                          style: TextStyle(
                            color: match.isFree ? Colors.greenAccent : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Match Info Card & Calendar Integration
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppTheme.primaryGreen, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Tarih ve Saat', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                    Text('$formattedDate - Saat $formattedTime', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: Colors.white10),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Saha Konumu', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                    Text('${match.district} - ${match.locationName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: Colors.white10),
                          ),
                          // Calendar & Reminder Export Button
                          OutlinedButton.icon(
                            onPressed: () {
                              final reminderTimeStr = DateFormat('HH:mm').format(match.dateTime.subtract(const Duration(hours: 2)));
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: AppTheme.cardDark,
                                    title: const Row(
                                      children: [
                                        Icon(Icons.event_available, color: AppTheme.primaryGreen),
                                        SizedBox(width: 8),
                                        Text('Takvime Eklendi! 📅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                    content: Text(
                                      '${match.title} maçı cihazınızın takvimine kaydedildi.\n\n🔔 Maç saatinden 2 saat önce (saat $reminderTimeStr) otomatik hatırlatma bildirimi gönderilecek.',
                                      style: const TextStyle(height: 1.4),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Tamam'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit_calendar, size: 18, color: AppTheme.primaryGreen),
                            label: const Text(
                              '📅 Takvime Ekle & Maç Hatırlatıcı Kur',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primaryGreen),
                              minimumSize: const Size.fromHeight(40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Host Card
                  const Text('Organizatör', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  const SizedBox(height: 8),
                  Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                            child: Text(
                              match.hostName[0].toUpperCase(),
                              style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(match.hostName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    Text(' ${match.hostRating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                 const SizedBox(height: 2),
                                 Builder(
                                   builder: (context) {
                                     final hostIndex = appState.users.indexWhere((u) => u.id == match.hostId);
                                     if (hostIndex == -1) return const SizedBox.shrink();
                                     final hostUser = appState.users[hostIndex];
                                     if (hostUser.isContactInfoPublic) {
                                       return Row(
                                         children: [
                                           const Icon(Icons.phone, size: 12, color: AppTheme.primaryGreen),
                                           const SizedBox(width: 4),
                                           Text(hostUser.phoneNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                                         ],
                                       );
                                     } else {
                                       return const Text('İletişim: Gizli', style: TextStyle(color: AppTheme.textMuted, fontSize: 12));
                                     }
                                   }
                                 ),
                              ],
                            ),
                          ),
                          if (!isHost) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryGreen),
                              tooltip: 'Kaptana Mesaj Gönder',
                              onPressed: () {
                                final sessionId = appState.startOrGetChatSession(match.hostId);
                                final hostIndex = appState.users.indexWhere((u) => u.id == match.hostId);
                                if (hostIndex != -1) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        sessionId: sessionId,
                                        recipientUser: appState.users[hostIndex],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text('Maç Açıklaması', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  const SizedBox(height: 8),
                  Text(
                    match.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Interactive Panel: Tactical Pitch & Applications
                  TacticalPitchCard(match: match, isHost: isHost, appState: appState),
                  const SizedBox(height: 16),

                  // Score & MVP Voting Section
                  MvpVotingCard(match: match, isHost: isHost, appState: appState),
                  const SizedBox(height: 16),

                  if (isHost) ...[
                    // HOST VIEW: Manage applications
                    const Text('Başvuran Oyuncular', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    const SizedBox(height: 8),
                    if (applications.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'Henüz bu ilana başvuru yapılmadı.',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applications.length,
                        itemBuilder: (context, idx) {
                          final app = applications[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PublicProfileScreen(userId: app.applicantId),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white10,
                                        child: Text(app.applicantName[0].toUpperCase()),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(app.applicantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                                Text(' ${app.applicantRating}', style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                            Text(app.applicantBio, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                            Builder(
                                              builder: (context) {
                                                final applicantUserIndex = appState.users.indexWhere((u) => u.id == app.applicantId);
                                                if (applicantUserIndex == -1) return const SizedBox.shrink();
                                                final applicantUser = appState.users[applicantUserIndex];
                                                final isContactVisible = applicantUser.isContactInfoPublic || 
                                                    (app.status == ApplicationStatus.accepted && 
                                                     (applicantUser.shareContactOnApproval || app.isContactShared));
                                                if (isContactVisible) {
                                                  return Row(
                                                    children: [
                                                      const Icon(Icons.phone, size: 12, color: AppTheme.primaryGreen),
                                                      const SizedBox(width: 4),
                                                      Text(applicantUser.phoneNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                                                      if (app.status == ApplicationStatus.accepted && app.isContactShared && !applicantUser.isContactInfoPublic)
                                                        const Text(' (İletişim Bilgisi Gönderildi)', style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold))
                                                      else if (app.status == ApplicationStatus.accepted && applicantUser.shareContactOnApproval && !applicantUser.isContactInfoPublic)
                                                        const Text(' (Otomatik Paylaşıldı)', style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                                    ],
                                                  );
                                                } else {
                                                  return const Text('Telefon: Gizli (Kullanıcının göndermesi bekleniyor)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12));
                                                }
                                              }
                                            ),
                                            Builder(
                                              builder: (context) {
                                                final applicantUserIndex = appState.users.indexWhere((u) => u.id == app.applicantId);
                                                if (applicantUserIndex == -1 || appState.users[applicantUserIndex].preferredPositions.isEmpty) {
                                                  return const SizedBox.shrink();
                                                }
                                                final positions = appState.users[applicantUserIndex].preferredPositions;
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 6.0),
                                                  child: Wrap(
                                                    spacing: 4,
                                                    runSpacing: 4,
                                                    children: positions.map((pos) {
                                                      Color chipColor;
                                                      switch (pos) {
                                                        case PositionType.kaleci:
                                                          chipColor = Colors.orangeAccent;
                                                          break;
                                                        case PositionType.defans:
                                                          chipColor = Colors.blueAccent;
                                                          break;
                                                        case PositionType.ortaSaha:
                                                          chipColor = Colors.tealAccent;
                                                          break;
                                                        case PositionType.forvet:
                                                          chipColor = Colors.redAccent;
                                                          break;
                                                      }
                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: chipColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: chipColor.withOpacity(0.3)),
                                                        ),
                                                        child: Text(
                                                          pos.displayName,
                                                          style: TextStyle(color: chipColor, fontSize: 9, fontWeight: FontWeight.bold),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                );
                                              }
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryGreen),
                                        tooltip: 'Oyuncuya Mesaj Gönder',
                                        onPressed: () {
                                          final sessionId = appState.startOrGetChatSession(app.applicantId);
                                          final applicantUserIndex = appState.users.indexWhere((u) => u.id == app.applicantId);
                                          if (applicantUserIndex != -1) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatRoomScreen(
                                                  sessionId: sessionId,
                                                  recipientUser: appState.users[applicantUserIndex],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Application actions based on status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (app.status == ApplicationStatus.pending) ...[
                                        OutlinedButton(
                                          onPressed: () {
                                            appState.rejectApplication(app.id);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            side: const BorderSide(color: Colors.redAccent),
                                            foregroundColor: Colors.redAccent,
                                          ),
                                          child: const Text('Reddet', style: TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            appState.acceptApplication(app.id);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            backgroundColor: AppTheme.primaryGreen,
                                            foregroundColor: Colors.black,
                                          ),
                                          child: const Text('Kabul Et', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ] else if (app.status == ApplicationStatus.accepted) ...[
                                        const Chip(
                                          label: Text('Kabul Edildi', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
                                          backgroundColor: Colors.transparent,
                                          side: BorderSide(color: Colors.green),
                                        ),
                                        const SizedBox(width: 8),
                                        // Review Button (Google Reviews style)
                                        ElevatedButton.icon(
                                          onPressed: () => _showReviewDialog(context, app.applicantId, app.applicantName, match.title),
                                          icon: const Icon(Icons.rate_review, size: 16),
                                          label: const Text('Puanla', style: TextStyle(fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            backgroundColor: Colors.amber,
                                            foregroundColor: Colors.black,
                                          ),
                                        ),
                                      ] else ...[
                                        const Chip(
                                          label: Text('Reddedildi', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                          backgroundColor: Colors.transparent,
                                          side: BorderSide(color: Colors.redAccent),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        },
                      ),
                  ] else ...[
                    // NON-HOST VIEW: Show Apply button or application status
                    if (myApplication == null)
                      ElevatedButton(
                        onPressed: () {
                          appState.applyToMatch(match.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Maça başarıyla başvurdunuz! Kaptan onayladığında bilgilendirileceksiniz.'),
                              backgroundColor: AppTheme.forestGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Maça Katılmak İçin Başvur'),
                      )
                    else if (myApplication.status == ApplicationStatus.pending)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.hourglass_empty, color: Colors.amber),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Başvurunuz Beklemede (Kaptan Onayı Bekleniyor)',
                                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (myApplication.status == ApplicationStatus.accepted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.greenAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Başvurunuz Kabul Edildi! Maça Davetlisiniz.',
                                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final user = appState.currentUser!;
                              final isShared = user.isContactInfoPublic || user.shareContactOnApproval || myApplication!.isContactShared;
                              if (isShared) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardDark,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'İletişim bilgileriniz kaptanla paylaşıldı (${user.phoneNumber})',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Card(
                                  color: AppTheme.cardDark,
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Kaptanın size ulaşabilmesi için iletişim bilgilerinizi göndermek ister misiniz?',
                                          style: TextStyle(fontSize: 13, height: 1.3),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            appState.shareContactInfoForApplication(myApplication!.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('İletişim bilgileriniz başarıyla kaptana gönderildi!'),
                                                backgroundColor: AppTheme.forestGreen,
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.send, size: 16),
                                          label: const Text('İletişim Bilgilerini Gönder'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryGreen,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                          ),
                        ],
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Başvurunuz Kaptan Tarafından Reddedildi.',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
