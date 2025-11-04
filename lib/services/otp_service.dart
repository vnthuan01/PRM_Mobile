import 'package:dio/dio.dart';
import '../model/dto/request/otp_request.dart';
import '../model/dto/response/otp_response.dart';
import 'api_service.dart';

class OtpService {
  final ApiService _apiService = ApiService();

  /// Gửi OTP
  Future<OtpResponse?> sendOtp(SendOtpRequest request) async {
    try {
      final Response response = await _apiService.post(
        '/Otp/send-otp',
        data: request.toJson(),
      );

      return OtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('[OtpService] sendOtp error: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      print('[OtpService] sendOtp unexpected error: $e');
      return null;
    }
  }

  /// Xác minh OTP
  Future<OtpResponse?> verifyOtp(VerifyOtpRequest request) async {
    try {
      final Response response = await _apiService.post(
        '/Otp/verify',
        data: request.toJson(),
      );

      return OtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('[OtpService] verifyOtp error: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      print('[OtpService] verifyOtp unexpected error: $e');
      return null;
    }
  }
}
