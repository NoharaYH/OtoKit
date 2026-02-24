import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/shared/game_provider.dart';
import '../../design_system/kit_shared/game_page_item.dart';
import '../../design_system/kit_shared/kit_game_carousel.dart';

// Contents
import 'components/mai_sync_page.dart';
import 'components/chu_sync_page.dart';

// Skins
import '../../design_system/visual_skins/implementations/maimai_dx/circle_background.dart';
import '../../design_system/visual_skins/implementations/chunithm/verse_background.dart';

class ScoreSyncPage extends StatefulWidget {
  const ScoreSyncPage({super.key});

  @override
  State<ScoreSyncPage> createState() => _ScoreSyncPageState();
}

class _ScoreSyncPageState extends State<ScoreSyncPage> {
  late final PageController _localController;

  @override
  void initState() {
    super.initState();
    final gameProvider = context.read<GameProvider>();
    _localController = PageController(initialPage: gameProvider.currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        gameProvider.pageValueNotifier.value = _localController.initialPage
            .toDouble();
      }
    });

    _localController.addListener(() {
      if (_localController.hasClients && _localController.page != null) {
        gameProvider.pageValueNotifier.value = _localController.page!;
      }
    });
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();

    return KitGameCarousel(
      controller: _localController,
      onPageChanged: gameProvider.onPageChanged,
      items: [
        const GamePageItem(
          skin: MaimaiSkin(),
          content: MaiSyncPage(),
          title: 'Maimai DX',
        ),
        const GamePageItem(
          skin: ChunithmSkin(),
          content: ChuSyncPage(),
          title: 'Chunithm',
        ),
      ],
    );
  }
}
