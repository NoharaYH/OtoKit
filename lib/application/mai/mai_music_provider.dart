import 'package:flutter/material.dart';
import '../../logic/mai_music_data/library/mai_library.dart';
import '../../logic/mai_music_data/data_sync/mai_sync_handler.dart';
import '../../logic/mai_music_data/data_formats/mai_music.dart';
import '../../logic/mai_music_data/data_formats/mai_song_row.dart';

class MaiMusicProvider extends ChangeNotifier {
  final MaiLibrary _library = MaiLibrary();
  final MaiSyncHandler _syncHandler = MaiSyncHandler();

  bool _isInitialized = false;
  bool _isLoading = false;
  SyncPhase _syncPhase = SyncPhase.idle;
  int _syncCurrent = 0;
  int _syncTotal = 0;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  SyncPhase get syncPhase => _syncPhase;
  int get syncCurrent => _syncCurrent;
  int get syncTotal => _syncTotal;
  bool get hasData => _library.musics.isNotEmpty;
  // TODO(SQLite): musics 将改为从 DAO Stream 消费，此处为过渡占位
  List<MaiMusic> get musics => _library.musics;

  /// 初始化：检查本地是否有缓存
  Future<void> init() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    await _library.initialize();

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  /// 手动执行同步
  Future<void> sync() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final newSongs = await _syncHandler.performSync(
        force: true,
        onPhaseChanged: (phase) {
          _syncPhase = phase;
          notifyListeners();
        },
        onProgress: (current, total) {
          _syncCurrent = current;
          _syncTotal = total;
          notifyListeners();
        },
      );
      if (newSongs != null) {
        // TODO(SQLite): 将 newSongs (List<MaiSongRow>) 写入 DAO 批量插入 SQLite
        // await _maiMusicDao.batchInsert(newSongs);
        // 以下 MaiLibrary 调用为过渡期临时兼容，待 DAO 层完成后移除
      }
    } finally {
      _isLoading = false;
      _syncPhase = SyncPhase.idle;
      _syncCurrent = 0;
      _syncTotal = 0;
      notifyListeners();
    }
  }

  /// 搜索
  // TODO(SQLite): search 将改为调用 DAO 的 watchSongs(keyword) 流式查询
  List<MaiMusic> search(String query) => _library.search(query);
}
