/// India-focused crisis helplines shown when sensitive keywords are detected.
class CrisisHelplines {
  CrisisHelplines._();

  static const List<Helpline> india = [
    Helpline(
      name: 'iCall',
      number: '9152987821',
      description: 'Counselling & emotional support',
    ),
    Helpline(
      name: 'AASRA',
      number: '9820466726',
      description: '24/7 suicide prevention helpline',
    ),
    Helpline(
      name: 'Vandrevala Foundation',
      number: '1860-2662-345',
      description: 'Mental health support',
    ),
    Helpline(
      name: 'Tele-MANAS',
      number: '14416',
      description: 'National mental health helpline',
    ),
  ];

  static const crisisKeywords = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'khud ko mar',
    'jaan dena',
    'mar jana',
    'self harm',
    'khud ko nuksan',
  ];

  static bool containsCrisisSignal(String text) {
    final lower = text.toLowerCase();
    return crisisKeywords.any(lower.contains);
  }
}

class Helpline {
  const Helpline({
    required this.name,
    required this.number,
    required this.description,
  });

  final String name;
  final String number;
  final String description;
}
