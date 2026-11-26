@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'overlay_frames_pinned.dart';

/// What every overlay looks like on each frame of its entrance and of its
/// exit, compared with the sequence recorded before the overlays were moved
/// off `flutter_animate` (at `f83e327`) and kept in
/// `overlay_frames_pinned.dart`.
///
/// A frame is five numbers read off the render tree around a piece of the
/// overlay's content:
///
/// * `layer`: the product of every opacity layer above it;
/// * `host`: the fade offered to a glass surface by the nearest
///   `BackdropFadeHost` above it, or -1 when there is none — a claimed fade
///   is not an opacity layer, so it has to be read where it is published;
/// * `scale`, `x`, `y`: the paint transform from the content to the screen.
///
/// A frame on which the content is not in the tree is a single `-1`.
///
/// To record the sequences again, run this file with
/// `--dart-define=PIN_OVERLAY_FRAMES=true`; it rewrites the pinned file.
const _pin = bool.fromEnvironment('PIN_OVERLAY_FRAMES');

const _frame = Duration(milliseconds: 16);
const _content = Key('content');

final _recorded = <String, List<List<double>>>{};

List<double> _read(WidgetTester tester, Finder content) {
  final found = content.evaluate();
  if (found.isEmpty) return const [-1];
  final render = found.first.renderObject!;
  var layer = 1.0;
  RenderObject? node = render;
  while (node != null) {
    if (node is RenderAnimatedOpacity) layer *= node.opacity.value;
    if (node is RenderOpacity) layer *= node.opacity;
    node = node.parent;
  }
  var host = -1.0;
  found.first.visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is BackdropFadeHost) {
      host = widget.opacity.value;
      return false;
    }
    return true;
  });
  final transform = render.getTransformTo(null);
  final t = transform.getTranslation();
  return [layer, host, transform.storage[0], t.x, t.y];
}

/// Pumps [frames] frames and reads [content] after each. The first pump is
/// the frame in which whatever was just asked for is first built.
Future<List<List<double>>> _record(
  WidgetTester tester,
  Finder content,
  int frames,
) async {
  final result = <List<double>>[];
  for (var i = 0; i < frames; i++) {
    await tester.pump(i == 0 ? Duration.zero : _frame);
    result.add(_read(tester, content));
  }
  return result;
}

String _format(List<double> frame) =>
    '[${frame.map((v) => v == v.roundToDouble() ? v.toInt() : //
          double.parse(v.toStringAsFixed(4))).join(', ')}]';

void _check(String name, List<List<double>> frames) {
  if (_pin) {
    _recorded[name] = frames;
    return;
  }
  final pinned = pinnedOverlayFrames[name];
  expect(pinned, isNotNull, reason: 'no pinned frames for "$name"');
  expect(frames.length, pinned!.length, reason: '$name: frame count');
  for (var i = 0; i < frames.length; i++) {
    final now = frames[i];
    final then = pinned[i];
    final what = '$name, frame $i: was ${_format(then)}, is ${_format(now)}';
    expect(now.length, then.length, reason: what);
    for (var j = 0; j < now.length; j++) {
      // Opacity and scale to a thousandth, position to a twentieth of a
      // pixel: the pinned numbers are rounded to four places.
      final tolerance = j >= 3 ? .05 : 1e-3;
      expect(now[j], closeTo(then[j], tolerance), reason: what);
    }
  }
}

Widget _app(
  Widget home, {
  bool reduceMotion = false,
  StyleTokens? style,
}) {
  return UnaApp(
    theme: style == null ? null : ThemeData(style: style),
    formFactor: FormFactor.desktop,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: home,
      ),
    ),
  );
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(1, 1));
  addTearDown(gesture.removePointer);
  return gesture;
}

const _box = SizedBox(key: _content, width: 160, height: 60);

/// Something a pointer can be over.
Widget _target(String key) => ColoredBox(
  key: Key(key),
  color: const Color(0x01000000),
  child: const SizedBox(width: 60, height: 32),
);

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1000, 800);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  tearDownAll(() {
    if (!_pin) return;
    final out = StringBuffer()
      ..writeln('// Recorded by overlay_frames_test.dart; see there.')
      ..writeln('// dart format off')
      ..writeln()
      ..writeln('/// The frames of every overlay entrance and exit, as')
      ..writeln('/// `[layer opacity, offered fade, scale, x, y]` per frame')
      ..writeln('/// (`[-1]` while the content is not in the tree).')
      ..writeln(
        'const pinnedOverlayFrames = <String, List<List<double>>>{',
      );
    for (final entry in _recorded.entries) {
      out.writeln("  '${entry.key}': [");
      for (final frame in entry.value) {
        out.writeln('    ${_format(frame)},');
      }
      out.writeln('  ],');
    }
    out.writeln('};');
    File(
      'test/src/components/overlay_frames_pinned.dart',
    ).writeAsStringSync(out.toString());
  });

  Future<void> popover(
    WidgetTester tester,
    String name, {
    Alignment alignment = Alignment.center,
    bool reduceMotion = false,
    StyleTokens? style,
    bool showArrow = false,
  }) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        reduceMotion: reduceMotion,
        style: style,
        Align(
          alignment: alignment,
          child: Popover(
            controller: controller,
            showArrow: showArrow,
            builder: (context) => _box,
            child: const SizedBox(width: 80, height: 32),
          ),
        ),
      ),
    );
    await tester.pump();
    controller.open();
    _check('$name in', await _record(tester, find.byKey(_content), 45));
    controller.close();
    _check('$name out', await _record(tester, find.byKey(_content), 24));
  }

  testWidgets('popover', (tester) => popover(tester, 'popover'));

  testWidgets(
    'popover above its trigger',
    (tester) => popover(
      tester,
      'popover above',
      alignment: Alignment.bottomCenter,
    ),
  );

  testWidgets(
    'popover with an arrow',
    (tester) => popover(tester, 'popover arrow', showArrow: true),
  );

  testWidgets(
    'popover, solid surface',
    (tester) => popover(tester, 'popover nova', style: StyleTokens.crisp),
  );

  testWidgets(
    'popover, reduced motion',
    (tester) => popover(tester, 'popover reduced', reduceMotion: true),
  );

  testWidgets('popover turned around mid-flight', (tester) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        Center(
          child: Popover(
            controller: controller,
            builder: (context) => _box,
            child: const SizedBox(width: 80, height: 32),
          ),
        ),
      ),
    );
    await tester.pump();
    controller.open();
    final frames = await _record(tester, find.byKey(_content), 8);
    controller.close();
    frames.addAll(await _record(tester, find.byKey(_content), 3));
    controller.open();
    frames.addAll(await _record(tester, find.byKey(_content), 40));
    _check('popover turned around', frames);
  });

  testWidgets('dropdown menu and submenu', (tester) async {
    await tester.pumpWidget(
      _app(
        Align(
          alignment: const Alignment(-.5, -.5),
          child: DropdownMenu(
            items: const [
              MenuItem(child: Text('One')),
              MenuItem(
                items: [
                  MenuItem(key: _content, child: Text('Inner')),
                ],
                child: Text('More'),
              ),
              MenuItem(child: Text('Three')),
            ],
            builder: (context, controller, _) => Button.outline(
              onPressed: controller.toggle,
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Open'));
    _check('menu in', await _record(tester, find.text('One'), 45));

    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    _check('submenu in', await _record(tester, find.byKey(_content), 60));
    await mouse.moveTo(tester.getCenter(find.text('Three')));
    _check('submenu out', await _record(tester, find.byKey(_content), 30));

    await tester.tap(find.text('Open'), warnIfMissed: false);
    _check('menu out', await _record(tester, find.text('One'), 24));
  });

  testWidgets('context menu at the pointer', (tester) async {
    await tester.pumpWidget(
      _app(
        const Center(
          child: ContextMenuRegion(
            items: [MenuItem(child: Text('Copy'))],
            child: SizedBox(width: 300, height: 200),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tapAt(
      const Offset(520, 380),
      buttons: kSecondaryButton,
      kind: PointerDeviceKind.mouse,
    );
    _check('context menu in', await _record(tester, find.text('Copy'), 45));
    await tester.tapAt(const Offset(20, 20));
    _check('context menu out', await _record(tester, find.text('Copy'), 24));
  });

  testWidgets('menubar: a menu, and the one that takes over', (tester) async {
    await tester.pumpWidget(
      _app(
        const Align(
          alignment: Alignment.topLeft,
          child: Menubar(
            items: [
              MenubarItem(
                items: [MenuItem(child: Text('New file'))],
                child: Text('File'),
              ),
              MenubarItem(
                items: [MenuItem(child: Text('Undo'))],
                child: Text('Edit'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('File'));
    _check('menubar in', await _record(tester, find.text('New file'), 45));
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Edit')));
    final frames = await _record(tester, find.text('Undo'), 30);
    _check('menubar takeover in', frames);
    await tester.tapAt(const Offset(600, 500));
    _check('menubar out', await _record(tester, find.text('Undo'), 24));
  });

  testWidgets('select', (tester) async {
    await tester.pumpWidget(
      _app(
        Center(
          child: Select<String>(
            onChanged: (_) {},
            placeholder: const Text('Pick'),
            options: const [
              SelectOption(value: 'a', child: Text('Apple')),
              SelectOption(value: 'b', child: Text('Banana')),
            ],
            selectedOptionBuilder: (context, value) => Text(value),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Pick'));
    _check('select in', await _record(tester, find.text('Apple'), 45));
    await tester.tap(find.text('Banana'));
    // The chosen option blinks before the list closes (`Motion.fast`); the
    // exit is recorded from the frame that closes it.
    await tester.binding.delayed(const Duration(milliseconds: 130));
    _check('select out', await _record(tester, find.text('Apple'), 24));
  });

  testWidgets('date picker popover', (tester) async {
    await tester.pumpWidget(
      _app(
        Center(
          child: DatePicker(
            value: DateTime(2026, 3, 10),
            onChanged: (_) {},
            placeholder: const Text('Date'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(DatePicker));
    _check('date picker in', await _record(tester, find.text('17'), 45));
    await tester.tapAt(const Offset(20, 20));
    _check('date picker out', await _record(tester, find.text('17'), 24));
  });

  Future<void> tooltip(
    WidgetTester tester,
    String name, {
    bool reduceMotion = false,
    StyleTokens? style,
  }) async {
    await tester.pumpWidget(
      _app(
        reduceMotion: reduceMotion,
        style: style,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                builder: (context) => const Text('First tip'),
                child: _target('a'),
              ),
              Tooltip(
                builder: (context) => const Text('Second tip'),
                child: _target('b'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('a'))));
    _check('$name in', await _record(tester, find.text('First tip'), 40));
    // The neighbour's tooltip takes over: a fade.
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('b'))));
    final frames = await _record(tester, find.text('Second tip'), 30);
    _check('$name takeover in', frames);
    await mouse.moveTo(const Offset(20, 20));
    _check('$name out', await _record(tester, find.text('Second tip'), 24));
  }

  testWidgets('tooltip', (tester) => tooltip(tester, 'tooltip'));

  testWidgets(
    'tooltip, solid surface',
    (tester) => tooltip(tester, 'tooltip nova', style: StyleTokens.crisp),
  );

  testWidgets(
    'tooltip, reduced motion',
    (tester) => tooltip(tester, 'tooltip reduced', reduceMotion: true),
  );

  Future<void> dialog(
    WidgetTester tester,
    String name, {
    bool reduceMotion = false,
    StyleTokens? style,
    bool alert = false,
  }) async {
    late BuildContext page;
    await tester.pumpWidget(
      _app(
        reduceMotion: reduceMotion,
        style: style,
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();
    showDialog<void>(
      context: page,
      builder: (context) => alert
          ? const Dialog.alert(title: Text('Title'), child: _box)
          : const Dialog(title: Text('Title'), child: _box),
    ).ignore();
    _check('$name in', await _record(tester, find.byKey(_content), 45));
    Navigator.of(page, rootNavigator: true).pop();
    _check('$name out', await _record(tester, find.byKey(_content), 24));
  }

  testWidgets('dialog', (tester) => dialog(tester, 'dialog'));

  testWidgets(
    'alert dialog',
    (tester) => dialog(tester, 'dialog alert', alert: true),
  );

  testWidgets(
    'dialog, solid surface',
    (tester) => dialog(tester, 'dialog nova', style: StyleTokens.crisp),
  );

  testWidgets(
    'dialog, reduced motion',
    (tester) => dialog(tester, 'dialog reduced', reduceMotion: true),
  );

  testWidgets('dialog closed before it had arrived', (tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();
    showDialog<void>(
      context: page,
      builder: (context) => const Dialog(title: Text('Title'), child: _box),
    ).ignore();
    final frames = await _record(tester, find.byKey(_content), 8);
    Navigator.of(page, rootNavigator: true).pop();
    frames.addAll(await _record(tester, find.byKey(_content), 24));
    _check('dialog closed early', frames);
  });

  Future<void> sheet(
    WidgetTester tester,
    String name, {
    SheetSide? side,
    bool reduceMotion = false,
  }) async {
    late BuildContext page;
    await tester.pumpWidget(
      _app(
        reduceMotion: reduceMotion,
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();
    showSheet<void>(
      context: page,
      side: side,
      builder: (context) => const Sheet(title: Text('Title'), child: _box),
    ).ignore();
    _check('$name in', await _record(tester, find.byKey(_content), 60));
    Navigator.of(page).pop();
    _check('$name out', await _record(tester, find.byKey(_content), 30));
  }

  testWidgets('sheet', (tester) => sheet(tester, 'sheet'));

  testWidgets(
    'sheet from the end',
    (tester) => sheet(tester, 'sheet end', side: SheetSide.end),
  );

  testWidgets(
    'sheet, reduced motion',
    (tester) => sheet(tester, 'sheet reduced', reduceMotion: true),
  );

  testWidgets('toast', (tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();
    final toaster = Toaster.of(page);
    final id = toaster.show(
      const Toast(
        title: Text('Saved', key: _content),
        duration: Duration(minutes: 1),
      ),
    );
    _check('toast in', await _record(tester, find.byKey(_content), 45));
    unawaited(toaster.dismiss(id));
    _check('toast out', await _record(tester, find.byKey(_content), 30));
  });

  testWidgets('popover at a rectangle', (tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();
    showPopover<void>(
      context: page,
      anchorRect: const Rect.fromLTWH(400, 300, 80, 24),
      builder: (context) => _box,
    ).ignore();
    _check('showPopover in', await _record(tester, find.byKey(_content), 45));
    Navigator.of(page).pop();
    _check('showPopover out', await _record(tester, find.byKey(_content), 24));
  });

  testWidgets('menu at a point', (tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();
    showMenu<void>(
      context: page,
      position: const Offset(400, 300),
      items: const [MenuItem(child: Text('Copy'))],
    ).ignore();
    _check('showMenu in', await _record(tester, find.text('Copy'), 45));
    await tester.tapAt(const Offset(20, 20));
    _check('showMenu out', await _record(tester, find.text('Copy'), 24));
  });

  testWidgets('text selection toolbar', (tester) async {
    final shown = ValueNotifier(false);
    addTearDown(shown.dispose);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder(
          valueListenable: shown,
          builder: (context, shown, _) => shown
              ? const TextSelectionToolbar(
                  anchorAbove: Offset(500, 400),
                  anchorBelow: Offset(500, 430),
                  children: [Text('Copy', key: _content)],
                )
              : const SizedBox.expand(),
        ),
      ),
    );
    await tester.pump();
    shown.value = true;
    _check(
      'selection toolbar in',
      await _record(tester, find.byKey(_content), 45),
    );
  });

  testWidgets('hover card', (tester) async {
    await tester.pumpWidget(
      _app(
        Center(
          child: HoverCard(
            builder: (context) => _box,
            child: _target('a'),
          ),
        ),
      ),
    );
    await tester.pump();
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('a'))));
    _check('hover card in', await _record(tester, find.byKey(_content), 90));
    await mouse.moveTo(const Offset(20, 20));
    _check('hover card out', await _record(tester, find.byKey(_content), 50));
  });

  testWidgets('accordion item', (tester) async {
    await tester.pumpWidget(
      _app(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 400,
            child: Accordion<int>(
              children: const [
                AccordionItem(
                  value: 1,
                  title: Text('Title'),
                  child: _box,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    List<double> read() {
      final height = tester.getSize(find.byType(AccordionItem<int>)).height;
      final icon = tester.renderObject(
        find.descendant(
          of: find.byType(AccordionItem<int>),
          matching: find.bySubtype<Icon>(),
        ),
      );
      final turn = icon.getTransformTo(null);
      return [
        ..._read(tester, find.byKey(_content)),
        height,
        turn.storage[0],
        turn.storage[1],
      ];
    }

    Future<List<List<double>>> record(int frames) async {
      final result = <List<double>>[];
      for (var i = 0; i < frames; i++) {
        await tester.pump(i == 0 ? Duration.zero : _frame);
        result.add(read());
      }
      return result;
    }

    await tester.tap(find.text('Title'));
    _check('accordion open', await record(50));
    await tester.tap(find.text('Title'));
    _check('accordion close', await record(50));
  });

  testWidgets('collapsible', (tester) async {
    final controller = CollapsibleController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 400,
            child: Collapsible(controller: controller, child: _box),
          ),
        ),
      ),
    );
    await tester.pump();
    Future<List<List<double>>> record(int frames) async {
      final result = <List<double>>[];
      for (var i = 0; i < frames; i++) {
        await tester.pump(i == 0 ? Duration.zero : _frame);
        result.add([
          ..._read(tester, find.byKey(_content)),
          tester.getSize(find.byType(Collapsible)).height,
        ]);
      }
      return result;
    }

    controller.open();
    _check('collapsible open', await record(50));
    controller.close();
    _check('collapsible close', await record(50));
  });

  testWidgets('indeterminate progress bar', (tester) async {
    await tester.pumpWidget(
      _app(
        const Center(child: SizedBox(width: 400, child: ProgressBar())),
      ),
    );
    final frames = <List<double>>[];
    for (var i = 0; i < 130; i++) {
      await tester.pump(i == 0 ? Duration.zero : _frame);
      frames.add(_progressLines(tester));
    }
    _check('progress bar', frames);
  });
}

/// Where the two lines of an indeterminate bar are painted: the left and
/// right edge of each within the bar, or -1 twice for a line that is not
/// drawn.
List<double> _progressLines(WidgetTester tester) {
  final bar = tester.renderObject<RenderBox>(find.byType(ProgressBar));
  final canvas = TestRecordingCanvas();
  bar.paint(TestRecordingPaintingContext(canvas), Offset.zero);
  final rects = <Rect>[
    for (final call in canvas.invocations)
      if (call.invocation.memberName == #drawRect)
        call.invocation.positionalArguments[0] as Rect
      else if (call.invocation.memberName == #drawRRect)
        (call.invocation.positionalArguments[0] as RRect).outerRect,
  ];
  // The first rectangle is the track.
  final lines = rects.skip(1).toList();
  return [
    for (var i = 0; i < 2; i++)
      if (i < lines.length) ...[lines[i].left, lines[i].right] else ...[-1, -1],
  ];
}
