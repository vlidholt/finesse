import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// On iOS and Android a field shows these on its own. This example asks for
/// them by name, so they can be tried on a desktop too: long-press or
/// right-click a word for the toolbar; with a touch screen, drag a handle.
class TextFieldTouchSelectionExample extends StatelessWidget {
  const TextFieldTouchSelectionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: TextField(
        initialValue: 'Long-press a word to select it',
        // The handles at the ends of a selection.
        selectionControls: finesseTextSelectionControls,
        // The horizontal toolbar over it, in place of the desktop menu.
        useBrowserContextMenu: false,
        contextMenuBuilder: (context, editableTextState) {
          return TextSelectionToolbar.editableText(
            editableTextState: editableTextState,
          );
        },
        // The loupe above the finger while a handle is dragged.
        magnifierConfiguration: TextMagnifierConfiguration(
          shouldDisplayHandlesInMagnifier: false,
          magnifierBuilder: (context, controller, magnifierInfo) {
            return TextMagnifier(magnifierInfo: magnifierInfo);
          },
        ),
      ),
    );
  }
}
