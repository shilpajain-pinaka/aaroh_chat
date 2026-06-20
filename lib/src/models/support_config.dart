/// Configures how the bot responds when a user seems to need human support
/// and no [TopicRule] or [KnowledgeItem] matched their message.
///
/// ### Behavior
/// - If the message looks support-related (e.g. "I need help", "talk to
///   someone", "this isn't working"), the bot shows [email] by default.
/// - If [contactUsUrl] is set, its link is shown alongside the email.
/// - [phoneNumber] is **only** shown if the user explicitly asks for a
///   phone number or to call (e.g. "what's your number", "can I call you").
///   It is never shown proactively, even in a support context.
///
/// ### Example
/// ```dart
/// SupportConfig(
///   email: 'support@shopmart.com',
///   contactUsUrl: 'https://shopmart.com/contact',
///   phoneNumber: '1800-XXX-XXXX',
/// )
/// ```
class SupportConfig {
  const SupportConfig({
    required this.email,
    this.contactUsUrl,
    this.phoneNumber,
  });

  /// Support email — shown by default for support-related queries.
  final String email;

  /// Optional "Contact Us" page URL — shown as a link/action if set.
  final String? contactUsUrl;

  /// Optional phone number — shown **only** when explicitly requested.
  final String? phoneNumber;
}
