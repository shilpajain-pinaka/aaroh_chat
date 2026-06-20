import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:aaroh_chat/src/engine/language_detector.dart';
import 'package:aaroh_chat/src/engine/wellness_intent.dart';

class KnowledgeSnippet {
  const KnowledgeSnippet({
    required this.title,
    required this.summary,
    required this.sourceUrl,
    required this.langCode,
  });

  final String title;
  final String summary;
  final String sourceUrl;
  final String langCode;
}

/// Fetches factual wellness information from open Wikipedia (multilingual).
class WebKnowledgeService {
  WebKnowledgeService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _intentSearchTerms = <WellnessIntent, String>{
    WellnessIntent.sleep: 'sleep hygiene mental health',
    WellnessIntent.anxiety: 'anxiety disorder coping',
    WellnessIntent.depression: 'major depressive disorder',
    WellnessIntent.loneliness: 'loneliness mental health',
    WellnessIntent.stress: 'psychological stress management',
    WellnessIntent.anger: 'anger management',
    WellnessIntent.physicalHealth: 'self care health',
    WellnessIntent.relationship: 'interpersonal relationship health',
    WellnessIntent.motivation: 'motivation psychology',
    WellnessIntent.routine: 'daily routine health',
  };

  Future<KnowledgeSnippet?> fetchForIntent({
    required WellnessIntent intent,
    required String userMessage,
    required String langCode,
  }) async {
    final wikiLang = LanguageDetector.wikiLang(langCode);
    final query = _buildQuery(intent, userMessage);

    try {
      final title = await _searchTitle(query, wikiLang);
      if (title == null) return null;
      return await _fetchSummary(title, wikiLang);
    } catch (_) {
      // Offline or blocked — engine still works without web
      return null;
    }
  }

  String _buildQuery(WellnessIntent intent, String userMessage) {
    final base = _intentSearchTerms[intent] ?? 'mental health wellness';
    final words = userMessage
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .take(3)
        .join(' ');
    return words.isNotEmpty ? '$base $words' : base;
  }

  Future<String?> _searchTitle(String query, String lang) async {
    final uri = Uri.https('${lang}.wikipedia.org', '/w/api.php', {
      'action': 'opensearch',
      'search': query,
      'limit': '1',
      'format': 'json',
    });

    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as List<dynamic>;
    if (data.length < 2) return null;
    final titles = data[1] as List<dynamic>;
    if (titles.isEmpty) return null;
    return titles.first as String;
  }

  Future<KnowledgeSnippet?> _fetchSummary(String title, String lang) async {
    final encoded = Uri.encodeComponent(title.replaceAll(' ', '_'));
    final uri = Uri.parse(
      'https://${lang}.wikipedia.org/api/rest_v1/page/summary/$encoded',
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final extract = data['extract'] as String?;
    if (extract == null || extract.isEmpty) return null;

    final contentUrls = data['content_urls'] as Map<String, dynamic>?;
    final desktop = contentUrls?['desktop'] as Map<String, dynamic>?;
    final pageUrl =
        desktop?['page'] as String? ?? 'https://$lang.wikipedia.org';

    return KnowledgeSnippet(
      title: data['title'] as String? ?? title,
      summary: _trimSummary(extract),
      sourceUrl: pageUrl,
      langCode: lang,
    );
  }

  String _trimSummary(String text) {
    if (text.length <= 320) return text;
    return '${text.substring(0, 317).trim()}...';
  }

  void dispose() => _client.close();
}
