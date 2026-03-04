import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../application/shared/game_provider.dart';
import '../../../design_system/constants/assets.dart';
import 'score_sync_logo_wrapper.dart';
import 'score_sync_assembly.dart';

class MaiSyncPage extends StatelessWidget {
  final int mode;
  final ValueChanged<int> onModeChanged;

  const MaiSyncPage({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final skinId = gp.isThemeGlobal ? gp.activeSkinId : gp.maiSkinId;
    final logoPath = skinId == 'mai_dx'
        ? AppAssets.logoMaimaiDx
        : AppAssets.logoMaimai;

    return ScoreSyncLogoWrapper(
      logoPath: logoPath,
      subtitle: 'MaiMai DX Prober',
      child: ScoreSyncAssembly(
        key: const ValueKey('ScoreSyncAssembly_Mai'),
        mode: mode,
        onModeChanged: onModeChanged,
        gameType: 0,
      ),
    );
  }
}
