class DocumentModel {
  final String? id;
  final String? caseId;
  final String? title;
  final String? description;
  final String? privacy;
  final String? fileUrl;
  final String? uploadedBy;
  final String? uploaderFirstName;
  final String? uploaderLastName;
  final String? createdAt;
  final String? updatedAt;

  DocumentModel({
    this.id,
    this.caseId,
    this.title,
    this.description,
    this.privacy,
    this.fileUrl,
    this.uploadedBy,
    this.uploaderFirstName,
    this.uploaderLastName,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString(),
      caseId: json['caseId']?.toString(),
      title: json['title'],
      description: json['description'],
      privacy: json['privacy'],
      fileUrl: json['fileUrl'],
      uploadedBy: json['uploadedBy']?.toString(),
      uploaderFirstName: json['uploaderFirstName'],
      uploaderLastName: json['uploaderLastName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'title': title,
      'description': description,
      'privacy': privacy,
    };
  }
}
