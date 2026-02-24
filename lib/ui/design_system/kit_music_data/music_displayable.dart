// lib/ui/design_system/kit_music_data/music_displayable.dart

/// 表现层歌曲协议
/// 用于解耦逻辑层 MaiMusic 与 UI 层 KitMusicCard
abstract class IKitMusicItem {
  String get title;
  String get artist;
  String get type; // SD or DX
  int get id;
}
