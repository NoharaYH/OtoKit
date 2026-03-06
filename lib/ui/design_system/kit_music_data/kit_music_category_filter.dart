import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../kit_shared/kit_animation_engine.dart';

/// 歌曲分类筛选面板
/// 设计规格参考 ScoreSyncCard，支持展开/折叠动效
class KitMusicCategoryFilter extends StatefulWidget {
  final bool isExpanded;
  final Widget? child;

  const KitMusicCategoryFilter({
    super.key,
    required this.isExpanded,
    this.child,
  });

  @override
  State<KitMusicCategoryFilter> createState() => _KitMusicCategoryFilterState();
}

class _KitMusicCategoryFilterState extends State<KitMusicCategoryFilter> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: KitAnimationEngine.expandDuration,
      curve: KitAnimationEngine.decelerateCurve,
      width: double.infinity,
      decoration: BoxDecoration(
        color: UiColors.white,
        borderRadius: BorderRadius.circular(UiSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: UiColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiSizes.cardRadius),
        child: AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UiSizes.cardContentPadding),
            child: widget.child ?? const Center(child: Text('分类筛选内容')),
          ),
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: KitAnimationEngine.expandDuration,
          firstCurve: KitAnimationEngine.decelerateCurve,
          secondCurve: KitAnimationEngine.decelerateCurve,
          sizeCurve: KitAnimationEngine.decelerateCurve,
        ),
      ),
    );
  }
}
