/// Detection signals for scam/fraud text.
///
/// Each detector scans English, romanised Hindi, and romanised Tamil keyword
/// sets — Indian scam traffic is overwhelmingly Hinglish/Tanglish, so an
/// English-only matcher misses most real traffic.
library signals;

class SignalMatch {
  final String category;
  final String matchedText;
  final int start;
  final int end;

  const SignalMatch({
    required this.category,
    required this.matchedText,
    required this.start,
    required this.end,
  });
}

class SignalDetector {
  final String id;
  final String label;
  final double weight;
  final List<String> keywords;

  const SignalDetector({
    required this.id,
    required this.label,
    required this.weight,
    required this.keywords,
  });

  List<SignalMatch> scan(String text) {
    final lower = text.toLowerCase();
    final matches = <SignalMatch>[];
    for (final kw in keywords) {
      final needle = kw.toLowerCase();
      var start = 0;
      while (true) {
        final idx = lower.indexOf(needle, start);
        if (idx == -1) break;
        matches.add(SignalMatch(
          category: id,
          matchedText: text.substring(idx, idx + needle.length),
          start: idx,
          end: idx + needle.length,
        ));
        start = idx + needle.length;
      }
    }
    return matches;
  }
}

/// The eight detectors. Weights are tuned by hand against the test corpus,
/// not learned — this is a deliberately explainable rule engine.
final List<SignalDetector> detectors = [
  const SignalDetector(
    id: 'authority',
    label: 'Claims police / government authority',
    weight: 22,
    keywords: [
      // English
      'cbi', 'income tax department', 'income tax', 'trai', 'reserve bank',
      'rbi', 'customs department', 'cyber crime', 'cyber cell', 'police',
      'court notice', 'supreme court', 'enforcement directorate', 'ed officer',
      'narcotics', 'digital arrest', 'fedex customs', 'courier seized',
      'parcel seized', 'nia', 'sebi',
      // Romanised Hindi
      'cbi ke taraf se', 'cbi se bol raha', 'police station se',
      'aapke against warrant', 'digital girftari', 'thane se bol raha',
      // Romanised Tamil
      'cbi la irundhu', 'police station la irundhu', 'kastan seizure',
    ],
  ),
  const SignalDetector(
    id: 'urgency',
    label: 'Creates false urgency',
    weight: 14,
    keywords: [
      'immediately', 'urgent', 'within 2 hours', 'within 1 hour',
      'within 30 minutes', 'last warning', 'final notice', 'act now',
      'right now', 'expires today', 'today itself', 'before midnight',
      'turant', 'abhi turant', 'jaldi karo', 'ippove', 'ippo thaan',
      'seekiram', 'kudirama',
    ],
  ),
  const SignalDetector(
    id: 'payment',
    label: 'Demands payment or transfer',
    weight: 20,
    keywords: [
      'upi', '@ybl', '@okaxis', '@okhdfcbank', '@paytm', 'transfer',
      'transfer the amount', 'clear the dues', 'pay immediately',
      'processing fee', 'refundable deposit', 'security deposit',
      'paisa transfer karo', 'paise bhejo', 'account mein daalo',
      'panam anuppu', 'kattanam podunga',
      r'₹',
    ],
  ),
  const SignalDetector(
    id: 'secrecy',
    label: 'Asks you to stay silent',
    weight: 18,
    keywords: [
      "don't tell anyone", 'do not disconnect', 'keep this confidential',
      'do not tell your family', 'this is confidential',
      'kisi ko mat batao', 'call mat kaato', 'phone mat rakho',
      'yaarukkum sollathe', 'call vidatha',
    ],
  ),
  const SignalDetector(
    id: 'threat',
    label: 'Threatens arrest, freeze, or legal action',
    weight: 20,
    keywords: [
      'warrant', 'arrest', 'account will be frozen', 'account frozen',
      'legal action', 'service will be disconnected', 'disconnected today',
      'fir will be filed', 'jail', 'giraftar', 'account freeze ho jayega',
      'kanakku freeze aagum', 'ippodiye kaisu illana',
    ],
  ),
  const SignalDetector(
    id: 'credential',
    label: 'Requests OTP, PIN, or KYC details',
    weight: 16,
    keywords: [
      'otp', 'cvv', 'pin number', 'share your otp', 'kyc update',
      'kyc expired', 'verify your account', 'update your kyc',
      'otp bhejo', 'otp batao', 'kyc karwao', 'otp sollunga',
    ],
  ),
  const SignalDetector(
    id: 'reward',
    label: 'Promises lottery, prize, or refund',
    weight: 12,
    keywords: [
      'you have won', 'lottery', 'lucky winner', 'cashback', 'prize money',
      'claim your reward', 'refund of', 'refund pending',
      'aap jeet gaye', 'inaam mila', 'lottery jeeta',
      'neenga vetriyadinga', 'parisu kidaikkum',
    ],
  ),
  const SignalDetector(
    id: 'channel',
    label: 'Suspicious link or sender pattern',
    weight: 10,
    keywords: [
      'bit.ly', 'tinyurl', 'click here', 'click the link below',
      '.xyz/', '.info/', 'wa.me/',
    ],
  ),
];
