class ScheduleModel {
  final String? id;
  final String? caseId;
  final String? title;
  final String? type;
  final String? description;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? lawyerId;
  final String? clientId;
  final String? lawyerName;
  final String? clientName;
  final String? createdAt;
  final String? updatedAt;

  ScheduleModel({
    this.id,
    this.caseId,
    this.title,
    this.type,
    this.description,
    this.date,
    this.startTime,
    this.endTime,
    this.lawyerId,
    this.clientId,
    this.lawyerName,
    this.clientName,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id']?.toString(),
      caseId: json['caseId']?.toString(),
      title: json['title'],
      type: json['type'],
      description: json['description'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      lawyerId: json['lawyerId']?.toString(),
      clientId: json['clientId']?.toString(),
      lawyerName: json['lawyerName'],
      clientName: json['clientName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'title': title,
      'type': type,
      'description': description,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
