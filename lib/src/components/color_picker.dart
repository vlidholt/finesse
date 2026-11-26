import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/disabled.dart';
import 'package:una/src/components/layout.dart';
import 'package:una/src/components/picker.dart';
import 'package:una/src/components/popover.dart';
import 'package:una/src/components/segmented_control.dart';
import 'package:una/src/components/text_field.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/components/layout.dart';
import 'package:una/src/theme/form_factor.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/haptics.dart';
import 'package:una/src/utils/shadow.dart';

/// Writes [color] as `#RRGGBB`, or `#RRGGBBAA` with [alpha].
String colorToHex(Color color, {bool alpha = false}) {
  String two(double channel) =>
      (channel * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  final rgb = '${two(color.r)}${two(color.g)}${two(color.b)}';
  return '#${alpha ? rgb + two(color.a) : rgb}'.toUpperCase();
}

/// Reads a colour written as `RGB`, `RRGGBB` or `RRGGBBAA`, with or
/// without a leading `#`; null when [text] is none of them.
Color? colorFromHex(String text) {
  var hex = text.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) return null;
  if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
  if (hex.length == 6) hex = '${hex}ff';
  if (hex.length != 8) return null;
  final value = int.parse(hex, radix: 16);
  return Color.fromARGB(
    value & 0xff,
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
  );
}

/// How a [ColorPicker] offers its colours, as iOS's colour picker does.
enum ColorPickerMode {
  /// An area for saturation and brightness over a track for the hue.
  spectrum,

  /// A grid of twelve hues in nine shades, under a row of greys.
  grid,

  /// A track each for red, green and blue, with their values.
  sliders,
}

/// A colour chosen by eye, by number or from a list: a [ColorPickerMode]
/// for the colour itself (a spectrum, a grid or red, green and blue
/// sliders, switched between by a segmented control when there are more
/// than one), a track for the opacity with [showAlpha], a hex field, and
/// [swatches].
///
/// ```dart
/// ColorPicker(
///   value: _accent,
///   onChanged: (color) => setState(() => _accent = color),
///   swatches: const [Color(0xFF0F766E), Color(0xFFB45309)],
/// )
/// ```
///
/// It is controlled and reports as the colour changes; a null [onChanged]
/// disables it. Every track is a slider to the keyboard and to assistive
/// technology: the arrow keys move a thumb, with Shift in larger steps,
/// and in the grid they move from cell to cell. `ColorPickerButton` puts
/// the picker behind a swatch.
class ColorPicker extends StatefulWidget {
  /// Creates a colour picker.
  const ColorPicker({
    required this.value,
    required this.onChanged,
    this.swatches,
    this.showAlpha = false,
    this.showHex = true,
    this.modes = ColorPickerMode.values,
    this.initialMode,
    super.key,
  });

  /// The colour shown.
  final Color value;

  /// Called with the new colour as it changes. Null disables the picker.
  final ValueChanged<Color>? onChanged;

  /// The ways the colour can be chosen, in the order the segmented control
  /// lists them; with one there is no control. Defaults to all three.
  final List<ColorPickerMode> modes;

  /// The mode shown first. Defaults to the first of [modes].
  final ColorPickerMode? initialMode;

  /// Colours offered under the picker, one tap each.
  final List<Color>? swatches;

  /// Whether the opacity can be chosen too.
  final bool showAlpha;

  /// Whether the colour can be typed as hex.
  final bool showHex;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  /// The colour as hue, saturation and brightness. Kept here because a
  /// [Color] forgets its hue at black, white and grey, and the thumbs
  /// would jump.
  late HSVColor _hsv = HSVColor.fromColor(widget.value);
  late ColorPickerMode _mode = widget.modes.contains(widget.initialMode)
      ? widget.initialMode!
      : widget.modes.first;
  late final _hex = TextEditingController(text: _hexOf(widget.value));

  String _hexOf(Color color) => colorToHex(color, alpha: widget.showAlpha);

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A colour from outside, not the one this picker just reported.
    if (widget.value != _hsv.toColor()) {
      _hsv = HSVColor.fromColor(widget.value);
    }
    final hex = _hexOf(widget.value);
    if (colorFromHex(_hex.text) != colorFromHex(hex)) _hex.text = hex;
    if (!widget.modes.contains(_mode)) _mode = widget.modes.first;
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _set(HSVColor hsv) {
    setState(() => _hsv = hsv);
    final color = hsv.toColor();
    _hex.text = _hexOf(color);
    if (color != widget.value) widget.onChanged?.call(color);
  }

  void _setColor(Color color) {
    final next = widget.showAlpha ? color : color.withValues(alpha: 1);
    setState(() => _hsv = HSVColor.fromColor(next));
    _hex.text = _hexOf(next);
    if (next != widget.value) widget.onChanged?.call(next);
  }

  /// [color] at the picker's current opacity: a grid cell or a channel
  /// changes the colour, not how see-through it is.
  void _setOpaque(Color color) =>
      _setColor(color.withValues(alpha: widget.showAlpha ? _hsv.alpha : 1));

  Widget _spectrum(BuildContext context) {
    final l = UnaLocalizations.of(context);
    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      gap: GapSize.md,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: _ColorArea(
            hsv: _hsv,
            semanticLabel: l.colorPicker.saturationAndBrightness,
            onChanged: (saturation, value) =>
                _set(_hsv.withSaturation(saturation).withValue(value)),
          ),
        ),
        _ColorTrack(
          value: _hsv.hue / 360,
          semanticLabel: l.colorPicker.hue,
          semanticValue: '${_hsv.hue.round()}°',
          thumbColor: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
          ),
          onChanged: (t) => _set(_hsv.withHue((t * 360).clamp(0, 360))),
        ),
      ],
    );
  }

  Widget _sliders(BuildContext context) {
    final theme = Theme.of(context);
    final l = UnaLocalizations.of(context);
    final color = _hsv.withAlpha(1).toColor();
    int byte(double channel) => (channel * 255).round().clamp(0, 255);
    Widget channel({
      required String label,
      required String short,
      required double value,
      required Color from,
      required Color to,
      required Color Function(double) at,
    }) {
      final style = theme.textTheme.caption.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );
      return Row(
        children: [
          SizedBox(
            width: 16,
            child: ExcludeSemantics(child: Text(short, style: style)),
          ),
          Expanded(
            child: _ColorTrack(
              value: value,
              semanticLabel: label,
              semanticValue: '${byte(value)}',
              thumbColor: color,
              gradient: LinearGradient(colors: [from, to]),
              onChanged: (t) => _setOpaque(at(t)),
            ),
          ),
          SizedBox(
            width: 36,
            child: ExcludeSemantics(
              child: Text(
                '${byte(value)}',
                textAlign: TextAlign.end,
                style: style,
              ),
            ),
          ),
        ],
      );
    }

    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      gap: GapSize.md,
      children: [
        channel(
          label: l.colorPicker.red,
          short: 'R',
          value: color.r,
          from: color.withValues(red: 0),
          to: color.withValues(red: 1),
          at: (t) => color.withValues(red: t),
        ),
        channel(
          label: l.colorPicker.green,
          short: 'G',
          value: color.g,
          from: color.withValues(green: 0),
          to: color.withValues(green: 1),
          at: (t) => color.withValues(green: t),
        ),
        channel(
          label: l.colorPicker.blue,
          short: 'B',
          value: color.b,
          from: color.withValues(blue: 0),
          to: color.withValues(blue: 1),
          at: (t) => color.withValues(blue: t),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = UnaLocalizations.of(context);
    final swatches = widget.swatches;
    final opaque = _hsv.withAlpha(1).toColor();
    final mobile = theme.formFactor != FormFactor.desktop;
    String percent(double v) => '${(v * 100).round()}%';

    return Disabled(
      enabled: widget.onChanged != null,
      child: UnaColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        gap: GapSize.md,
        children: [
          if (widget.modes.length > 1)
            Center(
              widthFactor: mobile ? null : 1,
              child: SegmentedControl<ColorPickerMode>(
                // Across the picker on a phone, as iOS has it; centred at
                // its own width on a desktop, where equal thirds of a
                // popover would cut the labels short.
                expand: mobile,
                value: _mode,
                onChanged: (mode) => setState(() => _mode = mode),
                segments: [
                  for (final mode in widget.modes)
                    Segment(
                      value: mode,
                      label: Text(switch (mode) {
                        ColorPickerMode.spectrum => l.colorPicker.spectrum,
                        ColorPickerMode.grid => l.colorPicker.grid,
                        ColorPickerMode.sliders => l.colorPicker.sliders,
                      }),
                    ),
                ],
              ),
            ),
          switch (_mode) {
            ColorPickerMode.spectrum => _spectrum(context),
            ColorPickerMode.grid => _ColorGrid(
              selected: opaque,
              semanticLabel: l.colorPicker.grid,
              onSelected: _setOpaque,
            ),
            ColorPickerMode.sliders => _sliders(context),
          },
          if (widget.showAlpha)
            _ColorTrack(
              value: _hsv.alpha,
              semanticLabel: l.colorPicker.opacity,
              semanticValue: percent(_hsv.alpha),
              thumbColor: _hsv.toColor(),
              checkered: true,
              gradient: LinearGradient(
                colors: [opaque.withValues(alpha: 0), opaque],
              ),
              onChanged: (t) => _set(_hsv.withAlpha(t)),
            ),
          if (widget.showHex)
            TextField(
              controller: _hex,
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: _Swatch(
                  color: _hsv.toColor(),
                  size: 18,
                  radius: theme.radii.sm,
                ),
              ),
              placeholder: Text(l.colorPicker.hex),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (text) {
                final color = colorFromHex(text);
                // Only a whole colour: "#1" on the way to "#123456" is not
                // one yet.
                final digits = text.replaceFirst('#', '').length;
                if (color != null && digits >= 6) {
                  final next = widget.showAlpha
                      ? color
                      : color.withValues(alpha: 1);
                  setState(() => _hsv = HSVColor.fromColor(next));
                  if (next != widget.value) widget.onChanged?.call(next);
                }
              },
              onSubmitted: (text) {
                final color = colorFromHex(text);
                if (color != null) _setColor(color);
                _hex.text = _hexOf(_hsv.toColor());
              },
            ),
          if (swatches != null && swatches.isNotEmpty)
            Wrap(
              // A finger's target on a phone, a pointer's on a desktop.
              spacing: mobile ? 10 : 8,
              runSpacing: mobile ? 10 : 8,
              children: [
                for (final swatch in swatches)
                  _SwatchButton(
                    color: swatch,
                    size: mobile ? 30 : 22,
                    selected:
                        colorToHex(swatch, alpha: true) ==
                        colorToHex(_hsv.toColor(), alpha: true),
                    onPressed: () => _setColor(swatch),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// iOS's grid: a row of greys from white to black over twelve hues, each
/// in nine shades from light to dark. A tap or a drag picks the cell under
/// the finger; the arrow keys move from cell to cell.
class _ColorGrid extends StatefulWidget {
  const _ColorGrid({
    required this.selected,
    required this.semanticLabel,
    required this.onSelected,
  });

  final Color selected;
  final String semanticLabel;
  final ValueChanged<Color> onSelected;

  static const columns = 12;
  static const rows = 10;

  /// The colour of the cell at [column] and [row].
  static Color colorAt(int column, int row) {
    if (row == 0) {
      final v = 1 - column / (columns - 1);
      return HSVColor.fromAHSV(1, 0, 0, v).toColor();
    }
    final hue = column * 360 / columns;
    final lightness = .9 - (row - 1) * (.72 / (rows - 2));
    return HSLColor.fromAHSL(1, hue, .9, lightness).toColor();
  }

  /// The cell showing [color], if one does.
  static (int, int)? cellOf(Color color) {
    final hex = colorToHex(color);
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        if (colorToHex(colorAt(column, row)) == hex) return (column, row);
      }
    }
    return null;
  }

  @override
  State<_ColorGrid> createState() => _ColorGridState();
}

class _ColorGridState extends State<_ColorGrid> {
  bool _focused = false;

  void _pickAt(Offset local, Size size) {
    final column = (local.dx / size.width * _ColorGrid.columns).floor().clamp(
      0,
      _ColorGrid.columns - 1,
    );
    final row = (local.dy / size.height * _ColorGrid.rows).floor().clamp(
      0,
      _ColorGrid.rows - 1,
    );
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final color = _ColorGrid.colorAt(
      rtl ? _ColorGrid.columns - 1 - column : column,
      row,
    );
    if (colorToHex(color) != colorToHex(widget.selected)) {
      Haptics.selection(context);
      widget.onSelected(color);
    }
  }

  void _move(int dx, int dy) {
    final (column, row) = _ColorGrid.cellOf(widget.selected) ?? (0, 0);
    widget.onSelected(
      _ColorGrid.colorAt(
        (column + dx).clamp(0, _ColorGrid.columns - 1),
        (row + dy).clamp(0, _ColorGrid.rows - 1),
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      _move(rtl ? -1 : 1, 0);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _move(rtl ? 1 : -1, 0);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _move(0, 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(0, -1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cell = _ColorGrid.cellOf(widget.selected);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      label: widget.semanticLabel,
      value: colorToHex(widget.selected),
      onIncrease: () => _move(1, 0),
      onDecrease: () => _move(-1, 0),
      increasedValue: colorToHex(widget.selected),
      decreasedValue: colorToHex(widget.selected),
      child: Focus(
        onKeyEvent: _onKey,
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: FocusRing(
          visible: _focused,
          borderRadius: theme.radii.md,
          child: AspectRatio(
            aspectRatio: _ColorGrid.columns / _ColorGrid.rows,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _pickAt(d.localPosition, size),
                  onPanDown: (d) => _pickAt(d.localPosition, size),
                  onPanUpdate: (d) => _pickAt(d.localPosition, size),
                  child: ClipRRect(
                    borderRadius: theme.radii.md,
                    child: CustomPaint(
                      size: size,
                      painter: _GridPainter(
                        selected: cell,
                        rtl: rtl,
                        ring: theme.colorScheme.background,
                        ink: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.selected,
    required this.rtl,
    required this.ring,
    required this.ink,
  });

  final (int, int)? selected;
  final bool rtl;
  final Color ring;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / _ColorGrid.columns;
    final h = size.height / _ColorGrid.rows;
    Rect cellRect(int column, int row) {
      final x = rtl ? _ColorGrid.columns - 1 - column : column;
      // A hair over, so neighbours meet without a seam.
      return Rect.fromLTWH(x * w, row * h, w + .5, h + .5);
    }

    for (var row = 0; row < _ColorGrid.rows; row++) {
      for (var column = 0; column < _ColorGrid.columns; column++) {
        canvas.drawRect(
          cellRect(column, row),
          Paint()..color = _ColorGrid.colorAt(column, row),
        );
      }
    }
    if (selected case (final column, final row)) {
      final rect = cellRect(column, row).deflate(1.5);
      final r = RRect.fromRectAndRadius(rect, const Radius.circular(3));
      canvas
        ..drawRRect(
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = ring,
        )
        ..drawRRect(
          r.deflate(1.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = ink.withValues(alpha: .35),
        );
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.selected != selected ||
      old.rtl != rtl ||
      old.ring != ring ||
      old.ink != ink;
}

/// How far an arrow key moves a thumb: a hundredth, a tenth with Shift.
double _keyStep() => HardwareKeyboard.instance.isShiftPressed ? .1 : .01;

/// The thumb of a colour control: the slider's, filled with the colour it
/// stands on.
class _ColorThumb extends StatelessWidget {
  const _ColorThumb({required this.color, required this.focused});

  final Color color;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = theme.sliderTheme.thumbRadius ?? 10;
    return FocusRing(
      visible: focused,
      borderRadius: theme.radii.full,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: ShadowDecoration.box(
          shape: BoxShape.circle,
          color: color,
          // White with a soft dark edge around it reads on every colour.
          border: Border.all(color: const Color(0xFFFFFFFF), width: 2),
          shadows: const [
            BoxShadow(color: Color(0x59000000), blurRadius: 2),
          ],
        ),
      ),
    );
  }
}

/// The area that sets saturation, left to right, and brightness, bottom
/// to top.
class _ColorArea extends StatefulWidget {
  const _ColorArea({
    required this.hsv,
    required this.onChanged,
    required this.semanticLabel,
  });

  final HSVColor hsv;
  final void Function(double saturation, double value) onChanged;
  final String semanticLabel;

  @override
  State<_ColorArea> createState() => _ColorAreaState();
}

class _ColorAreaState extends State<_ColorArea> {
  bool _focused = false;

  /// Where on the thumb the pointer took hold of it, from its centre, so
  /// a thumb picked up by its edge moves with the pointer instead of
  /// jumping to centre on it. Zero for a press off the thumb, which puts
  /// the thumb where it lands.
  Offset _grab = Offset.zero;

  void _press(Offset position, Size size, double thumb) {
    final centre = Offset(
      thumb + widget.hsv.saturation * math.max(0, size.width - thumb * 2),
      thumb + (1 - widget.hsv.value) * math.max(0, size.height - thumb * 2),
    );
    final fromCentre = position - centre;
    _grab = fromCentre.distance <= thumb ? fromCentre : Offset.zero;
    _at(position, size, thumb);
  }

  /// The saturation and value under [position]. The thumb stays inside
  /// the area, as it does on the tracks: its centre travels from a thumb
  /// radius in on one side to a radius in on the other, so a thumb in a
  /// corner is whole, and can be taken hold of anywhere.
  void _at(Offset position, Size size, double thumb) {
    final width = math.max(1, size.width - thumb * 2);
    final height = math.max(1, size.height - thumb * 2);
    final centre = position - _grab;
    widget.onChanged(
      ((centre.dx - thumb) / width).clamp(0.0, 1.0),
      1 - ((centre.dy - thumb) / height).clamp(0.0, 1.0),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final step = _keyStep();
    var saturation = widget.hsv.saturation;
    var value = widget.hsv.value;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      saturation += step;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      saturation -= step;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      value += step;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      value -= step;
    } else {
      return KeyEventResult.ignored;
    }
    widget.onChanged(saturation.clamp(0.0, 1.0), value.clamp(0.0, 1.0));
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hsv = widget.hsv;
    final radius = theme.radii.md;
    final thumb = theme.sliderTheme.thumbRadius ?? 10;
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value:
          '${(hsv.saturation * 100).round()}%, '
          '${(hsv.value * 100).round()}%',
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.precise,
          onShowFocusHighlight: (value) {
            if (_focused != value) setState(() => _focused = value);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                // A drag starts where the pointer came down, so the thumb is
                // taken hold of where it was touched, not past the slop.
                dragStartBehavior: DragStartBehavior.down,
                onTapDown: (details) =>
                    _press(details.localPosition, size, thumb),
                onPanStart: (details) =>
                    _press(details.localPosition, size, thumb),
                onPanUpdate: (details) =>
                    _at(details.localPosition, size, thumb),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(color: theme.colorScheme.border),
                        ),
                        child: ClipRRect(
                          borderRadius: radius,
                          child: CustomPaint(
                            painter: _AreaPainter(hue: hsv.hue),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left:
                          hsv.saturation * math.max(0, size.width - thumb * 2),
                      top:
                          (1 - hsv.value) *
                          math.max(0, size.height - thumb * 2),
                      child: _ColorThumb(
                        color: hsv.withAlpha(1).toColor(),
                        focused: _focused,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AreaPainter extends CustomPainter {
  const _AreaPainter({required this.hue});

  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // The pure hue, washed out towards the start and darkened towards the
    // bottom.
    canvas
      ..drawRect(
        rect,
        Paint()..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      )
      ..drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          ).createShader(rect),
      )
      ..drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0xFF000000)],
          ).createShader(rect),
      );
  }

  @override
  bool shouldRepaint(_AreaPainter oldDelegate) => oldDelegate.hue != hue;
}

/// A track with a gradient along it and a thumb on it: the hue, or the
/// opacity.
class _ColorTrack extends StatefulWidget {
  const _ColorTrack({
    required this.value,
    required this.onChanged,
    required this.gradient,
    required this.thumbColor,
    required this.semanticLabel,
    required this.semanticValue,
    this.checkered = false,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final Gradient gradient;
  final Color thumbColor;
  final String semanticLabel;
  final String semanticValue;
  final bool checkered;

  @override
  State<_ColorTrack> createState() => _ColorTrackState();
}

class _ColorTrackState extends State<_ColorTrack> {
  bool _focused = false;

  /// Where on the thumb the pointer took hold of it, from its centre.
  double _grab = 0;

  void _move(double delta) =>
      widget.onChanged((widget.value + delta).clamp(0.0, 1.0));

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (key == forward || key == LogicalKeyboardKey.arrowUp) {
      _move(_keyStep());
    } else if (key == back || key == LogicalKeyboardKey.arrowDown) {
      _move(-_keyStep());
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final thumb = theme.sliderTheme.thumbRadius ?? 10;
    final trackHeight = math.max<double>(
      theme.sliderTheme.trackHeight ?? 8,
      12,
    );
    final height = math.max(trackHeight, thumb * 2);
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: widget.semanticValue,
      increasedValue: widget.semanticValue,
      decreasedValue: widget.semanticValue,
      onIncrease: () => _move(.05),
      onDecrease: () => _move(-.05),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (value) {
            if (_focused != value) setState(() => _focused = value);
          },
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                // The thumb stays inside the track's ends.
                final travel = math.max(1, width - thumb * 2);
                final fraction = rtl ? 1 - widget.value : widget.value;
                void at(double dx) {
                  final t = ((dx - _grab - thumb) / travel).clamp(0.0, 1.0);
                  widget.onChanged(rtl ? 1 - t : t);
                }

                // A press on the thumb takes hold of it where it lands; one
                // off it puts the thumb there.
                void press(double dx) {
                  final fromCentre = dx - (thumb + fraction * travel);
                  _grab = fromCentre.abs() <= thumb ? fromCentre : 0;
                  at(dx);
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  dragStartBehavior: DragStartBehavior.down,
                  onTapDown: (details) => press(details.localPosition.dx),
                  onHorizontalDragStart: (details) =>
                      press(details.localPosition.dx),
                  onHorizontalDragUpdate: (details) =>
                      at(details.localPosition.dx),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        height: trackHeight,
                        child: ClipRRect(
                          borderRadius: theme.radii.full,
                          child: CustomPaint(
                            painter: _TrackPainter(
                              gradient: widget.gradient,
                              checkered: widget.checkered,
                              rtl: rtl,
                              checkColor: theme.colorScheme.mutedForeground
                                  .withValues(alpha: .35),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: fraction * travel,
                        child: _ColorThumb(
                          color: widget.thumbColor,
                          focused: _focused,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.gradient,
    required this.checkered,
    required this.rtl,
    required this.checkColor,
  });

  final Gradient gradient;
  final bool checkered;
  final bool rtl;
  final Color checkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (checkered) _paintChecks(canvas, size, checkColor);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = gradient.createShader(
          rect,
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        ),
    );
  }

  @override
  bool shouldRepaint(_TrackPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.checkered != checkered ||
      oldDelegate.rtl != rtl ||
      oldDelegate.checkColor != checkColor;
}

/// The checkerboard that shows through a translucent colour.
void _paintChecks(Canvas canvas, Size size, Color color) {
  const cell = 4.0;
  final paint = Paint()..color = color;
  for (var y = 0; y * cell < size.height; y++) {
    for (var x = y.isEven ? 0 : 1; x * cell < size.width; x += 2) {
      canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
    }
  }
}

/// A patch of a colour, over a checkerboard where it is translucent.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.size,
    required this.radius,
  });

  final Color color;
  final double size;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: scheme.border),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: CustomPaint(
            painter: color.a < 1
                ? _ChecksPainter(
                    scheme.mutedForeground.withValues(alpha: .35),
                  )
                : null,
            child: ColoredBox(color: color),
          ),
        ),
      ),
    );
  }
}

class _ChecksPainter extends CustomPainter {
  const _ChecksPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) => _paintChecks(canvas, size, color);

  @override
  bool shouldRepaint(_ChecksPainter oldDelegate) => oldDelegate.color != color;
}

/// One of the colours a picker offers.
class _SwatchButton extends StatelessWidget {
  const _SwatchButton({
    required this.color,
    required this.selected,
    required this.onPressed,
    this.size = 22,
  });

  final double size;
  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  /// The selected swatch's ring, and the gap between it and the swatch.
  static const ringWidth = 2.0;
  static const ringGap = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The ring is the swatch's own shape grown by the gap and its width,
    // so the two stay concentric at every radius, round where the swatch
    // is round. A ring with corners of its own met the swatch's corners
    // unevenly: a hair apart on the sides, and touching at the corners
    // once the radius rounded the swatch off.
    final swatchRadius = math.min(theme.radii.sm.topLeft.x, size / 2);
    const inset = ringWidth + ringGap;
    final ringRadius = BorderRadius.circular(swatchRadius + inset);
    return Pressable(
      onPressed: onPressed,
      selected: selected,
      semanticLabel: colorToHex(color, alpha: color.a < 1),
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: ringRadius,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: ringRadius,
            // The chosen one wears the page's ring.
            border: selected
                ? Border.all(
                    color: theme.colorScheme.foreground,
                    width: ringWidth,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(inset),
            child: _Swatch(
              color: color,
              size: size,
              radius: BorderRadius.circular(swatchRadius),
            ),
          ),
        ),
      ),
    );
  }
}

/// A swatch that shows a colour and opens a [ColorPicker] to change it: in
/// a popover on a desktop, in a bottom sheet on a phone.
///
/// ```dart
/// ColorPickerButton(
///   value: _accent,
///   onChanged: (color) => setState(() => _accent = color),
/// )
/// ```
///
/// In the popover the colour is taken as it changes. In the sheet the
/// picker turns a draft that Done reports and Cancel drops.
class ColorPickerButton extends StatefulWidget {
  /// Creates a colour picker button.
  const ColorPickerButton({
    required this.value,
    required this.onChanged,
    this.swatches,
    this.showAlpha = false,
    this.presentation = PickerPresentation.auto,
    this.title,
    this.size,
    this.enabled = true,
    this.focusNode,
    this.controller,
    this.semanticLabel,
    super.key,
  });

  /// The colour shown.
  final Color value;

  /// Called with the chosen colour. A null callback disables the button.
  final ValueChanged<Color>? onChanged;

  /// Colours offered under the picker.
  final List<Color>? swatches;

  /// Whether the opacity can be chosen too.
  final bool showAlpha;

  /// Whether the picker opens in a popover, a sheet, or whichever suits
  /// the theme's form factor.
  final PickerPresentation presentation;

  /// The title of the sheet. Defaults to the localized "Select colour".
  final Widget? title;

  /// The side of the swatch. Defaults to the height of a control.
  final double? size;

  /// Whether the picker can be opened.
  final bool enabled;

  /// The focus node of the swatch.
  final FocusNode? focusNode;

  /// Opens and closes the picker from outside.
  final PopoverController? controller;

  /// What the colour is for, for assistive technology.
  final String? semanticLabel;

  @override
  State<ColorPickerButton> createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = UnaLocalizations.of(context);
    final enabled = widget.enabled && widget.onChanged != null;
    final size = widget.size ?? theme.style.inputHeight;
    return PickerHost(
      presentation: widget.presentation,
      controller: widget.controller,
      triggerBuilder: (context, toggle) => Opacity(
        opacity: enabled ? 1 : theme.disabledOpacity,
        child: Pressable(
          onPressed: enabled ? toggle : null,
          focusNode: widget.focusNode,
          semanticLabel: widget.semanticLabel ?? l.colorPicker.selectColor,
          semanticValue: colorToHex(widget.value, alpha: widget.showAlpha),
          builder: (context, states) => FocusRing(
            visible: states.contains(WidgetState.focused),
            borderRadius: theme.radii.md,
            child: _Swatch(
              color: widget.value,
              size: size,
              radius: theme.radii.md,
            ),
          ),
        ),
      ),
      popoverBuilder: (context, close) => SizedBox(
        width: 248,
        child: ColorPicker(
          value: widget.value,
          swatches: widget.swatches,
          showAlpha: widget.showAlpha,
          onChanged: (color) => widget.onChanged?.call(color),
        ),
      ),
      sheetBuilder: (context, close) => _ColorSheet(
        initial: widget.value,
        title: widget.title ?? Text(l.colorPicker.selectColor),
        swatches: widget.swatches,
        showAlpha: widget.showAlpha,
        onDone: (color) {
          close();
          if (color != widget.value) widget.onChanged?.call(color);
        },
        onCancel: close,
      ),
    );
  }
}

class _ColorSheet extends StatefulWidget {
  const _ColorSheet({
    required this.initial,
    required this.title,
    required this.swatches,
    required this.showAlpha,
    required this.onDone,
    required this.onCancel,
  });

  final Color initial;
  final Widget title;
  final List<Color>? swatches;
  final bool showAlpha;
  final ValueChanged<Color> onDone;
  final VoidCallback onCancel;

  @override
  State<_ColorSheet> createState() => _ColorSheetState();
}

class _ColorSheetState extends State<_ColorSheet> {
  late Color _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    return PickerSheet(
      title: widget.title,
      onDone: () => widget.onDone(_draft),
      onCancel: widget.onCancel,
      child: ColorPicker(
        value: _draft,
        swatches: widget.swatches,
        showAlpha: widget.showAlpha,
        onChanged: (color) => setState(() => _draft = color),
      ),
    );
  }
}
