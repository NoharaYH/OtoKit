import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../kernel/state/toast_provider.dart';
import 'game_toast.dart';

// Fully controlled ToastOverlay replacing the old manager
class ToastOverlay extends StatefulWidget {
  final Widget child;

  const ToastOverlay({super.key, required this.child});

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // The Overlay Layer
        const Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: _ToastStackManager(key: ValueKey('ToastStackManager')),
          ),
        ),
      ],
    );
  }
}

class _ToastStackManager extends StatefulWidget {
  const _ToastStackManager({super.key});

  @override
  State<_ToastStackManager> createState() => _ToastStackManagerState();
}

class _ToastStackManagerState extends State<_ToastStackManager>
    with TickerProviderStateMixin {
  final List<ToastEntry> _entries = [];

  // Screen height percentage for bottom padding
  static const double _bottomPaddingRatio = 0.05;
  // Reduced slot height: "缩减现在高度的60%". Original 70 -> 42.
  static const double _slotHeight = 42.0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ToastProvider>();
    provider.addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    if (mounted) {
      context.read<ToastProvider>().removeListener(_onProviderUpdate);
    }
    for (var entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _onProviderUpdate() {
    if (!mounted) return;
    final provider = context.read<ToastProvider>();
    final currentToasts = provider.toasts;

    if (currentToasts.isNotEmpty) {
      final latest = currentToasts.last;
      // If we haven't seen this ID yet
      if (!_entries.any((e) => e.item.id == latest.id)) {
        _handleNewToast(latest);
      }
    }

    // Sync external removals if needed (e.g. clear all)
  }

  void _handleNewToast(ToastItem item) {
    // 1. Force Clean up "Exiting" entries to prevent overlap/logic clutter
    // Actually, we can just mark them as 'ignore for logic' but keep visual.
    // Or we force exit immediately if too many.

    // 2. Determine Slot allocations
    // Rule: New Toast -> Slot 1 (Top)
    // Existing at Slot 1 -> Move to Slot 2 (Bottom)
    // Existing at Slot 2 -> Move to Exit

    // Check current occupants
    // final occupant1 = _entries.firstWhereOrNull((e) => e.currentSlot == 1 && !e.isExiting);
    // If occupant1 exists, it will move to 2.
    // If there was something at 2 (occupant2), it moves to Exit.

    // Create new entry targeting Slot 1
    late ToastEntry newEntry;

    newEntry = ToastEntry(
      item: item,
      vsync: this,
      onDismissComplete: (id) {
        if (!mounted) return;
        setState(() {
          _entries.removeWhere((e) => e.item.id == id);
        });
        context.read<ToastProvider>().remove(id);
      },
      onSqueezeTrigger: () {
        if (!mounted) return;
        _triggerGlobalSqueeze(newEntry);
      },
      onAutoDismissStart: (entry) {
        if (!mounted) return;
        _triggerCascadeDismiss(entry);
      },
    );

    newEntry.currentSlot = 1; // It owns Slot 1 now (logically)

    setState(() {
      _entries.add(newEntry);
    });

    // Start Entry Animation
    newEntry.startEntry();
  }

  void _triggerGlobalSqueeze(ToastEntry triggerEntry) {
    // Called when the New Entry (at Slot 1) reaches 50% opacity/scale/position.
    // We must move whatever *was* at Slot 1 to Slot 2.
    // And whatever *was* at Slot 2 to Exit.

    // Implicitly, the `triggerEntry` is the one calling this.
    // It is effectively "claiming" the visual space of Slot 1.
    // The previous occupants need to get out of the way.

    // Identify logically who is where.
    // We iterate nicely.
    // The _entries list order: Oldest -> Newest.
    // So `triggerEntry` is last.
    // The one before it (if any) is the previous Newest (was at Slot 1).
    // The one before that (if any) is the previous Oldest (was at Slot 2).

    // However, we rely on `currentSlot` state.

    // Targets: Any entry that isn't the new one, and isn't already exiting.
    // We sort/filter them.
    // Actually, simple cascade:
    // Any entry with currentSlot == 1 (Old Top) -> Animate to 2.
    // Any entry with currentSlot == 2 (Old Bottom) -> Animate to Exit.

    // Optimization: Interrupt their current animations!
    // If they were waiting for timeout (auto-dismiss), CANCEL it.

    final targets = _entries
        .where((e) => !e.isExiting && e != triggerEntry)
        .toList();

    for (var target in targets) {
      // Cancel Auto-Dismiss Timer if active
      // target.cancelAutoDismiss(); // Already handled inside entry logic maybe?

      if (target.currentSlot == 1) {
        target.visibleSlot = 2; // Update target visual slot
        target.animateToSlot(2);
      } else if (target.currentSlot == 2) {
        target.visibleSlot = 3; // Exit
        target.startExit();
      }
    }
  }

  void _triggerCascadeDismiss(ToastEntry exitingEntry) {
    // Called when an entry starts auto-dismiss (timeout).
    // Typically this is the bottom-most entry (Slot 2).
    // If it exits, the one above it (Slot 1) should drop to Slot 2.

    if (exitingEntry.currentSlot == 2) {
      // Find if there is a Slot 1
      final slot1Entry = _entries.firstWhereOrNull(
        (e) => e.currentSlot == 1 && !e.isExiting,
      );
      if (slot1Entry != null) {
        // Delay slightly 150ms then drop
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && slot1Entry.isAlive && !slot1Entry.isExiting) {
            slot1Entry.visibleSlot = 2;
            slot1Entry.animateToSlot(2);
          }
        });
      }
    }
  }

  // Auto-dismiss logic: Only the BOTTOM (Slot 2) card should time out.
  // Or if there is only 1 card (at Slot 1/2), it times out.
  // We need a loop/checker?
  // No, we can just set a timer on the card itself, but coordinate.
  // Better: The card sets its own timer. When it fires, it checks:
  // "Am I the bottom-most visible card?"
  // If yes -> Exit.
  // If no -> Ignore/Reset? (Usually means it was pushed down, so it will be bottom soon?)

  // Revised: New Entry starts timer.
  // When timer fires:
  // If I am at Slot 2 (Bottom) -> Exit.
  // If I am at Slot 1 (Top) AND there is no Slot 2 -> I drop to Slot 2 then Exit? Or just Exit?
  // User: "当有单个框时...下面的(Slot 2)先移动...".
  // Let's assume natural timeout just exits from wherever it is, but cascades.

  // BUT to fix "grouping" issue (overlapping), we need strict single-file exit.
  // We'll enforce: YOU CANNOT START AUTO-EXIT if you are not the oldest active.

  // We delegate auto-dismiss initiation to the `_checkAutoDismiss` method in Manager.

  @override
  Widget build(BuildContext context) {
    // 10% of screen height
    final bottomPadding =
        MediaQuery.of(context).size.height * _bottomPaddingRatio;

    return Stack(
      children: [
        for (var entry in _entries)
          AnimatedBuilder(
            animation: Listenable.merge([
              entry.entryController,
              entry.shiftController,
              entry.exitController,
            ]),
            builder: (context, child) {
              double opacity = 1.0;
              double offsetY = 0; // Relative to bottomPadding

              // Target Offsets
              // Slot 1 (Top): 10% + SlotHeight (e.g. 70)
              // Slot 2 (Bottom): 10% + 0
              // Slot 3 (Exit): 10% - 150 (Below screen)

              const double slot1Y = _slotHeight;
              const double slot2Y = 0.0;
              const double slot3Y = -150.0;

              // Current Visual State Calculation
              if (entry.isExiting) {
                // Moving to Exit (Slot 3 position)
                // Start could be Slot 1 or Slot 2
                double startY = (entry.currentSlot == 1) ? slot1Y : slot2Y;
                // If it was squeezed from 2->3, start is 2.
                // If manual dismiss from 1, start is 1.

                // Use exitCurve (easeIn)
                offsetY = lerpDouble(startY, slot3Y, entry.exitCurve.value)!;

                // Fade out at end
                if (entry.exitController.value > 0.8) {
                  opacity = 1.0 - ((entry.exitController.value - 0.8) * 5);
                }
              } else if (entry.isShifting) {
                // Moving Slot 1 -> Slot 2
                // Curve easeInOut
                offsetY = lerpDouble(slot1Y, slot2Y, entry.shiftCurve.value)!;
              } else {
                // Entry or Static
                if (entry.entryController.isAnimating) {
                  // Entering to Slot 1?
                  // "从下方...向上弹出". Start below Slot 2?
                  // Let's start at -50.
                  // Curve handles overshoot.
                  // Target is Slot 1 (if New) or Slot 2 (if Single)?
                  // New always targets Slot 1 per trigger logic.

                  double targetY = (entry.targetSlot == 2) ? slot2Y : slot1Y;
                  // Start from below(-50)
                  offsetY = lerpDouble(-50.0, targetY, entry.entryCurve.value)!;
                } else {
                  // Static
                  offsetY = (entry.currentSlot == 1) ? slot1Y : slot2Y;
                }
              }

              return Positioned(
                bottom: bottomPadding + offsetY,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: GameToastCard(
                      message: entry.item.message,
                      type: entry.item.type,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

class ToastEntry {
  final ToastItem item;
  final TickerProvider vsync;
  final Function(String) onDismissComplete;
  final VoidCallback onSqueezeTrigger;
  final Function(ToastEntry) onAutoDismissStart;

  // Logical State
  int currentSlot = 1; // 1 = Top, 2 = Bottom.
  int visibleSlot = 1; // Where we are animating towards
  int targetSlot = 1; // Used for entry target calculation

  bool isExiting = false;
  bool isShifting = false;
  bool isAlive = true;

  // Timer
  // We use a future delayed in logic, but need to be able to cancel it.
  // Flutter Timer is cancelable.
  // But we use a flag `_cancelTimer` for simplicity with Future.delayed?
  // No, Timer class is better.
  // Or just `cancelAutoDismiss` method.
  bool _timerCancelled = false;

  // Controllers
  late final AnimationController entryController;
  late final Animation<double> entryCurve;

  late final AnimationController shiftController;
  late final Animation<double> shiftCurve;

  late final AnimationController exitController;
  late final Animation<double> exitCurve;

  ToastEntry({
    required this.item,
    required this.vsync,
    required this.onDismissComplete,
    required this.onSqueezeTrigger,
    required this.onAutoDismissStart,
  }) {
    // Entry: duration shortened (0.6x)
    // Original 600 -> 360ms
    // Original 700 -> 420ms
    entryController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 380),
    );
    entryCurve = CurvedAnimation(
      parent: entryController,
      curve: Curves.easeOutBack,
    );

    bool squeezeFired = false;
    entryController.addListener(() {
      if (!squeezeFired && entryController.value >= 0.5) {
        squeezeFired = true;
        onSqueezeTrigger();
      }
    });

    // Shift: 400 * 0.6 = 240
    shiftController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 240),
    );
    shiftCurve = CurvedAnimation(
      parent: shiftController,
      curve: Curves.easeInOut,
    );
    shiftController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isShifting = false;
        if (visibleSlot == 2) currentSlot = 2;
      }
    });

    // Exit: 400 * 0.6 = 240
    exitController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 240),
    );
    exitCurve = CurvedAnimation(parent: exitController, curve: Curves.easeIn);
    exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isAlive = false;
        onDismissComplete(item.id);
      }
    });

    // Start Auto Dismiss Timer
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!_timerCancelled && isAlive && !isExiting) {
        // Check if we are allowed to exit?
        // We just start exit. Manager handles cascade.
        // But wait, if we are Slot 1 and Slot 2 exists...
        // If Slot 2 exists, IT should timeout first (it's older).
        // So I (Slot 1) shouldn't exit yet.
        // We rely on order.
        // Assuming we are sorted by time.
        // If I am Slot 1, and Slot 2 exists, my timer will fire later than Slot 2's.
        // So Slot 2 exits. I become Slot 2. Then my timer fires.
        // Correct.
        startExit();
        onAutoDismissStart(this);

        // Trigger cascade for visual continuity?
        // If I (Slot 2) exit, Slot 1 needs to drop.
        // We can use a callback or listener in Manager.
        // But Manager doesn't listen to `startExit` directly here.
        // We should route logic through Manager?
        // No, just keep it self-contained for simple timeout.
        // The Manager loop `_onProviderUpdate` will see removal? No.
        // We need to notify Manager "I am leaving".
        // But we don't have a ref to Manager.
        // We can use `onSqueezeTrigger` equivalent for `onExitStart`?
        // Let's just animate.
        // Visual consistency: If Slot 2 leaves, Slot 1 stays at Slot 1 until Squeeze?
        // User requirement: "下面的框(Slot 2)先移动, 上面的(Slot 1)再接着移动"
        // This implies Slot 1 MUST drop to Slot 2.
        // Can we add `onExitStart` callback?
      }
    });
  }

  void cancelAutoDismiss() {
    _timerCancelled = true;
    // Also stop exit controller if pending?
    // If already exiting, we can't cancel.
  }

  void startEntry() {
    entryController.forward();
  }

  void animateToSlot(int slot) {
    if (slot == 2) {
      isShifting = true;
      // currentSlot updated on completion to avoid logic race? No, immediate updates usually safer for visual.
      // But we use 'visibleSlot' for tracking?
      currentSlot = 2; // Logic update immediately
      shiftController.forward(from: 0).then((_) {
        isShifting = false;
      });
    }
  }

  void startExit() {
    if (isExiting) return;
    isExiting = true;
    exitController.forward();
  }

  // Helper to start exit specific to cascade logic
  // But since we consolidated logic, `startExit` is enough.

  void dispose() {
    _timerCancelled = true;
    entryController.dispose();
    shiftController.dispose();
    exitController.dispose();
  }
}

// Extension re-added for firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
