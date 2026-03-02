import 'package:flutter/material.dart';
import 'setting_menu.dart';
import 'animations/expansion_animator.dart';

/// 可展开下拉选择器 (kit_setting 原子组件)
///
/// 将 ExpansionAnimator 与 SettingMenu[T] 封装为单一原子件。
/// 业务页 ONLY 声明 isExpanded 与选项数据，不感知动效实现细节。
///
/// 适用场景：多级联动中每一层的条件性展开下拉选择器。
/// ONLY 接受原始数据与回调，不持有任何状态，不引用 Provider。
class SettingExpandableMenu<T> extends StatelessWidget {
  /// 控制菜单是否展开可见。
  final bool isExpanded;

  /// 用于 ExpansionAnimator 内部 ValueKey 的语义标识，切换时确保 Element 重建。
  final String expansionKey;

  final List<T> options;
  final List<String> labels;
  final T current;
  final ValueChanged<T> onSelect;
  final Color accentColor;
  final IconData leadingIcon;

  /// 可选的分组标题，展示在选择器顶部。
  final String? sectionLabel;

  /// 相对于父级的水平缩进量，用于体现层级拓扑视觉关系。
  final double indent;

  const SettingExpandableMenu({
    super.key,
    required this.isExpanded,
    required this.expansionKey,
    required this.options,
    required this.labels,
    required this.current,
    required this.onSelect,
    required this.accentColor,
    this.leadingIcon = Icons.tune_outlined,
    this.sectionLabel,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionAnimator(
      isExpanded: isExpanded,
      child: Padding(
        key: ValueKey(expansionKey),
        padding: EdgeInsets.only(top: 8, left: indent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sectionLabel != null) ...[
              Text(
                sectionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
            ],
            SettingMenu<T>(
              options: options,
              labels: labels,
              current: current,
              onSelect: onSelect,
              accentColor: accentColor,
              leadingIcon: leadingIcon,
            ),
          ],
        ),
      ),
    );
  }
}
