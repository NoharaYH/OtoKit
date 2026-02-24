import '../../../network/mai_api/mai_client.dart';
import '../transform/mai_transformer.dart';
import '../data_formats/mai_music.dart';
import '../../../kernel/services/storage_service.dart';
import '../../../kernel/di/injection.dart';

enum SyncPhase { idle, pulling, merging }

class MaiSyncHandler {
  static const String kMaiDataFingerprint = 'mai_data_fingerprint';
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// 核心同步任务：包含指纹校验守门员逻辑
  Future<List<MaiMusic>?> performSync({
    bool force = false,
    void Function(SyncPhase)? onPhaseChanged,
    void Function(int current, int total)? onProgress,
  }) async {
    if (_isSyncing) return null;
    _isSyncing = true;
    onPhaseChanged?.call(SyncPhase.pulling);

    final client = MaiClient();
    final storage = getIt<StorageService>();

    try {
      // 1. 获取最新版本指纹 (使用落雪的 version/list 作为参考)
      final versions = await client.fetchVersions();
      // 取最新的一个版本 ID 作为指纹
      final String latestFingerprint = versions.isNotEmpty
          ? versions.last['id'].toString()
          : 'unknown';

      // 2. 导出本地指纹进行对比
      if (!force) {
        final localFingerprint = await storage.read(kMaiDataFingerprint);
        if (localFingerprint == latestFingerprint) {
          // 指纹一致，说明数据没更新，优雅退出
          return null;
        }
      }

      // 3. 指纹不一致或强制更新，开始拉取全量原始数据
      final results = await Future.wait([
        client.fetchDivingFishRaw(),
        client.fetchLxnsRaw(),
      ]);

      // 4. 使用 Transformer 进行变形转换
      onPhaseChanged?.call(SyncPhase.merging);
      final refined = await MaiTransformer.transform(
        results[0],
        results[1],
        onProgress: onProgress,
      );

      // 5. 同步成功后，更新本地指纹
      await storage.save(kMaiDataFingerprint, latestFingerprint);

      return refined;
    } catch (e) {
      rethrow;
    } finally {
      client.dispose();
      _isSyncing = false;
    }
  }
}
