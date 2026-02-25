import 'package:flutter/material.dart';
import '../constants/sizes.dart';
import 'kit_bounce_scaler.dart';

/// 通用行内确认框内容层 (Stateless)。
///
/// 布局：左侧为双行文本（标题 + 正文），右侧对齐绿勾/红叉圆形按钮，
/// 两者之间保留 [spaceS] 的标准间距。
/// 本组件仅负责内容渲染，动画容器（SizeTransition / AnimatedContainer）
/// 由调用方在外层包裹，以满足不同场景下的展开轴向。
class ConfirmationBox extends StatelessWidget {
  /// 左列顶行，通常为提示性小标题。
  final Widget label;

  /// 左列次行，通常为待确认内容的摘要文字。
  final Widget body;

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationBox({
    super.key,
    required this.label,
    required this.body,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧文字区占满剩余宽度
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              label,
              const SizedBox(height: UiSizes.spaceXXS),
              body,
            ],
          ),
        ),
        const SizedBox(width: UiSizes.spaceS),
        // 右侧按钮区紧凑排列
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KitBounceScaler(
              onTap: onConfirm,
              child: Container(
                padding: const EdgeInsets.all(UiSizes.spaceXXS),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 16),
              ),
            ),
            const SizedBox(width: UiSizes.spaceXS),
            KitBounceScaler(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.all(UiSizes.spaceXXS),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
