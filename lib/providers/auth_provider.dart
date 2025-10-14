import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../model/login_request.dart';
import '../model/register_request.dart';
import '../model/auth_response.dart';

class AuthProvider extends ChangeNotifier {
	final AuthRepository _repository;
	bool isLoading = false;
	String? error;
	AuthResponse? auth;

	AuthProvider(this._repository);

	Future<void> login(LoginRequest request) async {
		setIsLoading(true);
		try {
			auth = await _repository.login(request);
			error = null;
			await _persistToken(auth!.token);
		} catch (e) {
			error = e.toString();
		} finally {
			setIsLoading(false);
		}
	}

	Future<void> register(RegisterRequest request) async {
		setIsLoading(true);
		try {
			auth = await _repository.register(request);
			error = null;
			await _persistToken(auth!.token);
		} catch (e) {
			error = e.toString();
		} finally {
			setIsLoading(false);
		}
	}

	void setIsLoading(bool value) {
		isLoading = value;
		notifyListeners();
	}

	Future<void> _persistToken(String token) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString('authToken', token);
	}
}
