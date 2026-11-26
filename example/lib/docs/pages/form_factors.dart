import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/form_factors/form_factors_side_by_side.dart';

final formFactorsDoc = ComponentDoc(
  slug: 'form_factors',
  title: 'Form Factors',
  description:
      'Every style carries two sets of metrics, one for a desktop and one '
      'for a phone. The theme holds the choice, so the same widgets come '
      'out denser under a pointer and larger under a thumb.',
  body: (context) => DocProse(
    children: [
      const DocParagraph(
        'A `FormFactor` is `desktop` or `mobile`. It is a property of the '
        'theme, not of a widget: a button does not ask how wide the window '
        'is, it reads its height from the theme, and the theme was built '
        'for one form factor or the other. In the default style that is a '
        '36-point button and a 40-point field on a desktop, and 44 and 46 '
        'on a phone, where body text also grows from 14 to 15 and page '
        'margins tighten from 24 to 16.',
      ),
      DocExample(
        slug: 'form_factors',
        example: ComponentExample(
          id: 'form_factors_side_by_side',
          title: 'Side by side',
          description:
              'The same widgets twice. The only difference is the theme '
              'above each column.',
          minPreviewHeight: 420,
          builder: (_) => const FormFactorsSideBySideExample(),
        ),
      ),
      const DocSection(
        title: 'How it is chosen',
        children: [
          DocParagraph(
            '`UnaApp` picks the form factor from the window width: '
            'narrower than the theme\'s `md` breakpoint (768 by default) '
            'is `mobile`, anything wider is `desktop`. Resize the window '
            'across the breakpoint and the whole app re-lays itself out '
            'through the usual theme transition. To pin one regardless of '
            'width, pass it:',
          ),
          CodeBlock(
            code: '''
UnaApp(
  // Null, the default, follows the window width.
  formFactor: FormFactor.mobile,
  home: const HomePage(),
)''',
          ),
          DocParagraph(
            'Move the threshold by changing the breakpoint it reads: '
            '`ThemeData(breakpoints: Breakpoints(md: 600))`.',
          ),
        ],
      ),
      const DocSection(
        title: 'Reading it',
        children: [
          DocParagraph(
            'Most code never needs to. Sizes follow the form factor on '
            'their own, through component themes, the gap scale and '
            '`PageContainer`. Read it only where a screen is arranged '
            'differently on a phone:',
          ),
          CodeBlock(
            code: '''
// A one-off branch.
final isPhone = Theme.of(context).formFactor == FormFactor.mobile;

// Two layouts.
FormFactorBuilder(
  mobile: (context) => const ConversationList(),
  desktop: (context) => const Row(
    children: [ConversationList(), Expanded(child: Conversation())],
  ),
)''',
          ),
          DocParagraph(
            'Do not read the window width in a component to pick a size. '
            'A widget that does stops following a pinned `formFactor`, a '
            'themed subtree, and the preview on this page.',
          ),
        ],
      ),
      const DocSection(
        title: 'Laying out a subtree for the other one',
        children: [
          DocParagraph(
            '`ThemeData.withFormFactor` returns the same theme laid out '
            'for another form factor: every component theme is rebuilt '
            'from the style\'s other set of metrics. The result is cached, '
            'so calling it in `build` is cheap. It is how the example '
            'above, and the phone frames elsewhere in these docs, are '
            'made:',
          ),
          CodeBlock(
            code: '''
Theme(
  data: Theme.of(context).withFormFactor(FormFactor.mobile),
  child: const PhonePreview(),
)''',
          ),
        ],
      ),
      const DocSection(
        title: 'Where the mobile metrics come from',
        children: [
          DocParagraph(
            'A `StyleTokens` has a `mobile` field: a second, complete set '
            'of tokens for a touch-sized screen. `StyleTokens.fluid` '
            'points it at `StyleTokens.fluidMobile`, which was measured '
            'from the phone designs. A style that leaves it null gets '
            'derived metrics instead. `forFormFactor` is what resolves '
            'either:',
          ),
          CodeBlock(
            code: '''
StyleTokens.fluid.forFormFactor(FormFactor.mobile); // unaMobile
StyleTokens.crisp.forFormFactor(FormFactor.mobile);    // derived from crisp''',
          ),
          DocParagraph('The derivation only ever loosens a style:'),
          DocBullets(
            items: [
              'Buttons, icon buttons and fields grow to at least 44, '
                  'small buttons to 36 and large ones to 48.',
              'Body and field text grow to at least 15 on a 22 line.',
              'Chips grow to 36, checkboxes and radios to 20, menu rows '
                  'gain vertical padding, calendar cells reach 40.',
              'The app bar is 60 tall and page margins are 16.',
              'The `lg` gap drops from 16 to 12 and `xl` from 24 to 16.',
            ],
          ),
          DocParagraph(
            'For a custom style, either accept the derivation or supply '
            'your own phone metrics:',
          ),
          CodeBlock(
            code: '''
final mine = StyleTokens.crisp.copyWith(buttonHeight: 34);

ThemeData(
  style: mine.copyWith(
    // Start from the derived set and adjust it.
    mobile: mine
        .forFormFactor(FormFactor.mobile)
        .copyWith(buttonHeight: 48),
  ),
)''',
          ),
        ],
      ),
    ],
  ),
);
