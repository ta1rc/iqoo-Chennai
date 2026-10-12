# Scoring model

## Detectors

Eight independent signal categories, each a keyword set matched across English, romanised Hindi, and romanised Tamil (see `lib/engine/signals.dart`):

| id | signal | base weight |
|---|---|---|
| `authority` | Claims police / government authority | 22 |
| `payment` | Demands payment or transfer | 20 |
| `threat` | Threatens arrest, freeze, or legal action | 20 |
| `secrecy` | Asks the recipient to stay silent | 18 |
| `credential` | Requests OTP, PIN, or KYC details | 16 |
| `urgency` | Creates false urgency | 14 |
| `reward` | Promises lottery, prize, or refund | 12 |
| `channel` | Suspicious link or sender pattern | 10 |

Weights were hand-tuned against the test corpus, not learned — this is a deliberately explainable rule engine, not a black box.

## Why co-occurrence matters

A single signal is weak evidence. "Urgent" appears in real bank alerts too ("respond urgently if this wasn't you"). "₹" appears in every legitimate transaction SMS. Scoring on isolated keyword hits either misses real scams that use only one strong signal, or false-positives on ordinary financial messages that happen to mention money and urgency.

What actually distinguishes fraud is the **combination**. The "digital arrest" pattern — the dominant scam vector in Indian voice/SMS fraud right now — is authority + urgency + payment (or authority + threat + payment) appearing together. No legitimate bank, court, or government agency operates that way; the combination itself is the tell.

The scorer detects known combination triads/pairs and applies a multiplier on top of the summed weighted score:

```dart
const Map<String, double> _comboMultipliers = {
  'authority+urgency+payment': 1.6,
  'authority+threat+payment': 1.6,
  'authority+secrecy': 1.4,
  'credential+urgency': 1.3,
  'reward+payment': 1.3,
  'threat+payment': 1.3,
};
```

The highest matching multiplier applies once (multipliers don't stack), keeping a message that hits three related combos from scoring far past 100 relative to one that hits a single combo cleanly.

## Bands

- `0–29` — safe
- `30–64` — suspicious
- `65–100` — likely scam

## Limitations, stated plainly

- Keyword matching, not semantic understanding — a message that describes a scam pattern without using these terms won't be flagged. This is exactly the gap the planned on-device Gemma reasoning step is meant to close.
- Weights and multipliers are hand-tuned against a 30-message corpus, not calibrated against a large labelled dataset. Treat scores as a regression signal, not a probability.
- No handling of adversarial obfuscation (leetspeak, zero-width characters, deliberate misspelling) — out of scope for the current build.
