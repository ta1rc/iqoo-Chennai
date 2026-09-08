import 'package:flutter/material.dart';
import '../theme.dart';
import '../engine/scorer.dart';
import '../widgets/stamp.dart';

class VerdictScreen extends StatelessWidget {
  final String originalText;
  final Verdict verdict;

  const VerdictScreen({
    super.key,
    required this.originalText,
    required this.verdict,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verdict')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(child: VerdictStamp(band: verdict.band)),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'risk ${verdict.score}',
                  style: const TextStyle(
                    fontFamily: monoFontFamily,
                    color: NazarColors.ink,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (verdict.reasons.isNotEmpty) ...[
                const Text(
                  'Why',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NazarColors.ink,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(color: NazarColors.rule, height: 1),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: verdict.reasons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final reason = verdict.reasons[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reason.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: NazarColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${reason.evidence}"',
                            style: const TextStyle(
                              fontFamily: monoFontFamily,
                              fontSize: 13,
                              color: Color(0xFF4A5057),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ] else
                const Expanded(
                  child: Center(
                    child: Text(
                      'No scam signals found in this message.',
                      style: TextStyle(color: Color(0xFF4A5057)),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(color: NazarColors.rule, height: 1),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NazarColors.ink,
                    side: const BorderSide(color: NazarColors.ink, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Analyse another message'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
