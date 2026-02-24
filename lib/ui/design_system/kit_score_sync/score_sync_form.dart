import 'package:flutter/material.dart';
import '../constants/sizes.dart';
import '../kit_shared/confirm_button.dart';
import 'score_sync_token_field.dart';

class ScoreSyncForm extends StatelessWidget {
  final int mode;
  final TextEditingController dfController;
  final TextEditingController lxnsController;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback? onDfChanged;
  final VoidCallback? onLxnsChanged;
  final Function(String)? onDfPaste;
  final Function(String)? onLxnsPaste;

  const ScoreSyncForm({
    super.key,
    required this.mode,
    required this.dfController,
    required this.lxnsController,
    required this.isLoading,
    required this.onVerify,
    this.onDfChanged,
    this.onLxnsChanged,
    this.onDfPaste,
    this.onLxnsPaste,
  });

  @override
  Widget build(BuildContext context) {
    final needsDf = mode == 0 || mode == 1;
    final needsLxns = mode == 2 || mode == 1;

    return Column(
      key: ValueKey<int>(mode),
      children: [
        SizedBox(height: UiSizes.atomicComponentGap),
        if (needsDf)
          ScoreSyncTokenField(
            controller: dfController,
            hint: '请输入水鱼成绩导入Token',
            onChanged: onDfChanged,
            onPasteConfirmed: onDfPaste,
          ),
        if (needsLxns)
          ScoreSyncTokenField(
            controller: lxnsController,
            hint: '请输入落雪个人API密钥',
            onChanged: onLxnsChanged,
            onPasteConfirmed: onLxnsPaste,
          ),
        SizedBox(height: UiSizes.atomicComponentGap),
        ConfirmButton(
          text: '验证并保存Token',
          state: isLoading
              ? ConfirmButtonState.loading
              : ConfirmButtonState.ready,
          onPressed: onVerify,
        ),
      ],
    );
  }
}
