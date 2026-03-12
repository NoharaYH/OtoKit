import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/shared/navigation_provider.dart';
import '../constants/strings.dart';
import '../theme/core/app_theme.dart';

/// Medium+ 模式下替代 NavDeckOverlay 的持久侧边导航组件。
/// 消费 NavigationProvider 的 currentTag / isDeckOpen 语义；忽略 anchorY。
class KitNavRail extends StatelessWidget {
  const KitNavRail({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor =
        Theme.of(context).extension<AppTheme>()?.basic ?? Colors.blue;

    return Consumer<NavigationProvider>(
      builder: (context, nav, _) {
        return NavigationRail(
          selectedIndex: nav.currentTag == PageTag.scoreSync ? 0 : 1,
          onDestinationSelected: (index) {
            nav.switchTo(index == 0 ? PageTag.scoreSync : PageTag.musicData);
          },
          extended: nav.isDeckOpen,
          backgroundColor: Colors.transparent,
          indicatorColor: themeColor.withValues(alpha: 0.15),
          selectedIconTheme: IconThemeData(color: themeColor),
          selectedLabelTextStyle: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'JiangCheng',
          ),
          unselectedLabelTextStyle: const TextStyle(fontFamily: 'JiangCheng'),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: IconButton(
                  icon: Icon(Icons.menu_open, color: themeColor),
                  tooltip: nav.isDeckOpen ? '收起导航' : '展开导航',
                  onPressed: () {
                    if (nav.isDeckOpen) {
                      nav.closeDeck();
                    } else {
                      nav.openDeck(anchorY: 0);
                    }
                  },
                ),
              ),
            ),
          ),
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.sync_outlined),
              selectedIcon: const Icon(Icons.sync),
              label: Text(UiStrings.navScoreSync),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.library_music_outlined),
              selectedIcon: const Icon(Icons.library_music),
              label: Text(UiStrings.navMusicData),
            ),
          ],
        );
      },
    );
  }
}
