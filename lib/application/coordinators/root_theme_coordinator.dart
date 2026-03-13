import 'package:flutter/material.dart';

import '../mai/mai_music_provider.dart';
import '../shared/game_provider.dart';
import '../shared/navigation_provider.dart';
import '../../ui/design_system/theme/core/app_theme.dart';
import '../../ui/design_system/theme/special_theme/utage.dart';
import '../../ui/design_system/theme/theme_catalog.dart';
import 'resolved_theme_bundle.dart';

/// 单点计算并输出当前解析后的 [ResolvedThemeBundle]，
/// 供 RootPage 唯一消费，消除三处 Consumer2 重复计算与多次重建。
///
/// 独立模式下输出 Stack + Opacity 跨域渐隐背景，恢复舞萌↔中二切换时的平滑过渡。
class RootThemeCoordinator {
  RootThemeCoordinator(
    this._gameProvider,
    this._maiMusicProvider,
    this._navProvider,
  ) : resolvedBundle = ValueNotifier(_compute(_gameProvider, _maiMusicProvider, _navProvider)) {
    _gameProvider.addListener(_recompute);
    _maiMusicProvider.addListener(_recompute);
    _navProvider.addListener(_recompute);
    _gameProvider.pageValueNotifier.addListener(_recompute);
  }

  final GameProvider _gameProvider;
  final MusicLibraryController _maiMusicProvider;
  final NavigationProvider _navProvider;

  final ValueNotifier<ResolvedThemeBundle> resolvedBundle;

  void _recompute() {
    resolvedBundle.value = _compute(_gameProvider, _maiMusicProvider, _navProvider);
  }

  static ResolvedThemeBundle _compute(
    GameProvider gp,
    MusicLibraryController maiMusicProvider,
    NavigationProvider nav,
  ) {
    if (gp.isThemeGlobal) {
      final baseSkin = ThemeCatalog.findThemeById(gp.activeSkinId);
      final theme = gp.resolvedTheme(baseSkin);
      return ResolvedThemeBundle(
        theme: theme,
        buildBackground: (ctx) => theme.buildBackground(ctx),
      );
    }

    final double t = gp.pageValueNotifier.value.clamp(0.0, 1.0);
    final isUtage = nav.currentTag == PageTag.musicData && maiMusicProvider.isUtageMode;
    final AppTheme maiSkin;
    if (isUtage) {
      maiSkin = const UtageTheme();
    } else {
      maiSkin = gp.resolvedTheme(ThemeCatalog.findThemeById(gp.maiSkinId));
    }
    final chuSkin = gp.resolvedTheme(ThemeCatalog.findThemeById(gp.chuSkinId));
    final theme = maiSkin.lerp(chuSkin, t);

    // 独立模式：Stack + Opacity 跨域渐隐过渡。
    // 子节点必须用 Positioned.fill 包裹，否则 Stack 给非定位子节点无界约束，导致 RenderOpacity NEEDS-LAYOUT（仅中二页触发）。
    return ResolvedThemeBundle(
      theme: theme,
      buildBackground: (ctx) => Stack(
        fit: StackFit.expand,
        children: [
          if (t < 1.0) Positioned.fill(child: maiSkin.buildBackground(ctx)),
          if (t > 0.0)
            Positioned.fill(
              child: Opacity(
                opacity: t,
                child: chuSkin.buildBackground(ctx),
              ),
            ),
        ],
      ),
    );
  }

  void dispose() {
    _gameProvider.removeListener(_recompute);
    _maiMusicProvider.removeListener(_recompute);
    _navProvider.removeListener(_recompute);
    _gameProvider.pageValueNotifier.removeListener(_recompute);
    resolvedBundle.dispose();
  }
}
