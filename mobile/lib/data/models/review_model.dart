class Review {
  final String id;
  final String serviceRequestId;
  final String ownerId;
  final String caregiverId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.serviceRequestId,
    required this.ownerId,
    required this.caregiverId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      serviceRequestId: json['serviceRequestId'] as String,
      ownerId: json['ownerId'] as String,
      caregiverId: json['caregiverId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
