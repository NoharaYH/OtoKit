import 'package:flutter/material.dart';

class UiSizes {
  // --- 全局布局乘数 (架构常量) ---
  /// 主毛玻璃卡片的起始垂直偏移量 (屏幕高度的 5%)
  static const double shellMarginTopMultiplier = 0.05;

  /// 主毛玻璃卡片的水平边距 (屏幕宽度的 3%)
  static const double shellMarginSideMultiplier = 0.03;

  // --- 间距系统 (统一的标准) ---
  /// 4.0 - 极小间距
  static const double spaceXXS = 4.0;

  /// 8.0 - 小间距
  static const double spaceXS = 8.0;

  /// 12.0 - 永恒留白 (原子级标准)
  static const double spaceS = 12.0;

  /// 16.0 - 全局标准内边距
  static const double spaceM = 16.0;

  /// 32.0 - 头部区域间隙
  static const double spaceXL = 32.0;

  // --- 功能差别名 (强语义隔离) ---
  /// 12.0 - 核心业务组件之间的垂直标准间隙
  static const double atomicComponentGap = spaceS;

  /// 12.0 - 卡片内容的侧边对齐缩进标准
  static const double cardContentPadding = spaceS;

  /// 16.0 - 默认内边距
  static const double defaultPadding = spaceM;

  // --- 组件专属尺寸 ---
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputFieldHeight = 44.0;
  static const double logoHeight = 80.0;
  static const double logoAreaHeight = 100.0;

  /// 基础表单/头部/Tabs 的预估高度占用
  static const double syncFormEstimatedHeight = 464.0;

  // --- 动画时长 ---
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);

  // --- 保持布局一致性的辅助方法 ---
  /// 返回固定的 12px 边距，以确保玻璃外壳与屏幕边缘有呼吸空间。
  static double getHorizontalMargin(BuildContext context) {
    return spaceS;
  }

  /// 返回绝对像素级别的顶部边距
  static double getTopMargin(BuildContext context) {
    return MediaQuery.of(context).size.height * shellMarginTopMultiplier;
  }

  /// 返回尊重设备安全区域（刘海、状态栏）的顶部边距。
  /// 如果安全区域顶部插入大于标准顶部边距，
  /// 则添加一个小的额外偏移 (8.0)，以避免内容触及刘海。
  static double getTopMarginWithSafeArea(BuildContext context) {
    final double base = getTopMargin(context);
    final double safeTop = MediaQuery.of(context).viewPadding.top;
    if (safeTop > base) {
      return safeTop + 8.0; // 刘海后的额外间距
    }
    return base;
  }

  /// 返回页面内容（Logo + 卡片叠层）的标准内边距
  static EdgeInsets getPageContentPadding(BuildContext context) {
    return EdgeInsets.only(
      top: getTopMargin(context),
      left: getHorizontalMargin(context),
      right: getHorizontalMargin(context),
    );
  }

  /// 返回卡片的水平边距，包含内部内容侧边缩进
  static double getCardSideMargin(BuildContext context) {
    return getHorizontalMargin(context) + cardContentPadding;
  }

  /// 返回卡片的底部边距，遵守 3% 屏幕规则 + spaceS
  static double getCardBottomMargin(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight * 0.03) + spaceS;
  }

  /// 返回纯粹的底部安全区域边距
  static double getBottomMarginWithSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// 计算日志面板的可用高度，确保卡片刚好碰到遵守 3% 自适应边距标准的底部。
  static double getLogPanelMaxHeight(
    BuildContext context,
    double currentUsedHeight,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topMargin = getTopMarginWithSafeArea(context);
    final bottomMargin = getCardBottomMargin(context);

    // 预留空间 = 总高度 - 顶部边距 - 已占用高度 - 底部边距
    final available =
        screenHeight - topMargin - currentUsedHeight - bottomMargin;

    return available > 100 ? available : 180;
  }

  /// 返回点状指示器的顶部高度偏移
  static double getDotIndicatorTop(BuildContext context) {
    return getTopMargin(context) + logoAreaHeight - spaceS;
  }
}
