import 'dart:isolate';
import '../../../network/mai_api/mai_client.dart';
import '../transform/mai_transformer.dart';
import '../data_formats/mai_song_row.dart';
import '../../../kernel/services/storage_service.dart';
import '../../../kernel/di/injection.dart';

enum SyncPhase { idle, pulling, merging }

class MaiSyncHandler {
  static const String kMaiDataFingerprint = 'mai_data_fingerprint';
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// 核心同步任务：包含指纹校验守门员逻辑
  ///
  /// - 返回值变更: List<MaiMusic>? → List<MaiSongRow>?
  ///   调用方收到结果后应立即调用 DAO 将行数据批量写入 SQLite，不得持有在内存中。
  /// - Transformer 被包裹在 [Isolate.run] 内运行，保证主线程零阻塞。
  Future<List<MaiSongRow>?> performSync({
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
      final String latestFingerprint = versions.isNotEmpty
          ? versions.last['id'].toString()
          : 'unknown';

      // 2. 导出本地指纹进行对比
      if (!force) {
        final localFingerprint = await storage.read(kMaiDataFingerprint);
        if (localFingerprint == latestFingerprint) {
          return null;
        }
      }

      // 3. 指纹不一致或强制更新，并行拉取双端全量原始数据
      final results = await Future.wait([
        client.fetchDivingFishRaw(),
        client.fetchLxnsRaw(),
      ]);

      // 4. Transformer 全程在独立 Isolate 内运行，主线程无感知
      onPhaseChanged?.call(SyncPhase.merging);
      final List<MaiSongRow> rows = await Isolate.run(() async {
        return await MaiTransformer.transform(
          results[0],
          results[1],
          onProgress: onProgress,
        );
      });

      // 5. 同步成功后，更新本地指纹
      await storage.save(kMaiDataFingerprint, latestFingerprint);

      // 6. 返回扁平行列表，由调用方负责写入 SQLite
      return rows;
    } catch (e) {
      rethrow;
    } finally {
      client.dispose();
      _isSyncing = false;
    }
  }
}
