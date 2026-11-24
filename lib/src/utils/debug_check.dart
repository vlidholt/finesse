import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// Asserts that [context] has a [Theme] ancestor.
///
/// Throws a [FlutterError] in debug mode when there is none. Always returns
/// true, so call it inside an `assert`.
bool debugCheckHasTheme(BuildContext context) {
  assert(() {
    if (context.widget is! FinesseInheritedTheme &&
        context
                .getElementForInheritedWidgetOfExactType<
                  FinesseInheritedTheme
                >() ==
            null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No Theme widget ancestor found.'),
        ErrorDescription(
          '''${context.widget.runtimeType} widgets require a Theme widget ancestor.''',
        ),
        context.describeWidget(
          'The specific widget that could not find a Theme ancestor was',
        ),
        context.describeOwnershipChain(
          'The ownership chain for the affected widget is',
        ),
        ErrorHint(
          'No Theme ancestor could be found starting from the context '
          'that was passed to Theme.of(). This can happen because the '
          'app is not wrapped with the Finesse widget.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}
