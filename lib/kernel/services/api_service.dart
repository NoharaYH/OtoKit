import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Validate Diving Fish Token (Read-Only)
  Future<bool> validateDivingFishToken(String token) async {
    try {
      final response = await _dio.get(
        "https://www.diving-fish.com/api/maimaidxprober/player/records",
        options: Options(
          headers: {"Import-Token": token},
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Validate LXNS Token (Read-Only)
  Future<bool> validateLxnsToken(String token) async {
    try {
      final response = await _dio.get(
        "https://maimai.lxns.net/api/v0/maimai/player",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // LXNS OAuth Exchange Code for Token
  Future<Map<String, dynamic>?> exchangeLxnsCode(
    String code,
    String clientId,
    String codeVerifier,
  ) async {
    try {
      final response = await _dio.post(
        "https://maimai.lxns.net/api/v0/oauth/token",
        data: {
          "grant_type": "authorization_code",
          "client_id": clientId,
          "code": code,
          "code_verifier": codeVerifier,
          "redirect_uri": "https://app.otokit.com/oauth/callback",
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("[API] LXNS OAuth Exchange Error: $e");
    }
    return null;
  }

  // LXNS OAuth Refresh Token
  Future<Map<String, dynamic>?> refreshLxnsToken(
    String refreshToken,
    String clientId,
  ) async {
    try {
      final response = await _dio.post(
        "https://maimai.lxns.net/api/v0/oauth/token",
        data: {
          "grant_type": "refresh_token",
          "client_id": clientId,
          "refresh_token": refreshToken,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("[API] LXNS OAuth Refresh Error: $e");
    }
    return null;
  }
}
