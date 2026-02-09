import 'package:flutter/material.dart';

@immutable
class GameTheme extends ThemeExtension<GameTheme> {
  // Transfer Card Colors
  final Color transferCardBaseColor;
  final Color transferCardBorderColor;
  final Color transferCardShadowColor;
  final Color transferCardContainerColor;
  final Color transferCardActiveColor; // Main active color (pink/yellow)
  final Color transferCardGradientColor;

  // Generic UI Properties
  final BorderRadius mainBorderRadius;
  final double defaultSpacing;

  const GameTheme({
    required this.transferCardBaseColor,
    required this.transferCardBorderColor,
    required this.transferCardShadowColor,
    required this.transferCardContainerColor,
    required this.transferCardActiveColor,
    required this.transferCardGradientColor,
    required this.mainBorderRadius,
    this.defaultSpacing = 16.0,
  });

  @override
  GameTheme copyWith({
    Color? transferCardBaseColor,
    Color? transferCardBorderColor,
    Color? transferCardShadowColor,
    Color? transferCardContainerColor,
    Color? transferCardActiveColor,
    Color? transferCardGradientColor,
    BorderRadius? mainBorderRadius,
    double? defaultSpacing,
  }) {
    return GameTheme(
      transferCardBaseColor:
          transferCardBaseColor ?? this.transferCardBaseColor,
      transferCardBorderColor:
          transferCardBorderColor ?? this.transferCardBorderColor,
      transferCardShadowColor:
          transferCardShadowColor ?? this.transferCardShadowColor,
      transferCardContainerColor:
          transferCardContainerColor ?? this.transferCardContainerColor,
      transferCardActiveColor:
          transferCardActiveColor ?? this.transferCardActiveColor,
      transferCardGradientColor:
          transferCardGradientColor ?? this.transferCardGradientColor,
      mainBorderRadius: mainBorderRadius ?? this.mainBorderRadius,
      defaultSpacing: defaultSpacing ?? this.defaultSpacing,
    );
  }

  @override
  GameTheme lerp(ThemeExtension<GameTheme>? other, double t) {
    if (other is! GameTheme) {
      return this;
    }
    return GameTheme(
      transferCardBaseColor: Color.lerp(
        transferCardBaseColor,
        other.transferCardBaseColor,
        t,
      )!,
      transferCardBorderColor: Color.lerp(
        transferCardBorderColor,
        other.transferCardBorderColor,
        t,
      )!,
      transferCardShadowColor: Color.lerp(
        transferCardShadowColor,
        other.transferCardShadowColor,
        t,
      )!,
      transferCardContainerColor: Color.lerp(
        transferCardContainerColor,
        other.transferCardContainerColor,
        t,
      )!,
      transferCardActiveColor: Color.lerp(
        transferCardActiveColor,
        other.transferCardActiveColor,
        t,
      )!,
      transferCardGradientColor: Color.lerp(
        transferCardGradientColor,
        other.transferCardGradientColor,
        t,
      )!,
      mainBorderRadius: BorderRadius.lerp(
        mainBorderRadius,
        other.mainBorderRadius,
        t,
      )!,
      defaultSpacing: other.defaultSpacing,
    );
  }

  // Static Definitions
  static final maimai = GameTheme(
    transferCardBaseColor: const Color(0xCCFFFFFF), // White with opacity
    transferCardBorderColor: const Color(0x4DFF4081), // Pink accent opacity 0.3
    transferCardShadowColor: const Color(0x1AFF4081), // Pink accent opacity 0.1
    transferCardContainerColor: const Color(0xFFF5F5F5), // Grey 100
    transferCardActiveColor: const Color(0xFFFB9AB8), // Maimai Pink
    transferCardGradientColor: const Color(0xFFFFF0F5),
    mainBorderRadius: BorderRadius.circular(20),
  );

  static final chunithm = GameTheme(
    transferCardBaseColor: const Color(
      0xE6FFFFFF,
    ), // White with slightly more opacity for legibility or Black
    // Note: User description for Chunithm transfer card in logic seemed to assume white base too (TransferModeCard defaults)
    // But let's follow the implied theme. If it was distinct, let's make it distinct.
    // Current HomePage uses white opacity for both but different active colors.
    // I will use what was in HomePage/GameThemeConfig effectively.
    transferCardBorderColor: const Color(
      0x4DFFFF00,
    ), // Yellow accent opacity 0.3 (approx)
    transferCardShadowColor: const Color(0x1AFFFF00),
    transferCardContainerColor: const Color(0xFFFAFAFA), // Grey 50
    transferCardActiveColor: const Color(0xFFFFD700), // Gold
    transferCardGradientColor: const Color(0xFFFFFFE0),
    mainBorderRadius: BorderRadius.circular(16),
  );
}

// Extension to make access easier
extension GameThemeContext on BuildContext {
  GameTheme get gameTheme =>
      Theme.of(this).extension<GameTheme>() ?? GameTheme.maimai;
}
