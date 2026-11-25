import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A phone-sized screen for a docs example to put a `Scaffold` in.
///
/// It stands in for the window: the theme inside is laid out for a phone,
/// the real window's safe area and keyboard are kept out, and it has a
/// navigator of its own, so a drawer or a pushed page stays inside the
/// frame. [keyboardHeight] raises a stand-in for the software keyboard.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({
    required this.child,
    this.width = 340,
    this.height = 560,
    this.keyboardHeight = 0,
    super.key,
  });

  /// The screen: usually a `Scaffold`.
  final Widget child;

  final double width;
  final double height;

  /// How much of the bottom of the frame the stand-in keyboard covers.
  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = theme.radii.xl2;
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: radius),
        // Painted over the content, so nothing covers the frame's corners.
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: radius,
        ),
        child: SpringBuilder(
          value: keyboardHeight,
          spring: theme.motion.smooth,
          tolerance: .05,
          builder: (context, keyboard, _) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(width, height),
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.only(bottom: keyboard < 0 ? 0 : keyboard),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Its own navigator, and no heroes shared with the app's.
                // The first page is a slot: a route is built once, and the
                // screen it shows changes with every build of the example.
                _Screen(
                  screen: child,
                  child: HeroControllerScope.none(
                    child: Navigator(
                      onGenerateRoute: (settings) => FinessePageRoute<void>(
                        settings: settings,
                        builder: (_) => const _ScreenSlot(),
                      ),
                    ),
                  ),
                ),
                if (keyboard > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: keyboard,
                    child: const _StandInKeyboard(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carries the frame's screen to the first page of its navigator.
class _Screen extends InheritedWidget {
  const _Screen({required this.screen, required super.child});

  final Widget screen;

  @override
  bool updateShouldNotify(_Screen oldWidget) => screen != oldWidget.screen;
}

class _ScreenSlot extends StatelessWidget {
  const _ScreenSlot();

  @override
  Widget build(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Screen>()!.screen;
}

/// A grey slab with rows of keys, where the software keyboard would be.
class _StandInKeyboard extends StatelessWidget {
  const _StandInKeyboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ColoredBox(
      color: Color.alphaBlend(scheme.muted, scheme.card),
      child: Padding(
        padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
        child: Column(
          spacing: theme.layoutTheme.gap(GapSize.sm),
          children: [
            for (final keys in const [10, 9, 7])
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: theme.layoutTheme.gap(GapSize.xs),
                  children: [
                    for (var i = 0; i < keys; i++)
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.card,
                            borderRadius: theme.radii.sm,
                            border: Border.all(color: scheme.border),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
