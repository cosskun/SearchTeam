import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../models/match_ad.dart';
import '../models/application.dart';
import '../theme/app_theme.dart';
import 'chat_room_screen.dart';
import '../widgets/custom_rating_indicator.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;
    
    final userIndex = appState.users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bulunamadı.')),
      );
    }
    final user = appState.users[userIndex];
    final userReviews = appState.getReviewsForUser(userId);

    // Privacy Logic for Contact Information
    bool isContactVisible = false;
    bool isSharedSpecifically = false;
    bool isSharedAutomatically = false;

    if (currentUser != null) {
      if (currentUser.id == userId) {
        isContactVisible = true;
      } else if (user.isContactInfoPublic) {
        isContactVisible = true;
      } else {
        // Find if this applicant has any accepted applications hosted by currentUser
        // where contact sharing is active (either auto or manual)
        final matchingApps = appState.applications.where((app) =>
            app.applicantId == userId &&
            app.status == ApplicationStatus.accepted &&
            appState.matches.any((m) => m.id == app.matchId && m.hostId == currentUser.id));

        for (final app in matchingApps) {
          if (user.shareContactOnApproval) {
            isContactVisible = true;
            isSharedAutomatically = true;
          } else if (app.isContactShared) {
            isContactVisible = true;
            isSharedSpecifically = true;
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Avatar, Name, Rating
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      user.avatarUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomRatingIndicator(
                        rating: user.rating,
                        size: 18.0,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${user.rating} (${userReviews.length} yorum)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Achievement Badges
            if (user.earnedBadges.isNotEmpty) ...[
              const Text('🏆 Oyuncu Başarım Rozetleri', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.earnedBadges.map((badge) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amberAccent),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // 3. Physical Metrics & MVP Row
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.height, color: AppTheme.primaryGreen),
                          const SizedBox(height: 6),
                          Text(
                            user.height != null ? '${user.height!.toInt()} cm' : 'Belirtilmemiş',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text('Boy', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.scale_outlined, color: AppTheme.primaryGreen),
                          const SizedBox(height: 6),
                          Text(
                            user.weight != null ? '${user.weight!.toInt()} kg' : 'Belirtilmemiş',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text('Kilo', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber),
                          const SizedBox(height: 6),
                          Text(
                            '${user.mvpCount}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          const Text('MVP', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Preferred Positions
            if (user.preferredPositions.isNotEmpty) ...[
              const Text('Tercih Ettiği Mevkiler', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.preferredPositions.map((pos) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: chipColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      pos.displayName,
                      style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // 4. Bio
            const Text('Hakkımda', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  user.bio,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Contact Info
            const Text('İletişim Bilgileri', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 18),
                        const SizedBox(width: 10),
                        Text(user.email, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 20, color: Colors.white10),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, color: AppTheme.textMuted, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: isContactVisible
                              ? Row(
                                  children: [
                                    Text(user.phoneNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 6),
                                    if (isSharedSpecifically)
                                      const Text('(Gönderildi)', style: TextStyle(fontSize: 10, color: Colors.greenAccent))
                                    else if (isSharedAutomatically)
                                      const Text('(Otomatik Paylaşıldı)', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                                  ],
                                )
                              : const Text('Telefon: Gizli (Onaylanınca paylaşılır)', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 6. Past Reviews
            const Text('Geçmiş Değerlendirmeler', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            const SizedBox(height: 8),
            if (userReviews.isEmpty)
              const Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Henüz değerlendirme yapılmamış.', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userReviews.length,
                itemBuilder: (context, index) {
                  final review = userReviews[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review.reviewerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                DateFormat('dd.MM.yyyy').format(review.dateTime),
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          CustomRatingIndicator(rating: review.rating, size: 12.0),
                          const SizedBox(height: 6),
                          Text(
                            review.comment,
                            style: const TextStyle(fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: currentUser != null && currentUser.id != userId
          ? FloatingActionButton.extended(
              onPressed: () {
                final sessionId = appState.startOrGetChatSession(userId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      sessionId: sessionId,
                      recipientUser: user,
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.chat),
              label: const Text('Mesaj Gönder', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}
