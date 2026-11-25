// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'shadow_test.dart' as shadow;

/// `shadow_test.dart` again, in a browser.
///
/// An outer shadow is clipped to the outside of its element, and how that
/// clip is built matters per renderer: `Path.combine` with
/// `PathOperation.difference` cuts the hole on the VM and returns its first
/// operand unchanged on the web, where every `ShadowDecoration` therefore
/// painted its shadow behind the whole element — visible as a grey wash in
/// every translucent card, bar and menu, and in no VM test.
void main() => shadow.main();
