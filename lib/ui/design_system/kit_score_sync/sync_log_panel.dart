import 'package:flutter/material.dart';
import '../constants/sizes.dart';
import '../kit_shared/kit_animation_engine.dart';
import '../kit_shared/kit_bounce_scaler.dart';

/// 同步状态日志面板
///
/// 具有两段式动画：
/// 1. 胶囊：仅显示工具栏按钮
/// 2. 展开：显示日志内容并向下延伸
///
/// 确认框动画时序：
/// ① 点击关闭 → 确认框从右侧（与日志框圆角同圆心）淡入并向左滑至居中
/// ② 用户操作 → 确认框淡出并向右滑回初始停靠位
/// ③ 动画结束 → 确认框从 layout 中移除
class SyncLogPanel extends StatefulWidget {
  final String logs;
  final VoidCallback onCopy;
  final VoidCallback onClose;
  final VoidCallback onConfirmPause;
  final VoidCallback onConfirmResume;
  final bool forceHidden;
  final bool isTracking;

  const SyncLogPanel({
    super.key,
    required this.logs,
    required this.onCopy,
    required this.onClose,
    required this.onConfirmPause,
    required this.onConfirmResume,
    this.forceHidden = false,
    this.isTracking = false,
  });

  @override
  State<SyncLogPanel> createState() => _SyncLogPanelState();
}

class _SyncLogPanelState extends State<SyncLogPanel>
    with SingleTickerProviderStateMixin {
  // --- 日志面板展开状态 ---
  bool isShown = false;
  bool isActuallyExpanded = false;

  // --- 确认框 layout 存在状态 ---
  bool _isConfirmInLayout = false;

  // --- 确认框动画完毕后的业务回调暂存 ---
  VoidCallback? _pendingCallback;

  late final ScrollController _scrollController;
  late final AnimationController _confirmController;
  late final Animation<double> _confirmFade;
  late final Animation<Offset> _confirmSlide;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _confirmController = AnimationController(
      vsync: this,
      duration: KitAnimationEngine.shortDuration,
      reverseDuration: KitAnimationEngine.shortDuration,
    );

    // 淡入淡出
    _confirmFade = CurvedAnimation(
      parent: _confirmController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // 从右侧停靠位滑入 → 居中；反向滑回右侧
    _confirmSlide =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _confirmController,
            curve: KitAnimationEngine.decelerateCurve,
            reverseCurve: KitAnimationEngine.accelerateCurve,
          ),
        );

    // 动画结束后移除节点 & 执行业务回调
    _confirmController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() => _isConfirmInLayout = false);
        _pendingCallback?.call();
        _pendingCallback = null;
      }
    });

    if (!widget.forceHidden && widget.logs.isNotEmpty) {
      isShown = true;
      isActuallyExpanded = true;
    } else if (!widget.forceHidden) {
      _startEntryAnimation();
    }
  }

  @override
  void didUpdateWidget(SyncLogPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.forceHidden && !widget.forceHidden) {
      _startEntryAnimation();
    }

    // 闩锁：ONLY 在尚未折叠时执行一次，防止高频 notifyListeners 重入
    if (widget.forceHidden && isShown && isActuallyExpanded) {
      _forceResetConfirm();
      setState(() => isActuallyExpanded = false);
      Future.delayed(KitAnimationEngine.expandDuration, () {
        if (mounted) setState(() => isShown = false);
      });
    }

    if (widget.logs != oldWidget.logs && isActuallyExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _startEntryAnimation() {
    setState(() => isShown = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !widget.forceHidden) {
        setState(() => isActuallyExpanded = true);
      }
    });
  }

  // ① 点击关闭按钮
  void _triggerCloseIntent() {
    if (!widget.isTracking) {
      // 传分已结束，直接关闭无需确认
      widget.onClose();
      return;
    }
    widget.onConfirmPause();
    _confirmController.reset();
    setState(() => _isConfirmInLayout = true);
    // 初始 value=0 → opacity=0，offset=右侧；建树后直接 forward 不会闪烁
    _confirmController.forward();
  }

  // ② 用户操作后淡出并回弹，动画结束后由 StatusListener 执行回调
  void _resolveConfirm({required bool confirmed}) {
    _pendingCallback = confirmed ? widget.onClose : widget.onConfirmResume;
    _confirmController.reverse();
  }

  void _forceResetConfirm() {
    _confirmController.stop();
    _confirmController.reset();
    _pendingCallback = null;
    setState(() => _isConfirmInLayout = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double targetHeight = isActuallyExpanded
        ? UiSizes.getLogPanelMaxHeight(context, UiSizes.syncFormEstimatedHeight)
        : (isShown ? 38.0 : 0.0);

    final double totalHeight = isShown ? targetHeight + UiSizes.spaceS : 0.0;

    return AnimatedOpacity(
      duration: KitAnimationEngine.shortDuration,
      opacity: isShown ? 1.0 : 0.0,
      child: AnimatedScale(
        duration: KitAnimationEngine.shortDuration,
        scale: isShown ? 1.0 : 0.95,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: KitAnimationEngine.expandDuration,
          curve: KitAnimationEngine.decelerateCurve,
          width: double.infinity,
          height: totalHeight,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: UiSizes.spaceS),
                AnimatedContainer(
                  duration: KitAnimationEngine.expandDuration,
                  curve: KitAnimationEngine.decelerateCurve,
                  height: targetHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF323232),
                    borderRadius: BorderRadius.circular(
                      UiSizes.buttonBorderRadius,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildLogContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogContent() {
    return Column(
      children: [
        // 工具栏（38px 原始高度不变）
        SizedBox(
          height: 38,
          child: Stack(
            // 确认框在滑入前位于右侧，超出边界部分被暗色容器的 clipBehavior 剪裁
            clipBehavior: Clip.antiAlias,
            children: [
              // 复制按钮（左侧锚定）
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _IconButton(
                  icon: Icons.content_copy,
                  onTap: widget.onCopy,
                ),
              ),
              // 关闭按钮（右侧锚定，与日志框圆角同圆心）
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _IconButton(
                  icon: _isConfirmInLayout ? Icons.more_horiz : Icons.close,
                  onTap: _isConfirmInLayout ? null : _triggerCloseIntent,
                ),
              ),
              // 确认框（淡入后停靠在叉号按钮左侧）
              if (_isConfirmInLayout)
                Positioned(
                  right: 38, // 贴靠右侧 38px（关闭按钮宽度）
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: SlideTransition(
                      position: _confirmSlide,
                      child: FadeTransition(
                        opacity: _confirmFade,
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiSizes.cardContentPadding,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              UiSizes.buttonBorderRadius,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '是否结束传分？',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: UiSizes.spaceS),
                              _ConfirmIcon(
                                icon: Icons.check,
                                color: Colors.green,
                                onTap: () => _resolveConfirm(confirmed: true),
                              ),
                              const SizedBox(width: UiSizes.spaceXS),
                              _ConfirmIcon(
                                icon: Icons.close,
                                color: Colors.red,
                                onTap: () => _resolveConfirm(confirmed: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 日志内容区域
        Expanded(
          child: AnimatedOpacity(
            duration: KitAnimationEngine.shortDuration,
            opacity: isActuallyExpanded ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: RawScrollbar(
                controller: _scrollController,
                thumbColor: Colors.white.withValues(alpha: 0.3),
                radius: const Radius.circular(3),
                thickness: 3,
                interactive: true,
                child: SelectionArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.logs.isEmpty ? '等待日志输入...' : widget.logs,
                        style: const TextStyle(
                          color: Color(0xFFEEEEEE),
                          fontSize: 13,
                          fontFamily: 'monospace',
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return KitBounceScaler(
      onTap: onTap,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(
          icon,
          color: onTap != null ? Colors.white54 : Colors.white24,
          size: 18,
        ),
      ),
    );
  }
}

class _ConfirmIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ConfirmIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KitBounceScaler(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(UiSizes.spaceXXS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
