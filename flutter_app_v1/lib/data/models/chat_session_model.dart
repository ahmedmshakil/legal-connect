class ChatSessionModel {
  final String? id;
  final String? userId;
  final String? title;
  final String? createdAt;
  final String? updatedAt;
  final int? messageCount;

  ChatSessionModel({
    this.id,
    this.userId,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.messageCount,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id']?.toString() ?? json['session_id']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      title: json['title'],
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
      messageCount: json['message_count'] ?? json['messageCount'],
    );
  }
}

class AiMessageModel {
  final String? id;
  final String? sessionId;
  final String? role; // 'user' or 'assistant'
  final String? content;
  final List<SourceDocument>? sources;
  final String? createdAt;

  AiMessageModel({
    this.id,
    this.sessionId,
    this.role,
    this.content,
    this.sources,
    this.createdAt,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id']?.toString(),
      sessionId:
          json['session_id']?.toString() ?? json['sessionId']?.toString(),
      role: json['role'],
      content: json['content'] ?? json['answer'] ?? json['response'],
      sources: json['sources'] != null
          ? (json['sources'] as List)
                .map((s) => SourceDocument.fromJson(s))
                .toList()
          : null,
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

class SourceDocument {
  final String? title;
  final String? content;
  final double? score;
  final String? documentId;

  SourceDocument({this.title, this.content, this.score, this.documentId});

  factory SourceDocument.fromJson(Map<String, dynamic> json) {
    return SourceDocument(
      title: json['title'],
      content: json['content'],
      score: json['score']?.toDouble(),
      documentId: json['document_id']?.toString(),
    );
  }
}
