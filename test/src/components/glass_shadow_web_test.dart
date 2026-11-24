// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'glass_shadow_test.dart' as glass;

/// `glass_shadow_test.dart` again, in a browser: the renderer the grey wash
/// in the glass menus was seen on, and the one where a tooltip lost its
/// arrow.
void main() => glass.main();
