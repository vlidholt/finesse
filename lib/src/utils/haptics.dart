import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/haptics_env_stub.dart'
    if (dart.library.io) 'package:una/src/utils/haptics_env_io.dart';

/// How strong the tap of [Haptics.impact] is.
enum HapticImpact {
  /// A light tap: a drop, a toggle, a limit reached.
  light,

  /// A firmer tap: something picked up, a gesture armed.
  medium,

  /// The strongest tap. Rarely the right one.
  heavy,
}

/// The package's haptic feedback: one place that decides whether the device
/// ticks.
///
/// Every una control that ticks under a finger goes through here, and
/// an app's own controls can too:
///
/// ```dart
/// onChanged: (value) {
///   Haptics.selection(context);
///   setState(() => _value = value);
/// },
/// ```
///
/// A call does nothing
///
/// * on the web and on desktop platforms: only Android and iOS tick;
/// * under a theme with `ThemeData(haptics: false)`, which switches them off
///   for the whole app, or for the subtree below a `Theme` that carries it;
/// * in a test, unless the test sets [debugEnabledInTests].
///
/// It does not look at what kind of pointer caused the change. A control
/// that is also driven by a mouse or a keyboard asks only for a finger's
/// changes, as the board and the wheel do.
abstract final class Haptics {
  /// Whether calls are sent to the platform while running under
  /// `flutter test`. False by default, so that a tap in a widget test sends
  /// nothing to a platform channel the test may be recording.
  ///
  /// A test that asserts haptics sets it and puts it back:
  ///
  /// ```dart
  /// setUp(() => Haptics.debugEnabledInTests = true);
  /// tearDown(() => Haptics.debugEnabledInTests = false);
  /// ```
  @visibleForTesting
  static bool debugEnabledInTests = false;

  /// Whether a call made with [context] would reach the platform: the
  /// platform has a haptic engine an app may use, and the theme above
  /// [context] has not switched haptics off.
  ///
  /// Does not make [context] depend on the theme.
  static bool enabledOf(BuildContext context) {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return false;
    }
    if (runningInFlutterTest && !debugEnabledInTests) return false;
    // A callback can outlive its widget by a frame.
    if (!context.mounted) return false;
    return Theme.maybeOf(context, listen: false)?.haptics ?? true;
  }

  /// The tick of a selection changing under the finger: a wheel's row, a
  /// slider's stop, a segment, a step.
  static void selection(BuildContext context) {
    if (enabledOf(context)) HapticFeedback.selectionClick();
  }

  /// A tap for something that happened once: an item picked up
  /// ([HapticImpact.medium]) or put down ([HapticImpact.light]), a
  /// gesture that armed, a switch thrown.
  static void impact(
    BuildContext context, [
    HapticImpact impact = HapticImpact.light,
  ]) {
    if (!enabledOf(context)) return;
    switch (impact) {
      case HapticImpact.light:
        HapticFeedback.lightImpact();
      case HapticImpact.medium:
        HapticFeedback.mediumImpact();
      case HapticImpact.heavy:
        HapticFeedback.heavyImpact();
    }
  }
}
