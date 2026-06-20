import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aaroh_chat/src/core/theme/app_theme.dart';
import 'package:aaroh_chat/src/models/aaroh_config.dart';
import 'package:aaroh_chat/src/models/user_settings.dart';
import 'package:aaroh_chat/src/providers/sdk_chat_provider.dart';
import 'package:aaroh_chat/src/screens/sdk_chat_screen.dart';

export 'package:aaroh_chat/src/models/aaroh_config.dart';

/// ## AarohChatWidget
///
/// Drop-in Flutter widget that provides a full-featured chat UI.
///
/// ### Basic usage:
/// ```dart
/// AarohChatWidget(
///   config: AarohConfig(
///     companyName: 'MyApp',
///     knowledgeBase: ['We sell premium laptops...', 'Return policy: 30 days...'],
///   ),
/// )
/// ```
///
/// ### With structured knowledge (better matching + categories):
/// ```dart
/// AarohChatWidget(
///   config: AarohConfig(
///     companyName: 'MyApp',
///     knowledgeBase: [
///       KnowledgeItem(
///         question: 'What is your return policy?',
///         answer: '30-day hassle-free returns.',
///         category: 'Policies',
///         keywords: ['refund', 'exchange'],
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### With Claude API:
/// ```dart
/// AarohChatWidget(
///   config: AarohConfig(
///     companyName: 'MyApp',
///     claudeApiKey: 'sk-ant-...',
///     knowledgeBase: ['Product info...'],
///     searchEngineData: ['Q: What is your price? A: Starting ₹999'],
///   ),
/// )
/// ```
class AarohChatWidget extends StatefulWidget {
  const AarohChatWidget({
    super.key,
    required this.config,
    this.onAction,
    this.routes,
    this.onGenerateRoute,
  });

  /// SDK configuration — company branding, knowledge base, Claude API key.
  final AarohConfig config;

  /// Called when the user taps a reply action with a
  /// [MessageAction.actionId] set — run any custom logic here.
  final void Function(String actionId)? onAction;

  /// If a reply action has a [MessageAction.route] set (e.g. `/pricing`),
  /// it's resolved against these routes / [onGenerateRoute] inside this
  /// widget's own navigator. Pass the same route table your app already
  /// uses if you want deep links from the bot to navigate correctly.
  ///
  /// Not needed if you only use [MessageAction.url] or
  /// [MessageAction.actionId] — or if you use [pushAarohChat] instead,
  /// which reuses your existing app's navigator directly.
  final Map<String, WidgetBuilder>? routes;

  /// Alternative to [routes] for dynamic route generation.
  final RouteFactory? onGenerateRoute;

  @override
  State<AarohChatWidget> createState() => _AarohChatWidgetState();
}

class _AarohChatWidgetState extends State<AarohChatWidget> {
  late final SdkChatProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider =
        SdkChatProvider(config: widget.config, onAction: widget.onAction);
    _provider.initialize();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = const UserSettings();

    return ChangeNotifierProvider.value(
      value: _provider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(settings),
        routes: widget.routes ?? const {},
        onGenerateRoute: widget.onGenerateRoute,
        home: SdkChatScreen(config: widget.config),
      ),
    );
  }
}

/// Convenience function to push the Aaroh chat screen onto an existing navigator.
///
/// Use this if you already have a MaterialApp and just want to navigate to chat.
/// Unlike [AarohChatWidget], this reuses your app's own Navigator — so any
/// [MessageAction.route] from a bot reply will resolve against routes your
/// app already has registered, no extra setup needed.
///
/// The Aaroh chat screen brings its own [Theme] (built via
/// [AppTheme.build]) regardless of your app's theme, so it always renders
/// correctly even if your app's `ThemeData` doesn't know about Aaroh's
/// internal `ChatColors` theme extension.
///
/// ```dart
/// ElevatedButton(
///   onPressed: () => pushAarohChat(
///     context,
///     config: myConfig,
///     onAction: (actionId) {
///       if (actionId == 'track_order') { /* ... */ }
///     },
///   ),
///   child: Text('Open Chat'),
/// )
/// ```
Future<void> pushAarohChat(
  BuildContext context, {
  required AarohConfig config,
  void Function(String actionId)? onAction,
}) async {
  final provider = SdkChatProvider(config: config, onAction: onAction);
  await provider.initialize();

  if (!context.mounted) return;

  const settings = UserSettings();

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: Theme(
          data: AppTheme.build(settings),
          child: SdkChatScreen(config: config),
        ),
      ),
    ),
  );

  provider.dispose();
}
