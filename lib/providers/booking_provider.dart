import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../model/dto/request/booking_request.dart';
import '../model/dto/response/booking_response.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _repository;

  bool isLoading = false;
  String? error;
  List<Booking> bookings = [];
  Booking? createdBooking;
  String? lastMessage;
  BookingProvider(this._repository);

  Future<BookingResponse?> createBooking(BookingRequest request) async {
    setIsLoading(true);
    try {
      final response = await _repository.createBooking(request);
      return response;
    } on DioException catch (e) {
      error = _handleError(e);
    } catch (e) {
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
    return null;
  }

  Future<void> fetchBookingsByCustomer(String customerId) async {
    // Prevent multiple simultaneous calls
    if (isLoading) {
      print('[BookingProvider] Already loading, skipping duplicate request');
      return;
    }

    print('[BookingProvider] Fetching bookings for customer: $customerId');
    setIsLoading(true);
    try {
      final response = await _repository.getBookingsByCustomer(customerId);
      bookings = response;
      print('[BookingProvider] Loaded ${bookings.length} bookings');
      error = null;
    } on DioException catch (e) {
      print('[BookingProvider] DioException: ${e.message}');
      error = _handleError(e);
    } catch (e) {
      print('[BookingProvider] General error: $e');
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
  }

  Future<Booking?> getBookingById(String id) async {
    setIsLoading(true);
    Booking? result;
    try {
      result = await _repository.getBookingById(id);
      error = null;
    } on DioException catch (e) {
      error = _handleError(e);
    } catch (e) {
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
    return result;
  }

  Future<bool> deleteBooking(String id) async {
    setIsLoading(true);
    bool success = false;
    try {
      final result = await _repository.deleteBookingById(id);
      if (result != null) {
        bookings.removeWhere((booking) => booking.bookingId == id);
        success = true;
      }
      error = null;
    } on DioException catch (e) {
      error = _handleError(e);
    } catch (e) {
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
    return success;
  }

  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      if (e.response!.data is Map<String, dynamic> &&
          e.response!.data['message'] != null) {
        return e.response!.data['message'].toString();
      } else {
        return e.response!.data.toString();
      }
    }
    return e.message ?? "Lỗi kết nối server.";
  }
}
