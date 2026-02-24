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
    return UserModel(
      id: json['id']?.toString(),
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role'],
      emailVerified: json['emailVerified'],
      profilePictureUrl: json['profilePictureUrl'],
      profilePictureThumbnailUrl: json['profilePictureThumbnailUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
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
    };
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
    );
  }
}
