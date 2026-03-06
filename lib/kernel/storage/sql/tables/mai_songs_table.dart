import 'package:drift/drift.dart';

/// 普通曲表（仅 basic info + charts）
@DataClassName('MaiMusicTableData')
class MaiMusicTable extends Table {
  @override
  String get tableName => 'mai_music_data';

  IntColumn get id => integer()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get artist => text()();
  IntColumn get bpm => integer()();
  TextColumn get type => text()();
  TextColumn get genre => text()();
  TextColumn get versionText => text()();
  IntColumn get versionId => integer()();
  TextColumn get chartsJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 宴谱表（仅 basic info + utage_info + utage_charts，无 isBuddy）
@DataClassName('MaiUtageTableData')
class MaiUtageTable extends Table {
  @override
  String get tableName => 'mai_utage_data';

  IntColumn get id => integer()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get artist => text()();
  IntColumn get bpm => integer()();
  TextColumn get type => text()();
  TextColumn get versionText => text()();
  IntColumn get versionId => integer()();
  TextColumn get utageInfoJson => text()();
  TextColumn get utageChartsJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
