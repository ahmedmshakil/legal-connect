class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final bool? emailVerified;
  final String? profilePictureUrl;
  final String? profilePictureThumbnailUrl;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.emailVerified,
    this.profilePictureUrl,
    this.profilePictureThumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profilePicture = json['profilePicture'];
    final profilePictureMap = profilePicture is Map
        ? Map<String, dynamic>.from(profilePicture)
        : <String, dynamic>{};

    return UserModel(
      id: json['id']?.toString(),
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role']?.toString().toUpperCase(),
      emailVerified: json['emailVerified'],
      profilePictureUrl:
          json['profilePictureUrl'] ??
          json['fullPictureUrl'] ??
          profilePictureMap['profilePictureUrl'] ??
          profilePictureMap['fullPictureUrl'],
      profilePictureThumbnailUrl:
          json['profilePictureThumbnailUrl'] ??
          json['thumbnailPictureUrl'] ??
          profilePictureMap['profilePictureThumbnailUrl'] ??
          profilePictureMap['thumbnailPictureUrl'],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'emailVerified': emailVerified,
      'profilePictureUrl': profilePictureUrl,
      'profilePictureThumbnailUrl': profilePictureThumbnailUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel withFallback(UserModel? fallback) {
    if (fallback == null) return this;

    return UserModel(
      id: id ?? fallback.id,
      firstName: firstName ?? fallback.firstName,
      lastName: lastName ?? fallback.lastName,
      email: email ?? fallback.email,
      role: role ?? fallback.role,
      emailVerified: emailVerified ?? fallback.emailVerified,
      profilePictureUrl: profilePictureUrl ?? fallback.profilePictureUrl,
      profilePictureThumbnailUrl:
          profilePictureThumbnailUrl ?? fallback.profilePictureThumbnailUrl,
      createdAt: createdAt ?? fallback.createdAt,
      updatedAt: updatedAt ?? fallback.updatedAt,
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  bool get isUser => role == 'USER';
  bool get isLawyer => role == 'LAWYER';
  bool get isAdmin => role == 'ADMIN';

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    bool? emailVerified,
    String? profilePictureUrl,
    String? profilePictureThumbnailUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profilePictureThumbnailUrl:
          profilePictureThumbnailUrl ?? this.profilePictureThumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
