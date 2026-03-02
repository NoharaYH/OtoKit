import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../application/shared/game_provider.dart';
import '../../../design_system/constants/sizes.dart';
import '../../../design_system/constants/strings.dart';
import '../../../design_system/constants/colors.dart';
import '../../../design_system/kit_shared/kit_bounce_scaler.dart';
import '../../../design_system/visual_skins/skin_extension.dart';

/// 设置页: 个性化配置页 (v1.0)
/// 遵循 "Horizontal Paging Strategy" 规程。
class PersonalizationPage extends StatelessWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: UiSizes.getHorizontalMargin(context),
      ),
      child: Column(
        children: [
          _buildSection(
            context,
            title: UiStrings.startupPage,
            child: const StartupPageSelector(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: "皮肤系统",
            child: const ThemeSelectorMatrix(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: UiColors.grey700,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// StartupPageSelector: 托管启动页偏好设置逻辑。 UI 表现通过 KitBounceScaler 增强。
class StartupPageSelector extends StatelessWidget {
  const StartupPageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final skin = Theme.of(context).extension<SkinExtension>()!;

    return Column(
      children: [
        _buildStartupOption(
          context,
          title: UiStrings.startupMai,
          isSelected: gameProvider.startupPref == StartupPagePref.mai,
          onTap: () => gameProvider.setStartupPref(StartupPagePref.mai),
          skin: skin,
        ),
        const SizedBox(height: 12),
        _buildStartupOption(
          context,
          title: UiStrings.startupChu,
          isSelected: gameProvider.startupPref == StartupPagePref.chu,
          onTap: () => gameProvider.setStartupPref(StartupPagePref.chu),
          skin: skin,
        ),
        const SizedBox(height: 12),
        _buildStartupOption(
          context,
          title: UiStrings.startupLast,
          isSelected: gameProvider.startupPref == StartupPagePref.last,
          onTap: () => gameProvider.setStartupPref(StartupPagePref.last),
          skin: skin,
        ),
      ],
    );
  }

  Widget _buildStartupOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required SkinExtension skin,
  }) {
    return KitBounceScaler(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? skin.medium.withValues(alpha: 0.1)
              : UiColors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(UiSizes.buttonRadius),
          border: Border.all(
            color: isSelected ? skin.medium : UiColors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? skin.medium : UiColors.grey400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? skin.medium : UiColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ThemeSelectorMatrix: 主题切换矩阵。强插 SkinExtension 插值渲染。
class ThemeSelectorMatrix extends StatelessWidget {
  const ThemeSelectorMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UiColors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(UiSizes.panelRadius),
      ),
      child: Center(
        child: Text(
          "主题插值矩阵占位 (Slot 3)",
          style: TextStyle(color: UiColors.grey500, fontSize: 13),
        ),
      ),
    );
  }
}
