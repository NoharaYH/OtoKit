import 'dart:ui';
import 'package:flutter/material.dart';
import 'constants/sizes.dart';
import 'constants/colors.dart';
import 'theme/core/app_theme.dart';

/// 页面外壳
/// 提供：背景 + 白色毛玻璃底板 + 内容区域
///
/// 【架构红线】不判断设备形态、不包含侧边栏/热区/平板状态；showGlassOverlay 由调用方（如 RootPage）
/// 根据 compact/expanded 传入，本组件内部无 MediaQuery 或 ResponsiveLayoutScope 分支。
///
/// 使用场景：主页（需要统一背景和毛玻璃效果的页面）
/// 不使用场景：设置页、WebView 页（这些页面有自己的布局）
class PageShell extends StatelessWidget {
  final Widget child;

  /// Optional override for the background layer.
  /// If provided, this widget will be used instead of the current theme's skin background.
  /// This is useful for HomePage's cross-fading background.
  final Widget? backgroundOverride;

  /// Whether to show the glass-morphism overlay card. 【平板 vs 手机】由调用方根据 compact 传入，Compact 为 true，Medium+ 为 false（平板玻璃在 Shell 内）。
  /// Defaults to true.
  final bool showGlassOverlay;

  const PageShell({
    super.key,
    required this.child,
    this.backgroundOverride,
    this.showGlassOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get current skin from ThemeExtension
    final skin = Theme.of(context).extension<AppTheme>();

    // 2. Resolve background: Override > Skin Background > Fallback
    final Widget background =
        backgroundOverride ??
        (skin != null
            ? skin.buildBackground(context)
            : Container(color: UiColors.white)); // Fallback if no skin

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // BOTTOM: The unique background layer
          Positioned.fill(child: background),

          // MIDDLE: The unique glass overlay layer
          if (showGlassOverlay) _buildGlassOverlay(context),

          // TOP: Content layer
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _buildGlassOverlay(BuildContext context) {
    const borderRadius = BorderRadius.only(
      // 悬空包裹向内缩回。由于按钮外边缘距 Glass 有 12pt 的内缩 (Padding)。
      // 以按钮半径 R=16 为圆心计算同心弧：外侧 Glass 半径必须为 16.0 + 12.0 = 28.0。
      // 这样保证从右上角看，按钮圆弧刚好与背景玻璃边缘成绝对完美的等距平行。
      topLeft: Radius.circular(28.0),
      topRight: Radius.circular(28.0),
    );

    return Positioned(
      top: UiSizes.getTopMarginWithSafeArea(context),
      left: UiSizes.getHorizontalMargin(context),
      right: UiSizes.getHorizontalMargin(context),
      bottom: 0,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // LAYER 1：毛玻璃 + 渐变叠加（均值等价 0.25 不透明度）
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  // 渐变叠加：基准参考 SVG fill-opacity=0.369，均值展开
                  // topLeft 入光高亮 0.50，bottomRight 背光衰减 0.24，均值 ≈ 0.369
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      UiColors.white.withValues(alpha: 0.50),
                      UiColors.white.withValues(alpha: 0.24),
                    ],
                  ),
                ),
              ),
            ),

            // LAYER 2：渐变描边（topLeft 纯白 → 70% stop 透明，CustomPaint 零 GPU Pass）
            CustomPaint(painter: _GlassStrokePainter()),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 渐变描边 Painter
//
// 沿 glass 容器圆角矩形路径绘制 0.5px 描边。
// 渐变方向：topLeft → bottomRight，纯白至完全透明，70% stop。
// 不触发任何 GPU Offscreen Render Pass，与原方案性能等价。
// ─────────────────────────────────────────────────────────────────────────────

class _GlassStrokePainter extends CustomPainter {
  static const double _topRadius = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(_topRadius),
      topRight: const Radius.circular(_topRadius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.transparent],
        stops: [0.0, 0.7],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
