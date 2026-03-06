import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

@immutable
class UtageTheme extends AppTheme {
  const UtageTheme();

  @override
  ThemeDomain get domain => ThemeDomain.maimai;

  @override
  String get themeTitle => 'UTAGE';

  @override
  String get themeId => 'utage';

  @override
  Color get light => const Color(0xFFFDE7F3);

  @override
  Color get basic => const Color(0xFFB02675);

  @override
  Color get dark => const Color(0xFF2D2D2D);

  @override
  Color get subtitleColor => Colors.white;

  @override
  Color get dotColor => const Color(0xFFED4AC9);

  @override
  Widget buildBackground(BuildContext context) {
    return const _UtageTiledBackground();
  }

  @override
  AppTheme copyWith({
    Color? light,
    Color? basic,
    Color? dark,
    Color? subtitleColor,
    Color? dotColor,
  }) {
    return AppTheme.createDynamic(
      domainVal: domain,
      titleVal: themeTitle,
      idVal: themeId,
      lightColor: light ?? this.light,
      basicColor: basic ?? this.basic,
      darkColor: dark ?? this.dark,
      subtitleColorVal: subtitleColor ?? this.subtitleColor,
      dotColorVal: dotColor ?? this.dotColor,
      baseTheme: this,
    );
  }
}

class _UtageTiledBackground extends StatefulWidget {
  const _UtageTiledBackground();

  @override
  State<_UtageTiledBackground> createState() => _UtageTiledBackgroundState();
}

class _UtageTiledBackgroundState extends State<_UtageTiledBackground>
    with SingleTickerProviderStateMixin {
  ui.Image? _image;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _loadImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final data = await DefaultAssetBundle.of(
        context,
      ).load('assets/background/maimaidx/utage/background.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (mounted) {
        setState(() => _image = image);
      }
    } catch (e) {
      debugPrint('Failed to load utage background: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return Container(color: const Color(0xFFB02675));
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // 0.0 -> 0.499: offset = 0, 0.5 -> 1.0: offset = 0.25 (闪烁感)
            final double blinkProgress = _controller.value < 0.5 ? 0.0 : 0.25;
            return CustomPaint(
              painter: _TiledPainter(_image!, blinkProgress: blinkProgress),
              size: Size.infinite,
            );
          },
        ),
        const _UtageShineEffects(),
        const _UtageDiscoBall(),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.25, // 控制外层定位盒子的高度
          child: OverflowBox(
            maxWidth: double.infinity,
            child: Image.asset(
              'assets/background/maimaidx/utage/voice.webp',
              height: MediaQuery.of(context).size.height * 0.25, // 控制图片本身的渲染高度
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.21,
          child: OverflowBox(
            minWidth: 0.0,
            maxWidth: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/background/maimaidx/utage/floor.webp',
              height: MediaQuery.of(context).size.height * 0.21,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ],
    );
  }
}

class _TiledPainter extends CustomPainter {
  final ui.Image image;
  final double blinkProgress;

  _TiledPainter(this.image, {required this.blinkProgress});

  @override
  void paint(Canvas canvas, Size size) {
    if (image.width == 0 || image.height == 0) return;

    // 屏幕高度等分为 7.5 份，决定每个模块的真实高度
    final double tileHeight = size.height / 7.5;
    final double scale = tileHeight / image.height;
    final double tileWidth = image.width * scale;

    final Paint paint = Paint()..filterQuality = FilterQuality.medium;

    // 计算因为闪烁引出的像素位移：向左上角位移 (负方向)
    final double offsetX = -(tileWidth * blinkProgress);
    final double offsetY = -(tileHeight * blinkProgress);

    // 从屏幕正中心往四周推算平铺网格的 offset
    final double startX =
        ((size.width / 2) - (tileWidth / 2)) % tileWidth - tileWidth;
    final double startY =
        ((size.height / 2) - (tileHeight / 2)) % tileHeight - tileHeight;

    // 为了防止向左上角位移25%之后，右下角漏出缝隙，我们让循环边界多延展一个单位
    for (double y = startY; y < size.height + tileHeight; y += tileHeight) {
      for (double x = startX; x < size.width + tileWidth; x += tileWidth) {
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(x + offsetX, y + offsetY, tileWidth, tileHeight),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TiledPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.blinkProgress != blinkProgress;
}

class _UtageDiscoBall extends StatefulWidget {
  const _UtageDiscoBall();

  @override
  State<_UtageDiscoBall> createState() => _UtageDiscoBallState();
}

class _UtageDiscoBallState extends State<_UtageDiscoBall> {
  Timer? _timer;
  final math.Random _random = math.Random();

  final List<ui.Image?> _balls = List.filled(5, null);
  ui.Image? _glass;
  bool _loaded = false;

  int _currentStep = 1;
  final List<int> _activeImages = [1];

  @override
  void initState() {
    super.initState();
    _loadAllImages().then((_) {
      if (mounted) {
        setState(() => _loaded = true);
        _scheduleNextTick();
      }
    });
  }

  Future<void> _loadAllImages() async {
    final bundle = DefaultAssetBundle.of(context);
    try {
      for (int i = 0; i < 5; i++) {
        final data = await bundle.load(
          'assets/background/maimaidx/utage/ball_${i + 1}.webp',
        );
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _balls[i] = frame.image;
      }
      final glassData = await bundle.load(
        'assets/background/maimaidx/utage/ball_glass.webp',
      );
      final glassCodec = await ui.instantiateImageCodec(
        glassData.buffer.asUint8List(),
      );
      final glassFrame = await glassCodec.getNextFrame();
      _glass = glassFrame.image;
    } catch (e) {
      debugPrint('Failed to load disco balls: $e');
    }
  }

  void _scheduleNextTick() {
    final int delay = 180 + _random.nextInt(121); // 180ms ~ 300ms
    _timer = Timer(Duration(milliseconds: delay), _onTick);
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      _currentStep++;
      if (_currentStep > 5) _currentStep = 1;

      _activeImages.add(_currentStep);

      final int maxOverlap = 2;

      // 移除老帧直到符合当前的上限
      while (_activeImages.length > maxOverlap) {
        _activeImages.removeAt(0);
      }
    });
    _scheduleNextTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _balls.contains(null) || _glass == null) {
      return const SizedBox.shrink();
    }

    final double baseWidth = _balls[0]!.width.toDouble();
    final double baseHeight = _balls[0]!.height.toDouble();

    // ======= 💡 在这里修改缩放比例 =======
    // 例如 0.35 表示缩小到原来的 35%
    final double scale = 0.5;
    // ====================================

    final double width = baseWidth * scale;
    final double height = baseHeight * scale;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            size: Size(width, height),
            painter: _DiscoBallPainter(
              balls: List<ui.Image>.from(_balls.whereType<ui.Image>()),
              glass: _glass!,
              activeImages: List<int>.from(_activeImages),
              scale: scale,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoBallPainter extends CustomPainter {
  final List<ui.Image> balls;
  final ui.Image glass;
  final List<int> activeImages;
  final double scale;

  _DiscoBallPainter({
    required this.balls,
    required this.glass,
    required this.activeImages,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint normalPaint = Paint();
    final Paint lightenPaint = Paint()..blendMode = BlendMode.softLight;

    canvas.save();
    canvas.scale(scale, scale);

    // 创建隔离层，确保 light 混合模式只作用在彼此之上，不穿透改变纯粉色背景色
    // 这里因为缩放了canvas，所以要把绘制区域扩展回原图的大小才能正确开辟隔离层。
    canvas.saveLayer(
      Offset.zero & Size(size.width / scale, size.height / scale),
      Paint(),
    );

    for (int i = 0; i < activeImages.length; i++) {
      final imgIndex = activeImages[i] - 1; // 转为 0 索引基准
      final img = balls[imgIndex];

      // 栈底图片正常绘制无混叠；之上图片采用浅色叠加模式
      final paint = (i == 0) ? normalPaint : lightenPaint;
      canvas.drawImage(img, Offset.zero, paint);
    }

    // cover永远在所有球体上方
    canvas.drawImage(glass, Offset.zero, normalPaint);

    canvas.restore(); // restore layer
    canvas.restore(); // restore scale
  }

  @override
  bool shouldRepaint(covariant _DiscoBallPainter oldDelegate) {
    return true; // Simple approach since activeImages changes regularly
  }
}

class _UtageShineEffects extends StatefulWidget {
  const _UtageShineEffects();

  @override
  State<_UtageShineEffects> createState() => _UtageShineEffectsState();
}

class _UtageShineEffectsState extends State<_UtageShineEffects>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();
    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ======= 💡 尺寸缩放比例 (原图直接放大到 1.5) =======
    final double visualScale = 1.8;

    // 让光效的物理中心点对准屏幕 8% 的高度处
    final double centerY = MediaQuery.of(context).size.height * 0.04;
    // 基础尺寸设为正常大小，不会触发Infinity/NaN裁剪异常
    final double baseSize = 880.0;

    return Positioned(
      top: centerY - (baseSize / 2),
      left: 0,
      right: 0,
      child: Center(
        // 通过 Transform 纯视觉放大，完全不改变实际布局约束大小，规避溢出报错
        child: Transform.scale(
          scale: visualScale,
          child: SizedBox(
            width: baseSize,
            height: baseSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 3: 逆时针 18秒
                AnimatedBuilder(
                  animation: _ctrl3,
                  builder: (_, child) => Transform.rotate(
                    angle: -_ctrl3.value * 2 * math.pi,
                    child: child,
                  ),
                  child: Image.asset(
                    'assets/background/maimaidx/utage/shine_3.webp',
                    width: baseSize,
                    height: baseSize,
                    fit: BoxFit.contain,
                  ),
                ),
                // 2: 顺时针 14秒
                AnimatedBuilder(
                  animation: _ctrl2,
                  builder: (_, child) => Transform.rotate(
                    angle: _ctrl2.value * 2 * math.pi,
                    child: child,
                  ),
                  child: Image.asset(
                    'assets/background/maimaidx/utage/shine_2.webp',
                    width: baseSize,
                    height: baseSize,
                    fit: BoxFit.contain,
                  ),
                ),
                // 1: 逆时针 11秒
                AnimatedBuilder(
                  animation: _ctrl1,
                  builder: (_, child) => Transform.rotate(
                    angle: -_ctrl1.value * 2 * math.pi,
                    child: child,
                  ),
                  child: Image.asset(
                    'assets/background/maimaidx/utage/shine_1.webp',
                    width: baseSize,
                    height: baseSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
