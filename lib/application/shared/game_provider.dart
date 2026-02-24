import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  int _currentIndex = 0;
  final ValueNotifier<double> pageValueNotifier = ValueNotifier<double>(0.0);

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index.clamp(0, 1);
      notifyListeners();
    }
  }

  // Update index from PageView scroll
  void onPageChanged(int index) {
    setIndex(index);
  }

  @override
  void dispose() {
    pageValueNotifier.dispose();
    super.dispose();
  }
}
