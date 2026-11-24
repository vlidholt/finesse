import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/page_container/form_factor_builder.dart';
import 'package:example/docs/examples/page_container/page_container_basic.dart';
import 'package:flutter/widgets.dart';

final pageContainerDoc = ComponentDoc(
  slug: 'page_container',
  title: 'Page Container',
  description:
      '`PageContainer` centres page content, caps its width and gives it '
      'the page margins of the theme, so every screen lines up with the app '
      'bar. `FormFactorBuilder` picks between two layouts where a screen '
      'is arranged differently on a phone.',
  examples: [
    ComponentExample(
      id: 'page_container_basic',
      title: 'PageContainer',
      description:
          'Margins and the maximum width come from '
          '`ThemeData.layoutTheme`, so they tighten on a phone. The safe '
          'area, which inside a `Scaffold` includes the bars, is added to '
          'the padding; with `scrollable` the content still scrolls '
          'beneath them.',
      minPreviewHeight: 400,
      padding: const EdgeInsets.all(16),
      builder: (_) => const PageContainerBasicExample(),
    ),
    ComponentExample(
      id: 'form_factor_builder',
      title: 'FormFactorBuilder',
      description:
          'Use it where the layout is rearranged, not merely resized: '
          'sizes already follow the form factor through the theme. For a '
          'one-off branch read `Theme.of(context).formFactor`.',
      minPreviewHeight: 380,
      padding: const EdgeInsets.all(16),
      builder: (_) => const FormFactorBuilderExample(),
    ),
  ],
);
