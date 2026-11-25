import 'dart:io';

/// Whether the code is running under `flutter test`, which sets the
/// `FLUTTER_TEST` environment variable (the framework picks its default
/// target platform from the same variable).
final bool runningInFlutterTest = Platform.environment.containsKey(
  'FLUTTER_TEST',
);
