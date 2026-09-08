import 'package:flutter/material.dart';
import '../theme.dart';
import '../engine/scorer.dart';

/// A ruler-style risk gauge — ticked like a measurement on an official
/// form, rather than a rounded progress bar. Marks the safe/suspicious/
/// likely-scam boundaries so the score reads in context, not in isolation.
class RiskMeter extends StatelessWidget {
  final int score;
  final RiskBand band;

  const RiskMeter({super.key, required this.score, required this.band});

  Color get _color {
    switch (band) {
      case RiskBand.safe:
        return NazarColors.safe;
      case RiskBand.suspicious:
        return NazarColors.caution;
      case RiskBand.likelyScam:
        return NazarColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (score.clamp(0, 100)) / 100;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 22,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 9,
                    left: 0,
                    right: 0,
                    child: Container(height: 2, color: NazarColors.rule),
                  ),
                  Positioned(
                    left: width * 0.30 - 0.5,
                    top: 4,
                    child: Container(width: 1, height: 12, color: NazarColors.rule),
                  ),
                  Positioned(
                    left: width * 0.65 - 0.5,
                    top: 4,
                    child: Container(width: 1, height: 12, color: NazarColors.rule),
                  ),
                  Positioned(
                    top: 6,
                    left: 0,
                    child: Container(height: 2, width: width * fraction, color: _color),
                  ),
                  Positioned(
                    left: (width * fraction - 6).clamp(0, width - 12),
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _color,
                        border: Border.all(color: NazarColors.paper, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MeterLabel('safe'),
            _MeterLabel('suspicious'),
            _MeterLabel('scam'),
          ],
        ),
      ],
    );
  }
}

class _MeterLabel extends StatelessWidget {
  final String text;
  const _MeterLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: monoFontFamily,
        fontSize: 10,
        color: Color(0xFF8A9098),
        letterSpacing: 0.5,
      ),
    );
  }
}
