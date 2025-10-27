import 'package:dio/dio.dart';
import 'package:prm_project/model/dto/response/payment_response.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _api = ApiService();

  Future<PaymentResponse?> createPayment(String bookingId) async {
    try {
      print('[PaymentService] POST /api/Payment/create?bookingId=$bookingId');
      final response = await _api.post(
        '/Payment/create',
        queryParameters: {'bookingId': bookingId},
      );

      if (response.statusCode == 200) {
        final paymentResponse = PaymentResponse.fromJson(response.data);
        print(
          '[PaymentService] Created: ${paymentResponse.data?.paymentLink?.checkoutUrl}',
        );
        return paymentResponse;
      }
      return null;
    } on DioException catch (e) {
      print('[PaymentService] createPayment error: ${e.message}');
      if (e.response != null) {
        print('[PaymentService] Error response: ${e.response!.data.message}');
      }
      rethrow;
    }
  }
}
