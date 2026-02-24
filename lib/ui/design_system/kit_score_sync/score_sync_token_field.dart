import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/sizes.dart';

class ScoreSyncTokenField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onChanged;
  final Function(String)? onPasteConfirmed;

  const ScoreSyncTokenField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onPasteConfirmed,
  });

  @override
  State<ScoreSyncTokenField> createState() => _ScoreSyncTokenFieldState();
}

class _ScoreSyncTokenFieldState extends State<ScoreSyncTokenField> {
  bool _showToken = false;
  String? _pendingClipboard;

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.controller.text.isNotEmpty;
    final bgColor = hasContent ? Colors.grey[100] : Colors.grey[300];

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (!hasContent) {
              await _handlePasteWithConfirmation();
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: UiSizes.atomicComponentGap),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(UiSizes.buttonBorderRadius),
            ),
            padding: const EdgeInsets.only(
              left: UiSizes.cardContentPadding,
              top: 4,
              bottom: 4,
              right: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    obscureText: !_showToken,
                    onChanged: (val) {
                      setState(() => _pendingClipboard = null);
                      widget.onChanged?.call();
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _showToken = !_showToken),
                    child: Icon(
                      _showToken ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                if (hasContent)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        widget.controller.clear();
                        setState(() => _pendingClipboard = null);
                        widget.onChanged?.call();
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: GestureDetector(
                      onTap: _handlePasteWithConfirmation,
                      child: const Icon(
                        Icons.content_paste,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            if (child.key == const ValueKey('empty_clipboard')) {
              return child;
            }
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.4, 1.0),
                ),
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: UiSizes.atomicComponentGap,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(
                      UiSizes.buttonBorderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: UiSizes.atomicComponentGap,
                      horizontal: UiSizes.cardContentPadding,
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: _pendingClipboard != null
              ? KeyedSubtree(
                  key: ValueKey('paste_box_$_pendingClipboard'),
                  child: _buildPasteConfirmBoxContent(_pendingClipboard!),
                )
              : const SizedBox(
                  key: ValueKey('empty_clipboard'),
                  width: double.infinity,
                  height: 0,
                ),
        ),
      ],
    );
  }

  Future<void> _handlePasteWithConfirmation() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      if (!mounted) return;
      setState(() => _pendingClipboard = text);
    }
  }

  Widget _buildPasteConfirmBoxContent(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '是否要粘贴以下内容？',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: UiSizes.spaceXXS),
              Text(
                _showToken ? text : '•' * text.length.clamp(0, 20),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: _showToken
                    ? TextOverflow.ellipsis
                    : TextOverflow.clip,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  final textToPaste = _pendingClipboard!;
                  setState(() => _pendingClipboard = null);
                  widget.controller.text = textToPaste;
                  widget.onPasteConfirmed?.call(textToPaste);
                },
                child: Container(
                  padding: const EdgeInsets.all(UiSizes.spaceXXS),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 16),
                ),
              ),
              const SizedBox(width: UiSizes.spaceXS),
              GestureDetector(
                onTap: () => setState(() => _pendingClipboard = null),
                child: Container(
                  padding: const EdgeInsets.all(UiSizes.spaceXXS),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
