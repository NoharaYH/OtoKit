import 'package:flutter/material.dart';
import '../../../design_system/constants/assets.dart';
import '../../../design_system/visual_skins/implementations/maimai_dx/circle_background.dart';
import 'score_sync_logo_wrapper.dart';
import 'score_sync_assembly.dart';

class MaiSyncPage extends StatefulWidget {
  const MaiSyncPage({super.key});

  @override
  State<MaiSyncPage> createState() => _MaiSyncPageState();
}

class _MaiSyncPageState extends State<MaiSyncPage> {
  int _transferMode = 0;

  @override
  Widget build(BuildContext context) {
    return ScoreSyncLogoWrapper(
      logoPath: AppAssets.logoMaimai,
      subtitle: 'MaiMai DX Prober',
      themeColor: const MaimaiSkin().medium,
      child: Theme(
        data: Theme.of(context).copyWith(extensions: [const MaimaiSkin()]),
        child: ScoreSyncAssembly(
          mode: _transferMode,
          onModeChanged: (val) => setState(() => _transferMode = val),
          gameType: 0,
        ),
      ),
    );
  }
}
