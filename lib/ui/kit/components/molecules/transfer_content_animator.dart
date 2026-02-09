import 'package:flutter/material.dart';

class TransferContentAnimator extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const TransferContentAnimator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<TransferContentAnimator> createState() =>
      _TransferContentAnimatorState();
}

class _TransferContentAnimatorState extends State<TransferContentAnimator>
    with SingleTickerProviderStateMixin {
  late Widget _currentChild;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  // We need to keep the "old" child visible during fade out
  // But actually, we want the CURRENT child to fade out, THEN switch, THEN fade in.

  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.value = 1.0; // Start fully visible
  }

  @override
  void didUpdateWidget(covariant TransferContentAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger transition if the child key changes (e.g. from InputView to SuccessView)
    if (widget.child.key != oldWidget.child.key && !_isTransitioning) {
      _triggerTransition(widget.child);
    }
  }

  Future<void> _triggerTransition(Widget nextChild) async {
    if (!mounted) return;
    setState(() => _isTransitioning = true);

    // 1. FADE OUT
    await _controller.reverse();

    if (!mounted) return;

    // 2. CHANGE CHILD (and thus SIZE)
    setState(() {
      _currentChild = widget.child;
    });

    // 3. WAIT FOR RESIZE
    // AnimatedSize will see the new child and animate its size.
    // We wait for that animation duration plus a small buffer.
    await Future.delayed(widget.duration);

    if (!mounted) return;

    // 4. FADE IN
    await _controller.forward();

    if (mounted) setState(() => _isTransitioning = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // We wrap _currentChild to ensure layout constraints are passed down
          // Key is crucial for framework to differentiate widgets if needed,
          // but here we rely on _currentChild's internal key.
          child: _currentChild,
        ),
      ),
    );
  }
}
