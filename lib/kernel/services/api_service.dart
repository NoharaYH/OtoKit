import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/endpoints.dart';
import '../config/system_config.dart';
import '../config/maimai_config.dart';
import '../config/chunithm_config.dart';

@lazySingleton
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Validate Diving Fish Token (Read-Only)
  Future<bool> validateDivingFishToken(String token) async {
    try {
      final response = await _dio.get(
        Endpoints.dfMaimaiRecords,
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
      final String playerPath = gameType == 0
          ? MaimaiConfig.lxnsPlayerPath
          : ChunithmConfig.lxnsPlayerPath;
      final response = await _dio.get(
        "${Endpoints.lxnsBaseUrl}/$playerPath",
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
        Endpoints.lxnsTokenExchange,
        data: {
          "grant_type": "authorization_code",
          "client_id": clientId,
          "code": code,
          "code_verifier": codeVerifier,
          "redirect_uri": SystemConfig.oauthRedirectUri,
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
        Endpoints.lxnsTokenExchange,
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

  // Upload Maimai JSON Records to Diving Fish
  Future<Map<String, dynamic>?> uploadMaimaiRecords(
    String token,
    List<Map<String, dynamic>> records,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.dfMaimaiUpload,
        data: records,
        options: Options(
          headers: {"Import-Token": token},
          contentType: "application/json",
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      if (e is DioException) {
        print("[API] Diving Fish Upload Error: ${e.response?.data}");
      } else {
        print("[API] Diving Fish Upload Error: $e");
      }
    }
    return null;
  }
}
