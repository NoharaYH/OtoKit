import 'dart:async';
import 'package:flutter/material.dart';
import '../di/injection.dart';
import '../storage/sql/daos/mai_music_dao.dart';
import '../../logic/mai_music_data/data_sync/mai_oss_sync_handler.dart';
import '../../logic/mai_music_data/data_formats/mai_music.dart';
import '../../logic/mai_music_data/transform/mai_db_mapper.dart';

class MaiMusicProvider extends ChangeNotifier {
  final _syncHandler = MaiOssSyncHandler();
  final _maiMusicDao = getIt<MaiMusicDao>();

  StreamSubscription? _musicSubscription;
  StreamSubscription? _utageSubscription;

  List<MaiMusic> _musics = [];
  List<MaiMusic> _utageMusics = [];

  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get hasData => _musics.isNotEmpty;
  List<MaiMusic> get musics => _musics;
  List<MaiMusic> get utageMusics => _utageMusics;

  @override
  void dispose() {
    _musicSubscription?.cancel();
    _utageSubscription?.cancel();
    super.dispose();
  }

  /// 初始化：订阅普通曲库流与宴谱流
  Future<void> init() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    _musicSubscription = _maiMusicDao.watchSongs().listen((rows) {
      _musics = rows.map((r) => MaiDbMapper.fromTable(r)).toList();
      _checkInitialized();
    });

    _utageSubscription = _maiMusicDao.watchUtageSongs().listen((rows) {
      _utageMusics = rows.map((r) => MaiDbMapper.fromUtageTable(r)).toList();
      _checkInitialized();
    });
  }

  void _checkInitialized() {
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  /// 从 OSS 拉取两个 JSON 并分别写入两表
  Future<void> sync() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _syncHandler.performSync();
      if (result != null) {
        if (result.normal != null && result.normal!.isNotEmpty) {
          await _maiMusicDao.batchInsertNormal(result.normal!);
        }
        if (result.utage != null && result.utage!.isNotEmpty) {
          await _maiMusicDao.batchInsertUtage(result.utage!);
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索普通曲
  List<MaiMusic> search(String query) {
    if (query.isEmpty) return _musics;
    final search = query.toLowerCase();
    return _musics
        .where(
          (m) =>
              m.basicInfo.title.toLowerCase().contains(search) ||
              m.basicInfo.id.toString() == search,
        )
        .toList();
  }

  /// 搜索宴谱
  List<MaiMusic> searchUtage(String query) {
    if (query.isEmpty) return _utageMusics;
    final search = query.toLowerCase();
    return _utageMusics
        .where(
          (m) =>
              m.basicInfo.title.toLowerCase().contains(search) ||
              m.basicInfo.id.toString() == search,
        )
        .toList();
  }
}
