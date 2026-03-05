import '../data_formats/mai_song_row.dart';

enum SyncPhase { idle, pulling, writing }

class MaiOssSyncHandler {
  // TODO: 替换为实际的 OSS/CDN 地址
  static const String ossUrl = '';

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// 从 OSS 拉取合并后的曲库 JSON，解析为 [MaiSongRow] 列表后返回。
  /// URL 未配置或拉取失败时返回 null。
  Future<List<MaiSongRow>?> performSync({
    void Function(SyncPhase)? onPhaseChanged,
  }) async {
    if (_isSyncing) return null;
    _isSyncing = true;
    onPhaseChanged?.call(SyncPhase.pulling);
    try {
      // TODO: HTTP GET ossUrl
      //   final response = await dio.get(ossUrl);
      //   final list = response.data as List<dynamic>;
      //   onPhaseChanged?.call(SyncPhase.writing);
      //   return list.map((e) => MaiSongRow.fromMap(e as Map<String, dynamic>)).toList();
      return null;
    } finally {
      _isSyncing = false;
      onPhaseChanged?.call(SyncPhase.idle);
    }
  }
}
