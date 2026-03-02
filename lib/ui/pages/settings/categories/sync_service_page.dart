import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../application/transfer/sync_settings_provider.dart';
import '../../../../application/transfer/transfer_provider.dart';
import '../../../design_system/visual_skins/skin_extension.dart';
import '../../../design_system/constants/sizes.dart';
import '../../../design_system/constants/colors.dart';
import '../../../design_system/kit_shared/kit_bounce_scaler.dart';

/// 设置页: 传分服务专页 (v1.0)
/// 遵循 "Horizontal Paging Strategy" 与 "Short-term Memory Lockdown" 规程。
class SyncServicePage extends StatelessWidget {
  const SyncServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: UiSizes.getHorizontalMargin(context),
      ),
      child: ChangeNotifierProvider(
        create: (_) => SyncSettingsProvider(),
        child: Column(
          children: [
            _buildSection(
              context,
              title: "Diving-Fish (水鱼)",
              child: const DfTokenAssembly(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: "LXNS (落雪)",
              child: const LxnsOAuthAssembly(),
            ),
          ],
        ),
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

/// DfTokenAssembly: 包含高性能输入框组件。颜色通过 SkinExtension 动态获取。
class DfTokenAssembly extends StatelessWidget {
  const DfTokenAssembly({super.key});

  @override
  Widget build(BuildContext context) {
    final skin = Theme.of(context).extension<SkinExtension>()!;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: skin.light.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(UiSizes.inputRadius),
            border: Border.all(color: skin.medium.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "请输入水鱼 Token",
              hintStyle: TextStyle(color: UiColors.grey400, fontSize: 14),
            ),
            style: TextStyle(color: skin.dark, fontWeight: FontWeight.bold),
            onChanged: (val) {
              context.read<SyncSettingsProvider>().updateTempDfToken(val);
            },
          ),
        ),
        const SizedBox(height: 12),
        KitBounceScaler(
          onTap: () {
            final provider = context.read<SyncSettingsProvider>();
            final transfer = context.read<TransferProvider>();
            provider.saveToGlobal(transfer);
          },
          child: Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color: skin.medium,
              borderRadius: BorderRadius.circular(UiSizes.buttonRadius),
            ),
            alignment: Alignment.center,
            child: const Text(
              "验证并保存 Token",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// LxnsOAuthAssembly: 落雪单点授权触发按键 (OAuthIsolation)
class LxnsOAuthAssembly extends StatelessWidget {
  const LxnsOAuthAssembly({super.key});

  @override
  Widget build(BuildContext context) {
    final skin = Theme.of(context).extension<SkinExtension>()!;
    final transferProvider = context.watch<TransferProvider>();

    return KitBounceScaler(
      onTap: () => transferProvider.startLxnsOAuthFlow(),
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [skin.medium, skin.dark]),
          borderRadius: BorderRadius.circular(UiSizes.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: skin.medium.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          transferProvider.isLxnsVerified ? "已授权" : "单点授权登录",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
