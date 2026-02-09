import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../kernel/state/transfer_provider.dart';
import '../../../../kernel/state/toast_provider.dart';
import '../../../../ui/kit/foundation/game_theme.dart';
import '../../../../ui/kit/foundation/ui_config.dart';
import '../../../kit/components/molecules/transfer_content_animator.dart'; // Correct relative path
import 'transfer_page_maimaidx.dart';
import 'transfer_page_chunithm.dart';

// Note: Ensure Animator is accessible. It was moved to ui/kit/components/molecules.

class TransferModeCard extends StatefulWidget {
  final int mode; // 0: Diving Fish, 1: Both, 2: LXNS
  final ValueChanged<int> onModeChanged;
  final int gameType; // 0: Maimai, 1: Chunithm

  const TransferModeCard({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.gameType,
  });

  @override
  State<TransferModeCard> createState() => _TransferModeCardState();
}

class _TransferModeCardState extends State<TransferModeCard>
    with SingleTickerProviderStateMixin {
  // Local UI state for visibility toggles
  bool _showDfToken = false;
  bool _showLxnsToken = false;

  // Animation for Staggered Effect
  late final AnimationController _staggerController;
  late final Animation<double> _tabOpacity;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Tab fades out slower, comes back later
    _tabOpacity = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(
        0.0,
        1.0,
        curve: Curves.easeIn,
      ), // Simple linear verify first
    );
    _staggerController.forward();
  }

  @override
  void didUpdateWidget(TransferModeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      // Bug 1 Fix: Reset verification on mode switch
      // We need to do this asynchronously to avoid build conflicts or do it in the callback in parent.
      // Ideally parent calls it, but here we can force it via provider access if we have context.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransferProvider>().resetAllVerification();
      });

      // Bug 3 Fix: Trigger Re-entry animation
      _staggerController.reset();
      _staggerController.forward();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access theme via ThemeExtension
    final theme = Theme.of(context).extension<GameTheme>() ?? GameTheme.maimai;

    return Consumer<TransferProvider>(
      builder: (context, provider, child) {
        // Validation Logic from Provider
        final needsDf = widget.mode == 0 || widget.mode == 1;
        final needsLxns = widget.mode == 2 || widget.mode == 1;

        // Check readiness based on provider state
        final bool isDfReady = !needsDf || provider.isDivingFishVerified;
        final bool isLxnsReady = !needsLxns || provider.isLxnsVerified;
        final bool showSuccessPage = isDfReady && isLxnsReady;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: UiConfig.defaultPadding,
          ),
          decoration: BoxDecoration(
            color: theme.transferCardBaseColor,
            borderRadius: theme.mainBorderRadius,
            border: Border.all(
              color: theme.transferCardBorderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.transferCardShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab Selector with Staggered Animation
              FadeTransition(
                opacity: _tabOpacity,
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.transferCardContainerColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _buildModeTab(0, '水鱼', theme),
                      _buildModeTab(1, '双平台', theme),
                      _buildModeTab(2, '落雪', theme),
                    ],
                  ),
                ),
              ),

              // Content Area
              TransferContentAnimator(
                duration: UiConfig.defaultAnimationDuration,
                child: showSuccessPage
                    ? _buildSuccessView(provider, theme)
                    : _buildInputView(provider, needsDf, needsLxns, theme),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessView(TransferProvider provider, GameTheme theme) {
    return Column(
      key: ValueKey<String>('Success_${widget.gameType}'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.gameType == 0 ? "选择导入难度" : "中二传分设置",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () {
                    provider.resetVerification(df: true, lxns: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.transferCardActiveColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    "返回token填写",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.gameType == 0)
          Container(
            height: 1,
            color: const Color(0xFF7B7B7B),
            margin: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          ),
        widget.gameType == 0
            ? TransferPageMaimaiDx(activeColor: theme.transferCardActiveColor)
            : const TransferPageChunithm(),
      ],
    );
  }

  Widget _buildInputView(
    TransferProvider provider,
    bool needsDf,
    bool needsLxns,
    GameTheme theme,
  ) {
    return Column(
      key: ValueKey<int>(widget.mode),
      children: [
        const SizedBox(height: 8),
        if (needsDf)
          _buildTokenField(
            controller: provider.dfController,
            hint: '请输入水鱼成绩导入Token',
            showToken: _showDfToken,
            onToggleShow: (v) => setState(() => _showDfToken = v),
            isDf: true,
            provider: provider,
          ),
        if (needsLxns)
          _buildTokenField(
            controller: provider.lxnsController,
            hint: '请输入落雪个人API密钥',
            showToken: _showLxnsToken,
            onToggleShow: (v) => setState(() => _showLxnsToken = v),
            isDf: false,
            provider: provider,
          ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: UiConfig.inputFieldHeight,
          child: ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () async {
                    bool success = await provider.verifyAndSave(
                      mode: widget.mode,
                    );

                    if (!mounted) return;

                    // Replaces native SnackBar with Custom GameToast
                    if (success) {
                      context.read<ToastProvider>().show(
                        provider.successMessage ?? '验证通过',
                        ToastType.success,
                      );
                    } else if (provider.errorMessage != null) {
                      context.read<ToastProvider>().show(
                        provider.errorMessage!,
                        ToastType.error,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.transferCardActiveColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  UiConfig.buttonBorderRadius,
                ),
              ),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '验证并保存Token',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTokenField({
    required TextEditingController controller,
    required String hint,
    required bool showToken,
    required ValueChanged<bool> onToggleShow,
    required bool isDf,
    required TransferProvider provider,
  }) {
    final hasContent = controller.text.isNotEmpty;
    final bgColor = hasContent ? Colors.grey[100] : Colors.grey[300];

    return GestureDetector(
      onTap: () async {
        if (!hasContent) {
          await _handlePasteWithConfirmation(context, provider, isDf);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: !showToken,
                onChanged: (_) {
                  // Reset specific verify status
                  if (isDf)
                    provider.resetVerification(df: true);
                  else
                    provider.resetVerification(lxns: true);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            IconButton(
              icon: Icon(
                showToken ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => onToggleShow(!showToken),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            if (hasContent)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                onPressed: () {
                  controller.clear();
                  if (isDf)
                    provider.resetVerification(df: true);
                  else
                    provider.resetVerification(lxns: true);
                },
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              )
            else
              IconButton(
                icon: const Icon(
                  Icons.content_paste,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () async {
                  await _handlePasteWithConfirmation(context, provider, isDf);
                },
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePasteWithConfirmation(
    BuildContext context,
    TransferProvider provider,
    bool isDf,
  ) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      if (!context.mounted) return;

      final shouldPaste = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('检测到剪贴板内容'),
          content: Text(
            '是否粘贴以下内容？\n\n"${text.length > 20 ? "${text.substring(0, 20)}..." : text}"',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('粘贴'),
            ),
          ],
        ),
      );

      if (shouldPaste == true) {
        provider.handlePaste(text, isDf: isDf);
      }
    }
  }

  Widget _buildModeTab(int index, String text, GameTheme theme) {
    final isSelected = widget.mode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onModeChanged(index),
        child: AnimatedContainer(
          duration: UiConfig.shortAnimationDuration,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, theme.transferCardGradientColor],
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? theme.transferCardActiveColor : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
