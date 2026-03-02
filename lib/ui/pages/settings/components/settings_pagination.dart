import 'package:flutter/material.dart';
import '../../../design_system/kit_shared/kit_game_carousel.dart';
import '../../../design_system/kit_shared/game_page_item.dart';

/// 动效协议 C: 封装横向翻页策略 (Paging Strategy)
/// 使用 KitGameCarousel 引擎。以解决长列表配置的视觉疲劳。
class SettingsPagination extends StatefulWidget {
  final List<GamePageItem> categories;

  const SettingsPagination({super.key, required this.categories});

  @override
  State<SettingsPagination> createState() => _SettingsPaginationState();
}

class _SettingsPaginationState extends State<SettingsPagination> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: KitGameCarousel(
        items: widget.categories,
        controller: _pageController,
        onPageChanged: (index) {
          // 可以在此分发 category 切换事件
        },
      ),
    );
  }
}
