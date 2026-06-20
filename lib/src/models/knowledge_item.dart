/// A single structured knowledge entry for the Aaroh SDK.
///
/// Use this when you want more control than a plain string — categorize
/// entries, attach extra search keywords, or give each fact a stable [id]
/// (useful if you update/remove entries later).
///
/// ### Example
/// ```dart
/// KnowledgeItem(
///   id: 'return-policy',
///   question: 'What is your return policy?',
///   answer: 'We offer a 30-day hassle-free return on all products.',
///   category: 'Policies',
///   keywords: ['return', 'refund', 'exchange'],
/// )
/// ```
class KnowledgeItem {
  const KnowledgeItem({
    this.id,
    this.question,
    required this.answer,
    this.category,
    this.keywords = const [],
  });

  /// Optional stable identifier for this entry.
  final String? id;

  /// The question this entry answers. Optional — if omitted, this is
  /// treated as a general fact/document rather than a Q&A pair.
  final String? question;

  /// The answer text, or the fact/document content itself.
  final String answer;

  /// Optional grouping label (e.g. 'Pricing', 'Shipping', 'Policies').
  final String? category;

  /// Extra keywords that should also match this entry during search,
  /// beyond words already present in [question]/[answer].
  final List<String> keywords;

  /// Plain-text rendering used when building the Claude system prompt.
  String toPromptText() {
    if (question != null && question!.isNotEmpty) {
      return 'Q: $question\nA: $answer';
    }
    return answer;
  }

  /// All searchable text for this entry, lowercased.
  String get _searchText => [
        question ?? '',
        answer,
        category ?? '',
        ...keywords,
      ].join(' ').toLowerCase();

  /// Very small relevance score against a user query — counts how many
  /// distinct query words (3+ chars) appear in this entry's searchable text.
  /// Used by the built-in engine to find the best-matching entry without
  /// needing any external embedding/search service.
  int relevanceScore(String query) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9\u0900-\u097F]+'))
        .where((w) => w.length >= 3)
        .toSet();
    if (words.isEmpty) return 0;
    final text = _searchText;
    var score = 0;
    for (final w in words) {
      if (text.contains(w)) score++;
    }
    return score;
  }
}

/// Accepts either a plain [String] or a [KnowledgeItem] and normalizes it.
///
/// This is what lets [AarohConfig.knowledgeBase] stay backward compatible
/// with `List<String>` while also supporting `List<KnowledgeItem>`.
KnowledgeItem normalizeKnowledgeEntry(Object entry) {
  if (entry is KnowledgeItem) return entry;
  if (entry is String) return KnowledgeItem(answer: entry);
  throw ArgumentError(
    'knowledgeBase / searchEngineData entries must be String or '
    'KnowledgeItem, got ${entry.runtimeType}',
  );
}
