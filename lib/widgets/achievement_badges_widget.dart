import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AchievementBadgesWidget extends StatelessWidget {
  final List<String> badges;
  final String title;

  const AchievementBadgesWidget({
    super.key,
    required this.badges,
    this.title = '🏆 Oyuncu Başarım Rozetleri',
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Henüz rozet kazanılmadı.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges.map((badge) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amberAccent),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
