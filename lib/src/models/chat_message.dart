enum MessageRole { user, assistant, system }

/// An optional action attached to a bot reply — rendered as a tappable
/// button under the message bubble. Supports three ways to handle the tap
/// so the SDK user (the app embedding this widget) can pick whichever
/// fits — set any combination, they all fire if set:
///
/// - [route]: a **named route** (e.g. `/pricing`) pushed via
///   `Navigator.pushNamed` on the host app's own `Navigator`.
/// - [url]: an **external URL** (e.g. `https://shopmart.com/contact`)
///   opened via `url_launcher`.
/// - [actionId]: an arbitrary string handed back via the `onAction`
///   callback on [AarohChatWidget] / `pushAarohChat`, for any custom logic.
///
/// Tap order when multiple are set: [onAction] callback first, then
/// [route] (in-app navigation), then [url] (external link) as a fallback.
class MessageAction {
  const MessageAction({
    required this.label,
    this.route,
    this.url,
    this.actionId,
  });

  /// Button text, e.g. 'View Pricing', 'Contact Us'.
  final String label;

  /// Named in-app route to push, e.g. '/pricing'. Optional.
  final String? route;

  /// External URL to open, e.g. 'https://example.com/contact'. Optional.
  final String? url;

  /// Opaque id passed to the host app's `onAction` callback. Optional.
  final String? actionId;

  Map<String, dynamic> toJson() => {
        'label': label,
        'route': route,
        'url': url,
        'actionId': actionId,
      };

  factory MessageAction.fromJson(Map<String, dynamic> json) {
    return MessageAction(
      label: json['label'] as String,
      route: json['route'] as String?,
      url: json['url'] as String?,
      actionId: json['actionId'] as String?,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
    this.action,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final bool isStreaming;

  /// Optional tappable action attached to this reply (deep link / callback).
  final MessageAction? action;

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? createdAt,
    bool? isStreaming,
    MessageAction? action,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      action: action ?? this.action,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'action': action?.toJson(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      action: json['action'] != null
          ? MessageAction.fromJson(json['action'] as Map<String, dynamic>)
          : null,
    );
  }
}
