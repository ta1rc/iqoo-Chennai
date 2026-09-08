import 'signals.dart';

enum RiskBand { safe, suspicious, likelyScam }

class Reason {
  final String label;
  final String evidence;

  const Reason({required this.label, required this.evidence});
}

class Verdict {
  final int score;
  final RiskBand band;
  final List<Reason> reasons;

  const Verdict({
    required this.score,
    required this.band,
    required this.reasons,
  });

  String get bandLabel {
    switch (band) {
      case RiskBand.safe:
        return 'SAFE';
      case RiskBand.suspicious:
        return 'SUSPICIOUS';
      case RiskBand.likelyScam:
        return 'LIKELY SCAM';
    }
  }
}

/// Fraud lives in co-occurrence, not single keywords. A message that only
/// mentions "urgent" is noise; a message that combines authority + urgency
/// + payment is the fingerprint of the "digital arrest" scam pattern that
/// dominates Indian voice/SMS fraud in 2025-26. Rather than a flat weighted
/// sum, known triads get a multiplier on top of their base weights so the
/// combination scores meaningfully higher than any signal alone would.
const Map<String, double> _comboMultipliers = {
  'authority+urgency+payment': 1.6,
  'authority+threat+payment': 1.6,
  'authority+secrecy': 1.4,
  'credential+urgency': 1.3,
  'reward+payment': 1.3,
  'threat+payment': 1.3,
};

class Scorer {
  Verdict score(String text) {
    final matchesByCategory = <String, List<SignalMatch>>{};
    for (final detector in detectors) {
      final matches = detector.scan(text);
      if (matches.isNotEmpty) {
        matchesByCategory[detector.id] = matches;
      }
    }

    if (matchesByCategory.isEmpty) {
      return const Verdict(score: 0, band: RiskBand.safe, reasons: []);
    }

    double raw = 0;
    for (final detector in detectors) {
      final matches = matchesByCategory[detector.id];
      if (matches == null) continue;
      // Diminishing returns for repeated hits within the same category.
      final hits = matches.length.clamp(1, 3);
      raw += detector.weight * (1 + (hits - 1) * 0.3);
    }

    final present = matchesByCategory.keys.toSet();
    double multiplier = 1.0;
    for (final entry in _comboMultipliers.entries) {
      final required = entry.key.split('+').toSet();
      if (required.difference(present).isEmpty) {
        multiplier = multiplier > entry.value ? multiplier : entry.value;
      }
    }

    final score = (raw * multiplier).clamp(0, 100).round();

    RiskBand band;
    if (score < 30) {
      band = RiskBand.safe;
    } else if (score < 65) {
      band = RiskBand.suspicious;
    } else {
      band = RiskBand.likelyScam;
    }

    final reasons = <Reason>[];
    for (final detector in detectors) {
      final matches = matchesByCategory[detector.id];
      if (matches == null) continue;
      reasons.add(Reason(label: detector.label, evidence: matches.first.matchedText));
    }
    reasons.sort((a, b) {
      final da = detectors.firstWhere((d) => d.label == a.label).weight;
      final db = detectors.firstWhere((d) => d.label == b.label).weight;
      return db.compareTo(da);
    });

    return Verdict(score: score, band: band, reasons: reasons);
  }
}
