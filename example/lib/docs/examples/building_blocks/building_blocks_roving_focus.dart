import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A row that is one Tab stop: the arrow keys, Home and End move a
/// highlight inside it, Enter picks, and typing a letter jumps to a name.
class BuildingBlocksRovingFocusExample extends StatefulWidget {
  const BuildingBlocksRovingFocusExample({super.key});

  @override
  State<BuildingBlocksRovingFocusExample> createState() =>
      _BuildingBlocksRovingFocusExampleState();
}

class _BuildingBlocksRovingFocusExampleState
    extends State<BuildingBlocksRovingFocusExample> {
  static const _sizes = ['Small', 'Medium', 'Large', 'Extra large'];

  final _controller = RovingFocusController(
    itemCount: _sizes.length,
    highlightedIndex: 1,
  );
  final _focusNode = FocusNode();
  int _picked = 1;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RovingFocus(
      controller: _controller,
      focusNode: _focusNode,
      onActivate: (index) => setState(() => _picked = index),
      typeaheadLabelAt: (index) => _sizes[index],
      // The group only interprets keys. What the highlight looks like is
      // up to the caller, who listens to the controller and the focus.
      child: ListenableBuilder(
        listenable: Listenable.merge([_controller, _focusNode]),
        builder: (context, _) => Wrap(
          spacing: theme.layoutTheme.gap(GapSize.sm),
          runSpacing: theme.layoutTheme.gap(GapSize.sm),
          children: [
            for (var i = 0; i < _sizes.length; i++)
              GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                  _controller.highlightedIndex = i;
                  setState(() => _picked = i);
                },
                child: FocusRing(
                  visible:
                      _focusNode.hasFocus && _controller.highlightedIndex == i,
                  borderRadius: theme.radii.lg,
                  child: AnimatedFill(
                    color: i == _picked ? scheme.accent : scheme.card,
                    borderColor: i == _picked
                        ? scheme.accentBorder
                        : scheme.border,
                    borderRadius: theme.radii.lg,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.layoutTheme.gap(GapSize.md),
                        vertical: theme.layoutTheme.gap(GapSize.sm),
                      ),
                      child: Text(_sizes[i], style: theme.textTheme.small),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
