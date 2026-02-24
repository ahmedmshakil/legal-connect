class AvailabilitySlotModel {
  final String? id;
  final String? lawyerEmail;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? createdAt;

  AvailabilitySlotModel({
    this.id,
    this.lawyerEmail,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.createdAt,
  });

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotModel(
      id: json['id']?.toString(),
      lawyerEmail: json['lawyerEmail'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'dayOfWeek': dayOfWeek, 'startTime': startTime, 'endTime': endTime};
  }
}
