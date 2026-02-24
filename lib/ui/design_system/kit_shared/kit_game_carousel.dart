import 'package:flutter/material.dart';
import '../constants/sizes.dart';
import 'game_page_item.dart';
import 'sticky_dot_indicator.dart';

/// 统一游戏轮播外壳 (Core Animation Engine)
///
/// 核心职责：
/// 1. 实现背景层在多个皮肤间的平滑插值 (Skin Lerp)
/// 2. 实现内容层在滑动时的视差挤压动效 (Parallax & Scale)
/// 3. 实现分页指示器的自动变色与粘性动画
class KitGameCarousel extends StatelessWidget {
  final List<GamePageItem> items;
  final PageController controller;
  final ValueChanged<int>? onPageChanged;
  final List<Widget>? headerActions;

  const KitGameCarousel({
    super.key,
    required this.items,
    required this.controller,
    this.onPageChanged,
    this.headerActions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 2. 分页指示器 (自动感知皮肤变色)
        Positioned(
          top: UiSizes.getDotIndicatorTop(context),
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final double page = _safePage;
                final int index = page.floor();
                final double t = (page - index).clamp(0.0, 1.0);

                // 获取当前页与下一页的皮肤进行插值
                final currentSkin =
                    items[index.clamp(0, items.length - 1)].skin;
                final nextSkin =
                    items[(index + 1).clamp(0, items.length - 1)].skin;
                final lerpedSkin = currentSkin.lerp(nextSkin, t);

                return Theme(
                  data: Theme.of(context).copyWith(extensions: [lerpedSkin]),
                  child: StickyDotIndicator(
                    controller: controller,
                    count: items.length,
                  ),
                );
              },
            ),
          ),
        ),

        // 3. 内容层 (具备挤压动效的 PageView)
        Positioned.fill(
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, _) => _buildParallaxPage(context, index),
              );
            },
          ),
        ),

        // 4. 通用页眉操作区
        if (headerActions != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: headerActions!,
            ),
          ),
      ],
    );
  }

  /// 构建视差挤压分页内容
  Widget _buildParallaxPage(BuildContext context, int index) {
    final double page = _safePage;
    final double width = MediaQuery.of(context).size.width;
    final double diff = (page - index);
    final double absDiff = diff.abs();
    final double opacity = (1 - absDiff).clamp(0.0, 1.0);

    // 视差参数定义
    final double centerOffset = diff * width;
    final double slideEffect = -diff * 100.0; // 视差偏移系数
    final double scaleX = (1 - (absDiff * 0.2)).clamp(0.0, 1.0); // 挤压系数

    return Transform.translate(
      offset: Offset(centerOffset + slideEffect, 0),
      child: Transform(
        transform: Matrix4.diagonal3Values(scaleX, 1.0, 1.0),
        alignment: Alignment.center,
        child: Opacity(
          opacity: opacity,
          child: IgnorePointer(
            ignoring: absDiff > 0.5,
            child: Theme(
              data: Theme.of(context).copyWith(extensions: [items[index].skin]),
              child: items[index].content,
            ),
          ),
        ),
      ),
    );
  }

  double get _safePage {
    if (controller.hasClients) {
      return controller.page ?? controller.initialPage.toDouble();
    }
    return controller.initialPage.toDouble();
  }
}
