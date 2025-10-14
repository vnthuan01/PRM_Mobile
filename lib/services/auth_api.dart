import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../model/login_request.dart';
import '../model/register_request.dart';
import '../model/auth_response.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
	factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

	@POST('/auth/login')
	Future<AuthResponse> login(@Body() LoginRequest request);

	@POST('/auth/register')
	Future<AuthResponse> register(@Body() RegisterRequest request);
}
