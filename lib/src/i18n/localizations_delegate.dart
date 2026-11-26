import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/i18n/strings.g.dart';

/// Flutter localizations delegate for [UnaLocalizationsData].
///
/// Automatically added by `UnaApp`. Consumers can also provide it manually
/// through `WidgetsApp.localizationsDelegates`.
class GlobalUnaLocalizations
    extends LocalizationsDelegate<UnaLocalizationsData> {
  /// Creates the delegate. Prefer the shared [delegate] instance.
  const GlobalUnaLocalizations();

  /// The singleton instance of this delegate.
  static const GlobalUnaLocalizations delegate = GlobalUnaLocalizations();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<UnaLocalizationsData> load(Locale locale) {
    // Two-pass: prefer exact language+country match, fall back to
    // language-only, then to English.
    final exact = UnaLocale.values.where((l) {
      return l.languageCode == locale.languageCode &&
          l.countryCode == locale.countryCode;
    }).firstOrNull;
    final match =
        exact ??
        UnaLocale.values
            .where((l) => l.languageCode == locale.languageCode)
            .firstOrNull ??
        UnaLocale.en;

    // English is the base locale (not deferred) — load synchronously so the
    // widget tree is ready on the first frame, keeping tests fast.
    if (match == UnaLocale.en) {
      return SynchronousFuture<UnaLocalizationsData>(match.buildSync());
    }

    // All other locales are deferred imports. Must use the async build() so
    // loadLibrary() is called before accessing the locale class (required on
    // Flutter web / dart2js / wasm).
    return match.build();
  }

  @override
  bool shouldReload(GlobalUnaLocalizations old) => false;
}

/// Provides access to [UnaLocalizationsData] from the widget tree.
///
/// Usage:
/// ```dart
/// final l = UnaLocalizations.of(context);
/// ```
abstract class UnaLocalizations {
  /// Returns the [UnaLocalizationsData] for the nearest [Localizations]
  /// ancestor.
  ///
  /// Falls back to English when no delegate is found in the widget tree.
  static UnaLocalizationsData of(BuildContext context) {
    final data = Localizations.of<UnaLocalizationsData>(
      context,
      UnaLocalizationsData,
    );
    return data ?? UnaLocalizationsData();
  }
}
