import 'package:dio/dio.dart';
import 'package:prm_project/model/booking_request.dart';
import 'package:prm_project/model/booking_response.dart';
import 'package:prm_project/services/api_service.dart';

class BookingService {
  final ApiService _api = ApiService();

  /// Tạo mới một booking
  Future<Booking?> createBooking(BookingRequest request) async {
    try {
      print(
        '[BookingService] Sending POST /Bookings with: ${request.toJson()}',
      );
      final response = await _api.post('/Bookings', request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[BookingService] Booking created: ${response.data}');
        return Booking.fromJson(response.data);
      } else {
        print(
          '[BookingService] Unexpected status code: ${response.statusCode}',
        );
        return null;
      }
    } on DioException catch (e) {
      print('[BookingService] createBooking error: ${e.message}');
      if (e.response != null) {
        print('[BookingService] Error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

  /// Lấy danh sách booking của khách hàng
  Future<List<Booking>> getBookingsByCustomer(String customerId) async {
    try {
      print(
        '[BookingService] Fetching GET /Bookings/customer?customerId=$customerId',
      );
      final response = await _api.get(
        '/Bookings/customer',
        queryParameters: {'customerId': customerId},
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        final bookings = data.map((e) => Booking.fromJson(e)).toList();
        print('[BookingService] Found ${bookings.length} bookings');
        return bookings;
      }
      return [];
    } on DioException catch (e) {
      print('[BookingService] getBookingsByCustomer error: ${e.message}');
      if (e.response != null) {
        print('[BookingService] Error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

  /// Lấy tất cả bookings (hữu ích cho admin / list view)
  /// Có thể truyền queryParams như: {'status': 'pending', 'page': 1, 'limit': 20}
  Future<List<Booking>> getAllBookings({
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      print(
        '[BookingService] Fetching GET /Bookings (all) with params: $queryParams',
      );
      final response = await _api.get(
        '/Bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // response.data có thể là list hoặc object { data: [...], meta: {...} }
        if (response.data is List) {
          final data = response.data as List;
          return data.map((e) => Booking.fromJson(e)).toList();
        } else if (response.data is Map && response.data['data'] is List) {
          final data = response.data['data'] as List;
          return data.map((e) => Booking.fromJson(e)).toList();
        } else {
          print(
            '[BookingService] Unexpected GET /Bookings response shape: ${response.data}',
          );
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('[BookingService] getAllBookings error: ${e.message}');
      if (e.response != null) {
        print('[BookingService] Error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

  /// Lấy chi tiết một booking theo ID
  Future<Booking?> getBookingById(String id) async {
    try {
      print('[BookingService] GET /Bookings/$id');
      final response = await _api.get('/Bookings/$id');

      if (response.statusCode == 200 && response.data != null) {
        return Booking.fromJson(response.data);
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

  /// Gán kỹ thuật viên cho booking
  Future<bool> assignStaff(String bookingId, String staffId) async {
    try {
      print('[BookingService] PATCH /Bookings/$bookingId/assign/$staffId');
      // Nếu ApiService.patch yêu cầu 2 tham số (path, data), truyền null nếu không có body
      final response = await _api.patch(
        '/Bookings/$bookingId/assign/$staffId',
        null,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print('[BookingService] assignStaff error: ${e.message}');
      if (e.response != null) {
        print('[BookingService] Error response: ${e.response!.data}');
      }
      return false;
    }
  }
}
