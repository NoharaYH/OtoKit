import 'package:flutter/material.dart';
import '../constants/sizes.dart';
import '../constants/strings.dart';
import '../kit_shared/confirm_button.dart';
import 'score_sync_token_field.dart';

class ScoreSyncForm extends StatelessWidget {
  final int mode;
  final TextEditingController dfController;
  final TextEditingController lxnsController;
  final bool isLoading;
  final bool isDisabled;
  final bool isLxnsOAuthDone; // 是否已完成 OAuth
  final GlobalKey? lxnsFieldKey; // 用于触发确认框
  final VoidCallback onVerify;
  final VoidCallback? onDfChanged;
  final VoidCallback? onLxnsChanged;
  final Function(String)? onDfPaste;
  final Function(String)? onLxnsPaste;
  final VoidCallback? onLxnsOAuth;

  const ScoreSyncForm({
    super.key,
    required this.mode,
    required this.dfController,
    required this.lxnsController,
    required this.isLoading,
    this.isDisabled = false,
    this.isLxnsOAuthDone = false,
    this.lxnsFieldKey,
    required this.onVerify,
    this.onDfChanged,
    this.onLxnsChanged,
    this.onDfPaste,
    this.onLxnsPaste,
    this.onLxnsOAuth,
  });

  @override
  Widget build(BuildContext context) {
    final needsDf = mode == 0 || mode == 1;
    final needsLxns = mode == 2 || mode == 1;

    return Column(
      key: ValueKey<int>(mode),
      children: [
        if (needsDf)
          ScoreSyncTokenField(
            controller: dfController,
            hint: UiStrings.inputDivingFishToken,
            onChanged: onDfChanged,
            onPasteConfirmed: onDfPaste,
            isDisabled: isDisabled,
          ),
        if (needsLxns) ...[
          // OAuth 模式下，落雪不再需要手动输入 Token 框
          if (!isLxnsOAuthDone)
            ConfirmButton(
              text: UiStrings.authLxnsOAuth,
              fontSize: 14,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: isDisabled ? null : onLxnsOAuth,
            )
          else
            // 已授权时显示验证按钮（虽然 OAuth 成功通常即视为验证通过，但保留手动触发同步的入口）
            ConfirmButton(
              text: UiStrings.authLxnsVerify,
              fontSize: 14,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: isDisabled ? null : onVerify,
            ),
        ],
        // 如果是水鱼模式，保留底部的总验证按钮
        if (mode == 0) ...[
          ConfirmButton(
            text: isDisabled
                ? UiStrings.waitTransferEnd
                : UiStrings.verifyAndSave,
            state: isLoading
                ? ConfirmButtonState.loading
                : ConfirmButtonState.ready,
            borderRadius: UiSizes.buttonRadius,
            onPressed: isDisabled ? null : onVerify,
          ),
        ],
      ],
    );
  }
}
