// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'popover_arrow_test.dart' as arrow;

/// `popover_arrow_test.dart` again, in a browser: the outline of an arrowed
/// popover is one contour that is filled, clipped to and stroked, and paths
/// are where the web's renderer has differed before.
void main() => arrow.main();
