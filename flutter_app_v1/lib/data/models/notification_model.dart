class NotificationModel {
  final String? id;
  final String? receiverId;
  final String? content;
  final bool? isRead;
  final String? type;
  final String? createdAt;

  NotificationModel({
    this.id,
    this.receiverId,
    this.content,
    this.isRead,
    this.type,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      receiverId: json['receiverId']?.toString(),
      content: json['content'],
      isRead: json['isRead'],
      type: json['type'],
      createdAt: json['createdAt'],
    );
  }
}

class NotificationPreferenceModel {
  final String? id;
  final String? type;
  final bool? emailEnabled;
  final bool? webPushEnabled;

  NotificationPreferenceModel({
    this.id,
    this.type,
    this.emailEnabled,
    this.webPushEnabled,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      id: json['id']?.toString(),
      type: json['type'],
      emailEnabled: json['emailEnabled'],
      webPushEnabled: json['webPushEnabled'],
    );
  }
}
