import 'package:flutter/material.dart';
import 'setting_radio_list.dart';
import 'animations/expansion_animator.dart';

/// 可展开单选列表组件 (kit_setting 原子组件)
///
/// 将 ExpansionAnimator 与 SettingRadioList[T] 封装为单一原子件，
/// 业务页 ONLY 声明 isExpanded 与选项数据，不感知动效实现细节。
///
/// 适用场景：多级联动中每一层的条件性展开选项列表。
/// ONLY 接受原始数据与回调，不持有任何状态，不引用 Provider。
class SettingExpandableRadioList<T> extends StatelessWidget {
  /// 控制列表是否展开。
  final bool isExpanded;

  /// 用于 ExpansionAnimator 内部 ValueKey 的语义标识，切换时确保 Element 重建。
  final String expansionKey;

  final List<T> options;
  final List<String> labels;
  final T current;
  final ValueChanged<T> onSelect;
  final Color accentColor;

  /// 可选的分组标题，展示在列表顶部。
  final String? sectionLabel;

  /// 相对于父级的水平缩进量，用于体现层级拓扑视觉关系。
  final double indent;

  const SettingExpandableRadioList({
    super.key,
    required this.isExpanded,
    required this.expansionKey,
    required this.options,
    required this.labels,
    required this.current,
    required this.onSelect,
    required this.accentColor,
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
            SettingRadioList<T>(
              options: options,
              labels: labels,
              current: current,
              onSelect: onSelect,
              accentColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
