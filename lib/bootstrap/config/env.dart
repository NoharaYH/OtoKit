import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'LXNS_CLIENT_ID', obfuscate: true)
  static final String lxnsClientId = _Env.lxnsClientId;

  @EnviedField(varName: 'LXNS_CLIENT_SECRET', obfuscate: true)
  static final String lxnsClientSecret = _Env.lxnsClientSecret;
}
