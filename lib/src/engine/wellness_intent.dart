/// Wellness topics Aaroh can respond to — detected by our intent classifier.
enum WellnessIntent {
  greeting,
  sleep,
  anxiety,
  depression,
  loneliness,
  stress,
  anger,
  physicalHealth,
  relationship,
  motivation,
  routine,
  gratitude,
  thanks,
  crisis,
  followUp,
  general,
}

extension WellnessIntentLabel on WellnessIntent {
  String get key => name;
}
