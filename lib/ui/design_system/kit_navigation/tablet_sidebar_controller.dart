import 'package:flutter/material.dart';

/// 【架构红线·平板专属状态】平板侧边栏专用状态（open/close/expand/collapse/leaving）。
/// 仅在 OtokitResponsiveShell._buildExpandedLayout 子树内 ChangeNotifierProvider，手机路径不可见、
/// 不依赖；禁止将此状态放入 NavigationProvider 或全局单例。
class TabletSidebarController extends ChangeNotifier {
  bool _isOpen = false;
  bool _isExpanded = false;
  int _side = 0; // 0=左 1=右
  int? _leavingSide;
  bool _isClosing = false;

  bool get isOpen => _isOpen;
  bool get isExpanded => _isExpanded;
  int get side => _side;
  int? get leavingSide => _leavingSide;
  bool get isClosing => _isClosing;

  /// 从指定侧唤出侧边栏（0=左 1=右）。切换侧时保持展开态，并设 leavingSide 供 UI 播滑出动画。
  void open(int side) {
    if (_isOpen && _side == side) return;
    final wasSwitching = _isOpen && _side != side;
    _isOpen = true;
    if (wasSwitching) {
      _leavingSide = _side;
      _side = side;
    } else {
      _isExpanded = false;
      _side = side;
    }
    notifyListeners();
  }

  /// 滑出动画结束后由 UI 调用，清除 leaving 侧。
  void clearLeaving() {
    if (_leavingSide == null) return;
    _leavingSide = null;
    notifyListeners();
  }

  /// 收起侧边栏（仅标记关闭中，侧边栏播完退出动画后需由 UI 调用 finalizeClose）。
  void close() {
    if (!_isOpen || _isClosing) return;
    _isClosing = true;
    _leavingSide = null;
    notifyListeners();
  }

  /// 退出动画结束后由 UI 回调，真正关闭所有侧边栏状态。
  void finalizeClose() {
    if (!_isClosing) return;
    _isOpen = false;
    _isClosing = false;
    _isExpanded = false;
    notifyListeners();
  }

  /// 展开侧边栏。
  void expand() {
    if (!_isOpen) return;
    _isExpanded = true;
    notifyListeners();
  }

  /// 收起侧边栏展开态（保留单圆侧边栏）。
  void collapse() {
    if (!_isOpen) return;
    _isExpanded = false;
    notifyListeners();
  }
}
