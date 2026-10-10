enum ApplicationStatus {
  pending,
  accepted,
  rejected
}

class Application {
  final String id;
  final String matchId;
  final String applicantId;
  final String applicantName;
  final double applicantRating;
  final String applicantBio;
  final ApplicationStatus status;
  final DateTime dateTime;
  final bool isContactShared;

  Application({
    required this.id,
    required this.matchId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantRating,
    required this.applicantBio,
    this.status = ApplicationStatus.pending,
    required this.dateTime,
    this.isContactShared = false,
  });

  Application copyWith({
    ApplicationStatus? status,
    bool? isContactShared,
  }) {
    return Application(
      id: this.id,
      matchId: this.matchId,
      applicantId: this.applicantId,
      applicantName: this.applicantName,
      applicantRating: this.applicantRating,
      applicantBio: this.applicantBio,
      status: status ?? this.status,
      dateTime: this.dateTime,
      isContactShared: isContactShared ?? this.isContactShared,
    );
  }
}
