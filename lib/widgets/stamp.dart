import 'package:flutter/material.dart';
import '../theme.dart';
import '../engine/scorer.dart';

/// The verdict stamp. Rotated, unfilled border, single scale-and-settle
/// animation on appearance — the only non-user-triggered motion in the app.
class VerdictStamp extends StatefulWidget {
  final RiskBand band;

  const VerdictStamp({super.key, required this.band});

  @override
  State<VerdictStamp> createState() => _VerdictStampState();
}

class _VerdictStampState extends State<VerdictStamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    final disableAnimations = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (disableAnimations) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.band) {
      case RiskBand.safe:
        return NazarColors.safe;
      case RiskBand.suspicious:
        return NazarColors.caution;
      case RiskBand.likelyScam:
        return NazarColors.danger;
    }
  }

  String get _label {
    switch (widget.band) {
      case RiskBand.safe:
        return 'LIKELY SAFE';
      case RiskBand.suspicious:
        return 'SUSPICIOUS';
      case RiskBand.likelyScam:
        return 'LIKELY  SCAM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Transform.rotate(
        angle: -4 * 3.14159 / 180,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: _color, width: 2.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
