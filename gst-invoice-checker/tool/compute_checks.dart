import 'package:gst_invoice_checker/gst_invoice_checker.dart';
void main() {
  for (final p in ['27AAACA1234A1Z', '29AABCB7654P1Z', '27ABCDE1234F1Z']) {
    print('$p -> check ${gstinCheckChar(p)}  full valid: ${isValidGstin(p + gstinCheckChar(p))}');
  }
  print('bad sample 27AAACA1234A1Z2 valid? ${isValidGstin("27AAACA1234A1Z2")}');
}
