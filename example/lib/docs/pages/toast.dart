import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/toast/toast_basic.dart';
import 'package:example/docs/examples/toast/toast_inline.dart';
import 'package:example/docs/examples/toast/toast_loading.dart';
import 'package:example/docs/examples/toast/toast_stack.dart';
import 'package:example/docs/examples/toast/toast_variants.dart';

final toastDoc = ComponentDoc(
  slug: 'toast',
  title: 'Toast',
  description:
      'A short message that floats over the app and leaves by itself. '
      '`UnaApp` installs one `Toaster` above the navigator; '
      '`Toaster.of(context)` shows, replaces and dismisses `Toast`s in it. '
      'On a desktop the stack sits in the bottom end corner and a toast '
      'has a close button on hover; on a phone a toast spans the bottom of '
      'the page and is swiped away, down or sideways.',
  examples: [
    ComponentExample(
      id: 'toast_basic',
      title: 'Default',
      description:
          '`show` returns what identifies the toast; give it an `id` of '
          'your own when its `action` has to dismiss it. Pressing the '
          'action does not dismiss the toast by itself.',
      builder: (_) => const ToastBasicExample(),
    ),
    ComponentExample(
      id: 'toast_variants',
      title: 'Variants',
      description:
          'Every variant is the same surface — a popover surface, glass in '
          'a style whose popovers are — and says what it is with the icon '
          'it leads with, in the `success`, `warning` and `destructive` '
          'colours of the scheme. `leading` replaces the icon. A '
          'destructive toast is announced assertively.',
      builder: (_) => const ToastVariantsExample(),
    ),
    ComponentExample(
      id: 'toast_loading',
      title: 'Loading, then a result',
      description:
          'A `ToastVariant.loading` toast shows a spinner and stays. '
          '`update` replaces it where it is with its result, which then '
          'lives as long as any result. `dismissible: false` takes away '
          'the swipe, the close button and Escape.',
      builder: (_) => const ToastLoadingExample(),
    ),
    ComponentExample(
      id: 'toast_stack',
      title: 'The stack',
      description:
          'The newest toast is in front and the ones behind it show an '
          'edge. Pointing at the stack opens it and stops every clock '
          'until the pointer leaves. More than three wait unseen and come '
          'back as the ones in front leave. F6 moves the keyboard focus '
          'into the toasts and back; Escape dismisses the one that has '
          'it. `duration: Duration.zero` keeps a toast until it is '
          'dismissed.',
      builder: (_) => const ToastStackExample(),
    ),
    ComponentExample(
      id: 'toast_inline',
      title: 'On its own',
      description:
          'Outside a toaster a `Toast` is a plain widget, for a settings '
          'preview or a design review. Its look comes from '
          '`ThemeData.toastTheme`; where the stack sits, how wide a toast '
          'is and how many show come from `ThemeData.toasterTheme`.',
      minPreviewHeight: 380,
      builder: (_) => const ToastInlineExample(),
    ),
  ],
);
