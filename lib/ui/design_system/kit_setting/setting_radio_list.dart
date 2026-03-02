import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../kit_shared/kit_bounce_scaler.dart';

/// 内联单选列表组件 (kit_setting 原子组件)
///
/// 区别于 SettingMenu[T]（弹出浮层型），本组件直接渲染在卡片内部，
/// 适用于多级联动、需要 ExpansionAnimator 嵌套的场景。
///
/// 外观：纵向列表，每项左侧单选指示图标，当前选中项高亮 accentColor，
///       未选中项灰色，点击带 KitBounceScaler 物理反馈。
///
/// 泛型 T 为选项值类型。
/// ONLY 接受原始数据与回调，不持有任何状态，不引用 Provider。
class SettingRadioList<T> extends StatelessWidget {
  final List<T> options;
  final List<String> labels;
  final T current;
  final ValueChanged<T> onSelect;
  final Color accentColor;

  const SettingRadioList({
    super.key,
    required this.options,
    required this.labels,
    required this.current,
    required this.onSelect,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(options.length, (i) {
        final isSelected = current == options[i];
        return KitBounceScaler(
          onTap: () => onSelect(options[i]),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.08)
                  : UiColors.grey100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 18,
                  color: isSelected ? accentColor : UiColors.grey400,
                ),
                const SizedBox(width: 10),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? accentColor : UiColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
