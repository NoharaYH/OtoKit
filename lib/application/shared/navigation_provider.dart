import 'package:flutter/material.dart';

enum PageTag { scoreSync, musicData }

class NavigationProvider extends ChangeNotifier {
  PageTag _currentTag = PageTag.scoreSync;
  bool _isDeckOpen = false;
  bool _isSettingsOpen = false;
  double _anchorY = 0.0;

  // 用于交错动画的弹簧物理参数，按需存储
  // double _deckScrollOffset = 0.0;

  PageTag get currentTag => _currentTag;
  bool get isDeckOpen => _isDeckOpen;
  bool get isSettingsOpen => _isSettingsOpen;
  double get anchorY => _anchorY;

  /// 切换页面 (无全局路由，原地挂载)
  void switchTo(PageTag tag) {
    if (_currentTag == tag) {
      if (_isDeckOpen) closeDeck();
      return;
    }
    _currentTag = tag;
    _isDeckOpen = false; // 切换后默认收起导航
    notifyListeners();
  }

  /// 展开悬浮胶囊导航栈
  void openDeck({required double anchorY}) {
    if (_isDeckOpen) return;
    _isDeckOpen = true;
    _anchorY = anchorY;
    notifyListeners();
  }

  /// 收起悬浮胶囊导航栈
  void closeDeck() {
    if (!_isDeckOpen) return;
    _isDeckOpen = false;
    notifyListeners();
  }

  /// 拖拽更新锚点位置
  void updateAnchor(double y) {
    if (!_isDeckOpen) return;
    _anchorY = y;
    notifyListeners();
  }

  /// 打开设置页（作为叠加层）
  void openSettings() {
    if (_isDeckOpen) _isDeckOpen = false;
    _isSettingsOpen = true;
    notifyListeners();
  }

  /// 关闭设置页
  void closeSettings() {
    _isSettingsOpen = false;
    notifyListeners();
  }
}
