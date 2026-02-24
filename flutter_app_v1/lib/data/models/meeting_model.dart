class MeetingModel {
  final String? id;
  final String? roomName;
  final String? clientId;
  final String? lawyerId;
  final String? clientName;
  final String? lawyerName;
  final String? startTimestamp;
  final String? endTimestamp;
  final bool? isPaid;
  final String? paymentId;
  final String? createdAt;
  final String? updatedAt;

  MeetingModel({
    this.id,
    this.roomName,
    this.clientId,
    this.lawyerId,
    this.clientName,
    this.lawyerName,
    this.startTimestamp,
    this.endTimestamp,
    this.isPaid,
    this.paymentId,
    this.createdAt,
    this.updatedAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString(),
      roomName: json['roomName'],
      clientId: json['clientId']?.toString(),
      lawyerId: json['lawyerId']?.toString(),
      clientName: json['clientName'],
      lawyerName: json['lawyerName'],
      startTimestamp: json['startTimestamp'],
      endTimestamp: json['endTimestamp'],
      isPaid: json['isPaid'],
      paymentId: json['paymentId']?.toString(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'startTimestamp': startTimestamp,
      'endTimestamp': endTimestamp,
    };
  }
}
