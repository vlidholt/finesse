import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/icons/phosphor_icons.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/form_factor.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/content_switch.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/expand_reveal.dart';
import 'package:una/src/utils/motion_color.dart';
import 'package:una/src/utils/pop_in.dart';
import 'package:una/src/utils/spring.dart';
import 'package:una/src/utils/spring_size.dart';

/// What a [Step] of a [Stepper] shows itself as.
enum StepState {
  /// Decided by the step's place: completed before the current step,
  /// current on it, still to come after it.
  auto,

  /// Completed, whatever its place: a filled circle with a check.
  complete,

  /// Something in the step needs attention: a ring and a title in the
  /// scheme's destructive colour.
  error,

  /// Not available: dimmed, and it cannot be tapped.
  disabled,
}

/// One step of a [Stepper]: what it is called and, while it is the current
/// one, what it shows.
@immutable
class Step {
  /// Creates a step.
  const Step({
    required this.title,
    this.subtitle,
    this.content,
    this.state = StepState.auto,
    this.icon,
  });

  /// What the step is called, usually a `Text`.
  final Widget title;

  /// A quieter line under the [title]: "Optional", a summary of what was
  /// entered.
  final Widget? subtitle;

  /// What the step shows while it is the current one: its form. Only the
  /// current step's content is built, so what the user has entered belongs
  /// in state above the stepper.
  final Widget? content;

  /// How the step shows itself; see [StepState].
  final StepState state;

  /// Shown in the step's circle in place of its number. A completed step
  /// shows a check and a step in error a mark, whatever this is.
  final Widget? icon;
}

/// What a [Stepper] hands its `controlsBuilder`: where the user is, and
/// what Continue and Cancel do.
@immutable
class StepperControls {
  /// Creates the description of a stepper's controls.
  const StepperControls({
    required this.currentStep,
    required this.stepCount,
    this.onContinue,
    this.onCancel,
  });

  /// The index of the current step.
  final int currentStep;

  /// How many steps there are.
  final int stepCount;

  /// The stepper's `onContinue`.
  final VoidCallback? onContinue;

  /// The stepper's `onCancel`.
  final VoidCallback? onCancel;

  /// Whether the current step is the first.
  bool get isFirst => currentStep == 0;

  /// Whether the current step is the last.
  bool get isLast => currentStep == stepCount - 1;
}

/// A sequence of numbered steps with the current one opened: a checkout, a
/// sign-up, a set-up wizard.
///
/// ```dart
/// Stepper(
///   currentStep: _step,
///   onStepTapped: (step) => setState(() => _step = step),
///   onContinue: () => setState(() => _step++),
///   onCancel: () => setState(() => _step--),
///   steps: const [
///     Step(title: Text('Account'), content: AccountForm()),
///     Step(title: Text('Address'), content: AddressForm()),
///     Step(title: Text('Payment'), content: PaymentForm()),
///   ],
/// )
/// ```
///
/// The stepper is controlled: it shows [currentStep] and reports what the
/// user asks for; the parent decides whether to go there. Steps before the
/// current one show as completed, the current one is ringed, and the line
/// between two steps fills as the first of them is completed.
///
/// On a desktop the steps run across the top with the current step's
/// content below; on a phone they run down the page and the current step
/// opens under its title. [axis] decides it either way.
///
/// With an [onContinue] or an [onCancel] the stepper shows its own Continue
/// and Cancel buttons under the content; [controlsBuilder] replaces them.
class Stepper extends StatefulWidget {
  /// Creates a stepper.
  const Stepper({
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.axis,
    this.onContinue,
    this.onCancel,
    this.controlsBuilder,
    super.key,
  }) : assert(currentStep >= 0, 'currentStep must not be negative');

  /// The steps, in order.
  final List<Step> steps;

  /// The index of the step that is open.
  final int currentStep;

  /// Called with a step's index when its header is tapped, or activated
  /// from the keyboard. Null makes the headers plain labels. A
  /// [StepState.disabled] step is never reported.
  final ValueChanged<int>? onStepTapped;

  /// The direction the steps run in. Null follows the form factor:
  /// horizontal on a desktop, vertical on a phone.
  final Axis? axis;

  /// Called by the Continue button.
  final VoidCallback? onContinue;

  /// Called by the Cancel button.
  final VoidCallback? onCancel;

  /// Builds the controls under the current step's content, in place of the
  /// Continue and Cancel buttons.
  final Widget Function(BuildContext context, StepperControls controls)?
  controlsBuilder;

  @override
  State<Stepper> createState() => _StepperState();
}

/// How a step is drawn.
enum _Look { upcoming, current, complete, error }

class _StepperState extends State<Stepper> with TickerProviderStateMixin {
  /// How far the line after each step has filled, 0 to 1; one per step but
  /// the last.
  final _connectors = <SpringController>[];

  /// The step that was open until a moment ago, while a vertical stepper
  /// is still closing it.
  int? _leaving;

  /// The current step's controls: they move from one step to the next with
  /// their state, so a Continue pressed from the keyboard keeps the focus.
  final _controlsKey = GlobalKey(debugLabel: 'Stepper controls');

  @override
  void initState() {
    super.initState();
    _syncConnectors(animate: false);
  }

  @override
  void didUpdateWidget(Stepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncConnectors(animate: true);
    if (widget.currentStep != oldWidget.currentStep) {
      final previous = oldWidget.currentStep;
      _leaving = previous >= 0 && previous < widget.steps.length
          ? previous
          : null;
      // The focus has not moved — it is on Continue, or nowhere — so a
      // screen reader would not learn that the step did.
      final strings = UnaLocalizations.of(context).stepper;
      SemanticsService.sendAnnouncement(
        View.of(context),
        strings.position(
          step: _current + 1,
          count: widget.steps.length,
        ),
        Directionality.of(context),
      );
    }
  }

  @override
  void dispose() {
    for (final connector in _connectors) {
      connector.dispose();
    }
    super.dispose();
  }

  int get _current =>
      widget.currentStep.clamp(0, (widget.steps.length - 1).clamp(0, 1 << 30));

  bool _isComplete(int index) => switch (widget.steps[index].state) {
    StepState.complete => true,
    StepState.auto => index < _current,
    StepState.error || StepState.disabled => false,
  };

  _Look _lookOf(int index) => switch (widget.steps[index].state) {
    StepState.error => _Look.error,
    StepState.complete => _Look.complete,
    StepState.disabled => _Look.upcoming,
    StepState.auto =>
      index < _current
          ? _Look.complete
          : index == _current
          ? _Look.current
          : _Look.upcoming,
  };

  void _syncConnectors({required bool animate}) {
    final wanted = (widget.steps.length - 1).clamp(0, 1 << 30);
    while (_connectors.length > wanted) {
      _connectors.removeLast().dispose();
    }
    for (var i = 0; i < wanted; i++) {
      final target = _isComplete(i) ? 1.0 : 0.0;
      if (i >= _connectors.length) {
        _connectors.add(SpringController(vsync: this, value: target));
      } else if (_connectors[i].target != target) {
        if (animate) {
          final theme = Theme.of(context).stepperTheme;
          _connectors[i].animateTo(
            target,
            spring: theme.connectorSpring ?? Motion.of(context).smooth,
          );
        } else {
          _connectors[i].jumpTo(target);
        }
      }
    }
  }

  Widget? _controls(BuildContext context, int index) {
    final controls = StepperControls(
      currentStep: index,
      stepCount: widget.steps.length,
      onContinue: widget.onContinue,
      onCancel: widget.onCancel,
    );
    final builder = widget.controlsBuilder;
    if (builder != null) return builder(context, controls);
    if (widget.onContinue == null && widget.onCancel == null) return null;
    final theme = Theme.of(context);
    final strings = UnaLocalizations.of(context).stepper;
    return Wrap(
      spacing: theme.stepperTheme.gap ?? 12,
      runSpacing: 8,
      children: [
        Button(
          onPressed: widget.onContinue,
          enabled: widget.onContinue != null,
          child: Text(controls.isLast ? strings.finish : strings.next),
        ),
        if (widget.onCancel != null)
          Button.ghost(
            onPressed: widget.onCancel,
            child: Text(strings.cancel),
          ),
      ],
    );
  }

  /// The content of the step at [index] with the controls under it, or
  /// null when there is neither.
  ///
  /// Only the current step's body is [live]: its controls are the ones that
  /// carry the focus from step to step.
  Widget? _body(BuildContext context, int index, {bool live = true}) {
    final content = widget.steps[index].content;
    var controls = _controls(context, index);
    if (live && controls != null) {
      controls = KeyedSubtree(key: _controlsKey, child: controls);
    }
    if (content == null && controls == null) return null;
    final theme = Theme.of(context).stepperTheme;
    return Padding(
      padding: theme.contentPadding ?? const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?content,
          if (content != null && controls != null)
            SizedBox(height: theme.gap ?? 12),
          if (controls != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: controls,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    assert(widget.steps.isNotEmpty, 'A Stepper needs at least one step');
    final theme = Theme.of(context);
    final axis =
        widget.axis ??
        (theme.formFactor == FormFactor.mobile
            ? Axis.vertical
            : Axis.horizontal);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: axis == Axis.horizontal
          ? _buildHorizontal(context)
          : _buildVertical(context),
    );
  }

  _StepHeader _header(int index, Axis axis) {
    final step = widget.steps[index];
    final tappable =
        widget.onStepTapped != null && step.state != StepState.disabled;
    return _StepHeader(
      step: step,
      index: index,
      count: widget.steps.length,
      look: _lookOf(index),
      isCurrent: index == _current,
      axis: axis,
      before: index == 0 ? null : _connectors[index - 1].animation,
      after: index == widget.steps.length - 1
          ? null
          : _connectors[index].animation,
      onPressed: tappable ? () => widget.onStepTapped!(index) : null,
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final theme = Theme.of(context).stepperTheme;
    final body = _body(context, _current);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < widget.steps.length; i++)
              Expanded(child: _header(i, Axis.horizontal)),
          ],
        ),
        // The steps' content differs in height: the stepper follows it on
        // a spring, and the new content slides in from the side it is on.
        SpringSize(
          spring: theme.connectorSpring,
          child: ContentSwitch(
            value: _current,
            child: KeyedSubtree(
              key: ValueKey(_current),
              child: body ?? const SizedBox(width: double.infinity),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVertical(BuildContext context) {
    final theme = Theme.of(context).stepperTheme;
    final motion = Motion.of(context);
    final size = theme.indicatorSize ?? 28;
    final gap = theme.gap ?? 12;
    final spacing = theme.spacing ?? 20;
    final thickness = theme.connectorThickness ?? 2;
    final connectorGap = theme.connectorGap ?? 4;
    final last = widget.steps.length - 1;
    final body = _body(context, _current);
    // The step that is closing keeps its content for as long as it takes,
    // as a picture: it is no longer there to be used.
    final leaving = _leaving;
    final leavingBody = leaving == null || leaving == _current
        ? null
        : _body(context, leaving, live: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i <= last; i++)
          Stack(
            children: [
              // From under this step's circle down to the next one's.
              if (i != last)
                PositionedDirectional(
                  start: (size - thickness) / 2,
                  top: size + connectorGap,
                  bottom: connectorGap,
                  width: thickness,
                  child: _Connector(
                    progress: _connectors[i].animation,
                    axis: Axis.vertical,
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(bottom: i == last ? 0 : spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(i, Axis.vertical),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: size + gap),
                      child: SpringBuilder(
                        value: i == _current ? 1 : 0,
                        spring: theme.connectorSpring ?? motion.smooth,
                        onEnd: () {
                          if (i == _leaving && i != _current && mounted) {
                            setState(() => _leaving = null);
                          }
                        },
                        builder: (context, t, child) {
                          // Only the open step, and the one closing, are
                          // there at all.
                          if (child == null || (t <= 0 && i != _current)) {
                            return const SizedBox.shrink();
                          }
                          return ExpandReveal(
                            factor: t,
                            travel: motion.overlayTravel,
                            child: child,
                          );
                        },
                        child: i == _current
                            ? body
                            : i == leaving && leavingBody != null
                            ? IgnorePointer(
                                child: ExcludeFocus(
                                  child: ExcludeSemantics(child: leavingBody),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A step's circle and title, and in a horizontal stepper the halves of the
/// lines on either side of the circle.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.index,
    required this.count,
    required this.look,
    required this.isCurrent,
    required this.axis,
    required this.before,
    required this.after,
    required this.onPressed,
  });

  final Step step;
  final int index;
  final int count;
  final _Look look;
  final bool isCurrent;
  final Axis axis;

  /// The fill of the line before this step, and of the one after it.
  final Animation<double>? before;
  final Animation<double>? after;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepperTheme = theme.stepperTheme;
    final scheme = theme.colorScheme;
    final strings = UnaLocalizations.of(context).stepper;
    final motion = Motion.of(context);
    final size = stepperTheme.indicatorSize ?? 28;
    final gap = stepperTheme.gap ?? 12;
    final connectorGap = stepperTheme.connectorGap ?? 4;
    final horizontal = axis == Axis.horizontal;
    final disabled = step.state == StepState.disabled;

    final titleStyle = stepperTheme.titleStyle ?? theme.textTheme.small;
    final titleColor = switch (look) {
      _Look.error => stepperTheme.errorColor ?? scheme.destructive,
      _Look.upcoming =>
        stepperTheme.indicatorForegroundColor ?? scheme.mutedForeground,
      _Look.current || _Look.complete => titleStyle.color ?? scheme.foreground,
    };
    final textAlign = horizontal ? TextAlign.center : TextAlign.start;

    final label = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: horizontal
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        AnimatedColorBuilder(
          color: titleColor,
          duration: motion.fast,
          curve: motion.standard,
          builder: (context, color, child) => DefaultTextStyle.merge(
            style: titleStyle.copyWith(color: color),
            textAlign: textAlign,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            child: child!,
          ),
          child: step.title,
        ),
        if (step.subtitle != null)
          DefaultTextStyle.merge(
            style: stepperTheme.subtitleStyle ?? theme.textTheme.muted,
            textAlign: textAlign,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            child: step.subtitle!,
          ),
      ],
    );

    // A disabled step is dimmed; the lines beside it are not its own.
    Widget dimmed(Widget child) =>
        Opacity(opacity: disabled ? .5 : 1, child: child);

    Widget indicator(bool focused) => dimmed(
      FocusRing(
        visible: focused,
        borderRadius: BorderRadius.circular(size),
        child: Semantics(
          // "Step 2 of 4", then the title, read as one.
          label: strings.position(step: index + 1, count: count),
          child: ExcludeSemantics(
            child: _StepIndicator(index: index, look: look, icon: step.icon),
          ),
        ),
      ),
    );

    Widget build(Set<WidgetState> states) {
      final focused = states.contains(WidgetState.focused);
      if (horizontal) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: before == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: connectorGap,
                          ),
                          child: _Connector(
                            progress: before!,
                            axis: Axis.horizontal,
                            from: .5,
                          ),
                        ),
                ),
                indicator(focused),
                Expanded(
                  child: after == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: connectorGap,
                          ),
                          child: _Connector(
                            progress: after!,
                            axis: Axis.horizontal,
                            to: .5,
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: gap * 2 / 3),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 3),
              child: dimmed(label),
            ),
          ],
        );
      }
      return Row(
        children: [
          indicator(focused),
          SizedBox(width: gap),
          Expanded(
            // Beside the circle: centred on it when it is one line, and
            // growing down from it when it is more.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: dimmed(label),
              ),
            ),
          ),
        ],
      );
    }

    final value = switch (look) {
      _Look.complete => strings.complete,
      _Look.error => strings.error,
      _Look.upcoming || _Look.current => null,
    };
    final Widget header;
    if (onPressed != null) {
      header = Pressable(
        onPressed: onPressed,
        selected: isCurrent,
        semanticValue: value,
        // A whole column of the stepper is a large thing to shrink.
        pressScale: motion.surfacePressScale,
        builder: (context, states) => build(states),
      );
    } else {
      header = Semantics(
        container: true,
        selected: isCurrent,
        enabled: disabled ? false : null,
        value: value,
        child: build(const {}),
      );
    }
    return header;
  }
}

/// A step's circle: its number, its icon, a check or a mark.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.index,
    required this.look,
    required this.icon,
  });

  final int index;
  final _Look look;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepperTheme = theme.stepperTheme;
    final scheme = theme.colorScheme;
    final size = stepperTheme.indicatorSize ?? 28;
    final thickness = stepperTheme.connectorThickness ?? 2;
    final active = stepperTheme.activeColor ?? scheme.tint;
    final error = stepperTheme.errorColor ?? scheme.destructive;
    final complete = stepperTheme.completeColor ?? scheme.primary;
    const clear = Color(0x00000000);

    final (fill, border, foreground) = switch (look) {
      _Look.upcoming => (
        stepperTheme.indicatorColor ?? scheme.muted,
        stepperTheme.indicatorBorderColor ?? scheme.border,
        stepperTheme.indicatorForegroundColor ?? scheme.mutedForeground,
      ),
      _Look.current => (clear, active, active),
      _Look.complete => (
        complete,
        complete,
        stepperTheme.completeForegroundColor ?? scheme.primaryForeground,
      ),
      _Look.error => (clear, error, error),
    };
    final numbered = look == _Look.upcoming || look == _Look.current;
    final glyph = size * .5;

    return SizedBox.square(
      dimension: size,
      child: AnimatedFill(
        color: fill,
        borderColor: border,
        borderWidth: thickness,
        borderRadius: BorderRadius.circular(size),
        child: IconTheme.merge(
          data: IconThemeData(size: glyph, color: foreground),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // One goes as the other comes: the number shrinks away while
              // the check is drawn in.
              PopIn(
                visible: numbered,
                spring: Motion.of(context).snappy,
                child:
                    icon ??
                    Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style:
                          (stepperTheme.indicatorTextStyle ??
                                  theme.textTheme.small)
                              .copyWith(color: foreground, height: 1),
                    ),
              ),
              PopIn(
                visible: look == _Look.complete,
                wipe: true,
                child: const PhosphorIcon(PhosphorIconsBold.check),
              ),
              PopIn(
                visible: look == _Look.error,
                child: const PhosphorIcon(PhosphorIconsBold.exclamationMark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line between two steps, or one half of it, filled from its start as
/// far as [progress] says.
class _Connector extends StatelessWidget {
  const _Connector({
    required this.progress,
    required this.axis,
    this.from = 0,
    this.to = 1,
  });

  /// The fill of the whole line, 0 to 1.
  final Animation<double> progress;
  final Axis axis;

  /// The part of the whole line this piece is: a horizontal stepper draws
  /// each line as two halves, one in each step's column.
  final double from;
  final double to;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepperTheme = theme.stepperTheme;
    final thickness = stepperTheme.connectorThickness ?? 2;
    return CustomPaint(
      size: axis == Axis.horizontal
          ? Size(double.infinity, thickness)
          : Size(thickness, double.infinity),
      painter: _ConnectorPainter(
        progress: progress,
        axis: axis,
        from: from,
        to: to,
        thickness: thickness,
        color: stepperTheme.connectorColor ?? theme.colorScheme.borderStrong,
        activeColor: stepperTheme.activeColor ?? theme.colorScheme.tint,
        rtl: Directionality.of(context) == TextDirection.rtl,
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.progress,
    required this.axis,
    required this.from,
    required this.to,
    required this.thickness,
    required this.color,
    required this.activeColor,
    required this.rtl,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Axis axis;
  final double from;
  final double to;
  final double thickness;
  final Color color;
  final Color activeColor;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final filled = ((progress.value - from) / (to - from)).clamp(0.0, 1.0);
    final Rect line;
    final Rect done;
    if (axis == Axis.horizontal) {
      line = Rect.fromLTWH(
        0,
        (size.height - thickness) / 2,
        size.width,
        thickness,
      );
      final width = size.width * filled;
      done = Rect.fromLTWH(
        rtl ? size.width - width : 0,
        line.top,
        width,
        thickness,
      );
    } else {
      line = Rect.fromLTWH(
        (size.width - thickness) / 2,
        0,
        thickness,
        size.height,
      );
      done = Rect.fromLTWH(line.left, 0, thickness, size.height * filled);
    }
    canvas.drawRect(line, Paint()..color = color);
    if (filled > 0) canvas.drawRect(done, Paint()..color = activeColor);
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.axis != axis ||
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.thickness != thickness ||
      oldDelegate.color != color ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.rtl != rtl;
}
