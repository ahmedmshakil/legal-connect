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
    // Backend CaseResponseDTO nests lawyer/client inside objects
    final lawyer = json['lawyer'] is Map ? Map<String, dynamic>.from(json['lawyer']) : <String, dynamic>{};
    final client = json['client'] is Map ? Map<String, dynamic>.from(json['client']) : <String, dynamic>{};

    return CaseModel(
      id: json['caseId']?.toString() ?? json['id']?.toString(),
      title: json['title'],
      description: json['description'],
      status: json['status'],
      lawyerId: lawyer['id']?.toString() ?? json['lawyerId']?.toString(),
      clientId: client['id']?.toString() ?? json['clientId']?.toString(),
      lawyerFirstName: lawyer['firstName'] ?? json['lawyerFirstName'],
      lawyerLastName: lawyer['lastName'] ?? json['lawyerLastName'],
      lawyerEmail: lawyer['email'] ?? json['lawyerEmail'],
      clientFirstName: client['firstName'] ?? json['clientFirstName'],
      clientLastName: client['lastName'] ?? json['clientLastName'],
      clientEmail: client['email'] ?? json['clientEmail'],
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
