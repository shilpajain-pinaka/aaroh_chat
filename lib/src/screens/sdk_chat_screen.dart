import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aaroh_chat/src/core/theme/app_theme.dart';
import 'package:aaroh_chat/src/models/aaroh_config.dart';
import 'package:aaroh_chat/src/providers/sdk_chat_provider.dart';
import 'package:aaroh_chat/src/screens/history_screen.dart';
import 'package:aaroh_chat/src/screens/language_screen.dart';
import 'package:aaroh_chat/src/widgets/chat_input.dart';
import 'package:aaroh_chat/src/widgets/crisis_banner.dart';
import 'package:aaroh_chat/src/widgets/message_bubble.dart';
import 'package:aaroh_chat/src/widgets/sdk_welcome_card.dart';

/// Main chat screen exposed by the Aaroh SDK.
/// Shows company branding at top, "Powered by Aaroh" at bottom,
/// and only 3 navigation options: Chat / History / Language.
class SdkChatScreen extends StatefulWidget {
  const SdkChatScreen({super.key, required this.config});

  final AarohConfig config;

  @override
  State<SdkChatScreen> createState() => _SdkChatScreenState();
}

class _SdkChatScreenState extends State<SdkChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;

    return Consumer<SdkChatProvider>(
      builder: (context, chat, _) {
        if (chat.messages.isNotEmpty || chat.isStreaming) {
          _scrollToBottom();
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 1,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Company logo or fallback initial
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: config.companyLogoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            config.companyLogoUrl ?? '',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _companyInitial(config.companyName, theme),
                          ),
                        )
                      : _companyInitial(config.companyName, theme),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.companyName,
                      style:
                          AppTheme.brandTitleStyle(theme.colorScheme.onSurface)
                              .copyWith(fontSize: 17),
                    ),
                    Text(
                      chat.isStreaming ? 'Typing…' : 'Online',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // History icon (top right)
              IconButton(
                tooltip: 'Chat History',
                icon: const Icon(Icons.history_rounded, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: chat,
                      child: const HistoryScreen(),
                    ),
                  ),
                ),
              ),
              // Language icon
              IconButton(
                tooltip: 'Language',
                icon: const Icon(Icons.language_rounded, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: chat,
                      child: const LanguageScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Crisis banner
              if (chat.showCrisisBanner)
                CrisisBanner(onDismiss: chat.dismissCrisisBanner),

              // Error banner
              if (chat.error != null)
                MaterialBanner(
                  content: Text(chat.error ?? 'Something Went Wrong'),
                  leading: const Icon(Icons.error_outline),
                  backgroundColor: theme.colorScheme.errorContainer,
                  actions: [
                    TextButton(
                      onPressed: chat.clearError,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),

              // Message list or welcome card
              Expanded(
                child: chat.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chat.messages.isEmpty
                        ? SdkWelcomeCard(
                            config: config,
                            onSuggestionTap: chat.sendMessage,
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: chat.messages.length,
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: MessageBubble(
                                  message: chat.messages[index],
                                  compact: false,
                                  onActionTap: (action) =>
                                      _handleAction(context, chat, action),
                                ),
                              );
                            },
                          ),
              ),

              // Chat input
              ChatInput(
                onSend: chat.sendMessage,
                isLoading: chat.isStreaming,
                hint: 'Ask anything…',
              ),

              // Powered by Aaroh footer
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                color: theme.colorScheme.surfaceContainerLowest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      config.poweredByText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _companyInitial(String name, ThemeData theme) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'A',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Resolves a tapped [MessageAction] in priority order:
  /// 1. Fires the host app's `onAction` callback (if `actionId` is set)
  /// 2. Pushes the named [MessageAction.route] via this screen's Navigator
  /// 3. Opens [MessageAction.url] externally
  Future<void> _handleAction(
    BuildContext context,
    SdkChatProvider chat,
    MessageAction action,
  ) async {
    chat.handleAction(action);

    if (action.route != null) {
      try {
        Navigator.of(context).pushNamed(action.route!);
        return;
      } catch (_) {
        // No matching named route registered in the host app — fall
        // through to url, if any, rather than crashing.
      }
    }

    if (action.url != null) {
      final uri = Uri.tryParse(action.url ?? '');
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
