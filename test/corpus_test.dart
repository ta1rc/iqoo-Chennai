import 'package:flutter_test/flutter_test.dart';
import 'package:nazar/engine/analyzer.dart';
import 'package:nazar/engine/scorer.dart';

void main() {
  final analyzer = RuleBasedAnalyzer();

  group('scams should score suspicious or above', () {
    final scams = <String, String>{
      'digital arrest - CBI': 'This is CBI ke taraf se. Ek warrant aapke against issue hua hai. '
          'Aapko turant contact karna hai warna aapko arrest kiya jayega. Kisi ko mat batao. '
          'Call mat kaato.',
      'digital arrest - customs parcel': 'Your parcel has been seized by customs department. '
          'Illegal items found. To avoid arrest, transfer the amount of Rs 45000 immediately '
          'via UPI within 2 hours. Do not disconnect the call.',
      'KYC expiry': 'Dear customer your KYC has expired. Update your KYC immediately by sharing '
          'OTP otherwise your account will be frozen today itself.',
      'electricity disconnection': 'Your electricity service will be disconnected today at 9:30 PM '
          'due to unpaid bill. Pay immediately to avoid disconnection. Click here bit.ly/elec123',
      'courier customs seizure': 'FedEx customs has seized your parcel containing illegal substances. '
          'Cyber crime case has been filed. Contact immediately or face legal action.',
      'lottery win': 'Congratulations! You have won Rs 25,00,000 in KBC lottery. To claim your reward '
          'share your bank account and pay processing fee of Rs 5000 via UPI.',
      'fake refund': 'Your refund of Rs 4599 is pending. Click the link below and share your card CVV '
          'and PIN number to receive refund immediately.',
      'OTP harvest': 'We noticed suspicious login on your account. Share your OTP immediately to secure '
          'your account or it will be permanently blocked within 30 minutes.',
      'tamil digital arrest': 'Naan CBI la irundhu pேசுறேன். Ungal peyar la oru case irukku. '
          'Ippove panam anuppu illana arrest pண்ணுவோம். Yaarukkum sollathe.',
      'trai disconnection': 'TRAI has ordered your mobile number to be disconnected within 2 hours due '
          'to illegal activity. Press 9 to speak to officer immediately or provide OTP to verify.',
      'income tax notice': 'Income tax department has issued a warrant against you for tax fraud. '
          'Supreme court notice attached. Pay the pending dues immediately to avoid arrest.',
      'ed officer scam': 'This call is from ED officer regarding money laundering case. Digital arrest '
          'has been ordered. Transfer Rs 90000 to the given account immediately, do not tell your family.',
      'bank kyc hindi': 'Aapka account KYC update nahi hua hai. Turant otp batao warna account freeze '
          'ho jayega aaj hi.',
      'prize sms': 'You are the lucky winner of iPhone 15 prize money. Claim your reward now by paying '
          'Rs 999 refundable deposit at bit.ly/claim99',
      'narcotics parcel': 'Narcotics department found illegal drugs in your name parcel. NIA case filed. '
          'Call mat kaato, turant paisa transfer karo warna giraftar hoga.',
    };

    scams.forEach((label, text) {
      test(label, () async {
        final verdict = await analyzer.analyze(text);
        expect(verdict.band, isNot(RiskBand.safe),
            reason: 'Expected "$label" to be flagged, got score ${verdict.score}');
      });
    });
  });

  group('legitimate messages should score under 30 (no false positives)', () {
    final legit = <String, String>{
      'HDFC debit alert': 'Rs.1,250.00 debited from a/c XX1234 on 07-Sep-26 for UPI/POS txn. '
          'Avl bal Rs.34,520.10. If not you, call 18002586161 -HDFC Bank',
      'real bank OTP': '482913 is your OTP for transaction of Rs.500 at Amazon. Valid for 10 mins. '
          'Do not share this OTP with anyone. -ICICI Bank',
      'delivery notification': 'Your Amazon order #402-1234567 has been shipped and will be delivered '
          'by tomorrow. Track at amazon.in/track',
      'appointment reminder': 'Reminder: Your appointment with Dr. Sharma is scheduled for tomorrow at '
          '4:30 PM at Apollo Hospital, Chennai.',
      'salary credit': 'Rs.65,000.00 credited to a/c XX5678 on 01-Sep-26. Avl bal Rs.1,12,340.50. '
          '-SBI',
      'recharge confirmation': 'Your Airtel prepaid recharge of Rs.399 is successful. Valid till '
          '07-Oct-26. Thank you for using Airtel.',
      'flight reminder': 'Your IndiGo flight 6E-204 from Chennai to Bengaluru departs tomorrow at '
          '6:15 AM. Web check-in is now open.',
      'college notice': 'Reminder: Semester fee payment deadline is 15-Sep-26. Pay via the official '
          'college portal only. Contact accounts office for queries.',
      'gym reminder': 'Hi! Your gym membership renewal is due next week. Visit the front desk to renew '
          'and continue your sessions.',
      'restaurant booking': 'Your table for 4 at Peshawri, Chennai is confirmed for 8:00 PM today. '
          'See you soon!',
      'electricity bill normal': 'Your TANGEDCO electricity bill of Rs.1,840 for August is generated. '
          'Pay by 20-Sep-26 to avoid late fee.',
      'courier normal': 'Your Flipkart order has been delivered. Rate your delivery experience in the app.',
      'bank statement': 'Your monthly account statement for a/c XX1234 is ready. Download it from the '
          'net banking portal.',
      'insurance renewal': 'Your car insurance policy is due for renewal on 30-Sep-26. Renew online at '
          'the official insurer website to avoid a lapse.',
      'work meeting': 'Reminder: Team standup meeting today at 10:00 AM on Google Meet. See calendar '
          'invite for the link.',
    };

    legit.forEach((label, text) {
      test(label, () async {
        final verdict = await analyzer.analyze(text);
        expect(verdict.score, lessThan(30),
            reason: 'Expected "$label" to be safe, got score ${verdict.score} (${verdict.bandLabel})');
      });
    });
  });
}
