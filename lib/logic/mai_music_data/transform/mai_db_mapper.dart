import 'dart:convert';
import '../../../kernel/storage/sql/app_database.dart';
import '../data_formats/mai_music.dart';

/// Drift 表行 → 业务模型 MaiMusic。
/// [fromTable] 普通曲表，[fromUtageTable] 宴谱表。
class MaiDbMapper {
  static MaiMusic fromTable(MaiMusicTableData table) {
    return MaiMusic(
      basicInfo: MaiBasicInfo(
        id: table.id,
        title: table.title,
        artist: table.artist,
        bpm: table.bpm,
        type: table.type,
        genre: table.genre,
        version: MaiVersionInfo(text: table.versionText, id: table.versionId),
        isUtage: false,
      ),
      charts: _parseChartsJson(table.chartsJson),
      utageInfo: null,
      utageCharts: [],
    );
  }

  static MaiMusic fromUtageTable(MaiUtageTableData table) {
    return MaiMusic(
      basicInfo: MaiBasicInfo(
        id: table.id,
        title: table.title,
        artist: table.artist,
        bpm: table.bpm,
        type: table.type,
        genre: '宴会场',
        version: MaiVersionInfo(text: table.versionText, id: table.versionId),
        isUtage: true,
      ),
      charts: [],
      utageInfo: _parseUtageInfo(table.utageInfoJson),
      utageCharts: _parseUtageChartsJson(table.utageChartsJson),
    );
  }

  static List<MaiChart> _parseChartsJson(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((item) {
      return MaiChart(
        difficulty: item['difficulty'],
        level: item['level'],
        levelLabel: item['label'],
        constant: (item['constant'] as num).toDouble(),
        designer: item['designer'],
        notes: MaiNotes(
          total: item['total'],
          tap: item['tap'],
          hold: item['hold'],
          slide: item['slide'],
          touch: item['touch'],
          breakNote: item['break'],
        ),
      );
    }).toList();
  }

  static MaiUtageInfo _parseUtageInfo(String jsonStr) {
    final Map<String, dynamic> m = jsonDecode(jsonStr);
    return MaiUtageInfo(
      level: m['level'] ?? '',
      type: m['type'] ?? '',
      commit: m['commit'] ?? '',
      skipCondition: m['skip_condition'] ?? '',
      playerCount: (m['player_count'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
    );
  }

  static List<MaiUtageChart> _parseUtageChartsJson(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((item) {
      final notes = item['notes'] as Map<String, dynamic>;
      return MaiUtageChart(
        sides: item['sides'] as String?,
        notes: MaiNotes(
          total: notes['total'],
          tap: notes['tap'],
          hold: notes['hold'],
          slide: notes['slide'],
          touch: notes['touch'],
          breakNote: notes['break'],
        ),
      );
    }).toList();
  }
}
