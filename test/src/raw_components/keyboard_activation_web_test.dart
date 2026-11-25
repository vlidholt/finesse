// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'keyboard_activation_test.dart' as keyboard_activation;

/// `keyboard_activation_test.dart` again, in a browser, where Enter is
/// bound to `ButtonActivateIntent` rather than `ActivateIntent`: a control
/// that answers only the second is deaf to Enter on the web.
void main() {
  keyboard_activation.main();
}
