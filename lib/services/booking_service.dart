import 'package:dio/dio.dart';
import 'package:prm_project/model/dto/request/booking_request.dart';
import 'package:prm_project/model/dto/response/booking_response.dart';
import 'package:prm_project/services/api_service.dart';

class BookingService {
  final ApiService _api = ApiService();

  Future<BookingResponse?> createBooking(BookingRequest request) async {
    try {
      print('[BookingService] Creating booking with data: ${request.toJson()}');
      final response = await _api.post('/Booking', data: request.toJson());

      if (response.statusCode == 201 && response.data != null) {
        print('[BookingService] Booking created successfully');
        return BookingResponse.fromJson(response.data);
      }
      print('[BookingService] Unexpected status code: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('[BookingService] createBooking error: $e');
      if (e.response != null) {
        return BookingResponse.fromJson(e.response!.data);
      }
      return null;
    }
  }

  Future<List<Booking>> getBookingsByCustomer(String customerId) async {
    try {
      print('[BookingService] Fetching bookings for customer: $customerId');
      final response = await _api.get(
        '/Booking/customer/$customerId?pageNumber=1&pageSize=100',
      );

      if (response.statusCode == 200) {
        print('[BookingService] Response data: ${response.data}');
        if (response.data is Map<String, dynamic> &&
            response.data['data'] is List) {
          return (response.data['data'] as List)
              .map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (response.data is List) {
          return (response.data as List)
              .map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          print('[BookingService] Invalid response format: ${response.data}');
          throw Exception(
            'Invalid response format: expected { data: [...] } or [...]',
          );
        }
      }
      print('[BookingService] Unexpected status code: ${response.statusCode}');
      return [];
    } catch (e) {
      print('[BookingService] getBookingsByCustomer error: $e');
      rethrow;
    }
  }

  Future<Booking?> getBookingById(String id) async {
    try {
      print('[BookingService] GET /Booking/$id');
      final response = await _api.get('/Booking/$id');

      print('[BookingService] Response status: ${response.statusCode}');
      print('[BookingService] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // Handle the wrapped response structure
        if (response.data is Map<String, dynamic> &&
            response.data['data'] != null) {
          final bookingData = response.data['data'] as Map<String, dynamic>;
          print('[BookingService] Parsing booking data: $bookingData');
          return Booking.fromJson(bookingData);
        } else {
          // Fallback for direct booking data
          print('[BookingService] Parsing direct booking data');
          return Booking.fromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      print('[BookingService] getBookingById error: ${e.message}');
      if (e.response != null) {
        print('[BookingService] Error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

  Future<Booking?> deleteBookingById(String id) async {
    try {
      print('[BookingService] DELETE /Booking/$id');
      final response = await _api.delete('/Booking/$id');

      if (response.statusCode == 200 && response.data != null) {
        return Booking.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('[BookingService] deleteBookingById error: ${e.message}');
      if (e.response != null) {
        print('[BookingService] Error response: ${e.response!.data}');
      }
      rethrow;
    }
  }
}
