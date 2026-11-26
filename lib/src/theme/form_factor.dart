/// The class of screen a theme is laid out for.
///
/// Every `StyleTokens` carries two sets of metrics. `UnaApp` picks between
/// them from the window width — below the theme's `md` breakpoint is
/// [mobile] — so the same widgets come out with 36-point buttons in a desktop
/// window and 44-point ones on a phone.
enum FormFactor {
  /// A pointer-driven layout: dense controls, wide page margins.
  desktop,

  /// A touch-driven layout: 44-point targets, larger body text, tight page
  /// margins.
  mobile,
}
