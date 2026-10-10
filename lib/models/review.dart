class Review {
  final String id;
  final String matchId;
  final String matchTitle;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final double rating; // 1.0 to 5.0 stars
  final String comment;
  final DateTime dateTime;

  Review({
    required this.id,
    required this.matchId,
    required this.matchTitle,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.dateTime,
  });
}
