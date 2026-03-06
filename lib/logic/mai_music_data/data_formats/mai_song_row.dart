import 'dart:convert';

/// 普通曲持久化行（仅写入 mai_music_data）
class MaiMusicRow {
  final int id;
  final String title;
  final String artist;
  final int bpm;
  final String type; // SD or DX
  final String genre;
  final String versionText;
  final int versionId;
  final String chartsJson;

  const MaiMusicRow({
    required this.id,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.type,
    required this.genre,
    required this.versionText,
    required this.versionId,
    required this.chartsJson,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'bpm': bpm,
        'type': type,
        'genre': genre,
        'version_text': versionText,
        'version_id': versionId,
        'charts_json': chartsJson,
      };
}

/// 宴谱持久化行（仅写入 mai_utage_data，无 isBuddy）
class MaiUtageRow {
  final int id;
  final String title;
  final String artist;
  final int bpm;
  final String type;
  final String versionText;
  final int versionId;
  final String utageInfoJson;
  final String utageChartsJson;

  const MaiUtageRow({
    required this.id,
    required this.title,
    required this.artist,
    required this.bpm,
    required this.type,
    required this.versionText,
    required this.versionId,
    required this.utageInfoJson,
    required this.utageChartsJson,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'bpm': bpm,
        'type': type,
        'version_text': versionText,
        'version_id': versionId,
        'utage_info_json': utageInfoJson,
        'utage_charts_json': utageChartsJson,
      };
}

// =============================================================================
// Charts（普通谱面块）
// =============================================================================

class MaiChartRow {
  final int difficulty;
  final String levelLabel;
  final String level;
  final double constant;
  final String designer;
  final int notesTap;
  final int notesHold;
  final int notesSlide;
  final int notesTouch;
  final int notesBreak;
  final int notesTotal;

  const MaiChartRow({
    required this.difficulty,
    required this.levelLabel,
    required this.level,
    required this.constant,
    required this.designer,
    required this.notesTap,
    required this.notesHold,
    required this.notesSlide,
    required this.notesTouch,
    required this.notesBreak,
    required this.notesTotal,
  });

  Map<String, dynamic> toMap() => {
        'difficulty': difficulty,
        'label': levelLabel,
        'level': level,
        'constant': constant,
        'designer': designer,
        'tap': notesTap,
        'hold': notesHold,
        'slide': notesSlide,
        'touch': notesTouch,
        'break': notesBreak,
        'total': notesTotal,
      };
}

String encodeCharts(List<MaiChartRow> charts) {
  return jsonEncode(charts.map((c) => c.toMap()).toList());
}

// =============================================================================
// Utage Info（宴谱信息块，无 isBuddy）
// =============================================================================

class UtageInfoRow {
  final String level;
  final String type;
  final String commit;
  final String skipCondition;
  final List<int> playerCount;

  const UtageInfoRow({
    required this.level,
    required this.type,
    required this.commit,
    required this.skipCondition,
    required this.playerCount,
  });

  Map<String, dynamic> toMap() => {
        'level': level,
        'type': type,
        'commit': commit,
        'skip_condition': skipCondition,
        'player_count': playerCount,
      };
}

String encodeUtageInfo(UtageInfoRow info) {
  return jsonEncode(info.toMap());
}

// =============================================================================
// Utage Charts（宴谱面块）
// =============================================================================

class UtageChartRow {
  final String? sides;
  final int notesTap;
  final int notesHold;
  final int notesSlide;
  final int notesTouch;
  final int notesBreak;
  final int notesTotal;

  const UtageChartRow({
    this.sides,
    required this.notesTap,
    required this.notesHold,
    required this.notesSlide,
    required this.notesTouch,
    required this.notesBreak,
    required this.notesTotal,
  });

  Map<String, dynamic> toMap() => {
        'sides': sides,
        'notes': {
          'tap': notesTap,
          'hold': notesHold,
          'slide': notesSlide,
          'touch': notesTouch,
          'break': notesBreak,
          'total': notesTotal,
        },
      };
}

String encodeUtageCharts(List<UtageChartRow> charts) {
  return jsonEncode(charts.map((c) => c.toMap()).toList());
}
