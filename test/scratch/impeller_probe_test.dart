import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('probe', () {
    // ignore: avoid_print
    print('shader filters: ${ui.ImageFilter.isShaderFilterSupported}');
  });
}
