import 'dart:ui' as ui;

enum WindowSizeClass { compact, medium, expanded, large }

enum DeviceTopology { flat, singleHinge, dualHinge }

class LayoutAnalysis {
  final WindowSizeClass sizeClass;
  final DeviceTopology topology;
  final List<ui.Rect> hingeBounds;

  const LayoutAnalysis({
    required this.sizeClass,
    required this.topology,
    this.hingeBounds = const [],
  });
}

/// 纯函数布局分析器。无状态、无副作用、无业务依赖。
/// 接收逻辑宽度与 displayFeatures，返回布局判定结果。
LayoutAnalysis analyzeLayout({
  required double widthDp,
  required List<ui.DisplayFeature> displayFeatures,
}) {
  final WindowSizeClass sizeClass;
  if (widthDp < 600) {
    sizeClass = WindowSizeClass.compact;
  } else if (widthDp < 840) {
    sizeClass = WindowSizeClass.medium;
  } else if (widthDp < 1200) {
    sizeClass = WindowSizeClass.expanded;
  } else {
    sizeClass = WindowSizeClass.large;
  }

  final hinges = displayFeatures
      .where(
        (f) =>
            f.type == ui.DisplayFeatureType.hinge ||
            f.type == ui.DisplayFeatureType.fold,
      )
      .toList();

  final DeviceTopology topology;
  final List<ui.Rect> hingeBounds;
  if (hinges.length >= 2) {
    topology = DeviceTopology.dualHinge;
    hingeBounds = hinges.map((f) => f.bounds).toList();
  } else if (hinges.length == 1) {
    topology = DeviceTopology.singleHinge;
    hingeBounds = [hinges.first.bounds];
  } else {
    topology = DeviceTopology.flat;
    hingeBounds = [];
  }

  return LayoutAnalysis(
    sizeClass: sizeClass,
    topology: topology,
    hingeBounds: hingeBounds,
  );
}
