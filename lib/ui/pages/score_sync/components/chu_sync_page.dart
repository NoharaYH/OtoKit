import 'package:flutter/material.dart';
import '../../../design_system/constants/assets.dart';
import '../../../design_system/visual_skins/implementations/chunithm/verse_background.dart';
import 'score_sync_logo_wrapper.dart';
import 'score_sync_assembly.dart';

class ChuSyncPage extends StatefulWidget {
  const ChuSyncPage({super.key});

  @override
  State<ChuSyncPage> createState() => _ChuSyncPageState();
}

class _ChuSyncPageState extends State<ChuSyncPage> {
  int _transferMode = 0;

  @override
  Widget build(BuildContext context) {
    return ScoreSyncLogoWrapper(
      logoPath: AppAssets.logoChunithm,
      subtitle: 'CHUNITHM Prober',
      themeColor: const ChunithmSkin().medium,
      child: Theme(
        data: Theme.of(context).copyWith(extensions: [const ChunithmSkin()]),
        child: ScoreSyncAssembly(
          key: const ValueKey('ScoreSyncAssembly_Chu'),
          mode: _transferMode,
          onModeChanged: (val) => setState(() => _transferMode = val),
          gameType: 1,
        ),
      ),
    );
  }
}
