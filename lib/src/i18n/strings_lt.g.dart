///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class FinesseLocalizationsDataLt extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataLt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.lt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <lt>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataLt _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataLt $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataLt(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$lt timePicker = _FinesseLocalizationsData$timePicker$lt._(_root);
	@override late final _FinesseLocalizationsData$datePicker$lt datePicker = _FinesseLocalizationsData$datePicker$lt._(_root);
	@override late final _FinesseLocalizationsData$input$lt input = _FinesseLocalizationsData$input$lt._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$lt keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$lt._(_root);
	@override late final _FinesseLocalizationsData$dialog$lt dialog = _FinesseLocalizationsData$dialog$lt._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$lt extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$lt._(FinesseLocalizationsDataLt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Valandos';
	@override String get minutes => 'Minutės';
	@override String get seconds => 'Sekundės';
	@override String get period => 'Laikotarpis';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$lt extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$lt._(FinesseLocalizationsDataLt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pasirinkite datą';
}

// Path: input
class _FinesseLocalizationsData$input$lt extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$lt._(FinesseLocalizationsDataLt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Iškirpti';
	@override String get copy => 'Kopijuoti';
	@override String get paste => 'Įklijuoti';
	@override String get selectAll => 'Pasirinkti viską';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$lt extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$lt._(FinesseLocalizationsDataLt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Atlikta';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$lt extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$lt._(FinesseLocalizationsDataLt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Uždaryti';
	@override String get dismiss => 'Atsisakyti';
}

/// The flat map containing all translations for locale <lt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataLt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Valandos',
			'timePicker.minutes' => 'Minutės',
			'timePicker.seconds' => 'Sekundės',
			'timePicker.period' => 'Laikotarpis',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Pasirinkite datą',
			'input.cut' => 'Iškirpti',
			'input.copy' => 'Kopijuoti',
			'input.paste' => 'Įklijuoti',
			'input.selectAll' => 'Pasirinkti viską',
			'keyboardToolbar.done' => 'Atlikta',
			'dialog.close' => 'Uždaryti',
			'dialog.dismiss' => 'Atsisakyti',
			_ => null,
		};
	}
}
