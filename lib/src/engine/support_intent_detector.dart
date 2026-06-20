/// Lightweight intent detection used purely for the [SupportConfig]
/// fallback flow — kept separate from the wellness-focused
/// [WellnessIntent]/[LanguageDetector] engine since this is a generic,
/// domain-agnostic check any SDK consumer's queries might hit.
class SupportIntentDetector {
  SupportIntentDetector._();

  static const _supportPhrases = [
    'help',
    'support',
    'talk to someone',
    'talk to a human',
    'talk to an agent',
    'customer care',
    'customer service',
    'not working',
    'isn\'t working',
    'isnt working',
    'broken',
    'complaint',
    'issue',
    'problem',
    'stuck',
    'contact you',
    'reach you',
    'reach out',
    'speak to',
    'representative',
  ];

  static const _phraseRequestPhrases = [
    'phone number',
    'contact number',
    'your number',
    'call you',
    'call number',
    'mobile number',
    'whatsapp number',
    'can i call',
    'phone no',
  ];

  /// True if [message] looks like the user wants human support.
  static bool isSupportRequest(String message) {
    final lower = message.toLowerCase();
    return _supportPhrases.any(lower.contains);
  }

  /// True if [message] explicitly asks for a phone/contact number.
  static bool wantsPhoneNumber(String message) {
    final lower = message.toLowerCase();
    return _phraseRequestPhrases.any(lower.contains);
  }
}
