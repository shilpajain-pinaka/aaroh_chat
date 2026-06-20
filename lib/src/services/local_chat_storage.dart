import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:aaroh_chat/src/models/chat_message.dart';
import 'package:aaroh_chat/src/models/chat_session.dart';

/// Local-only chat storage with multi-session support.
class LocalChatStorage extends ChangeNotifier {
  static const _sessionsKey = 'aaroh_sessions';

  final _uuid = const Uuid();
  List<ChatSession> _sessions = [];
  String? _activeSessionId;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  String? get activeSessionId => _activeSessionId;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _sessions = list
            .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } catch (_) {
        _sessions = [];
      }
    }
    notifyListeners();
  }

  /// Start a fresh new session and return its id.
  String startNewSession() {
    final id = _uuid.v4();
    final now = DateTime.now();
    final session = ChatSession(
      id: id,
      title: 'New Chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
    _sessions.insert(0, session);
    _activeSessionId = id;
    _persistSessions();
    notifyListeners();
    return id;
  }

  void setActiveSession(String sessionId) {
    _activeSessionId = sessionId;
    notifyListeners();
  }

  List<ChatMessage> loadActiveMessages() {
    if (_activeSessionId == null) return [];
    final idx = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (idx == -1) return [];
    return List.from(_sessions[idx].messages);
  }

  Future<void> saveMessage(ChatMessage message) async {
    if (_activeSessionId == null) return;
    final idx = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (idx == -1) return;

    final session = _sessions[idx];
    final updated = List<ChatMessage>.from(session.messages)..add(message);

    // Generate title from the first user message
    String title = session.title;
    if (title == 'New Chat' && message.role == MessageRole.user) {
      title = message.content.length > 40
          ? '${message.content.substring(0, 40)}…'
          : message.content;
    }

    _sessions[idx] = session.copyWith(
      messages: updated,
      title: title,
      updatedAt: DateTime.now(),
    );
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _persistSessions();
    notifyListeners();
  }

  Future<void> updateLastMessage(ChatMessage message) async {
    if (_activeSessionId == null) return;
    final idx = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (idx == -1) return;

    final session = _sessions[idx];
    final msgs = List<ChatMessage>.from(session.messages);
    final msgIdx = msgs.indexWhere((m) => m.id == message.id);
    if (msgIdx != -1) {
      msgs[msgIdx] = message;
    } else {
      msgs.add(message);
    }
    _sessions[idx] =
        session.copyWith(messages: msgs, updatedAt: DateTime.now());
    await _persistSessions();
  }

  Future<void> clearActiveSession() async {
    if (_activeSessionId == null) return;
    final idx = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (idx != -1) {
      _sessions[idx] = _sessions[idx].copyWith(
        messages: [],
        updatedAt: DateTime.now(),
      );
    }
    await _persistSessions();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) {
      _activeSessionId = null;
    }
    await _persistSessions();
    notifyListeners();
  }

  Future<void> _persistSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionsKey,
      jsonEncode(_sessions.map((s) => s.toJson()).toList()),
    );
  }
}
