import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../foundation/game_theme.dart';
import '../../../../../kernel/state/toast_provider.dart';

class GameToastCard extends StatelessWidget {
  final String message;
  final ToastType type;

  const GameToastCard({super.key, required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    // Access theme
    final gameTheme =
        Theme.of(context).extension<GameTheme>() ?? GameTheme.maimai;

    // Define Colors
    final Color themeColor = gameTheme.transferCardActiveColor;

    Color baseColor;
    IconData iconData;

    switch (type) {
      case ToastType.info:
        baseColor = themeColor;
        iconData = Icons.info_outline_rounded;
        break;
      case ToastType.success:
        baseColor = const Color(0xFF00C853);
        iconData = Icons.check_circle_outline_rounded;
        break;
      case ToastType.error:
        baseColor = const Color(0xFFFF1744);
        iconData = Icons.error_outline_rounded;
        break;
    }

    // Styling
    // "背景应该为比描边略淡的实色，而不是现在这种发白的颜色"
    // "描边" is borderColor.
    // Let's use baseColor as the main hue.

    // Actually user said "比描边略淡的实色".
    // Maybe they mean the *box itself* is colored, not white/black.
    // "比描边略淡": Border is 0.8 opacity baseColor.
    // Background could be 0.1 opacity baseColor on surface (very light tint).
    // Or if they want it like a "chip", maybe 0.9 opacity baseColor?
    // "不是现在这种发白的颜色" implies they want more color.
    // Let's go with a strong tint.
    // Background: baseColor with 0.9 opacity (so it's almost the color itself) -> Too strong for text?
    // Let's try baseColor with 0.15 opacity on Surface. That's standard "Container" color for chips.
    // But "发白" means they might want it DARKER or MORE VIBRANT.
    // Let's try: Background = Surface + 0.9 * BaseColor? No.
    // Let's try: Background = BaseColor with 0.9 opacity. Text must be white then.
    // IF the user wants " 实色" (solid color), usually in game UI this means a vivid backing.
    // Let's try: Background = BaseColor. Text = White.
    // "比描边略淡": Border is Lighter/Darker?
    // Let's stick to: Background = BaseColor (0.85 opacity). Border = BaseColor (1.0).
    // Text = White.

    final solidBgColor = baseColor.withOpacity(0.85); // Solid-ish
    final solidBorderColor = baseColor;
    final textColor = Colors.white; // Always white on solid color
    final iconColor = Colors.white;

    final glowColor = baseColor.withOpacity(0.4);

    return Container(
      width: 360,
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 2,
      ), // Tighter vertical margin
      decoration: BoxDecoration(
        color: solidBgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: solidBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ), // Reduced blur for performance
          child: Padding(
            // "继续缩减提示框的高度，缩减到现在高度的60%"
            // Previous vertical padding was 10.
            // Let's reduce significantly.
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                // Remove container or make it very subtle?
                // Just the icon on solid background.
                Icon(
                  iconData,
                  color: iconColor,
                  size: 18, // Reduced size
                ),
                const SizedBox(width: 10),
                // Text
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12, // Reduced font size
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      decoration: TextDecoration.none,
                      fontFamily: 'JiangCheng',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
