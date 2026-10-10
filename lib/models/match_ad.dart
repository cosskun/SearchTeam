enum PositionType {
  kaleci,
  defans,
  ortaSaha,
  forvet;

  String get displayName {
    switch (this) {
      case PositionType.kaleci:
        return 'Kaleci';
      case PositionType.defans:
        return 'Defans';
      case PositionType.ortaSaha:
        return 'Orta Saha';
      case PositionType.forvet:
        return 'Forvet';
    }
  }
}

enum MatchStatus {
  active,
  completed,
  cancelled
}

class MatchAd {
  final String id;
  final String hostId;
  final String hostName;
  final double hostRating;
  final String title;
  final String description;
  final String locationName; // E.g. "Kadir Has Halısahası"
  final String district;     // E.g. "Kadıköy", "Şişli"
  final double? latitude;
  final double? longitude;
  final DateTime dateTime;
  final double price;        // 0.0 means free (ücretsiz)
  final PositionType requiredPosition;
  final int spotsNeeded;     // E.g. 1
  final MatchStatus status;
  final Map<String, String> tacticalRoster; // E.g. {"Kaleci": "user_id"}
  final String? finalScore;   // E.g. "8 - 6"
  final String? mvpUserId;    // User ID of the voted MVP
  final Map<String, String> mvpVotes; // voterUserId -> candidateUserId
  final String weatherText;   // E.g. "21°C Açık ☀️"

  MatchAd({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.hostRating,
    required this.title,
    required this.description,
    required this.locationName,
    required this.district,
    this.latitude,
    this.longitude,
    required this.dateTime,
    required this.price,
    required this.requiredPosition,
    this.spotsNeeded = 1,
    this.status = MatchStatus.active,
    Map<String, String>? tacticalRoster,
    this.finalScore,
    this.mvpUserId,
    Map<String, String>? mvpVotes,
    this.weatherText = '21°C Açık ☀️',
  })  : tacticalRoster = tacticalRoster ?? {},
        mvpVotes = mvpVotes ?? {};

  bool get isFree => price <= 0.0;

  MatchAd copyWith({
    String? title,
    String? description,
    String? locationName,
    String? district,
    double? latitude,
    double? longitude,
    DateTime? dateTime,
    double? price,
    PositionType? requiredPosition,
    int? spotsNeeded,
    MatchStatus? status,
    Map<String, String>? tacticalRoster,
    String? finalScore,
    String? mvpUserId,
    Map<String, String>? mvpVotes,
    String? weatherText,
  }) {
    return MatchAd(
      id: this.id,
      hostId: this.hostId,
      hostName: this.hostName,
      hostRating: this.hostRating,
      title: title ?? this.title,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateTime: dateTime ?? this.dateTime,
      price: price ?? this.price,
      requiredPosition: requiredPosition ?? this.requiredPosition,
      spotsNeeded: spotsNeeded ?? this.spotsNeeded,
      status: status ?? this.status,
      tacticalRoster: tacticalRoster ?? Map.from(this.tacticalRoster),
      finalScore: finalScore ?? this.finalScore,
      mvpUserId: mvpUserId ?? this.mvpUserId,
      mvpVotes: mvpVotes ?? Map.from(this.mvpVotes),
      weatherText: weatherText ?? this.weatherText,
    );
  }
}
