import 'package:aaroh_chat/src/models/chat_message.dart';

/// A rule the SDK consumer defines: "when the user asks about X, reply
/// with Y" — optionally with a tappable action (deep link or callback).
///
/// This is the **primary** way to control built-in-engine replies for
/// non-wellness topics. Rules are checked in the order you provide them;
/// the first rule whose [triggers] match the user's message wins.
///
/// ### Example — plain reply
/// ```dart
/// TopicRule(
///   triggers: ['pricing', 'cost', 'how much'],
///   reply: 'Our Pro plan starts at ₹999/month.',
/// )
/// ```
///
/// ### Example — reply with a deep link
/// ```dart
/// TopicRule(
///   triggers: ['pricing', 'plans'],
///   reply: 'Here are our current plans:',
///   action: MessageAction(label: 'View Pricing', route: '/pricing'),
/// )
/// ```
///
/// ### Example — reply with a custom callback action
/// ```dart
/// TopicRule(
///   triggers: ['track order', 'where is my order'],
///   reply: 'Let me pull that up for you.',
///   action: MessageAction(label: 'Track Order', actionId: 'track_order'),
/// )
/// ```
class TopicRule {
  const TopicRule({
    this.id,
    required this.triggers,
    required this.reply,
    this.action,
  });

  /// Optional stable identifier for this rule.
  final String? id;

  /// Words/phrases that trigger this rule. Matching is case-insensitive
  /// substring matching — if the user's message contains any of these,
  /// the rule fires. Use short, specific phrases for best results.
  final List<String> triggers;

  /// The reply text shown to the user.
  final String reply;

  /// Optional tappable action (deep link route and/or callback id).
  final MessageAction? action;

  /// Whether [message] matches this rule.
  bool matches(String message) {
    final lower = message.toLowerCase();
    return triggers.any((t) => lower.contains(t.toLowerCase()));
  }
}
