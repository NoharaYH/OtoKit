# MaimaiData 架构参考 (OTOKiT 当前配置)

本文档描述 OTOKiT 项目内**曲库与宴谱**的数据结构、表定义、行模型及与云端数据源的对应关系。不包含桶地址与具体请求方式。

---

## 1. 数据源与表对应关系

| 云端资源     | 应用内表         | 说明 |
|--------------|------------------|------|
| 普通曲 JSON  | mai_music_data   | 仅 basic_info + charts |
| 宴谱 JSON    | mai_utage_data   | 仅 basic_info + utage_info + utage_charts，无 is_buddy |

- 曲库页消费 `mai_music_data`；宴谱页消费 `mai_utage_data`。
- 普通曲与宴谱物理分表，无交叉列。

---

## 2. 普通曲：数据格式与表结构

### 2.1 云端单条 JSON 结构（仅含 basic_info + charts）

```json
{
  "basic_info": {
    "id": 11451,
    "title": "PANDORA PARADOX",
    "artist": "TAG underground army",
    "bpm": 180,
    "type": "DX",
    "genre": "其他游戲",
    "version": {
      "text": "maimai DX",
      "id": 19000
    }
  },
  "charts": [
    {
      "difficulty": 0,
      "label": "Basic",
      "level": "6",
      "constant": 6.0,
      "designer": "---",
      "notes": {
        "total": 276,
        "tap": 202,
        "hold": 34,
        "slide": 17,
        "touch": 18,
        "break": 5
      }
    }
  ]
}
```

**表列对应：** id, title, artist, bpm, type, genre, version_text, version_id, charts_json

### 2.2 持久化行模型 MaiMusicRow

- 文件：`lib/logic/mai_music_data/data_formats/mai_song_row.dart`
- 字段：id, title, artist, bpm, type, genre, versionText, versionId, chartsJson
- charts 以 **charts_json** 单列存储（JSON 数组字符串），与 Drift 表一致。

### 2.3 charts_json 内部形状（写入表后的 JSON）

谱面数组每项为扁平对象（notes 展开到顶层），与 MaiChartRow.toMap() 一致：

```json
[
  {
    "difficulty": 0,
    "label": "Basic",
    "level": "6",
    "constant": 6.0,
    "designer": "---",
    "tap": 202,
    "hold": 34,
    "slide": 17,
    "touch": 18,
    "break": 5,
    "total": 276
  }
]
```

---

## 3. 宴谱：数据格式与表结构

### 3.1 云端单条 JSON 结构（仅含 basic_info + utage_info + utage_charts）

**宴谱侧不使用 is_buddy**（表与行模型均无该字段）。

```json
{
  "basic_info": {
    "id": 70130,
    "title": "進め！むてんかへ!!",
    "artist": "ノーポイッ!",
    "bpm": 168,
    "type": "SD",
    "genre": "宴会场",
    "version": { "text": "maimai でらっくす", "id": 19000 }
  },
  "utage_info": {
    "level": "宴等级",
    "type": "宴",
    "commit": "谱师骚话",
    "skip_condition": "",
    "player_count": [2, 2]
  },
  "utage_charts": [
    {
      "sides": "left",
      "notes": {
        "total": 336,
        "tap": 288,
        "hold": 22,
        "slide": 18,
        "touch": 0,
        "break": 8
      }
    }
  ]
}
```

**表列对应：** id, title, artist, bpm, type, version_text, version_id, utage_info_json, utage_charts_json（无 genre、无 charts_json、无 is_buddy）

### 3.2 持久化行模型 MaiUtageRow

- 文件：`lib/logic/mai_music_data/data_formats/mai_song_row.dart`
- 字段：id, title, artist, bpm, type, versionText, versionId, utageInfoJson, utageChartsJson
- 无 genre、无 chartsJson、无 isBuddy。

### 3.3 utage_info_json / utage_charts_json

- **utage_info_json**：单对象 JSON，含 level, type, commit, skip_condition, player_count。
- **utage_charts_json**：数组 JSON，每项含 sides 与 notes（total, tap, hold, slide, touch, break）。

---

## 4. SQLite 表定义 (DDL)

与 `lib/kernel/storage/sql/tables/mai_songs_table.dart` 一致。

### 4.1 mai_music_data（普通歌曲表）

```sql
CREATE TABLE mai_music_data (
    id           INTEGER  NOT NULL PRIMARY KEY,
    title        TEXT     NOT NULL,
    artist       TEXT     NOT NULL,
    bpm          INTEGER  NOT NULL,
    type         TEXT     NOT NULL,              -- 'SD' | 'DX'
    genre        TEXT     NOT NULL,
    version_text TEXT     NOT NULL,
    version_id   INTEGER  NOT NULL,
    charts_json  TEXT     NOT NULL               -- JSON 数组，谱面集合
);

CREATE INDEX IF NOT EXISTS idx_mai_music_version ON mai_music_data (version_id);
CREATE INDEX IF NOT EXISTS idx_mai_music_genre   ON mai_music_data (genre);
CREATE INDEX IF NOT EXISTS idx_mai_music_title   ON mai_music_data (title);
```

### 4.2 mai_utage_data（宴会场专项表）

无 is_buddy，无 charts_json，无 genre 列。

```sql
CREATE TABLE mai_utage_data (
    id                INTEGER  NOT NULL PRIMARY KEY,
    title             TEXT     NOT NULL,
    artist            TEXT     NOT NULL,
    bpm               INTEGER  NOT NULL,
    type              TEXT     NOT NULL,
    version_text      TEXT     NOT NULL,
    version_id        INTEGER  NOT NULL,
    utage_info_json   TEXT     NOT NULL,
    utage_charts_json TEXT     NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_mai_utage_title ON mai_utage_data (title);
```

---

## 5. 设计原则

1. **物理隔离**：普通曲与宴谱分表存储；云端提供两个独立 JSON，分别写入 mai_music_data / mai_utage_data。
2. **冗余消除**：mai_utage_data 无 genre（恒为“宴会場”）、无 charts_json、无 is_buddy。
3. **零关联 (Zero Join)**：谱面/宴谱面以 JSON 文本在主行中闭环存储；basic_info 拆成列便于筛选与排序，嵌套结构整段存 JSON。

---

## 6. 应用内消费

- **曲库页**：只查 `mai_music_data`，使用 DAO `watchSongs()`，经 `MaiDbMapper.fromTable` 转为业务模型。
- **宴谱页**：只查 `mai_utage_data`，使用 DAO `watchUtageSongs()`，经 `MaiDbMapper.fromUtageTable` 转为业务模型。
- **封面**：按 id 约定路径（如 `cover/{id}.png`），由前端拼地址与缓存策略，不写入库。

---

## 7. 相关文件索引

| 用途           | 路径 |
|----------------|------|
| Drift 表定义   | lib/kernel/storage/sql/tables/mai_songs_table.dart |
| 行模型         | lib/logic/mai_music_data/data_formats/mai_song_row.dart |
| OSS JSON 解析 | lib/logic/mai_music_data/transform/oss_json_parser.dart |
| 表行→业务模型  | lib/logic/mai_music_data/transform/mai_db_mapper.dart |
| DAO            | lib/kernel/storage/sql/daos/mai_music_dao.dart |
| 测试与 DDL 参考 | test/sql/（含 mai_songs.drift、fixtures、out） |
