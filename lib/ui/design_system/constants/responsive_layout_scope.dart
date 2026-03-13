import 'package:flutter/material.dart';

/// Shell 向子树下发的已翻译布局意图。
/// 业务页只消费这里的值，不直接接触 WindowSizeClass / DeviceTopology / displayFeatures。
///
/// 【架构红线·平板/手机区分下游唯一来源】所有「是否平板/手机」的布局与组件决策应基于
/// 本 Scope 的字段，不直接读 MediaQuery 做宽度分档。isCompactNavigation=true 表示手机路径，
/// false 表示平板路径；primaryPaneWidth 用于边距/档位（如 600/840 阈值在 UiSizes 中消费）。
class ResponsiveLayoutScope extends InheritedWidget {
  /// 当前可用 Pane 数量（1 / 2 / 3），由 Shell 根据 layout_analyzer + 铰链退让计算。
  final int availablePaneCount;

  /// 主区域实际可用宽度（dp），用于边距与「大屏/小屏」语义（如 >600 / >840）。
  final double primaryPaneWidth;

  /// 【平板 vs 手机】true=Compact 导航（手机），false=Medium+ 导航（平板）。影响导航组件选择与手势热区。
  final bool isCompactNavigation;

  const ResponsiveLayoutScope({
    super.key,
    required this.availablePaneCount,
    required this.primaryPaneWidth,
    required this.isCompactNavigation,
    required super.child,
  });

  /// 返回 nullable，使得 Shell 未就绪时（如单元测试）业务页可优雅退化
  static ResponsiveLayoutScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveLayoutScope>();
  }

  static ResponsiveLayoutScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No ResponsiveLayoutScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ResponsiveLayoutScope oldWidget) {
    return availablePaneCount != oldWidget.availablePaneCount ||
        primaryPaneWidth != oldWidget.primaryPaneWidth ||
        isCompactNavigation != oldWidget.isCompactNavigation;
  }
}
