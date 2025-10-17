import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../model/booking_request.dart';
import '../model/booking_response.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _repository;

  bool isLoading = false;
  String? error;
  List<Booking> bookings = [];
  Booking? createdBooking;

  BookingProvider(this._repository);

  // ==========================
  // CREATE BOOKING
  // ==========================
  Future<bool> createBooking(BookingRequest request) async {
    setIsLoading(true);
    bool success = false;
    try {
      final response = await _repository.createBooking(request);
      if (response != null) {
        createdBooking = response;
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

  // ==========================
  // GET BOOKINGS BY CUSTOMER
  // ==========================
  Future<void> fetchBookingsByCustomer(String customerId) async {
    setIsLoading(true);
    try {
      final response = await _repository.getBookingsByCustomer(customerId);
      bookings = response;
      error = null;
    } on DioException catch (e) {
      error = _handleError(e);
    } catch (e) {
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
  }

  // ==========================
  // GET ALL BOOKINGS (Admin / Technician)
  // ==========================
  Future<void> fetchAllBookings() async {
    setIsLoading(true);
    try {
      final response = await _repository.getAllBookings();
      bookings = response;
      error = null;
    } on DioException catch (e) {
      error = _handleError(e);
    } catch (e) {
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
  }

  // ==========================
  // ASSIGN STAFF TO BOOKING
  // ==========================
  Future<bool> assignStaff(String bookingId, String staffId) async {
    setIsLoading(true);
    bool success = false;
    try {
      success = await _repository.assignStaff(bookingId, staffId);
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

  // ==========================
  // GET BOOKING BY ID
  // ==========================
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

  // ==========================
  // STATE HELPERS
  // ==========================
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

  // ==========================
  // HANDLE DIO ERRORS
  // ==========================
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
