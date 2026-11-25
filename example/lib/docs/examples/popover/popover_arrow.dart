import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// showArrow gives the popover a tip that points at its trigger. It is part
/// of the surface — the same fill, outline, glass and shadow — and rides
/// whichever edge faces the trigger, so the anchor alone decides the side.
class PopoverArrowExample extends StatelessWidget {
  const PopoverArrowExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ArrowPopover(label: 'Below'),
        _ArrowPopover(
          label: 'Above',
          anchor: Anchor(
            childAlignment: Alignment.topCenter,
            overlayAlignment: Alignment.bottomCenter,
            offset: Offset(0, -4),
          ),
        ),
        _ArrowPopover(
          label: 'Beside',
          anchor: Anchor(
            childAlignment: AlignmentDirectional.centerEnd,
            overlayAlignment: AlignmentDirectional.centerStart,
            offset: Offset(4, 0),
          ),
        ),
        // Aligned with the start of its trigger, the arrow still finds the
        // trigger's middle.
        _ArrowPopover(
          label: 'From the start',
          anchor: Anchor(
            childAlignment: AlignmentDirectional.bottomStart,
            overlayAlignment: AlignmentDirectional.topStart,
            offset: Offset(0, 4),
          ),
        ),
      ],
    );
  }
}

class _ArrowPopover extends StatefulWidget {
  const _ArrowPopover({required this.label, this.anchor});

  final String label;

  /// Where the popover goes; null leaves it to the theme, which puts it
  /// below the trigger and above it when there is no room.
  final AnchorBase? anchor;

  @override
  State<_ArrowPopover> createState() => _ArrowPopoverState();
}

class _ArrowPopoverState extends State<_ArrowPopover> {
  final controller = PopoverController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Popover(
      controller: controller,
      showArrow: true,
      anchor: widget.anchor,
      popover: (_) => SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text('Share this page', style: textTheme.small),
            Text(
              'Anyone with the link can read it.',
              style: textTheme.muted,
            ),
          ],
        ),
      ),
      child: Button.outline(
        onPressed: controller.toggle,
        child: Text(widget.label),
      ),
    );
  }
}
