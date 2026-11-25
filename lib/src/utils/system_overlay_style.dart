import 'package:flutter/services.dart';

/// The status- and navigation-bar style for a screen whose surface under
/// them is of [brightness]: both bars transparent, so the page and its glass
/// bars reach the edges of the screen, with dark icons over a light surface
/// and light icons over a dark one.
SystemUiOverlayStyle systemOverlayStyleFor(Brightness brightness) {
  final icons = brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: const Color(0x00000000),
    // Android reads the icons' brightness, iOS the bar's.
    statusBarIconBrightness: icons,
    statusBarBrightness: brightness,
    systemNavigationBarColor: const Color(0x00000000),
    systemNavigationBarDividerColor: const Color(0x00000000),
    systemNavigationBarIconBrightness: icons,
    systemNavigationBarContrastEnforced: false,
  );
}

/// Whether [color], laid over [backdrop], is a dark or a light surface.
///
/// A bar's fill is often translucent; what the status-bar icons have to read
/// against is the fill over the page behind it.
Brightness surfaceBrightness(Color color, Color backdrop) {
  final surface = Color.alphaBlend(color, backdrop.withValues(alpha: 1));
  // The threshold Material uses: the luminance at which black and white
  // text contrast equally.
  final luminance = surface.computeLuminance();
  return (luminance + .05) * (luminance + .05) > .15
      ? Brightness.light
      : Brightness.dark;
}
