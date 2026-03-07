import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// PKCE 工具：生成 code_verifier 与 code_challenge（SHA-256 + base64url）。
/// 仅被 infrastructure 或 application 的 OAuth 流程使用。
class PkceHelper {
  PkceHelper._();

  static const _chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';

  /// 生成符合 RFC 7636 的 code_verifier（43–128 字符）。
  static String generateVerifier({int length = 128}) {
    final random = Random.secure();
    return List.generate(
      length.clamp(43, 128),
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
  }

  /// 计算 code_challenge：BASE64URL(SHA256(verifier))，无 padding。
  static String computeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
