import 'package:flutter/material.dart';

/// 容器扩张/收缩驱动器 (kit_setting/animations 动效资产)
///
/// 遵循 SETTING_PAGE_SPECIFICATION §4 扩张收缩逻辑：
///   展开：容器扩张先行（物理占位阶段 A），内容渐显置后（渲染阶段 B）。
///   收缩：内容渐隐先行，渐隐完成后容器坍塌（两步串行，非并行）。
///
/// 物理参数：
///   Duration = 350ms
///   Curve    = Curves.easeInOutCubic
///   内容淡入区间：Interval(0.5, 1.0) -> 容器扩张过半后再渐显内容
///   内容淡出区间：Interval(0.0, 0.5) -> 内容先于容器收缩完成渐隐
///
/// 使用规程：
///   直接作为 SettingCard.child Slot 内的子项，由内向外撑开父容器。
///   REJECT 在调用方自行实现 AnimatedSize 或 AnimatedSwitcher。
class ExpansionAnimator extends StatefulWidget {
  /// 驱动展开/收缩的外部状态。
  final bool isExpanded;

  /// 展开时显示的内容。key 应使用基于内容语义的 ValueKey，
  /// 以确保切换时触发 Element 重建，隔离隐式状态。
  final Widget child;

  const ExpansionAnimator({
    super.key,
    required this.isExpanded,
    required this.child,
  });

  @override
  State<ExpansionAnimator> createState() => _ExpansionAnimatorState();
}

class _ExpansionAnimatorState extends State<ExpansionAnimator>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 350);
  static const _curve = Curves.easeInOutCubic;

  late AnimationController _controller;

  // 内容淡入：在容器扩张过半后才开始渐显（阶段 B）
  late Animation<double> _fadeInAnimation;

  // 内容淡出：内容先于容器收缩完成（阶段 A 反向）
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: _curve),
    );

    _fadeOutAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: _curve),
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpansionAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // 容器高度由 AnimatedSize 跟随内部内容自然撑开
        return ClipRect(
          child: AnimatedSize(
            duration: _duration,
            curve: _curve,
            alignment: Alignment.topCenter,
            child: _controller.value == 0.0
                ? const SizedBox.shrink()
                : FadeTransition(
                    // 展开时用 fadeIn（0.5→1.0 区间），收缩时用 fadeOut（0.0→0.5 区间反向）
                    opacity: widget.isExpanded
                        ? _fadeInAnimation
                        : _fadeOutAnimation,
                    child: widget.child,
                  ),
          ),
        );
      },
    );
  }
}
