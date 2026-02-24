class CaseModel {
  final String? id;
  final String? title;
  final String? description;
  final String? status;
  final String? lawyerId;
  final String? clientId;
  final String? lawyerFirstName;
  final String? lawyerLastName;
  final String? lawyerEmail;
  final String? clientFirstName;
  final String? clientLastName;
  final String? clientEmail;
  final String? createdAt;
  final String? updatedAt;

  CaseModel({
    this.id,
    this.title,
    this.description,
    this.status,
    this.lawyerId,
    this.clientId,
    this.lawyerFirstName,
    this.lawyerLastName,
    this.lawyerEmail,
    this.clientFirstName,
    this.clientLastName,
    this.clientEmail,
    this.createdAt,
    this.updatedAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id']?.toString(),
      title: json['title'],
      description: json['description'],
      status: json['status'],
      lawyerId: json['lawyerId']?.toString(),
      clientId: json['clientId']?.toString(),
      lawyerFirstName: json['lawyerFirstName'],
      lawyerLastName: json['lawyerLastName'],
      lawyerEmail: json['lawyerEmail'],
      clientFirstName: json['clientFirstName'],
      clientLastName: json['clientLastName'],
      clientEmail: json['clientEmail'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'clientEmail': clientEmail,
    };
  }

  String get lawyerFullName =>
      '${lawyerFirstName ?? ''} ${lawyerLastName ?? ''}'.trim();
  String get clientFullName =>
      '${clientFirstName ?? ''} ${clientLastName ?? ''}'.trim();
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isResolved => status == 'RESOLVED';
}
