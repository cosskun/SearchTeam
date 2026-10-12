import 'package:flutter/material.dart';
import '../models/match_ad.dart';
import '../theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../screens/match_details_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchAd match;
  final bool isCurrentUserHost;

  const MatchCard({
    super.key,
    required this.match,
    required this.isCurrentUserHost,
  });

  IconData _getPositionIcon(PositionType position) {
    switch (position) {
      case PositionType.kaleci:
        return Icons.pan_tool;
      case PositionType.defans:
        return Icons.shield;
      case PositionType.ortaSaha:
        return Icons.adjust;
      case PositionType.forvet:
        return Icons.sports_martial_arts;
    }
  }

  Color _getPositionColor(PositionType position) {
    switch (position) {
      case PositionType.kaleci:
        return Colors.orangeAccent;
      case PositionType.defans:
        return Colors.blueAccent;
      case PositionType.ortaSaha:
        return Colors.tealAccent;
      case PositionType.forvet:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = AppDateFormatter.formatShortDateWithTime(match.dateTime);

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
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Position Badge, Weather Badge & Pricing Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Required position badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPositionColor(match.requiredPosition).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getPositionColor(match.requiredPosition).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getPositionIcon(match.requiredPosition),
                                size: 13,
                                color: _getPositionColor(match.requiredPosition),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                match.requiredPosition.displayName,
                                style: TextStyle(
                                  color: _getPositionColor(match.requiredPosition),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Weather badge pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                            match.weatherText,
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pricing badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: match.isFree
                          ? Colors.green.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      match.isFree ? 'ÜCRETSİZ' : '${match.price.toInt()} TL',
                      style: TextStyle(
                        color: match.isFree ? AppTheme.primaryGreen : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Description preview
              Text(
                match.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                match.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),

              const Divider(height: 1, color: Colors.white10),
              const SizedBox(height: 12),

              // Info: Location, Date & Host Details
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${match.district} - ${match.locationName}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Footer: Host profile summary and spots needed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Host Rating Info
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                          child: Text(
                            match.hostName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isCurrentUserHost ? 'Senin İlanın' : match.hostName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(
                          ' ${match.hostRating}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Missing spots left badge
                  Text(
                    '${match.spotsNeeded} Oyuncu Aranıyor',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
