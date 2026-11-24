import 'package:finesse/src/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Flutter localizations delegate for [FinesseLocalizationsData].
///
/// Automatically added by `FinesseApp`. Consumers can also provide it manually
/// through `WidgetsApp.localizationsDelegates`.
class GlobalFinesseLocalizations
    extends LocalizationsDelegate<FinesseLocalizationsData> {
  /// Creates the delegate. Prefer the shared [delegate] instance.
  const GlobalFinesseLocalizations();

  /// The singleton instance of this delegate.
  static const GlobalFinesseLocalizations delegate =
      GlobalFinesseLocalizations();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<FinesseLocalizationsData> load(Locale locale) {
    // Two-pass: prefer exact language+country match, fall back to
    // language-only, then to English.
    final exact = FinesseLocale.values.where((l) {
      return l.languageCode == locale.languageCode &&
          l.countryCode == locale.countryCode;
    }).firstOrNull;
    final match =
        exact ??
        FinesseLocale.values
            .where((l) => l.languageCode == locale.languageCode)
            .firstOrNull ??
        FinesseLocale.en;

    // English is the base locale (not deferred) — load synchronously so the
    // widget tree is ready on the first frame, keeping tests fast.
    if (match == FinesseLocale.en) {
      return SynchronousFuture<FinesseLocalizationsData>(match.buildSync());
    }

    // All other locales are deferred imports. Must use the async build() so
    // loadLibrary() is called before accessing the locale class (required on
    // Flutter web / dart2js / wasm).
    return match.build();
  }

  @override
  bool shouldReload(GlobalFinesseLocalizations old) => false;
}

/// Provides access to [FinesseLocalizationsData] from the widget tree.
///
/// Usage:
/// ```dart
/// final l = FinesseLocalizations.of(context);
/// ```
abstract class FinesseLocalizations {
  /// Returns the [FinesseLocalizationsData] for the nearest [Localizations]
  /// ancestor.
  ///
  /// Falls back to English when no delegate is found in the widget tree.
  static FinesseLocalizationsData of(BuildContext context) {
    final data = Localizations.of<FinesseLocalizationsData>(
      context,
      FinesseLocalizationsData,
    );
    return data ?? FinesseLocalizationsData();
  }
}
