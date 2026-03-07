import 'package:injectable/injectable.dart';

import '../../../domain/repositories/transfer_repository.dart';
import '../../../shared/errors/network_exception.dart';
import '../../../shared/result/result.dart';
import '../../network/clients/divingfish_api_client.dart';

@lazySingleton
class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._divingFish);

  final DivingFishApiClient _divingFish;

  @override
  Future<Result<void, NetworkException>> uploadMaimaiRecords(
    String token,
    List<Map<String, dynamic>> records,
  ) async {
    return _divingFish.uploadMaimaiRecords(token, records);
  }
}
