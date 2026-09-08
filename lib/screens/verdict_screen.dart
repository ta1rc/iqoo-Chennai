import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String get _summary {
    final buffer = StringBuffer()
      ..writeln('Nazar verdict: ${verdict.bandLabel} (risk ${verdict.score})');
    for (final reason in verdict.reasons) {
      buffer.writeln('- ${reason.label}: "${reason.evidence}"');
    }
    return buffer.toString().trim();
  }

  Future<void> _copySummary(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _summary));
    HapticFeedback.selectionClick();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verdict copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verdict'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 20),
            tooltip: 'Copy verdict',
            onPressed: () => _copySummary(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 28),
              const Text(
                'Message analysed',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NazarColors.ink,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: NazarColors.rule, height: 1),
              const SizedBox(height: 12),
              Text(
                originalText,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: monoFontFamily,
                  fontSize: 12.5,
                  color: Color(0xFF4A5057),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
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
                ...verdict.reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
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
                    ),
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No scam signals found in this message.',
                      style: TextStyle(color: Color(0xFF4A5057)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
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
