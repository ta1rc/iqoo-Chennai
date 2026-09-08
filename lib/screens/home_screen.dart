import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme.dart';
import '../engine/analyzer.dart';
import '../engine/scorer.dart';
import 'verdict_screen.dart';

/// Realistic samples for a cold-open demo: a judge should reach a verdict
/// in one tap without typing, and see the range of what the engine catches.
const List<Map<String, String>> scamSamples = [
  {
    'label': 'Digital arrest (CBI)',
    'text': 'This is CBI ke taraf se. Ek warrant aapke against issue hua hai. '
        'Aapko turant contact karna hai warna aapko arrest kiya jayega. '
        'Kisi ko mat batao. Call mat kaato.',
  },
  {
    'label': 'Courier customs seizure',
    'text': 'Your FedEx parcel has been seized by customs. Illegal items '
        'found inside. To avoid arrest, transfer Rs 45,000 via UPI within '
        '2 hours. Do not disconnect the call.',
  },
  {
    'label': 'TRAI disconnection',
    'text': 'TRAI has ordered your mobile number to be disconnected within '
        '2 hours due to illegal activity. Press 9 to speak to officer '
        'immediately or provide OTP to verify.',
  },
  {
    'label': 'Lottery win',
    'text': 'Congratulations! You have won Rs 25,00,000 in KBC lottery. To '
        'claim your reward share your bank account and pay processing fee '
        'of Rs 5000 via UPI.',
  },
  {
    'label': 'Tamil digital arrest',
    'text': 'Naan CBI la irundhu pேசுறேன். Ungal peyar la oru case irukku. '
        'Ippove panam anuppu illana arrest pண்ணுவோம். Yaarukkum sollathe.',
  },
];

const List<Map<String, String>> legitSamples = [
  {
    'label': 'Real bank debit alert',
    'text': 'Rs.1,250.00 debited from a/c XX1234 on 07-Sep-26 for UPI/POS '
        'txn. Avl bal Rs.34,520.10. If not you, call 18002586161 -HDFC Bank',
  },
  {
    'label': 'Genuine OTP',
    'text': '482913 is your OTP for transaction of Rs.500 at Amazon. Valid '
        'for 10 mins. Do not share this OTP with anyone. -ICICI Bank',
  },
  {
    'label': 'Delivery notification',
    'text': 'Your Amazon order #402-1234567 has been shipped and will be '
        'delivered by tomorrow. Track at amazon.in/track',
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final ScamAnalyzer _analyzer = RuleBasedAnalyzer();
  List<Map<String, String>> _history = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('history');
    if (raw != null) {
      final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      setState(() {
        _history = decoded
            .map((e) => e.map((k, v) => MapEntry(k, v.toString())))
            .toList();
      });
    }
  }

  Future<void> _saveHistoryEntry(String text, Verdict verdict) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = {
      'text': text.length > 80 ? '${text.substring(0, 80)}...' : text,
      'band': verdict.bandLabel,
      'score': verdict.score.toString(),
    };
    _history.insert(0, entry);
    if (_history.length > 20) _history = _history.sublist(0, 20);
    await prefs.setString('history', jsonEncode(_history));
    setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    setState(() => _history = []);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _analyze(String text) async {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final verdict = await _analyzer.analyze(text);
    await _saveHistoryEntry(text, verdict);
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerdictScreen(originalText: text, verdict: verdict),
      ),
    );
  }

  Widget _sampleSection(String title, List<Map<String, String>> samples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...samples.map(
          (sample) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: _loading ? null : () => _analyze(sample['text']!),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: NazarColors.ink,
                side: const BorderSide(color: NazarColors.rule),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(sample['label']!),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Nazar',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: NazarColors.safe),
                    SizedBox(width: 6),
                    Text('offline', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Paste a message to check it…',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: NazarColors.rule),
                    ),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Clear',
                            onPressed: () => _controller.clear(),
                          )
                        : IconButton(
                            icon: const Icon(Icons.content_paste, size: 18),
                            tooltip: 'Paste',
                            onPressed: _pasteFromClipboard,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: (_loading || !hasText)
                        ? null
                        : () => _analyze(_controller.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: NazarColors.ink,
                      disabledBackgroundColor:
                          NazarColors.ink.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Check message'),
                  ),
                ),
                const SizedBox(height: 28),
                _sampleSection('Try a scam example', scamSamples),
                const SizedBox(height: 12),
                _sampleSection('Try a legitimate example', legitSamples),
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: NazarColors.rule, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearHistory,
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A5057),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ..._history.map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              h['text'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${h['band']} · ${h['score']}',
                            style: const TextStyle(
                              fontFamily: monoFontFamily,
                              fontSize: 11,
                              color: Color(0xFF4A5057),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
