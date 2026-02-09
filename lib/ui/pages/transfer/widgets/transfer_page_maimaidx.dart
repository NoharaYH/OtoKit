import 'package:flutter/material.dart';
import 'maimai_difficulty_selector.dart';

class TransferPageMaimaiDx extends StatelessWidget {
  final Color activeColor;

  const TransferPageMaimaiDx({super.key, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    // The parent `TransferContentAnimator` already applies horizontal padding of 16.0.
    // The Tab Selector has a margin of 12 + padding of 4 = 16.0 effective offset for the inner buttons.
    // So by having 0 horizontal padding here, we align perfectly with the inner Tab buttons (16.0 total).
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: MaimaiDifficultySelector(
        activeColor: activeColor,
        onImport: () {
          // TODO: Implement Transfer Logic
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('开始导入...')));
        },
      ),
    );
  }
}
