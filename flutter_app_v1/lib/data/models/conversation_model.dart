class ConversationModel {
  final String? id;
  final String? participantOneId;
  final String? participantTwoId;
  final String? otherParticipantName;
  final String? otherParticipantEmail;
  final String? otherParticipantProfilePicture;
  final String? lastMessage;
  final String? lastMessageTime;
  final int? unreadCount;
  final String? createdAt;
  final String? updatedAt;

  ConversationModel({
    this.id,
    this.participantOneId,
    this.participantTwoId,
    this.otherParticipantName,
    this.otherParticipantEmail,
    this.otherParticipantProfilePicture,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString(),
      participantOneId: json['participantOneId']?.toString(),
      participantTwoId: json['participantTwoId']?.toString(),
      otherParticipantName: json['otherParticipantName'],
      otherParticipantEmail: json['otherParticipantEmail'],
      otherParticipantProfilePicture: json['otherParticipantProfilePicture'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  bool get hasUnread => (unreadCount ?? 0) > 0;
}

class MessageModel {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? content;
  final bool? isRead;
  final String? createdAt;

  MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    this.content,
    this.isRead,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString(),
      conversationId: json['conversationId']?.toString(),
      senderId: json['senderId']?.toString(),
      content: json['content'],
      isRead: json['isRead'],
      createdAt: json['createdAt'],
    );
  }
}
