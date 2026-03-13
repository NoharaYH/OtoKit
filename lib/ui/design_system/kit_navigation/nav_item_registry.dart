import 'package:flutter/material.dart';

import '../../../../application/shared/navigation_provider.dart';
import '../constants/strings.dart';

/// 导航项描述符。仅数据，无状态、无 UI。
///
/// 手机（NavDeckOverlay）与平板（TabletSidebarMinimal）共用此描述符列表，
/// 各自独立渲染；新增入口时仅在此处添加一条即可双端生效。
class NavItemDescriptor {
  final PageTag? tag;
  final IconData icon;
  final String label;
  final String subLabel;
  final Color? color;

  const NavItemDescriptor({
    required this.tag,
    required this.icon,
    required this.label,
    required this.subLabel,
    this.color,
  });
}

/// 侧边栏/浮层导航入口唯一定义处。
///
/// 新增选项：在此列表增加一条；若为新页面，另在 [PageTag] 与 RootPage 路由中增加对应项。
final class NavItemRegistry {
  NavItemRegistry._();

  static const List<NavItemDescriptor> entries = [
    NavItemDescriptor(
      tag: PageTag.scoreSync,
      icon: Icons.sync,
      label: UiStrings.navScoreSync,
      subLabel: 'score data sync',
      color: Colors.green,
    ),
    NavItemDescriptor(
      tag: PageTag.musicData,
      icon: Icons.library_music,
      label: UiStrings.navMusicData,
      subLabel: 'music data base',
      color: Colors.blue,
    ),
    NavItemDescriptor(
      tag: null,
      icon: Icons.more_horiz,
      label: UiStrings.navComingSoon,
      subLabel: 'coming soon',
      color: null,
    ),
  ];
}
