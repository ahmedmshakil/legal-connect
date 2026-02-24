class NoteModel {
  final String? id;
  final String? caseId;
  final String? title;
  final String? content;
  final String? privacy;
  final String? createdBy;
  final String? createdByFirstName;
  final String? createdByLastName;
  final String? createdAt;
  final String? updatedAt;

  NoteModel({
    this.id,
    this.caseId,
    this.title,
    this.content,
    this.privacy,
    this.createdBy,
    this.createdByFirstName,
    this.createdByLastName,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id']?.toString(),
      caseId: json['caseId']?.toString(),
      title: json['title'],
      content: json['content'],
      privacy: json['privacy'],
      createdBy: json['createdBy']?.toString(),
      createdByFirstName: json['createdByFirstName'],
      createdByLastName: json['createdByLastName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'title': title,
      'content': content,
      'privacy': privacy,
    };
  }

  bool get isPrivate => privacy == 'PRIVATE';
  bool get isShared => privacy == 'SHARED';
}
