import 'dart:ui' as ui show Shadow;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Draws one glyph of an icon font with its lines made [outline] logical
/// pixels thicker: the glyph filled, and over it the same glyph stroked
/// with a round-joined outline [outline] wide in the same colour. Half the
/// outline falls outside each edge of a line, so a line gains [outline] in
/// all.
///
/// `PhosphorIcon` builds this for an icon it thickens. It is not part of
/// the package's API.
///
/// The box is whatever its constraints say — the icon's square — and the
/// glyph is centred in it. Nothing is clipped, so the half-outline that a
/// glyph touching the edge of its em square puts outside the box is still
/// painted.
class ThickenedGlyph extends LeafRenderObjectWidget {
  /// Creates a thickened glyph.
  const ThickenedGlyph({
    required this.glyph,
    required this.style,
    required this.color,
    required this.outline,
    required this.textDirection,
    this.shadows,
    this.blendMode,
    super.key,
  });

  /// The character to draw.
  final String glyph;

  /// The font: family, size, variations. It carries no colour, foreground
  /// or shadows; those are [color], [blendMode] and [shadows].
  final TextStyle style;

  /// The colour of the glyph, alpha included.
  final Color color;

  /// The width of the outline: what each line of the glyph gains.
  final double outline;

  /// The direction the glyph is laid out in.
  final TextDirection textDirection;

  /// Shadows cast by the glyph as the font has it.
  final List<ui.Shadow>? shadows;

  /// How the glyph is blended with what is beneath it.
  final BlendMode? blendMode;

  @override
  RenderThickenedGlyph createRenderObject(BuildContext context) {
    return RenderThickenedGlyph(
      glyph: glyph,
      style: style,
      color: color,
      outline: outline,
      textDirection: textDirection,
      shadows: shadows,
      blendMode: blendMode,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderThickenedGlyph renderObject,
  ) {
    renderObject
      ..glyph = glyph
      ..style = style
      ..color = color
      ..outline = outline
      ..textDirection = textDirection
      ..shadows = shadows
      ..blendMode = blendMode;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('outline', outline))
      ..add(ColorProperty('color', color));
  }
}

/// The render object of a [ThickenedGlyph].
class RenderThickenedGlyph extends RenderBox {
  /// Creates the render object of a [ThickenedGlyph].
  RenderThickenedGlyph({
    required String glyph,
    required TextStyle style,
    required Color color,
    required double outline,
    required TextDirection textDirection,
    List<ui.Shadow>? shadows,
    BlendMode? blendMode,
  }) : _glyph = glyph,
       _style = style,
       _color = color,
       _outline = outline,
       _textDirection = textDirection,
       _shadows = shadows,
       _blendMode = blendMode;

  /// The character to draw.
  String get glyph => _glyph;
  String _glyph;
  set glyph(String value) {
    if (value == _glyph) return;
    _glyph = value;
    _invalidate();
  }

  /// The font the glyph is drawn in.
  TextStyle get style => _style;
  TextStyle _style;
  set style(TextStyle value) {
    if (value == _style) return;
    _style = value;
    _invalidate();
  }

  /// The colour of the glyph, alpha included.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    _invalidate();
  }

  /// The width of the outline: what each line of the glyph gains.
  double get outline => _outline;
  double _outline;
  set outline(double value) {
    if (value == _outline) return;
    _outline = value;
    _invalidate();
  }

  /// The direction the glyph is laid out in.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    _invalidate();
  }

  /// Shadows cast by the glyph as the font has it.
  List<ui.Shadow>? get shadows => _shadows;
  List<ui.Shadow>? _shadows;
  set shadows(List<ui.Shadow>? value) {
    if (listEquals(value, _shadows)) return;
    _shadows = value;
    _invalidate();
  }

  /// How the glyph is blended with what is beneath it.
  BlendMode? get blendMode => _blendMode;
  BlendMode? _blendMode;
  set blendMode(BlendMode? value) {
    if (value == _blendMode) return;
    _blendMode = value;
    _invalidate();
  }

  // The fill and the outline are two paragraphs because a paragraph's paint
  // is part of its style; the third exists only for shadows under a layer.
  TextPainter? _fill;
  TextPainter? _stroke;
  TextPainter? _shadow;

  /// Whether the fill and the outline are painted opaque into a layer that
  /// then carries the alpha and the blend mode.
  ///
  /// The outline overlaps the fill by half its width. Painted one after the
  /// other in a translucent colour, or with a blend mode, the overlap would
  /// be blended twice and show as a darker rim inside every edge. An opaque
  /// colour painted normally has no such problem and needs no layer.
  bool get _layered => _color.a < 1 || _blendMode != null;

  void _invalidate() {
    _disposePainters();
    markNeedsLayout();
  }

  void _disposePainters() {
    _fill?.dispose();
    _stroke?.dispose();
    _shadow?.dispose();
    _fill = _stroke = _shadow = null;
  }

  TextPainter _painter(TextStyle style) {
    return TextPainter(
      text: TextSpan(text: _glyph, style: style),
      textDirection: _textDirection,
    )..layout();
  }

  TextPainter get _fillPainter {
    final layered = _layered;
    return _fill ??= _painter(
      _style.copyWith(
        color: layered ? _color.withValues(alpha: 1) : _color,
        shadows: layered ? null : _shadows,
      ),
    );
  }

  TextPainter get _strokePainter {
    return _stroke ??= _painter(
      _style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _outline
          ..strokeJoin = StrokeJoin.round
          ..color = _layered ? _color.withValues(alpha: 1) : _color,
      ),
    );
  }

  /// Only the shadows, for when the glyph itself is inside a layer whose
  /// alpha they must not take.
  TextPainter? get _shadowPainter {
    final shadows = _shadows;
    if (!_layered || shadows == null || shadows.isEmpty) return null;
    return _shadow ??= _painter(
      _style.copyWith(color: const Color(0x00000000), shadows: shadows),
    );
  }

  Offset _glyphOffset(Size box) {
    final glyph = _fillPainter.size;
    return Offset(
      (box.width - glyph.width) / 2,
      (box.height - glyph.height) / 2,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) => _fillPainter.width;

  @override
  double computeMaxIntrinsicWidth(double height) => _fillPainter.width;

  @override
  double computeMinIntrinsicHeight(double width) => _fillPainter.height;

  @override
  double computeMaxIntrinsicHeight(double width) => _fillPainter.height;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(_fillPainter.size);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return _glyphOffset(size).dy +
        _fillPainter.computeDistanceToActualBaseline(baseline);
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    return _glyphOffset(constraints.constrain(_fillPainter.size)).dy +
        _fillPainter.computeDistanceToActualBaseline(baseline);
  }

  @override
  void performLayout() {
    size = constraints.constrain(_fillPainter.size);
  }

  // An icon is a target for the detector around it, as a paragraph is.
  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final origin = offset + _glyphOffset(size);
    final fill = _fillPainter;
    if (!_layered) {
      fill.paint(canvas, origin);
      if (_outline > 0) _strokePainter.paint(canvas, origin);
      return;
    }
    _shadowPainter?.paint(canvas, origin);
    // Room for the outline, and for a glyph that leaves its em square.
    final bounds = (origin & fill.size).inflate(
      _outline + (_style.fontSize ?? fill.height) / 4,
    );
    canvas.saveLayer(
      bounds,
      Paint()
        ..color = const Color(0xFF000000).withValues(alpha: _color.a)
        ..blendMode = _blendMode ?? BlendMode.srcOver,
    );
    fill.paint(canvas, origin);
    if (_outline > 0) _strokePainter.paint(canvas, origin);
    canvas.restore();
  }

  @override
  void dispose() {
    _disposePainters();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('outline', outline))
      ..add(ColorProperty('color', color));
  }
}
