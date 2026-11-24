import 'package:flutter/widgets.dart';

/// Creates an [AnimationController] and rebuilds [builder] on every tick of
/// it.
class AnimationBuilder extends StatefulWidget {
  /// Creates an animation builder with a controller of the given [duration].
  const AnimationBuilder({
    super.key,
    required this.duration,
    required this.builder,
  });

  /// The duration of the controller. A change updates the existing controller.
  final Duration duration;

  /// Builds the child with the controller. Called on every tick of the
  /// controller.
  final Widget Function(BuildContext context, AnimationController controller)
  builder;

  @override
  State<AnimationBuilder> createState() => _AnimationBuilderState();
}

class _AnimationBuilderState extends State<AnimationBuilder>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  @override
  void didUpdateWidget(AnimationBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The controller is created once with the initial duration, so without
    // this a later duration change was silently ignored.
    if (widget.duration != oldWidget.duration) {
      controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return widget.builder(context, controller);
      },
    );
  }
}
