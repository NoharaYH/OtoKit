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
  Future<bool> validateLxnsToken(String token, {int gameType = 0}) async {
    try {
      final String game = gameType == 0 ? "maimai" : "chunithm";
      final response = await _dio.get(
        "https://maimai.lxns.net/api/v0/user/$game/player",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode == 200) {
        final body = response.data;
        return body is Map<String, dynamic> && body['success'] == true;
      }
    } catch (e) {
      print("[API] Validate LXNS Token Error: $e");
    }
    return false;
  }

  // LXNS OAuth Exchange Code for Token (PKCE, no client_secret)
  Future<Map<String, dynamic>?> exchangeLxnsCode(
    String code,
    String clientId,
    String clientSecret,
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
          "redirect_uri": "http://127.0.0.1:34125/oauth/callback",
        },
      );
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['data'] is Map) {
          return body['data'] as Map<String, dynamic>;
        }
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
    String clientSecret,
  ) async {
    try {
      final response = await _dio.post(
        "https://maimai.lxns.net/api/v0/oauth/token",
        data: {
          "grant_type": "refresh_token",
          "client_id": clientId,
          "client_secret": clientSecret,
          "refresh_token": refreshToken,
        },
      );
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['data'] is Map) {
          return body['data'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("[API] LXNS OAuth Refresh Error: $e");
    }
    return null;
  }
}
