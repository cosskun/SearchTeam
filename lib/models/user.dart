import 'match_ad.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String bio;
  final double rating; // Average rating (e.g. 4.7)
  final int totalReviews; // Total reviews received
  final int totalMatchesPlayed;
  final int totalMatchesHosted;
  final int mvpCount;
  final List<PositionType> preferredPositions;
  final bool isContactInfoPublic;
  final bool shareContactOnApproval;
  final double? height; // in cm
  final double? weight; // in kg
  final String avatarUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.bio,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalMatchesPlayed = 0,
    this.totalMatchesHosted = 0,
    this.mvpCount = 0,
    this.preferredPositions = const [],
    this.isContactInfoPublic = false,
    this.shareContactOnApproval = false,
    this.height,
    this.weight,
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
  });

  List<String> get earnedBadges {
    final List<String> list = [];
    if (mvpCount > 0) {
      list.add('🏆 ${mvpCount}x Maçın Adamı (MVP)');
    }
    if (rating >= 4.8 && totalReviews >= 1) {
      list.add('⭐ Centilmen Oyuncu (5.0)');
    }
    if (totalMatchesHosted >= 3) {
      list.add('👑 Tecrübeli Kaptan');
    }
    if (preferredPositions.contains(PositionType.kaleci)) {
      list.add('🥅 Panter Kaleci');
    }
    if (totalMatchesPlayed >= 2) {
      list.add('🌙 Gece Kuşu (22:00)');
    }
    return list;
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? bio,
    double? rating,
    int? totalReviews,
    int? totalMatchesPlayed,
    int? totalMatchesHosted,
    int? mvpCount,
    List<PositionType>? preferredPositions,
    bool? isContactInfoPublic,
    bool? shareContactOnApproval,
    double? height,
    double? weight,
    String? avatarUrl,
  }) {
    return AppUser(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalMatchesPlayed: totalMatchesPlayed ?? this.totalMatchesPlayed,
      totalMatchesHosted: totalMatchesHosted ?? this.totalMatchesHosted,
      mvpCount: mvpCount ?? this.mvpCount,
      preferredPositions: preferredPositions ?? this.preferredPositions,
      isContactInfoPublic: isContactInfoPublic ?? this.isContactInfoPublic,
      shareContactOnApproval: shareContactOnApproval ?? this.shareContactOnApproval,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
