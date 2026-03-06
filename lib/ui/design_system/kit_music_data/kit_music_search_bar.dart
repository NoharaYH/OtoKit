import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../constants/animations.dart';
import '../theme/core/app_theme.dart';
import '../kit_shared/kit_bounce_scaler.dart';

/// 曲库/宴谱标准搜索条：左侧搜索框（占位符 + 高级检索展开按钮），右侧宴按钮。
/// 高度为标准间距两倍；外圈白描边 0.5，内圈主题 basic / 宴色 1.0。
class KitMusicSearchBar extends StatelessWidget {
  /// 高级检索是否展开（用于 chevron 旋转）
  final bool isExpanded;

  /// 宴模式是否激活（影响右侧按钮高亮与图标色）
  final bool isUtageActive;

  /// 点击搜索框右侧展开按钮时回调，由父级切换 isExpanded 并展示 [KitMusicSearchAdvancedPanel]
  final ValueChanged<bool>? onExpandChanged;

  /// 点击右侧宴按钮时回调
  final VoidCallback? onUtageToggle;

  const KitMusicSearchBar({
    super.key,
    this.isExpanded = false,
    this.isUtageActive = false,
    this.onExpandChanged,
    this.onUtageToggle,
  });

  static const double _outerStroke = 2.5;
  static const double _innerStroke = 2.0;
  static const double _searchBarHeight = 45.0;
  static const double _expandButtonSize = 26.25; // 在 21.0 基础上放大 1/4 (21 * 1.25)
  static const double _gapSearchToUtage = UiSizes.spaceXS;
  static const Color _utageFill = Color(0xFFED4AC9);
  static const Color _utageBase = Color(0xFFB02675);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppTheme>();
    final basicColor = theme?.basic ?? _utageBase;

    return SizedBox(
      height: _searchBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _SearchFieldBorder(
              innerStrokeColor: basicColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: UiSizes.spaceS,
                  right:
                      ((KitMusicSearchBar._searchBarHeight -
                              (KitMusicSearchBar._outerStroke * 2) -
                              (KitMusicSearchBar._innerStroke * 2) -
                              KitMusicSearchBar._expandButtonSize) /
                          2) +
                      1.0, // 向左挪动 1px
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          style: const TextStyle(
                            fontFamily: 'JiangCheng',
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: '使用 ID、标题、别名搜索',
                            hintStyle: TextStyle(
                              fontFamily: 'JiangCheng',
                              color: UiColors.grey500,
                              fontSize: 14,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _expandButtonSize,
                      height: _expandButtonSize,
                      child: Center(
                        child: KitBounceScaler(
                          onTap: () => onExpandChanged?.call(!isExpanded),
                          child: _ExpandChevronButton(
                            isExpanded: isExpanded,
                            size: _expandButtonSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: _gapSearchToUtage),
          SizedBox(
            width: _searchBarHeight,
            child: KitBounceScaler(
              onTap: onUtageToggle,
              child: _UtageButton(
                baseColor: _utageBase,
                isActive: isUtageActive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 双描边容器：外白 0.5，内层可指定颜色 1.0
class _SearchFieldBorder extends StatelessWidget {
  final Color innerStrokeColor;
  final Widget child;

  const _SearchFieldBorder({
    required this.innerStrokeColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = UiSizes.cardRadius; // 使用标准卡片圆角规格
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: UiColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: UiColors.white,
          width: KitMusicSearchBar._outerStroke,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            radius - KitMusicSearchBar._outerStroke,
          ),
          border: Border.all(
            color: innerStrokeColor,
            width: KitMusicSearchBar._innerStroke,
          ),
          color: UiColors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            radius -
                KitMusicSearchBar._outerStroke -
                KitMusicSearchBar._innerStroke,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 搜索框右侧灰色展开按钮，chevron 随 isExpanded 旋转（收起朝上，展开朝下）。
/// 圆形与搜索框同高，中心与搜索框上/下/右保持相同间距（均为 height/2）。
class _ExpandChevronButton extends StatefulWidget {
  final bool isExpanded;
  final double size;

  const _ExpandChevronButton({required this.isExpanded, required this.size});

  @override
  State<_ExpandChevronButton> createState() => _ExpandChevronButtonState();
}

class _ExpandChevronButtonState extends State<_ExpandChevronButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: UiAnimations.standard,
    );
    // 0 = 朝上(收起), 0.5 = 朝下(展开)。Icons.keyboard_arrow_down 默认朝下，0.5 turns 旋转 180° 朝上
    _rotation = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: UiAnimations.curveOut),
    );
    if (widget.isExpanded) _controller.forward();
  }

  @override
  void didUpdateWidget(_ExpandChevronButton oldWidget) {
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
    final s = widget.size;
    return RotationTransition(
      turns: _rotation,
      child: Material(
        color: UiColors.grey200,
        shape: const CircleBorder(),
        child: SizedBox(
          width: s,
          height: s,
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_down,
              size: s,
              color: UiColors.grey600,
            ),
          ),
        ),
      ),
    );
  }
}

/// 宴按钮：内 #b02675，描边与搜索框同宽，文字 GameFont 白字居中
class _UtageButton extends StatelessWidget {
  final Color baseColor;
  final bool isActive;

  const _UtageButton({required this.baseColor, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    const double radius = UiSizes.cardRadius; // 使用标准卡片圆角规格
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: UiColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: UiColors.white,
          width: KitMusicSearchBar._outerStroke,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            radius - KitMusicSearchBar._outerStroke,
          ),
          border: Border.all(
            color: baseColor,
            width: KitMusicSearchBar._innerStroke,
          ),
          color: isActive ? baseColor : KitMusicSearchBar._utageFill,
        ),
        child: Center(
          child: Text(
            '宴',
            style: TextStyle(
              fontFamily: 'GameFont',
              color: UiColors.white,
              fontSize: 20,
              shadows: isActive
                  ? [const Shadow(color: Colors.white70, blurRadius: 8)]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
