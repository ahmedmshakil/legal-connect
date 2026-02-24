import 'user_model.dart';

class AuthResponseModel {
  final String? token;
  final UserModel? user;

  AuthResponseModel({this.token, this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
