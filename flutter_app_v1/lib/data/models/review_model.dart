class ReviewModel {
  final String? id;
  final String? caseId;
  final String? reviewerId;
  final String? lawyerId;
  final String? reviewerFirstName;
  final String? reviewerLastName;
  final String? reviewerProfilePicture;
  final int? rating;
  final String? comment;
  final String? createdAt;
  final String? updatedAt;

  ReviewModel({
    this.id,
    this.caseId,
    this.reviewerId,
    this.lawyerId,
    this.reviewerFirstName,
    this.reviewerLastName,
    this.reviewerProfilePicture,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString(),
      caseId: json['caseId']?.toString(),
      reviewerId: json['reviewerId']?.toString(),
      lawyerId: json['lawyerId']?.toString(),
      reviewerFirstName: json['reviewerFirstName'],
      reviewerLastName: json['reviewerLastName'],
      reviewerProfilePicture: json['reviewerProfilePicture'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'lawyerId': lawyerId,
      'rating': rating,
      'comment': comment,
    };
  }

  String get reviewerFullName =>
      '${reviewerFirstName ?? ''} ${reviewerLastName ?? ''}'.trim();
}
