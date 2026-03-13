import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../application/shared/navigation_provider.dart';
import '../constants/sizes.dart';
import 'kit_nav_capsule.dart';
import 'nav_item_registry.dart';

/// 【架构红线·手机专属组件】Compact 下的浮层胶囊导航。
/// 仅由 OtokitResponsiveShell._buildCompactLayout 挂载，平板路径使用 TabletSidebarMinimal，不使用本组件。
class NavDeckOverlay extends StatefulWidget {
  const NavDeckOverlay({super.key});

  @override
  State<NavDeckOverlay> createState() => _NavDeckOverlayState();
}

class _NavDeckOverlayState extends State<NavDeckOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 弹簧动画控制器
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 整体交错持续时间
    );

    // 背景 50% 黑的淡入
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, child) {
        if (nav.isDeckOpen) {
          _controller.forward();
        } else {
          _controller.reverse();
        }

        // 屏蔽触摸的根层
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.value == 0.0 && !nav.isDeckOpen) {
              return const SizedBox.shrink(); // 完全关闭时不渲染
            }

            return Stack(
              children: [
                // 1. 50% 变暗幕布区隔背景
                Positioned.fill(
                  child: GestureDetector(
                    onTap: nav.closeDeck, // 点击空白处收起
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withValues(
                        alpha: _fadeAnimation.value * 0.5,
                      ),
                    ),
                  ),
                ),
                // 2. 悬浮胶囊队列绘制区（Positioned.fill 避免无界约束导致 RenderOpacity NEEDS-LAYOUT）
                Positioned.fill(child: _buildCapsuleStack(context, nav)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCapsuleStack(BuildContext context, NavigationProvider nav) {
    final screenHeight = MediaQuery.of(context).size.height;

    // 预估整个胶囊堆的高度，用于触底时是否反转展开方向
    const double capHeight = 55.2;
    const estimatedDeckHeight = 250.0;

    // 是否触底需要反转重心：锚点距离底部如果小于整个容器，则向上展开
    final spaceBelow = screenHeight - nav.anchorY;
    final isReverse = spaceBelow < estimatedDeckHeight;

    // 这里的gap为卡片间距。原先为12(spaceS)，按增加20%的要求，调整为 12 * 1.2 = 14.4
    const double capGap = 14.4;
    // Positioned 必须带 width/height，否则子节点收到无界约束导致 RenderOpacity NEEDS-LAYOUT。
    const double capWidth = 200.0; // 240 缩短三分之一

    // 为了实现"由锚点出发顺次错开弹起"的效果，根据反转状态决定渲染起始点
    // 这里采用基线纵坐标来简化计算，默认左边缘距离屏幕 5%
    final leftX = MediaQuery.of(context).size.width * 0.05;
    final startY = isReverse
        ? (nav.anchorY - estimatedDeckHeight).clamp(
            UiSizes.spaceXL,
            screenHeight,
          )
        : nav.anchorY;

    // 导航项来自唯一定义处，与平板 TabletSidebarMinimal 共用
    final items = NavItemRegistry.entries
        .map(
          (e) => _CapsuleItemData(
            tag: e.tag,
            icon: e.icon,
            label: e.label,
            subLabel: e.subLabel,
            customColor: e.color,
          ),
        )
        .toList();

    List<Widget> children = [];

    // 生成交错动画 (Staggered Animation)
    for (int i = 0; i < items.length; i++) {
      // 交错延迟的计算
      final delayFactor = isReverse ? (items.length - 1 - i) : i;
      final startInterval = (delayFactor * 0.1).clamp(0.0, 0.6); // 保证在 1.0 内完成

      // 慢-快-慢 的阻尼过渡动画
      final slideCurve = CurvedAnimation(
        parent: _controller,
        curve: Interval(startInterval, 1.0, curve: Curves.easeOutQuart),
      );

      final slideTween = Tween<double>(begin: -150.0, end: 0.0);
      final opacityCurve = CurvedAnimation(
        parent: _controller,
        curve: Interval(
          startInterval,
          startInterval + 0.3,
          curve: Curves.easeIn,
        ),
      );

      // 垂直定位固定，由 _Slide 负责 X 轴进入
      final currentY = startY + i * (capHeight + capGap);

      children.add(
        Positioned(
          left: leftX,
          top: currentY,
          width: capWidth,
          height: capHeight,
          child: Transform.translate(
            offset: Offset(slideTween.evaluate(slideCurve), 0),
            child: Opacity(
              opacity: opacityCurve.value,
              child: Align(
                alignment: Alignment.centerLeft,
                child: KitNavCapsule(
                  icon: items[i].icon,
                  subLabel: items[i].subLabel,
                  label: items[i].label,
                  customColor: items[i].customColor,
                  // 如果是假卡，不产生高亮
                  isSelected:
                      items[i].tag != null && nav.currentTag == items[i].tag,
                  onTap: () {
                    if (items[i].tag != null) nav.switchTo(items[i].tag!);
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 底部附加小圆球按钮，与上面胶囊卡片的间距对齐为相同的间距(capGap)
    final bottomY = startY + items.length * (capHeight + capGap);

    // 两个按钮分开出场，内侧（设置）先出，外侧（空）后出
    final bottomDelayBase = isReverse ? -1 : items.length;
    final innerStart = (bottomDelayBase >= 0 ? bottomDelayBase * 0.1 : 0.0)
        .clamp(0.0, 0.7);
    final outerStart = (innerStart + 0.1).clamp(0.0, 0.8);

    final innerSlideCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(innerStart, 1.0, curve: Curves.easeOutQuart),
    );
    final innerOpacityCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(innerStart, innerStart + 0.3, curve: Curves.easeIn),
    );

    final outerSlideCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(outerStart, 1.0, curve: Curves.easeOutQuart),
    );
    final outerOpacityCurve = CurvedAnimation(
      parent: _controller,
      curve: Interval(outerStart, outerStart + 0.3, curve: Curves.easeIn),
    );

    // 内部设置按钮
    children.add(
      Positioned(
        left: leftX,
        top: bottomY,
        width: capHeight,
        height: capHeight,
        child: Transform.translate(
          offset: Offset(
            Tween<double>(begin: -150, end: 0).evaluate(innerSlideCurve),
            0,
          ),
          child: Opacity(
            opacity: innerOpacityCurve.value,
            child: KitNavCapsule(
              icon: Icons.settings,
              isCircle: true,
              onTap: () {
                nav.openSettings();
              },
            ),
          ),
        ),
      ),
    );

    // 外侧空白占位按钮
    children.add(
      Positioned(
        left: leftX + capHeight + UiSizes.spaceS,
        top: bottomY,
        width: capHeight,
        height: capHeight,
        child: Transform.translate(
          offset: Offset(
            Tween<double>(begin: -150, end: 0).evaluate(outerSlideCurve),
            0,
          ),
          child: Opacity(
            opacity: outerOpacityCurve.value,
            child: KitNavCapsule(
              icon: Icons.circle_outlined, // 随便一个象征空的 icon
              isCircle: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    return Stack(children: children);
  }
}

class _CapsuleItemData {
  final PageTag? tag;
  final IconData icon;
  final String label;
  final String subLabel;
  final Color? customColor;

  _CapsuleItemData({
    required this.tag,
    required this.icon,
    required this.label,
    required this.subLabel,
    this.customColor,
  });
}
