import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme.dart';
import '../engine/analyzer.dart';
import '../engine/scorer.dart';
import 'verdict_screen.dart';

const List<Map<String, String>> sampleMessages = [
  {
    'label': 'Digital arrest (CBI)',
    'text': 'This is CBI ke taraf se. Ek warrant aapke against issue hua hai. '
        'Aapko turant contact karna hai warna aapko arrest kiya jayega. '
        'Kisi ko mat batao. Call mat kaato.',
  },
  {
    'label': 'KYC expiry',
    'text': 'Dear customer your KYC has expired. Update your KYC immediately '
        'by sharing OTP otherwise your account will be frozen today itself.',
  },
  {
    'label': 'Real bank debit alert',
    'text': 'Rs.1,250.00 debited from a/c XX1234 on 07-Sep-26 for UPI/POS '
        'txn. Avl bal Rs.34,520.10. If not you, call 18002586161 -HDFC Bank',
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
    _loadHistory();
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

  Future<void> _analyze(String text) async {
    if (text.trim().isEmpty) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Paste a message to check it…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: NazarColors.rule),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : () => _analyze(_controller.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: NazarColors.ink,
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
              const Text(
                'Try a sample',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ...sampleMessages.map(
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
              if (_history.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: NazarColors.rule, height: 1),
                const SizedBox(height: 12),
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, i) {
                      final h = _history[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          h['text'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: Text(
                          '${h['band']} · ${h['score']}',
                          style: const TextStyle(
                            fontFamily: monoFontFamily,
                            fontSize: 11,
                            color: Color(0xFF4A5057),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
