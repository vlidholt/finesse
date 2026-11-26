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
class UnaLocalizationsDataLt extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataLt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.lt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <lt>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataLt _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataLt $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataLt(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$lt timePicker = _UnaLocalizationsData$timePicker$lt._(_root);
	@override late final _UnaLocalizationsData$datePicker$lt datePicker = _UnaLocalizationsData$datePicker$lt._(_root);
	@override late final _UnaLocalizationsData$input$lt input = _UnaLocalizationsData$input$lt._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$lt keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$lt._(_root);
	@override late final _UnaLocalizationsData$dialog$lt dialog = _UnaLocalizationsData$dialog$lt._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$lt extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$lt._(UnaLocalizationsDataLt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Valandos';
	@override String get minutes => 'Minutės';
	@override String get seconds => 'Sekundės';
	@override String get period => 'Laikotarpis';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$lt extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$lt._(UnaLocalizationsDataLt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pasirinkite datą';
}

// Path: input
class _UnaLocalizationsData$input$lt extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$lt._(UnaLocalizationsDataLt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Iškirpti';
	@override String get copy => 'Kopijuoti';
	@override String get paste => 'Įklijuoti';
	@override String get selectAll => 'Pasirinkti viską';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$lt extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$lt._(UnaLocalizationsDataLt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Atlikta';
}

// Path: dialog
class _UnaLocalizationsData$dialog$lt extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$lt._(UnaLocalizationsDataLt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Uždaryti';
	@override String get dismiss => 'Atsisakyti';
}

/// The flat map containing all translations for locale <lt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataLt {
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
