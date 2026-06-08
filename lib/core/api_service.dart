import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Always use production API — localhost:8000 only works inside an emulator, not on real devices
  static const String baseUrl = "https://api.gaja.cash/api/v1";
  static String? token;
  static String? userId;
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    // Return response even for non-2xx status codes (don't throw, let the UI handle it)
    validateStatus: (status) => status != null && status < 500,
  ));

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> login(String phone, String password) async {
    try {
      return await _dio.post(
        '/customer/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );
    } on DioException catch (e) {
      debugPrint("Login Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> checkUser(String phone) async {
    try {
      return await _dio.post(
        '/customer/auth/check',
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      debugPrint("Check User Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? gender,
    String? dateOfBirth,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? email,
    String? idPhotoUrl,
  }) async {
    try {
      return await _dio.post(
        '/customer/auth/register',
        data: {
          'phone': phone,
          'f_name': firstName,
          'l_name': lastName,
          'password': password,
          if (gender != null) 'gender': gender,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
          if (addressLine1 != null) 'address_line1': addressLine1,
          if (addressLine2 != null) 'address_line2': addressLine2,
          if (city != null) 'city': city,
          if (email != null) 'email': email,
          if (idPhotoUrl != null) 'id_photo_url': idPhotoUrl,
        },
      );
    } on DioException catch (e) {
      debugPrint("Registration Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> sendOtp(String phone) async {
    try {
      return await _dio.post(
        '/customer/auth/otp/send',
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      debugPrint("OTP Send Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> verifyOtp(String phone, String otp) async {
    try {
      return await _dio.post(
        '/customer/auth/otp/verify',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      debugPrint("OTP Verify Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> processTransfer({required String recipientId, required double amount, required String method}) async {
    try {
      return await _dio.post(
        '/transfer/process',
        data: {
          'recipient_id': recipientId,
          'amount': amount,
          'method': method,
        },
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      debugPrint("Transfer Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> vendorCashout({required double amount, required String bankAccountId}) async {
    try {
      return await _dio.post(
        '/vendor/cashout',
        data: {
          'amount': amount,
          'bank_account_id': bankAccountId,
        },
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      debugPrint("Cashout Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> getBalance(String userId) async {
    try {
      return await _dio.get(
        '/wallets/$userId/balance',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      debugPrint("Get Balance Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> getUserProfile(String userId) async {
    try {
      return await _dio.get(
        '/users/$userId',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      debugPrint("Get Profile Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      return await _dio.post(
        '/users/upload',
        data: formData,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      debugPrint("File Upload Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> createAgentKYC(Map<String, dynamic> data) async {
    try {
      return await _dio.post(
        '/users/agent-kyc',
        data: data,
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      debugPrint("Create Agent KYC Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<Response> getAgentKYC(String userId) async {
    try {
      return await _dio.get(
        '/users/agent-kyc/$userId',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      debugPrint("Get Agent KYC Error: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }
}
