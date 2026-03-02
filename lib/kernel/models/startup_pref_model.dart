/// 启动页偏好三段式路径数据模型 (HIERARCHICAL_CACHING_PLAN)
///
/// 格式：Primary:Secondary:Tertiary
/// 示例：
///   Sync:Mai:DivingFish    -> 启动直接进入 [舞萌成绩同步 - 水鱼]
///   Sync:Inherit:None      -> 启动进入成绩同步页，具体游戏以退出时为准
///   Sync:Mai:Inherit       -> 启动进入舞萌成绩同步，查分器以退出时为准
///   Detail:Chu:None        -> 启动进入 [中二节奏歌曲详情]
///   Last:None:None         -> 启动完全以退出时页面为准 (全回溯)
///
/// inherit 关键字：表示该层级从回溯缓存中继承属性，替代旧 Last 语义以避免混淆。
/// 此文件不引入任何 Flutter/UI 依赖，ONLY 为纯 Dart 数据结构。

// ── 枚举定义 ──────────────────────────────────────────────────────────────────

enum StartupPrimary {
  sync,
  detail,
  last;

  String serialize() => name[0].toUpperCase() + name.substring(1);

  static StartupPrimary parse(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'sync':
        return StartupPrimary.sync;
      case 'detail':
        return StartupPrimary.detail;
      default:
        return StartupPrimary.last;
    }
  }
}

enum StartupSecondary {
  mai,
  chu,

  /// 从回溯缓存继承游戏选择（替代旧 Last，避免与 Primary.last 混淆）
  inherit,
  none;

  String serialize() {
    if (this == StartupSecondary.inherit) return 'Inherit';
    return name[0].toUpperCase() + name.substring(1);
  }

  static StartupSecondary parse(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'mai':
        return StartupSecondary.mai;
      case 'chu':
        return StartupSecondary.chu;
      case 'inherit':
      case 'last': // 向后兼容旧存储格式
        return StartupSecondary.inherit;
      default:
        return StartupSecondary.none;
    }
  }
}

enum StartupTertiary {
  divingFish,
  luoXue,
  dual,

  /// 从回溯缓存继承查分器选择
  inherit,
  none;

  String serialize() {
    switch (this) {
      case StartupTertiary.divingFish:
        return 'DivingFish';
      case StartupTertiary.luoXue:
        return 'LuoXue';
      case StartupTertiary.dual:
        return 'Dual';
      case StartupTertiary.inherit:
        return 'Inherit';
      case StartupTertiary.none:
        return 'None';
    }
  }

  static StartupTertiary parse(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'divingfish':
        return StartupTertiary.divingFish;
      case 'luoxue':
        return StartupTertiary.luoXue;
      case 'dual':
        return StartupTertiary.dual;
      case 'inherit':
        return StartupTertiary.inherit;
      default:
        return StartupTertiary.none;
    }
  }
}

// ── 复合模型 ──────────────────────────────────────────────────────────────────

class StartupPrefModel {
  final StartupPrimary primary;
  final StartupSecondary secondary;
  final StartupTertiary tertiary;

  const StartupPrefModel({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  /// 降级默认值：全回溯模式。
  /// 适用于首次启动或存储数据异常时。
  static const defaultFallback = StartupPrefModel(
    primary: StartupPrimary.last,
    secondary: StartupSecondary.none,
    tertiary: StartupTertiary.none,
  );

  /// 若路径任意层级包含 last / inherit，则需要激活状态回溯监听器。
  /// 三级均覆盖，确保 Sync:Mai:Inherit 等场景不漏触发。
  /// 此为监听器激活的唯一判断门控——REJECT 在 Provider 或 UI 层重复此逻辑。
  bool get needsStateObserver =>
      primary == StartupPrimary.last ||
      secondary == StartupSecondary.inherit ||
      tertiary == StartupTertiary.inherit;

  /// 序列化为复合路径字符串写入存储。
  String serialize() =>
      '${primary.serialize()}:${secondary.serialize()}:${tertiary.serialize()}';

  /// 从存储字符串解析，格式异常时统一降级为 defaultFallback。
  static StartupPrefModel parse(String? raw) {
    if (raw == null || raw.isEmpty) return defaultFallback;
    final segments = raw.split(':');
    if (segments.length != 3) return defaultFallback;
    return StartupPrefModel(
      primary: StartupPrimary.parse(segments[0]),
      secondary: StartupSecondary.parse(segments[1]),
      tertiary: StartupTertiary.parse(segments[2]),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StartupPrefModel &&
      other.primary == primary &&
      other.secondary == secondary &&
      other.tertiary == tertiary;

  @override
  int get hashCode => Object.hash(primary, secondary, tertiary);

  @override
  String toString() => 'StartupPrefModel(${serialize()})';
}
