import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/shared/navigation_provider.dart';
import 'constants/layout_analyzer.dart';
import 'constants/responsive_layout_scope.dart';
import 'constants/sizes.dart';
import 'kit_navigation/kit_nav_rail.dart';
import 'kit_navigation/nav_deck_overlay.dart';
import 'kit_shared/kit_action_circle.dart';
import 'theme/core/app_theme.dart';

const double _defaultPrimaryRatio = 0.5;
const double _minPaneWidth = 280.0;

/// 应用级响应式壳层。物理位置为 PageShell 的 child。
///
/// 职责：
/// - 读取 MediaQuery 调用纯函数布局分析器
/// - 将分析结果翻译为布局意图并通过 ResponsiveLayoutScope 下发
/// - Compact：渲染 NavDeckOverlay + 左侧手势热区
/// - Medium+：渲染 KitNavRail（持久侧边导航）
/// - 管理右上角操作按钮区
///
/// 不负责：持有业务状态、决定业务模块是否存在、将断点信息上传至 application/
class OtokitResponsiveShell extends StatelessWidget {
  /// 页面内容（AnimatedSwitcher 包裹的当前页面）
  final Widget child;

  const OtokitResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final analysis = analyzeLayout(
      widthDp: mq.size.width,
      displayFeatures: mq.displayFeatures,
    );

    final isCompact = analysis.sizeClass == WindowSizeClass.compact;

    final double totalWidth = mq.size.width;
    final int paneCount = _resolvePaneCount(analysis, totalWidth);

    final double primaryWidth;
    if (paneCount == 1) {
      primaryWidth = totalWidth;
    } else if (analysis.topology != DeviceTopology.flat &&
        analysis.hingeBounds.isNotEmpty) {
      primaryWidth = analysis.hingeBounds.first.left;
    } else {
      primaryWidth = totalWidth * _defaultPrimaryRatio;
    }

    return ResponsiveLayoutScope(
      availablePaneCount: paneCount,
      primaryPaneWidth: primaryWidth,
      isCompactNavigation: isCompact,
      child:
          isCompact
              ? _buildCompactLayout(context, child)
              : _buildExpandedLayout(context, child),
    );
  }

  /// Compact 布局：悬浮胶囊导航 + 左侧手势热区
  Widget _buildCompactLayout(BuildContext context, Widget content) {
    return Stack(
      children: [
        Positioned.fill(child: content),
        _buildEdgeGesture(context),
        _buildActionButtons(context, showMenu: true),
        const Positioned.fill(child: NavDeckOverlay()),
      ],
    );
  }

  /// Medium+ 布局：持久 Rail 导航 + 右侧内容区
  Widget _buildExpandedLayout(BuildContext context, Widget content) {
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            children: [
              const KitNavRail(),
              Expanded(child: content),
            ],
          ),
        ),
        _buildActionButtons(context, showMenu: false),
      ],
    );
  }

  /// 左侧 4% 宽手势热区，仅 Compact 模式渲染
  Widget _buildEdgeGesture(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.04,
      child: Consumer<NavigationProvider>(
        builder: (context, nav, _) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              if (details.delta.dx > 5 && !nav.isDeckOpen) {
                nav.openDeck(anchorY: details.globalPosition.dy);
              }
            },
          );
        },
      ),
    );
  }

  /// 右上角操作按钮区
  /// [showMenu] Compact 时显示菜单按钮，Medium+ 时仅显示设置按钮
  Widget _buildActionButtons(BuildContext context, {required bool showMenu}) {
    final themeColor =
        Theme.of(context).extension<AppTheme>()?.basic ?? Colors.white;
    return Positioned(
      top: UiSizes.getTopMarginWithSafeArea(context) + 12.0,
      right: UiSizes.screenEdgeMargin + 12.0,
      child: Consumer<NavigationProvider>(
        builder: (context, nav, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KitActionCircle(
                icon: Icons.settings,
                color: themeColor,
                onTap: () => nav.openSettings(),
              ),
              if (showMenu) ...[
                const SizedBox(width: UiSizes.spaceS),
                Builder(
                  builder:
                      (btnCtx) => KitActionCircle(
                        icon: Icons.menu_open,
                        color: themeColor,
                        onTap: () {
                          final box =
                              btnCtx.findRenderObject() as RenderBox;
                          final pos = box.localToGlobal(Offset.zero);
                          nav.openDeck(anchorY: pos.dy + box.size.height);
                        },
                      ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// 根据设备拓扑与铰链物理尺寸计算可用 Pane 数量。
///
/// Flat：compact/medium → 1，expanded/large → 2。
/// SingleHinge：两侧区域均 ≥ [_minPaneWidth] 时给 2，否则退让为 1。
/// DualHinge：统计三个物理区中宽度 ≥ [_minPaneWidth] 的区域数，clamp(1, 3)。
int _resolvePaneCount(LayoutAnalysis analysis, double totalWidth) {
  switch (analysis.topology) {
    case DeviceTopology.flat:
      return analysis.sizeClass == WindowSizeClass.compact ||
              analysis.sizeClass == WindowSizeClass.medium
          ? 1
          : 2;

    case DeviceTopology.singleHinge:
      if (analysis.hingeBounds.isEmpty) return 1;
      final hinge = analysis.hingeBounds.first;
      final leftZone = hinge.left;
      final rightZone = totalWidth - hinge.right;
      return leftZone >= _minPaneWidth && rightZone >= _minPaneWidth ? 2 : 1;

    case DeviceTopology.dualHinge:
      if (analysis.hingeBounds.length < 2) return 1;
      final h0 = analysis.hingeBounds[0];
      final h1 = analysis.hingeBounds[1];
      final validCount = [
        h0.left,
        h1.left - h0.right,
        totalWidth - h1.right,
      ].where((z) => z >= _minPaneWidth).length;
      return validCount.clamp(1, 3);
  }
}
