import '../services/auth_api.dart';
import '../model/login_request.dart';
import '../model/register_request.dart';
import '../model/auth_response.dart';

class AuthRepository {
	final AuthApi _api;
	AuthRepository(this._api);

	Future<AuthResponse> login(LoginRequest request) async {
		try {
			return await _api.login(request);
		} catch (err) {
			// handle or rethrow error as needed
			rethrow;
		}
	}

	Future<AuthResponse> register(RegisterRequest request) async {
		try {
			return await _api.register(request);
		} catch (err) {
			// handle or rethrow error as needed
			rethrow;
		}
	}
}
