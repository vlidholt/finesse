import 'package:example/docs/docs.dart';

final responsiveDoc = ComponentDoc(
  slug: 'responsive',
  title: 'Responsive',
  description:
      'A scale of six breakpoints, carried on the theme: a builder widget '
      'and a context extension.',
  body: (context) => const DocProse(
    children: [
      DocParagraph(
        'Breakpoints are for layouts that change with the width of the '
        'window. Sizes that change between a desktop and a phone (control '
        'heights, text, page margins, gaps) are not a breakpoint question: '
        'the theme already carries them. See Form Factors, which is '
        'switched at the `md` breakpoint below.',
      ),
      DocSection(
        title: 'Breakpoints',
        children: [
          DocParagraph(
            "The theme carries six breakpoints matching Tailwind's "
            'scale. Override any of them on `ThemeData`:',
          ),
          CodeBlock(
            code: '''
ThemeData(
  breakpoints: Breakpoints(
    tn: 0,     // tiny
    sm: 640,
    md: 768,
    lg: 1024,
    xl: 1280,
    xxl: 1536,
  ),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Reading the current breakpoint',
        children: [
          DocParagraph(
            '`ResponsiveBuilder` rebuilds with the breakpoint for the '
            'current width; `context.breakpoint` reads the same value '
            'inline.',
          ),
          CodeBlock(
            code: '''
ResponsiveBuilder(
  builder: (context, breakpoint) {
    final sm = breakpoint >= Theme.of(context).breakpoints.sm;
    return sm ? const WideLayout() : const NarrowLayout();
  },
)''',
          ),
          DocParagraph(
            "Comparisons follow Tailwind's semantics. `sm` means "
            '"small and up", so test with `>=`. Use `==` only to target '
            'exactly one band.',
          ),
        ],
      ),
      DocSection(
        title: 'Switching on the band',
        children: [
          DocParagraph(
            'Each band is its own type on a sealed class, so a `switch` '
            'covers the scale exhaustively:',
          ),
          CodeBlock(
            code: '''
return switch (context.breakpoint) {
  BreakpointTN() => const Text('Tiny'),
  BreakpointSM() => const Text('Small'),
  BreakpointMD() => const Text('Medium'),
  BreakpointLG() => const Text('Large'),
  BreakpointXL() => const Text('Extra large'),
  BreakpointXXL() => const Text('Extra extra large'),
};''',
          ),
        ],
      ),
    ],
  ),
);
