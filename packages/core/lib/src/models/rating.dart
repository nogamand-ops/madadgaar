class Rating {
  final String id;
  final String requestId;
  final String fromUserId;
  final String toUserId;
  final String direction;
  final int stars;
  final String review;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.requestId,
    required this.fromUserId,
    required this.toUserId,
    required this.direction,
    required this.stars,
    required this.review,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        id: json['id'] as String,
        requestId: json['requestId'] as String,
        fromUserId: json['fromUserId'] as String,
        toUserId: json['toUserId'] as String,
        direction: json['direction'] as String,
        stars: (json['stars'] as num).toInt(),
        review: json['review'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
