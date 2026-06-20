import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:aaroh_chat/src/core/theme/app_theme.dart';
import 'package:aaroh_chat/src/models/chat_message.dart';
import 'formatted_message_text.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.compact = false,
    this.onActionTap,
  });

  final ChatMessage message;
  final bool compact;

  /// Called when the user taps the message's [MessageAction] button, if any.
  final ValueChanged<MessageAction>? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatColors = AppTheme.chatColors(context);
    final isUser = message.role == MessageRole.user;
    final time = DateFormat('h:mm a').format(message.createdAt);
    final horizontalPadding = compact ? 16.0 : 20.0;

    if (isUser) {
      return _UserMessage(
        message: message,
        time: time,
        bubbleColor: chatColors.userBubble,
        textColor: chatColors.userBubbleText,
        horizontalPadding: horizontalPadding,
      );
    }

    return _AssistantMessage(
      message: message,
      time: time,
      textColor: chatColors.assistantText,
      primaryColor: theme.colorScheme.primary,
      horizontalPadding: horizontalPadding,
      onActionTap: onActionTap,
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({
    required this.message,
    required this.time,
    required this.bubbleColor,
    required this.textColor,
    required this.horizontalPadding,
  });

  final ChatMessage message;
  final String time;
  final Color bubbleColor;
  final Color textColor;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.content,
              style: AppTheme.messageStyle(
                color: textColor,
                fontSize: 15.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({
    required this.message,
    required this.time,
    required this.textColor,
    required this.primaryColor,
    required this.horizontalPadding,
    this.onActionTap,
  });

  final ChatMessage message;
  final String time;
  final Color textColor;
  final Color primaryColor;
  final double horizontalPadding;
  final ValueChanged<MessageAction>? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'आ',
                  style: AppTheme.messageStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormattedMessageText(
                      text: message.content,
                      color: textColor,
                      isStreaming: message.isStreaming,
                    ),
                    if (message.isStreaming && message.content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _StreamingCursor(color: primaryColor),
                      ),
                    if (!message.isStreaming && message.action != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: OutlinedButton(
                          onPressed: () => onActionTap?.call(message.action!),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(
                                color: primaryColor.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(message.action!.label),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 6),
            child: Text(
              time,
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor({required this.color});

  final Color color;

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 16,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
