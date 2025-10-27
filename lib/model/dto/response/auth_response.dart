import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String? email;
  @JsonKey(name: 'fullName')
  final String? fullName;
  @JsonKey(name: 'phoneNumber')
  final String? phoneNumber;
  final String status;
  final int role;
  final String createdAt;

  User({
    required this.id,
    this.email,
    this.fullName,
    this.phoneNumber,
    required this.status,
    required this.role,
    required this.createdAt,
  });

  factory User.empty() {
    return User(
      id: '',
      email: '',
      fullName: '',
      phoneNumber: '',
      status: '',
      role: 0,
      createdAt: '',
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool isSuccess;
  final String message;
  final AuthData data;

  AuthResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthData {
  final String token;
  final String expiresAt;
  final User user;
  final String message;

  AuthData({
    required this.token,
    required this.expiresAt,
    required this.user,
    required this.message,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}
