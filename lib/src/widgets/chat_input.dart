import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:aaroh_chat/src/core/theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.hint = 'Type your message…',
  });

  final ValueChanged<String> onSend;
  final bool isLoading;
  final String hint;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final SpeechToText _speech = SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone not available on this device.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          setState(() {});
        }
        if (result.finalResult) {
          setState(() => _isListening = false);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend(text);
    _controller.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatColors = AppTheme.chatColors(context);
    final hasText = _controller.text.trim().isNotEmpty;
    final canSend = hasText && !widget.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Mic button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isListening
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  size: 20,
                  color: _isListening
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: _isListening ? 'Stop listening' : 'Voice input',
                onPressed: widget.isLoading ? null : _toggleListening,
              ),
            ),
            const SizedBox(width: 8),
            // Text field
            Expanded(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    style: AppTheme.messageStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Listening…' : widget.hint,
                      filled: true,
                      fillColor: chatColors.inputBackground,
                      hintStyle: AppTheme.messageStyle(
                        color: _isListening
                            ? theme.colorScheme.error.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.55),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: _isListening
                              ? theme.colorScheme.error.withValues(alpha: 0.5)
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.4),
                          width: _isListening ? 1.5 : 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: canSend
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: canSend ? _submit : null,
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: canSend
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
