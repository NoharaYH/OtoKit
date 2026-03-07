import 'dart:async';
import 'dart:io';

/// 本地 OAuth 回调 HTTP 服务器，监听一次请求后返回 code 并关闭。
/// 仅被 infrastructure 或 application 的 OAuth 流程使用。
class OAuthCallbackServer {
  /// 在 [port] 上绑定，监听 [callbackPath] 的 GET 请求，从 query 取 code；
  /// 超时 [timeout] 后未收到则返回 null。
  Future<String?> waitForCode({
    required int port,
    required String callbackPath,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      port,
      shared: true,
    );
    final completer = Completer<String?>();
    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
    server.listen((HttpRequest request) async {
      if (!completer.isCompleted && request.uri.path == callbackPath) {
        final code = request.uri.queryParameters['code'];
        completer.complete(code);
      }
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(
          '<meta charset="utf-8"><body><h2 style="text-align:center;margin-top:50px;">授权成功！您可以关闭此网页并返回应用。</h2></body>',
        );
      await request.response.close();
    });
    try {
      return await completer.future;
    } finally {
      await server.close(force: true);
    }
  }
}
