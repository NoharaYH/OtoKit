import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/repositories/vpn_repository.dart';
import '../../domain/services/html_record_parser.dart';
import '../../infrastructure/native/channel/vpn_channel_gateway.dart';
import '../../infrastructure/parsers/maimai_html_parser_impl.dart';
import '../../infrastructure/storage/repositories_impl/auth_repository_impl.dart';
import '../../infrastructure/storage/repositories_impl/transfer_repository_impl.dart';
import '../config/prod_env.dart';
import '../../shared/env/app_env.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  getIt.init();
  getIt.registerLazySingleton<VpnRepository>(() => getIt<VpnChannelGateway>());
  getIt.registerLazySingleton<AppEnv>(() => getIt<ProdEnv>());
  getIt.registerLazySingleton<AuthRepository>(
    () => getIt<AuthRepositoryImpl>(),
  );
  getIt.registerLazySingleton<TransferRepository>(
    () => getIt<TransferRepositoryImpl>(),
  );
  getIt.registerLazySingleton<HtmlRecordParser>(
    () => getIt<MaimaiHtmlParserImpl>(),
  );
}
