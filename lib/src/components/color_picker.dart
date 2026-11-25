import 'dart:math' as math;

import 'package:finesse/src/components/layout.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

/// A colour chosen by eye, by number or from a list: an area for
/// saturation and brightness, a track for the hue and, with [showAlpha],
/// one for the opacity, a hex field, and [swatches].
///
/// ```dart
/// ColorPicker(
///   value: _accent,
///   onChanged: (color) => setState(() => _accent = color),
///   swatches: const [Color(0xFF0F766E), Color(0xFFB45309)],
/// )
/// ```
///
/// It is controlled and reports as the colour changes. Every part is a
/// slider to the keyboard and to assistive technology: the arrow keys
/// move a thumb, with Shift in larger steps. `ColorPickerButton` puts the
/// picker behind a swatch.
class ColorPicker extends StatefulWidget {
  /// Creates a colour picker.
  const ColorPicker({
    required this.value,
    required this.onChanged,
    this.swatches,
    this.showAlpha = false,
    this.showHex = true,
    super.key,
  });

  /// The colour shown.
  final Color value;

  /// Called with the new colour as it changes.
  final ValueChanged<Color> onChanged;

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
    if (color != widget.value) widget.onChanged(color);
  }

  void _setColor(Color color) {
    final next = widget.showAlpha ? color : color.withValues(alpha: 1);
    setState(() => _hsv = HSVColor.fromColor(next));
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = FinesseLocalizations.of(context);
    final swatches = widget.swatches;
    final opaque = _hsv.withAlpha(1).toColor();
    String percent(double v) => '${(v * 100).round()}%';

    return FinesseColumn(
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
              if (color != null && digits >= 6) _setColor(color);
            },
            onSubmitted: (text) {
              final color = colorFromHex(text);
              if (color != null) _setColor(color);
              _hex.text = _hexOf(_hsv.toColor());
            },
          ),
        if (swatches != null && swatches.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final swatch in swatches)
                _SwatchButton(
                  color: swatch,
                  selected:
                      colorToHex(swatch, alpha: true) ==
                      colorToHex(_hsv.toColor(), alpha: true),
                  onPressed: () => _setColor(swatch),
                ),
            ],
          ),
      ],
    );
  }
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

  void _at(Offset position, Size size) {
    widget.onChanged(
      (position.dx / size.width).clamp(0.0, 1.0),
      1 - (position.dy / size.height).clamp(0.0, 1.0),
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
                onTapDown: (details) => _at(details.localPosition, size),
                onPanStart: (details) => _at(details.localPosition, size),
                onPanUpdate: (details) => _at(details.localPosition, size),
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
                      left: hsv.saturation * size.width - thumb,
                      top: (1 - hsv.value) * size.height - thumb,
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
                void at(double dx) {
                  final t = ((dx - thumb) / travel).clamp(0.0, 1.0);
                  widget.onChanged(rtl ? 1 - t : t);
                }

                final fraction = rtl ? 1 - widget.value : widget.value;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => at(details.localPosition.dx),
                  onHorizontalDragStart: (details) =>
                      at(details.localPosition.dx),
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
  });

  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Pressable(
      onPressed: onPressed,
      selected: selected,
      semanticLabel: colorToHex(color, alpha: color.a < 1),
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: theme.radii.md,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: theme.radii.md,
            // The chosen one wears the page's ring.
            border: selected
                ? Border.all(color: theme.colorScheme.foreground, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _Swatch(color: color, size: 22, radius: theme.radii.sm),
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
    final l = FinesseLocalizations.of(context);
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
