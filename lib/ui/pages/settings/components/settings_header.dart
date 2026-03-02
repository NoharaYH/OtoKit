import 'package:flutter/material.dart';
import '../../../design_system/constants/colors.dart';
import '../../../design_system/constants/sizes.dart';
import '../../../design_system/kit_shared/kit_bounce_scaler.dart';

/// 动效协议 A/B/D: 支持扩张与重心位移的设置页导航头
class SettingsHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final double expansionProgress; // 0.0 (收缩) to 1.0 (完全扩张)

  const SettingsHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.expansionProgress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // 阶段 B: 原 Icon 与 Title 同步执行左对齐重心位移
    // 阶段 D: 在已扩张的顶部标题栏左侧淡入返回按钮
    return Padding(
      padding: EdgeInsets.only(
        top: UiSizes.getTopMarginWithSafeArea(context),
        left: UiSizes.getHorizontalMargin(context) + 12.0,
        right: UiSizes.getHorizontalMargin(context) + 12.0,
        bottom: UiSizes.atomicComponentGap,
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 标题
          Transform.translate(
            offset: Offset(lerpDouble(40.0, 0.0, expansionProgress)!, 0),
            child: Opacity(
              opacity: expansionProgress,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: UiColors.grey800,
                ),
              ),
            ),
          ),

          // 阶段 D: 返回按钮
          Opacity(
            opacity: expansionProgress,
            child: KitBounceScaler(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 24,
                color: UiColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
