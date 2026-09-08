import 'scorer.dart';

/// Seam that makes the Chennai build cheap: swap the implementation behind
/// this interface without touching the UI or scoring model's callers.
abstract class ScamAnalyzer {
  Future<Verdict> analyze(String text);
}

/// Tonight's implementation: deterministic, pure-Dart, fully offline.
class RuleBasedAnalyzer implements ScamAnalyzer {
  final Scorer _scorer = Scorer();

  @override
  Future<Verdict> analyze(String text) async {
    return _scorer.score(text);
  }
}

// Chennai (12-13 Sep): rules pre-filter obvious cases, then a quantised
// Gemma model reasons over the survivors for nuance the rules miss.
// Same ScamAnalyzer interface, same Verdict return type — nothing above
// this seam changes.
//
// class HybridAnalyzer implements ScamAnalyzer {
//   final RuleBasedAnalyzer _preFilter = RuleBasedAnalyzer();
//   final GemmaEngine _gemma; // on-device, quantised, NPU-backed
//
//   HybridAnalyzer(this._gemma);
//
//   @override
//   Future<Verdict> analyze(String text) async {
//     final ruleVerdict = await _preFilter.analyze(text);
//     if (ruleVerdict.band == RiskBand.safe) return ruleVerdict;
//     return _gemma.reason(text, ruleVerdict);
//   }
// }
