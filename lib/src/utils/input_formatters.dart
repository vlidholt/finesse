import 'package:flutter/services.dart';

/// Converts all entered text to upper case. Keeps the selection.
class UpperCaseTextInputFormatter extends TextInputFormatter {
  /// Creates an upper-case formatter.
  const UpperCaseTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Converts all entered text to lower case. Keeps the selection.
class LowerCaseTextInputFormatter extends TextInputFormatter {
  /// Creates a lower-case formatter.
  const LowerCaseTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
