import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/back_button/back_button_basic.dart';
import 'package:example/docs/examples/back_button/back_button_custom.dart';

final backButtonDoc = ComponentDoc(
  slug: 'back_button',
  title: 'Back Button',
  description:
      'The two buttons that leave a page. `BackButton` is a caret pointing '
      'at the start of the line; `CloseButton` is a cross. Each pops the '
      'page it is on, and an `AppBar` shows the right one by itself: a '
      'back button on a page that can be popped, a close button on a '
      'full-screen dialog.',
  examples: [
    ComponentExample(
      id: 'back_button_basic',
      title: 'Back and close',
      description:
          'Without an `onPressed` each calls `Navigator.maybePop`, so a '
          '`PopScope` on the page gets its say. The caret turns round in a '
          'right-to-left language; the cross does not. Both are announced '
          'in the app\'s language ("Back", "Close"), and on a desktop the '
          'same word is the tooltip.',
      builder: (_) => const BackButtonBasicExample(),
    ),
    ComponentExample(
      id: 'back_button_custom',
      title: 'Another icon, another name',
      description:
          '`icon` replaces the glyph and `semanticLabel` the name — "Back '
          'to inbox" tells a screen reader more than "Back". `enabled: '
          'false` keeps the button in place and inert.',
      builder: (_) => const BackButtonCustomExample(),
    ),
  ],
);
