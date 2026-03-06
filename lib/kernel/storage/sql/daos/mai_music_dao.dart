import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../../../logic/mai_music_data/data_formats/mai_song_row.dart';
import '../tables/mai_songs_table.dart';
import '../app_database.dart';

part 'mai_music_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [MaiMusicTable, MaiUtageTable])
class MaiMusicDao extends DatabaseAccessor<AppDatabase> with _$MaiMusicDaoMixin {
  MaiMusicDao(super.db);

  /// 批量插入普通曲（仅写 mai_music_data）
  Future<void> batchInsertNormal(List<MaiMusicRow> rows) async {
    await batch((batch) {
      for (final row in rows) {
        batch.insert(
          maiMusicTable,
          MaiMusicTableCompanion.insert(
            id: Value(row.id),
            title: row.title,
            artist: row.artist,
            bpm: row.bpm,
            type: row.type,
            genre: row.genre,
            versionText: row.versionText,
            versionId: row.versionId,
            chartsJson: row.chartsJson,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// 批量插入宴谱（仅写 mai_utage_data）
  Future<void> batchInsertUtage(List<MaiUtageRow> rows) async {
    await batch((batch) {
      for (final row in rows) {
        batch.insert(
          maiUtageTable,
          MaiUtageTableCompanion.insert(
            id: Value(row.id),
            title: row.title,
            artist: row.artist,
            bpm: row.bpm,
            type: row.type,
            versionText: row.versionText,
            versionId: row.versionId,
            utageInfoJson: row.utageInfoJson,
            utageChartsJson: row.utageChartsJson,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// 监听普通曲库流
  Stream<List<MaiMusicTableData>> watchSongs({String? query}) {
    final search = query?.trim().toLowerCase() ?? '';
    if (search.isEmpty) {
      return (select(maiMusicTable)
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .watch();
    }
    return (select(maiMusicTable)
          ..where((t) => t.title.contains(search))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .watch();
  }

  /// 监听宴谱流
  Stream<List<MaiUtageTableData>> watchUtageSongs({String? query}) {
    final search = query?.trim().toLowerCase() ?? '';
    if (search.isEmpty) {
      return (select(maiUtageTable)
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .watch();
    }
    return (select(maiUtageTable)
          ..where((t) => t.title.contains(search))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .watch();
  }

  /// 统计普通曲数量
  Future<int> countSongs() async {
    final countExp = maiMusicTable.id.count();
    final query = selectOnly(maiMusicTable)..addColumns([countExp]);
    return (await query.map((row) => row.read(countExp)).getSingle()) ?? 0;
  }

  /// 统计宴谱数量
  Future<int> countUtageSongs() async {
    final countExp = maiUtageTable.id.count();
    final query = selectOnly(maiUtageTable)..addColumns([countExp]);
    return (await query.map((row) => row.read(countExp)).getSingle()) ?? 0;
  }
}
