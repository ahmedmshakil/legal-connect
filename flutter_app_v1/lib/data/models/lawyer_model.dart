class LawyerModel {
  final String? id;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? firm;
  final int? yearsOfExperience;
  final String? barCertificateNumber;
  final String? practicingCourt;
  final String? division;
  final String? district;
  final String? bio;
  final String? barCertificateFileUrl;
  final String? verificationStatus;
  final double? hourlyCharge;
  final List<String>? specializations;
  final bool? completeProfile;
  final String? profilePictureUrl;
  final String? profilePictureThumbnailUrl;
  final double? averageRating;
  final int? totalReviews;
  final String? createdAt;
  final String? updatedAt;

  LawyerModel({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.firm,
    this.yearsOfExperience,
    this.barCertificateNumber,
    this.practicingCourt,
    this.division,
    this.district,
    this.bio,
    this.barCertificateFileUrl,
    this.verificationStatus,
    this.hourlyCharge,
    this.specializations,
    this.completeProfile,
    this.profilePictureUrl,
    this.profilePictureThumbnailUrl,
    this.averageRating,
    this.totalReviews,
    this.createdAt,
    this.updatedAt,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    return LawyerModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      firm: json['firm'],
      yearsOfExperience: json['yearsOfExperience'],
      barCertificateNumber: json['barCertificateNumber'],
      practicingCourt: json['practicingCourt'],
      division: json['division'],
      district: json['district'],
      bio: json['bio'],
      barCertificateFileUrl: json['barCertificateFileUrl'],
      verificationStatus: json['verificationStatus'],
      hourlyCharge: json['hourlyCharge']?.toDouble(),
      specializations: json['specializations'] != null
          ? List<String>.from(json['specializations'])
          : null,
      completeProfile: json['completeProfile'],
      profilePictureUrl: json['profilePictureUrl'],
      profilePictureThumbnailUrl: json['profilePictureThumbnailUrl'],
      averageRating: json['averageRating']?.toDouble(),
      totalReviews: json['totalReviews'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firm': firm,
      'yearsOfExperience': yearsOfExperience,
      'barCertificateNumber': barCertificateNumber,
      'practicingCourt': practicingCourt,
      'division': division,
      'district': district,
      'bio': bio,
      'specializations': specializations,
      'hourlyCharge': hourlyCharge,
    };
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  bool get isPending => verificationStatus == 'PENDING';
  bool get isApproved => verificationStatus == 'APPROVED';
  bool get isRejected => verificationStatus == 'REJECTED';
}
