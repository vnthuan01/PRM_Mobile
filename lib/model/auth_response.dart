import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
	final String token;
	final String userId;
	final String email;

	AuthResponse({required this.token, required this.userId, required this.email});

	factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
	Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
