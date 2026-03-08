import 'package:flutter/material.dart';

import '../../ui/design_system/theme/core/app_theme.dart';

/// 由 RootThemeCoordinator 单点输出，包含主题与背景构建策略。
///
/// [theme] 供 Header、Dots、Theme.of().extension 等使用。
/// [buildBackground] 背景层构建，支持独立模式下的跨域渐隐过渡。
class ResolvedThemeBundle {
  const ResolvedThemeBundle({
    required this.theme,
    required this.buildBackground,
  });

  final AppTheme theme;

  /// 构建背景 Widget，由 RootPage 调用并传入 context
  final Widget Function(BuildContext context) buildBackground;
}
