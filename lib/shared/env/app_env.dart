import '../config/transfer_game_config.dart';

/// 运行时环境配置接口，供 infrastructure 与 application 使用。
/// 实现放在 kernel/config（ProdEnv），由 DI 注册。
abstract class AppEnv {
  String get lxnsClientId;
  String get lxnsClientSecret;
  String get oauthRedirectUri;
  int get oauthPort;
  String get oauthCallbackPath;
  String get oauthScope;
  String get oauthDeepLinkHost;
  String get proxyBaseUrl;
  String get lxnsBaseUrl;
  String get lxnsAuthorizeUrl;
  String get lxnsTokenExchangeUrl;
  String get divingFishBaseUrl;
  String get wahlapAuthBaseUrl;

  /// gameType: 0 = maimai, 1 = chunithm
  TransferGameConfig getTransferConfig(int gameType);
}
