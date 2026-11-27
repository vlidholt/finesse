import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/extensions/text_style.dart';

/// Lays out a form field: a [label] above [child], then a [description] and an
/// [error] below it.
///
/// Styles and paddings come from [decoration] merged over
/// `ThemeData.decoration`.
///
/// The control inside reads what the decorator says about it through
/// [InputDecoratorScope.maybeOf] — a `TextField` does — and puts the label,
/// description and error in its own semantics node, so a screen reader
/// hears them on the control rather than as text beside it. The painted
/// copies are then left out of the semantics tree. A label, description or
/// error that is not a [Text] (or a [RichText]) has no text to hand on and
/// stays readable where it is painted.
///
/// An error is announced when it appears or changes.
class InputDecorator extends StatefulWidget {
  /// Creates an input decorator.
  const InputDecorator({
    super.key,
    this.child,
    this.label,
    this.error,
    this.description,
    this.decoration,
  });

  /// The field itself.
  final Widget? child;

  /// The label shown above [child].
  final Widget? label;

  /// The error message shown below [child].
  final Widget? error;

  /// The help text shown below [child], above [error].
  final Widget? description;

  /// Overrides for the label, description and error styles and paddings.
  final UnaDecoration? decoration;

  @override
  State<InputDecorator> createState() => _InputDecoratorState();
}

/// The plain text of [widget] when it is a [Text] or a [RichText], what a
/// screen reader would read for it; otherwise null.
String? _plainText(Widget? widget) {
  final text = switch (widget) {
    final Text text =>
      text.semanticsLabel ?? text.data ?? text.textSpan?.toPlainText(),
    final RichText text => text.text.toPlainText(),
    _ => null,
  };
  return text == null || text.trim().isEmpty ? null : text;
}

class _InputDecoratorState extends State<InputDecorator> {
  final _claims = _Claims();

  /// The error last built, so that a new one is announced once.
  String? _shownError;

  @override
  void initState() {
    super.initState();
    _shownError = _plainText(widget.error);
  }

  @override
  void didUpdateWidget(InputDecorator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final error = _plainText(widget.error);
    if (error != null && error != _shownError) {
      // After the frame, when the control's node carries the error too.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _plainText(widget.error) != error) return;
        SemanticsService.sendAnnouncement(
          View.of(context),
          error,
          Directionality.of(context),
          assertiveness: Assertiveness.assertive,
        );
      });
    }
    _shownError = error;
  }

  @override
  void dispose() {
    _claims.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDecoration = theme.decoration.merge(widget.decoration);
    final hasError = effectiveDecoration.hasError ?? false;

    final effectiveFallbackToLabelStyle =
        effectiveDecoration.fallbackToLabelStyle ?? true;

    final defaultErrorStyle = theme.textTheme.muted.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.destructive,
    );

    final defaultLabelStyle = theme.textTheme.muted.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.foreground,
    );

    final effectiveErrorStyle =
        effectiveDecoration.errorStyle ?? defaultErrorStyle;

    var effectiveLabelStyle = switch (hasError) {
      true => effectiveDecoration.errorLabelStyle,
      false => effectiveDecoration.labelStyle,
    };

    if (effectiveFallbackToLabelStyle && effectiveLabelStyle == null) {
      effectiveLabelStyle =
          effectiveDecoration.labelStyle ??
          switch (hasError) {
            true => defaultErrorStyle,
            false => defaultLabelStyle,
          };
    }

    final effectiveDescriptionStyle =
        (effectiveDecoration.descriptionStyle ?? theme.textTheme.muted)
            .fallback(color: theme.colorScheme.mutedForeground);

    final labelText = _plainText(widget.label);
    final descriptionText = _plainText(widget.description);
    final errorText = _plainText(widget.error);

    // Out of the semantics tree once a control has taken the text into its
    // own node; read where it is painted until then, and always when there
    // is no text to take.
    Widget painted(Widget child, String? text) => text == null
        ? child
        : _ExcludeWhenClaimed(claims: _claims, child: child);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label case final label?)
          Padding(
            padding:
                effectiveDecoration.labelPadding ??
                const EdgeInsets.only(bottom: 8),
            // With fallbackToLabelStyle off and no label style set, the
            // label keeps the ambient style; this used to throw on a null
            // check.
            child: painted(
              effectiveLabelStyle == null
                  ? label
                  : DefaultTextStyle(style: effectiveLabelStyle, child: label),
              labelText,
            ),
          ),
        if (widget.child case final child?)
          InputDecoratorScope._(
            label: labelText,
            description: descriptionText,
            error: errorText,
            claims: _claims,
            child: child,
          ),
        if (widget.description case final description?)
          Padding(
            padding:
                effectiveDecoration.descriptionPadding ??
                const EdgeInsets.only(top: 8),
            child: painted(
              DefaultTextStyle(
                style: effectiveDescriptionStyle,
                child: description,
              ),
              descriptionText,
            ),
          ),
        if (widget.error case final error?)
          Padding(
            padding:
                effectiveDecoration.errorPadding ??
                const EdgeInsets.only(top: 8),
            child: painted(
              DefaultTextStyle(style: effectiveErrorStyle, child: error),
              errorText,
            ),
          ),
      ],
    );
  }
}

/// What an [InputDecorator] says about the control it decorates: the text
/// of its label, its description and its error.
///
/// A control reads it with [maybeOf] and puts it in its own semantics node
/// — the label as its name, the error and the description as its hint
/// ([hint]), and an error as `SemanticsValidationResult.invalid` — so a
/// screen reader hears them on the control. Reading it is taking it: the
/// decorator then leaves its painted copies out of the semantics tree,
/// which would otherwise read them a second time. `TextField` (and every
/// field built on it), `OtpField` and `TimeField` do this.
///
/// The content of an overlay opened from inside the control (a popover, a
/// menu, a select's list) is not the control: the portal that builds it
/// hides the scope with [InputDecoratorScope.none].
class InputDecoratorScope extends InheritedWidget {
  const InputDecoratorScope._({
    required this.label,
    required this.description,
    required this.error,
    required _Claims claims,
    required super.child,
  }) : _claims = claims;

  /// Hides the scope of any decorator above from [child], for content that
  /// is built under a control without being part of it.
  const InputDecoratorScope.none({super.key, required super.child})
    : label = null,
      description = null,
      error = null,
      _claims = null;

  /// The text of the decorator's label: the control's name.
  final String? label;

  /// The text of the decorator's description.
  final String? description;

  /// The text of the decorator's error, while it shows one.
  final String? error;

  final _Claims? _claims;

  /// The hint a control's node takes from this scope: the error, then the
  /// description, each on a line of its own. Null when there is neither.
  String? get hint {
    final parts = [?error, ?description];
    return parts.isEmpty ? null : parts.join('\n');
  }

  /// The scope of the nearest [InputDecorator] around [context], or null.
  ///
  /// Calling this tells the decorator that the control at [context] puts
  /// the scope's text in its own semantics node, so the decorator leaves
  /// its painted label, description and error out of the semantics tree.
  /// It takes them back when that control is gone. [context] rebuilds when
  /// the text changes.
  static InputDecoratorScope? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<InputDecoratorScope>();
    if (scope == null || scope._claims == null) return null;
    return scope;
  }

  @override
  InheritedElement createElement() => _InputDecoratorScopeElement(this);

  @override
  bool updateShouldNotify(InputDecoratorScope oldWidget) {
    return label != oldWidget.label ||
        description != oldWidget.description ||
        error != oldWidget.error ||
        !identical(_claims, oldWidget._claims);
  }
}

class _InputDecoratorScopeElement extends InheritedElement {
  _InputDecoratorScopeElement(InputDecoratorScope super.widget);

  _Claims? get _claims => (widget as InputDecoratorScope)._claims;

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    _claims?.add(dependent);
    super.updateDependencies(dependent, aspect);
  }

  @override
  void removeDependent(Element dependent) {
    _claims?.remove(dependent);
    super.removeDependent(dependent);
  }
}

/// The controls that took a decorator's text into their own nodes.
class _Claims extends ChangeNotifier {
  final _claimants = <Element>{};
  bool _disposed = false;

  bool get any => _claimants.isNotEmpty;

  void add(Element element) {
    if (_claimants.add(element) && _claimants.length == 1) _notify();
  }

  void remove(Element element) {
    if (_claimants.remove(element) && _claimants.isEmpty) _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Leaves its child out of the semantics tree while a control has claimed
/// the decorator's text.
///
/// Decided when the semantics are gathered, after every build: the label
/// is built before the control that claims it.
class _ExcludeWhenClaimed extends SingleChildRenderObjectWidget {
  const _ExcludeWhenClaimed({required this.claims, super.child});

  final _Claims claims;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderExcludeWhenClaimed(claims);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderExcludeWhenClaimed renderObject,
  ) {
    renderObject.claims = claims;
  }
}

class _RenderExcludeWhenClaimed extends RenderProxyBox {
  _RenderExcludeWhenClaimed(this._claims);

  _Claims _claims;
  _Claims get claims => _claims;
  set claims(_Claims value) {
    if (identical(value, _claims)) return;
    if (attached) {
      _claims.removeListener(markNeedsSemanticsUpdate);
      value.addListener(markNeedsSemanticsUpdate);
    }
    _claims = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _claims.addListener(markNeedsSemanticsUpdate);
  }

  @override
  void detach() {
    _claims.removeListener(markNeedsSemanticsUpdate);
    super.detach();
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_claims.any) return;
    super.visitChildrenForSemantics(visitor);
  }
}
