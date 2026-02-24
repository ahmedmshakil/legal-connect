class BlogModel {
  final String? id;
  final String? title;
  final String? content;
  final String? status;
  final String? authorId;
  final String? authorFirstName;
  final String? authorLastName;
  final String? authorProfilePicture;
  final String? createdAt;
  final String? updatedAt;

  BlogModel({
    this.id,
    this.title,
    this.content,
    this.status,
    this.authorId,
    this.authorFirstName,
    this.authorLastName,
    this.authorProfilePicture,
    this.createdAt,
    this.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id']?.toString(),
      title: json['title'],
      content: json['content'],
      status: json['status'],
      authorId: json['authorId']?.toString(),
      authorFirstName: json['authorFirstName'],
      authorLastName: json['authorLastName'],
      authorProfilePicture: json['authorProfilePicture'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'status': status};
  }

  String get authorFullName =>
      '${authorFirstName ?? ''} ${authorLastName ?? ''}'.trim();
  bool get isDraft => status == 'DRAFT';
  bool get isPublished => status == 'PUBLISHED';
}
