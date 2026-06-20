import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:aaroh_chat/src/models/aaroh_config.dart';
import 'package:aaroh_chat/src/models/chat_message.dart';

/// Handles communication with Claude (claude-sonnet-4-6) API.
class ClaudeApiService {
  ClaudeApiService({required this.config});

  final AarohConfig config;

  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';
  static const _apiVersion = '2023-06-01';

  // Toggle this off (or wire it to a build flag) before shipping to prod
  // if you don't want request/response bodies in release logs.
  static const _verboseLogging = true;

  void _log(String message) {
    if (_verboseLogging) {
      debugPrint('[ClaudeApiService] $message');
    }
  }

  String _buildSystemPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('You are a helpful assistant for ${config.companyName}. '
        'Be friendly, concise, and accurate. '
        'Always represent the company professionally.');

    if (config.knowledgeContext.isNotEmpty) {
      buffer.writeln('\n${config.knowledgeContext}');
      buffer.writeln(
          '\nUse the above company knowledge to answer user questions accurately. '
          'If a question is not covered in the knowledge base, answer helpfully from your general knowledge.');
    }
    return buffer.toString();
  }

  Future<String> sendMessage({
    required String userMessage,
    required List<ChatMessage> history,
    void Function(String partial)? onPartial,
  }) async {
    final apiKey = config.claudeApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      _log('ERROR: missing Claude API key in config');
      throw Exception('Claude API key is not configured.');
    }

    final messages = history
        .where((m) => m.content.isNotEmpty)
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    messages.add({'role': 'user', 'content': userMessage});

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 1024,
      'system': _buildSystemPrompt(),
      'messages': messages,
      'stream': onPartial != null,
    });

    _log('Sending request — model=$_model, history=${history.length}, '
        'streaming=${onPartial != null}, bodyBytes=${body.length}');

    try {
      final result = onPartial != null
          ? await _streamResponse(apiKey, body, onPartial)
          : await _fetchResponse(apiKey, body);
      _log('Request completed — responseLength=${result.length}');
      return result;
    } catch (e, st) {
      _log('Request failed: $e');
      _log('Stack trace: $st');
      rethrow;
    }
  }

  Future<String> _fetchResponse(String apiKey, String body) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: _headers(apiKey),
      body: body,
    );

    _log('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _log(
          'Response usage: ${data['usage']}, stop_reason: ${data['stop_reason']}');

      final content = data['content'];
      if (content is! List || content.isEmpty) {
        _log('ERROR: response had no content blocks: ${response.body}');
        throw Exception('Claude API returned an empty response.');
      }

      // Concatenate all text blocks rather than assuming index 0 is text
      // (the model can return multiple blocks, e.g. if extended thinking
      // or tool use is ever enabled).
      final text = content
          .whereType<Map<String, dynamic>>()
          .where((block) => block['type'] == 'text')
          .map((block) => block['text'] as String? ?? '')
          .join();

      if (text.isEmpty) {
        _log('WARNING: response contained no text blocks: ${response.body}');
      }

      return text;
    } else {
      _log('Error response body: ${response.body}');
      throw Exception(
          'Claude API error ${response.statusCode}: ${response.body}');
    }
  }

  Future<String> _streamResponse(
    String apiKey,
    String body,
    void Function(String) onPartial,
  ) async {
    final request = http.Request('POST', Uri.parse(_endpoint));
    request.headers.addAll(_headers(apiKey));
    request.body = body;

    final streamedResponse = await request.send();
    _log('Stream response status: ${streamedResponse.statusCode}');

    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      _log('Stream error body: $errorBody');
      throw Exception(
          'Claude API error ${streamedResponse.statusCode}: $errorBody');
    }

    final buffer = StringBuffer();
    var eventCount = 0;

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      for (final line in chunk.split('\n')) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]' || data.isEmpty) continue;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final type = json['type'] as String?;
          eventCount++;

          switch (type) {
            case 'content_block_delta':
              final delta = json['delta'] as Map<String, dynamic>?;
              // Only accumulate plain text deltas. Ignore input_json_delta
              // (tool use) / thinking_delta / signature_delta payloads so
              // they don't get mixed into the visible response text.
              if (delta?['type'] == 'text_delta') {
                final text = delta?['text'] as String? ?? '';
                buffer.write(text);
                onPartial(buffer.toString());
              }
              break;

            case 'message_delta':
              final stopReason = json['delta']?['stop_reason'];
              if (stopReason != null) {
                _log(
                    'Stream stop_reason: $stopReason, usage: ${json['usage']}');
              }
              break;

            case 'error':
              // The API can send a mid-stream error event (e.g.
              // overloaded_error) even after a 200 status line.
              final error = json['error'] as Map<String, dynamic>?;
              _log('Stream error event: $error');
              throw Exception(
                  'Claude API stream error: ${error?['type']} - ${error?['message']}');

            case 'message_stop':
              _log('Stream finished — totalEvents=$eventCount, '
                  'finalLength=${buffer.length}');
              break;

            default:
              // message_start, content_block_start, content_block_stop,
              // ping, etc. — nothing to accumulate, but log at a low level
              // for debugging if needed.
              break;
          }
        } on FormatException catch (e) {
          _log('WARNING: failed to parse SSE line as JSON: $e — raw: $data');
        }
      }
    }

    if (buffer.isEmpty) {
      _log('WARNING: stream completed with no text content '
          '(eventCount=$eventCount)');
    }

    return buffer.toString();
  }

  Map<String, String> _headers(String apiKey) => {
        'x-api-key': apiKey,
        'anthropic-version': _apiVersion,
        'content-type': 'application/json',
      };
}
