import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../decoration_finders.dart';
import '../../una_harness.dart';

/// `Card.onPressed`, `selected`, `sectionGap` and `semanticLabel`: a card as
/// the row of a master-detail list.
void main() {
  /// The card's own box: fill, outline and radius.
  BoxDecoration decorationOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find
          .descendant(of: find.byType(Card), matching: find.byType(Container))
          .first,
    );
    return boxDecorationOf(container.decoration)!;
  }

  Widget card({
    VoidCallback? onPressed,
    bool selected = false,
    String? semanticLabel,
    Widget? footer,
    Color? backgroundColor,
    UnaBorder? border,
    BorderRadius? radius,
  }) {
    return Center(
      child: SizedBox(
        width: 320,
        child: Card(
          onTap: onPressed,
          selected: selected,
          semanticLabel: semanticLabel,
          style: CardTheme(
            backgroundColor: backgroundColor,
            border: border,
            borderRadius: radius,
          ),
          title: const Text('Senior designer'),
          description: const Text('Halcyon'),
          footer: footer,
          child: const Text('Remote, full time'),
        ),
      ),
    );
  }

  group('Card.onPressed', () {
    testWidgets('a card without it is not a control', (tester) async {
      await pumpUna(tester, card());
      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Pressable),
        ),
        findsNothing,
      );
      expect(find.byType(FocusRing), findsNothing);
      // Nothing in it takes keyboard focus.
      expect(
        find.descendant(of: find.byType(Card), matching: find.byType(Focus)),
        findsNothing,
      );
    });

    testWidgets('a tap anywhere on the card calls it', (tester) async {
      var presses = 0;
      await pumpUna(tester, card(onPressed: () => presses++));

      await tester.tap(find.text('Senior designer'));
      expect(presses, 1);
      // The padding is the card too, not only its text.
      final rect = tester.getRect(find.byType(Card));
      await tester.tapAt(rect.bottomRight - const Offset(4, 4));
      await tester.tapAt(rect.topLeft + const Offset(4, 4));
      expect(presses, 3);
    });

    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => card(
          onPressed: () {},
          selected: true,
          footer: Button.outline(onPressed: () {}, child: const Text('Apply')),
        ),
      );
    });

    testWidgets('pressing it changes neither its size nor its position', (
      tester,
    ) async {
      await pumpUna(tester, card());
      final plain = tester.getRect(find.byType(Card));
      final title = tester.getRect(find.text('Senior designer'));

      await pumpUna(tester, card(onPressed: () {}));
      expect(tester.getRect(find.byType(Card)), plain);
      expect(tester.getRect(find.text('Senior designer')), title);
    });

    testWidgets('Tab reaches it; Enter and Space activate it', (tester) async {
      var presses = 0;
      await pumpUna(tester, card(onPressed: () => presses++));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(presses, 2);
    });

    testWidgets("keyboard focus draws the theme's ring on the card's radius", (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpUna(tester, card(onPressed: () {}));
      final theme = themeOf(tester, find.byType(Card));
      var ring = tester.widget<FocusRing>(find.byType(FocusRing));
      expect(ring.visible, isFalse);
      expect(ring.borderRadius, theme.cardTheme.borderRadius);
      expect(ring.inset, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      ring = tester.widget<FocusRing>(find.byType(FocusRing));
      expect(ring.visible, isTrue);
      // The ring takes no room: the card is where it was.
      expect(
        tester.getRect(find.byType(FocusRing)),
        tester.getRect(find.byType(Card)),
      );

      const radius = BorderRadius.all(Radius.circular(3));
      await pumpUna(tester, card(onPressed: () {}, radius: radius));
      expect(
        tester.widget<FocusRing>(find.byType(FocusRing)).borderRadius,
        radius,
      );
    });

    testWidgets('a button inside the card takes its own taps', (tester) async {
      var cardPresses = 0;
      var buttonPresses = 0;
      await pumpUna(
        tester,
        card(
          onPressed: () => cardPresses++,
          footer: Button.outline(
            onPressed: () => buttonPresses++,
            child: const Text('Apply'),
          ),
        ),
      );

      await tester.tap(find.text('Apply'));
      await tester.pump();
      expect(buttonPresses, 1);
      expect(cardPresses, 0);

      // And the rest of the card is still the card.
      await tester.tap(find.text('Remote, full time'));
      await tester.pump();
      expect(buttonPresses, 1);
      expect(cardPresses, 1);
    });

    testWidgets('a pressable inside the card takes its own taps too', (
      tester,
    ) async {
      var cardPresses = 0;
      var chipPresses = 0;
      await pumpUna(
        tester,
        card(
          onPressed: () => cardPresses++,
          footer: Chip(
            label: const Text('Save'),
            onPressed: () => chipPresses++,
          ),
        ),
      );
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(chipPresses, 1);
      expect(cardPresses, 0);
    });

    testWidgets('a focused button inside the card is what Enter activates', (
      tester,
    ) async {
      var cardPresses = 0;
      var buttonPresses = 0;
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpUna(
        tester,
        card(
          onPressed: () => cardPresses++,
          footer: Button.outline(
            focusNode: node,
            onPressed: () => buttonPresses++,
            child: const Text('Apply'),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(buttonPresses, 1);
      expect(cardPresses, 0);
    });
  });

  group('Card.selected', () {
    testWidgets('takes the accent fill and a 1.5 tint outline from the '
        'scheme, in both brightnesses', (tester) async {
      for (final brightness in Brightness.values) {
        for (final onPressed in <VoidCallback?>[null, () {}]) {
          await pumpUna(
            tester,
            card(selected: true, onPressed: onPressed),
            theme: ThemeData(brightness: brightness),
          );
          final scheme = themeOf(tester, find.byType(Card)).colorScheme;
          final decoration = decorationOf(tester);
          final border = decoration.border! as Border;
          final reason = '$brightness, pressable: ${onPressed != null}';

          expect(decoration.color, scheme.accent, reason: reason);
          for (final side in [
            border.top,
            border.right,
            border.bottom,
            border.left,
          ]) {
            expect(side.color, scheme.tint, reason: reason);
            expect(side.width, 1.5, reason: reason);
          }
        }
      }
    });

    testWidgets('an unselected card keeps the card fill and its hairline', (
      tester,
    ) async {
      await pumpUna(tester, card(onPressed: () {}));
      final theme = themeOf(tester, find.byType(Card));
      final decoration = decorationOf(tester);
      expect(decoration.color, theme.cardTheme.backgroundColor);
      expect(decoration.color, isNot(theme.colorScheme.accent));
      final border = decoration.border! as Border;
      expect(border.top.width, 1);
      expect(border.top.color, isNot(theme.colorScheme.tint));
    });

    testWidgets('selecting changes the fill and the outline, in every style', (
      tester,
    ) async {
      for (final style in [
        StyleTokens.fluid,
        StyleTokens.crisp,
        StyleTokens.pebble,
        StyleTokens.sharp,
      ]) {
        final theme = ThemeData(style: style);
        await pumpUna(tester, card(), theme: theme);
        final off = decorationOf(tester);
        await pumpUna(tester, card(selected: true), theme: theme);
        final on = decorationOf(tester);
        expect(on.color, isNot(off.color), reason: style.name);
        expect(on.color, theme.colorScheme.accent, reason: style.name);
        expect(
          (on.border! as Border).top.color,
          theme.colorScheme.tint,
          reason: style.name,
        );
        // The corners do not move.
        expect(on.borderRadius, off.borderRadius, reason: style.name);
      }
    });

    testWidgets('an explicit backgroundColor and border still win', (
      tester,
    ) async {
      const fill = Color(0xff102030);
      const outline = Color(0xff405060);
      await pumpUna(
        tester,
        card(
          selected: true,
          backgroundColor: fill,
          border: UnaBorder.all(color: outline, width: 3),
        ),
      );
      final decoration = decorationOf(tester);
      expect(decoration.color, fill);
      expect((decoration.border! as Border).top.color, outline);
      expect((decoration.border! as Border).top.width, 3);
    });

    testWidgets('a selected card is exactly the size of an unselected one, '
        'and nothing inside it moves', (tester) async {
      for (final style in [StyleTokens.fluid, StyleTokens.crisp]) {
        for (final formFactor in FormFactor.values) {
          final theme = ThemeData(style: style);
          final footer = Button.outline(
            onPressed: () {},
            child: const Text('Apply'),
          );
          final reason = '${style.name} ${formFactor.name}';

          await pumpUna(
            tester,
            card(footer: footer),
            theme: theme,
            formFactor: formFactor,
          );
          final cardRect = tester.getRect(find.byType(Card));
          final title = tester.getRect(find.text('Senior designer'));
          final description = tester.getRect(find.text('Halcyon'));
          final body = tester.getRect(find.text('Remote, full time'));
          final button = tester.getRect(find.byType(Button));

          for (final onPressed in <VoidCallback?>[null, () {}]) {
            await pumpUna(
              tester,
              card(footer: footer, selected: true, onPressed: onPressed),
              theme: theme,
              formFactor: formFactor,
            );
            // The 1.5 outline really is there…
            expect(
              (decorationOf(tester).border! as Border).top.width,
              1.5,
              reason: reason,
            );
            // …and it cost the card nothing.
            expect(tester.getRect(find.byType(Card)), cardRect, reason: reason);
            expect(
              tester.getRect(find.text('Senior designer')),
              title,
              reason: reason,
            );
            expect(
              tester.getRect(find.text('Halcyon')),
              description,
              reason: reason,
            );
            expect(
              tester.getRect(find.text('Remote, full time')),
              body,
              reason: reason,
            );
            expect(tester.getRect(find.byType(Button)), button, reason: reason);
          }
        }
      }
    });

    testWidgets('the padding gives back exactly what the heavier outline '
        'takes', (tester) async {
      await pumpUna(tester, card());
      final resting = tester.widget<Container>(
        find
            .descendant(of: find.byType(Card), matching: find.byType(Container))
            .first,
      );
      await pumpUna(tester, card(selected: true));
      final selected = tester.widget<Container>(
        find
            .descendant(of: find.byType(Card), matching: find.byType(Container))
            .first,
      );
      final restingPadding = resting.padding!.resolve(TextDirection.ltr);
      final selectedPadding = selected.padding!.resolve(TextDirection.ltr);
      // 1 → 1.5 of border on each side, so half a pixel less padding.
      expect(restingPadding, const EdgeInsets.all(20));
      expect(selectedPadding, const EdgeInsets.all(19.5));
    });

    testWidgets('a custom padding is compensated the same way', (tester) async {
      Widget padded({required bool selected}) => Center(
        child: SizedBox(
          width: 320,
          child: Card(
            selected: selected,
            style: const CardTheme(padding: EdgeInsets.fromLTRB(8, 4, 12, 6)),
            child: const SizedBox(key: Key('body'), height: 30),
          ),
        ),
      );
      await pumpUna(tester, padded(selected: false));
      final cardRect = tester.getRect(find.byType(Card));
      final body = tester.getRect(find.byKey(const Key('body')));
      await pumpUna(tester, padded(selected: true));
      expect(tester.getRect(find.byType(Card)), cardRect);
      expect(tester.getRect(find.byKey(const Key('body'))), body);
    });

    testWidgets('a selected card with no padding to give does not go '
        'negative', (tester) async {
      await pumpUna(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: Card(
              selected: true,
              style: CardTheme(padding: EdgeInsets.zero),
              child: SizedBox(key: Key('body'), height: 30),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      // The outline has nowhere to hide, so here the card does grow by it.
      expect(tester.getSize(find.byType(Card)).height, 30 + 1.5 * 2);
    });

    testWidgets('an opaque selected fill stops the card blurring', (
      tester,
    ) async {
      // A style whose cards are glass: una's own are translucent
      // without a blur.
      final glass = ThemeData(
        style: StyleTokens.fluid.copyWith(cardBlur: true),
      );
      await pumpUna(tester, card(), theme: glass);
      expect(find.byType(BackdropFilter), findsOneWidget);

      await pumpUna(tester, card(selected: true), theme: glass);
      final accent = themeOf(tester, find.byType(Card)).colorScheme.accent;
      // …and a backdrop layer is only paid for while the fill shows it.
      expect(
        find.byType(BackdropFilter),
        accent.a < 1 ? findsOneWidget : findsNothing,
      );
    });
  });

  group('Card header', () {
    const action = SizedBox(key: Key('action'), width: 36, height: 36);

    Widget header({Widget? description}) => Center(
      child: SizedBox(
        width: 320,
        child: Card(
          title: const Text('Title'),
          description: description,
          action: action,
          child: const SizedBox(height: 10),
        ),
      ),
    );

    testWidgets('a lone title is centred on its action', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpUna(tester, header(), textDirection: direction);
        final title = tester.getRect(find.text('Title'));
        final actionRect = tester.getRect(find.byKey(const Key('action')));
        // The action is the taller of the two, so the title moves down to
        // its middle rather than sitting at its top.
        expect(actionRect.height, greaterThan(title.height));
        expect(title.center.dy, closeTo(actionRect.center.dy, .01));
        expect(title.top, greaterThan(actionRect.top));
        // And the action is still at the end of the row.
        if (direction == TextDirection.ltr) {
          expect(actionRect.left, greaterThanOrEqualTo(title.right));
        } else {
          expect(actionRect.right, lessThanOrEqualTo(title.left));
        }
      }
    });

    testWidgets('with a description the action stays at the top, level with '
        'the title', (tester) async {
      await pumpUna(
        tester,
        header(
          description: const Text(
            'A description long enough to wrap on to a second line of the '
            'card, so that the header is much taller than its action.',
          ),
        ),
      );
      final title = tester.getRect(find.text('Title'));
      final description = tester.getRect(find.textContaining('A description'));
      final actionRect = tester.getRect(find.byKey(const Key('action')));
      expect(description.bottom, greaterThan(actionRect.bottom));
      expect(actionRect.top, title.top);
      // Not centred against the whole header.
      expect(
        actionRect.center.dy,
        lessThan((title.top + description.bottom) / 2),
      );
    });

    testWidgets('a lone title with no action is where it always was', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: Card(title: Text('Title'), child: SizedBox(height: 10)),
          ),
        ),
      );
      final box = tester.getRect(find.byType(Card));
      // The card's padding and its 1px outline.
      expect(tester.getRect(find.text('Title')).top, box.top + 20 + 1);
    });

    testWidgets('a description alone keeps its action at the top', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: Card(
              description: Text('Only a description'),
              action: action,
              child: SizedBox(height: 10),
            ),
          ),
        ),
      );
      expect(
        tester.getRect(find.byKey(const Key('action'))).top,
        tester.getRect(find.text('Only a description')).top,
      );
    });
  });

  group('Card.sectionGap', () {
    const body = SizedBox(key: Key('body'), height: 30);
    const footer = SizedBox(key: Key('footer'), height: 20);

    Widget sections({double? sectionGap, double? gap}) => Center(
      child: SizedBox(
        width: 320,
        child: Card(
          style: CardTheme(
            sectionGap: sectionGap,
            gap: gap,
          ),
          title: const Text('Title'),
          description: const Text('Description'),
          footer: footer,
          child: body,
        ),
      ),
    );

    ({double headerToBody, double bodyToFooter, double titleToDescription})
    gaps(WidgetTester tester) {
      final title = tester.getRect(find.text('Title'));
      final description = tester.getRect(find.text('Description'));
      final bodyRect = tester.getRect(find.byKey(const Key('body')));
      final footerRect = tester.getRect(find.byKey(const Key('footer')));
      return (
        headerToBody: bodyRect.top - description.bottom,
        bodyToFooter: footerRect.top - bodyRect.bottom,
        titleToDescription: description.top - title.bottom,
      );
    }

    testWidgets("defaults to the theme's gap between sections", (tester) async {
      for (final style in [StyleTokens.fluid, StyleTokens.crisp]) {
        await pumpUna(tester, sections(), theme: ThemeData(style: style));
        final theme = themeOf(tester, find.byType(Card));
        final themed = theme.cardTheme.sectionGap!;
        final measured = gaps(tester);
        expect(measured.headerToBody, themed, reason: style.name);
        expect(measured.bodyToFooter, themed, reason: style.name);
        // The card's padding, as documented.
        expect(
          theme.cardTheme.padding,
          EdgeInsets.all(themed),
          reason: style.name,
        );
      }
    });

    testWidgets('overrides the gap between header, child and footer, and '
        'leaves the title gap alone', (tester) async {
      await pumpUna(tester, sections());
      final themed = gaps(tester);

      await pumpUna(tester, sections(sectionGap: 7));
      final tight = gaps(tester);
      expect(tight.headerToBody, 7);
      expect(tight.bodyToFooter, 7);
      expect(tight.titleToDescription, themed.titleToDescription);

      await pumpUna(tester, sections(sectionGap: 0));
      expect(gaps(tester).headerToBody, 0);
      expect(gaps(tester).bodyToFooter, 0);
    });

    testWidgets('gap still only separates the title from its description', (
      tester,
    ) async {
      await pumpUna(tester, sections(sectionGap: 7, gap: 11));
      final measured = gaps(tester);
      expect(measured.titleToDescription, 11);
      expect(measured.headerToBody, 7);
      expect(measured.bodyToFooter, 7);
    });

    testWidgets('a tighter section gap makes the card shorter by exactly '
        'the difference', (tester) async {
      await pumpUna(tester, sections());
      final themed = themeOf(
        tester,
        find.byType(Card),
      ).cardTheme.sectionGap!;
      final tall = tester.getSize(find.byType(Card)).height;

      await pumpUna(tester, sections(sectionGap: 4));
      expect(
        tester.getSize(find.byType(Card)).height,
        tall - 2 * (themed - 4),
      );
    });
  });

  group('Card semantics', () {
    testWidgets('a pressable card is one enabled button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, card(onPressed: () {}));

      final data = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
      expect(data.hasAction(ui.SemanticsAction.focus), isTrue);
      // A plain button: it is not one of a set until it is selected.
      expect(data.flagsCollection.isSelected, ui.Tristate.none);
      // With no label of its own it reads its content.
      expect(data.label, contains('Senior designer'));
      expect(data.label, contains('Halcyon'));
      handle.dispose();
    });

    testWidgets('semanticLabel is read first, and the content after it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await pumpUna(
        tester,
        card(onPressed: () => presses++, semanticLabel: 'Open job'),
      );

      final node = tester.getSemantics(find.byType(Pressable));
      final data = node.getSemanticsData();
      expect(
        data.label,
        'Open job\nSenior designer\nHalcyon\nRemote, full time',
      );
      expect(data.flagsCollection.isButton, isTrue);
      // Read, and also activated: the label must not cost the card its
      // tap action.
      expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
      node.owner!.performAction(node.id, ui.SemanticsAction.tap);
      await tester.pump();
      expect(presses, 1);
      handle.dispose();
    });

    testWidgets('a labelled, pressable card keeps a button inside it in the '
        'semantics tree, and tappable', (tester) async {
      final handle = tester.ensureSemantics();
      var cardPresses = 0;
      var saves = 0;
      await pumpUna(
        tester,
        Center(
          child: SizedBox(
            width: 320,
            child: Card(
              onTap: () => cardPresses++,
              semanticLabel: 'Open job',
              title: const Text('Senior designer'),
              description: const Text('Halcyon'),
              action: IconButton.ghost(
                icon: const Icon(
                  PhosphorIconsRegular.bookmarkSimple,
                  semanticLabel: 'Save',
                ),
                onPressed: () => saves++,
              ),
              child: const Text('Remote, full time'),
            ),
          ),
        ),
      );

      // The card is one node…
      final cardNode = tester.getSemantics(find.byType(Pressable).first);
      final cardData = cardNode.getSemanticsData();
      expect(cardData.label, startsWith('Open job'));
      expect(cardData.flagsCollection.isButton, isTrue);
      expect(cardData.hasAction(ui.SemanticsAction.tap), isTrue);
      // …and the button inside it is another, under it, with its own name
      // and its own tap action.
      expect(find.bySemanticsLabel('Save'), findsOneWidget);
      final saveNode = tester.getSemantics(find.bySemanticsLabel('Save'));
      expect(saveNode.id, isNot(cardNode.id));
      expect(cardData.label, isNot(contains('Save')));
      expect(
        saveNode.getSemanticsData().hasAction(ui.SemanticsAction.tap),
        isTrue,
      );
      var isUnderCard = false;
      for (var n = saveNode.parent; n != null; n = n.parent) {
        if (n.id == cardNode.id) isUnderCard = true;
      }
      expect(isUnderCard, isTrue);
      final buttonNode = tester.getSemantics(find.byType(IconButton));
      expect(buttonNode.getSemanticsData().flagsCollection.isButton, isTrue);

      // Assistive technology activates each on its own.
      final owner = cardNode.owner!;
      owner.performAction(saveNode.id, ui.SemanticsAction.tap);
      await tester.pump();
      expect(saves, 1);
      expect(cardPresses, 0);
      owner.performAction(cardNode.id, ui.SemanticsAction.tap);
      await tester.pump();
      expect(saves, 1);
      expect(cardPresses, 1);

      // And so does a finger.
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(saves, 2);
      expect(cardPresses, 1);
      await tester.tap(find.text('Remote, full time'));
      await tester.pump();
      expect(saves, 2);
      expect(cardPresses, 2);
      handle.dispose();
    });

    testWidgets('an unlabelled pressable card keeps its inner button too', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        card(
          onPressed: () {},
          footer: IconButton.ghost(
            icon: const Icon(
              PhosphorIconsRegular.bookmarkSimple,
              semanticLabel: 'Save',
            ),
            onPressed: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Save'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('semanticLabel does nothing to a card that cannot be pressed', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, card(semanticLabel: 'Ignored'));
      expect(find.bySemanticsLabel('Ignored'), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Senior designer')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a selected pressable card is a selected button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, card(onPressed: () {}, selected: true));
      final data = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('a selected card that cannot be pressed is announced as '
        'selected, and not as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, card(selected: true));
      final data = tester
          .getSemantics(find.text('Senior designer'))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('a plain card announces no selected state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, card());
      final data = tester
          .getSemantics(find.text('Senior designer'))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected, ui.Tristate.none);
      expect(data.flagsCollection.isButton, isFalse);
      handle.dispose();
    });
  });
}
