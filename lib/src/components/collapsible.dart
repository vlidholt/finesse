import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/expand_reveal.dart';
import 'package:flutter/widgets.dart';

/// Controls the open state of a [Collapsible].
class CollapsibleController extends ChangeNotifier {
  /// Creates a controller. [isOpen] sets whether the content starts shown.
  CollapsibleController({bool isOpen = false}) : _open = isOpen;

  bool _open;

  /// Whether the collapsible's content is currently shown.
  bool get isOpen => _open;

  /// Shows the content.
  void open() => setOpen(true);

  /// Hides the content.
  void close() => setOpen(false);

  /// Shows the content if hidden, hides it if shown.
  void toggle() => setOpen(!_open);

  /// Shows the content when [open] is true and hides it otherwise.
  void setOpen(bool open) {
    if (_open == open) return;
    _open = open;
    notifyListeners();
  }
}

/// Builds the trigger of a [Collapsible].
///
/// [open] is the current state and [toggle] flips it.
typedef CollapsibleTriggerBuilder =
    Widget Function(BuildContext context, bool open, VoidCallback toggle);

/// {@template Collapsible}
/// An expandable/collapsible section.
///
/// Mirrors shadcn/ui's `Collapsible`: the primitive underneath an accordion,
/// for when you want a single independently-toggled region rather than a set
/// of them.
///
/// ```dart
/// Collapsible(
///   trigger: (context, open, toggle) => Button.ghost(
///     onPressed: toggle,
///     child: Text(open ? 'Hide' : 'Show'),
///   ),
///   child: const Text('Content'),
/// )
/// ```
///
/// For a group of sections where opening one closes the others, use
/// `Accordion` instead.
/// {@endtemplate}
class Collapsible extends StatefulWidget {
  /// {@macro Collapsible}
  const Collapsible({
    super.key,
    required this.child,
    this.trigger,
    this.controller,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.crossAxisAlignment,
    this.maintainState = false,
  });

  /// The collapsible content.
  final Widget child;

  /// Builds the always-visible trigger.
  ///
  /// Receives the current open state and a callback that flips it, so a
  /// trigger placed here needs no [controller] of its own.
  ///
  /// Optional: leave it null and drive the collapsible from a [controller] when
  /// the trigger lives elsewhere in your layout.
  final CollapsibleTriggerBuilder? trigger;

  /// An external controller for the open state.
  ///
  /// When null an internal one is created, seeded from [initiallyOpen].
  final CollapsibleController? controller;

  /// Whether the collapsible starts open. Ignored when [controller] is set.
  final bool initiallyOpen;

  /// Called whenever the open state changes.
  final ValueChanged<bool>? onOpenChanged;

  /// {@template Collapsible.crossAxisAlignment}
  /// How the trigger and content are aligned horizontally.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// Whether the collapsed content stays in the tree.
  ///
  /// Defaults to `false`, which keeps state out of memory. Set to `true` when
  /// the content holds scroll position or form state worth preserving.
  final bool maintainState;

  @override
  State<Collapsible> createState() => CollapsibleState();
}

/// The state of a [Collapsible].
class CollapsibleState extends State<Collapsible>
    with SingleTickerProviderStateMixin {
  CollapsibleController? _internalController;

  /// The controller in use: [Collapsible.controller] when given, otherwise
  /// an internal one.
  CollapsibleController get controller =>
      widget.controller ?? _internalController!;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: controller.isOpen ? 1 : 0,
  );

  late final CurvedAnimation _sizeFactor = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = CollapsibleController(
        isOpen: widget.initiallyOpen,
      );
    }
    controller.addListener(_onOpenChanged);
  }

  @override
  void didUpdateWidget(Collapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _onOpenChanged,
      );
      controller.addListener(_onOpenChanged);
      _onOpenChanged();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onOpenChanged);
    _internalController?.dispose();
    _sizeFactor.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onOpenChanged() {
    if (controller.isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onOpenChanged?.call(controller.isOpen);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final collapsibleTheme = theme.collapsibleTheme;

    // Open and shut on the surface spring, for as long as it takes to
    // settle.
    final motion = Motion.of(context);
    final curve = motion.smooth.curve;
    _animationController.duration = motion.smooth.settleDuration;
    _sizeFactor
      ..curve = curve
      // Flipped, the same curve decelerates into the closed state too
      // instead of running backwards and stopping dead.
      ..reverseCurve = curve.flipped;

    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        collapsibleTheme.crossAxisAlignment ??
        CrossAxisAlignment.stretch;

    final open = controller.isOpen;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: effectiveCrossAxisAlignment,
      children: [
        if (widget.trigger != null)
          Semantics(
            container: true,
            child: widget.trigger!(context, open, controller.toggle),
          ),
        AnimatedBuilder(
          animation: _sizeFactor,
          builder: (context, child) {
            // Skip building the content entirely while fully collapsed,
            // unless the caller asked to keep its state.
            if (_sizeFactor.value == 0 && !widget.maintainState) {
              return const SizedBox.shrink();
            }
            // Anchored to the top start: only the height animates, and the
            // content fades in as it is uncovered.
            return ExpandReveal(
              factor: _sizeFactor.value,
              travel: motion.overlayTravel,
              child: child!,
            );
          },
          child: ExcludeSemantics(
            excluding: !open,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
