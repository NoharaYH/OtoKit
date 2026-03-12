import 'package:flutter/material.dart';

/// Shell 向子树下发的已翻译布局意图。
/// 业务页只消费这里的值，不直接接触 WindowSizeClass / DeviceTopology / displayFeatures。
class ResponsiveLayoutScope extends InheritedWidget {
  /// 当前可用 Pane 数量（1 / 2 / 3）
  final int availablePaneCount;

  /// 主区域实际可用宽度（dp）
  final double primaryPaneWidth;

  /// 是否处于 Compact 导航模式（影响导航组件选择与手势热区渲染）
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
