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
class FinesseLocalizationsDataDa extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataDa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.da,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <da>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataDa _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataDa $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataDa(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$da timePicker = _FinesseLocalizationsData$timePicker$da._(_root);
	@override late final _FinesseLocalizationsData$datePicker$da datePicker = _FinesseLocalizationsData$datePicker$da._(_root);
	@override late final _FinesseLocalizationsData$input$da input = _FinesseLocalizationsData$input$da._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$da keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$da._(_root);
	@override late final _FinesseLocalizationsData$dialog$da dialog = _FinesseLocalizationsData$dialog$da._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$da extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$da._(FinesseLocalizationsDataDa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Timer';
	@override String get minutes => 'Minutter';
	@override String get seconds => 'Sekunder';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$da extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$da._(FinesseLocalizationsDataDa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vælg dato';
}

// Path: input
class _FinesseLocalizationsData$input$da extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$da._(FinesseLocalizationsDataDa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klip';
	@override String get copy => 'Kopiér';
	@override String get paste => 'Sæt ind';
	@override String get selectAll => 'Vælg alt';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$da extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$da._(FinesseLocalizationsDataDa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get done => 'Færdig';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$da extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$da._(FinesseLocalizationsDataDa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get close => 'Luk';
	@override String get dismiss => 'Luk';
}

/// The flat map containing all translations for locale <da>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataDa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Timer',
			'timePicker.minutes' => 'Minutter',
			'timePicker.seconds' => 'Sekunder',
			'timePicker.period' => 'Periode',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Vælg dato',
			'input.cut' => 'Klip',
			'input.copy' => 'Kopiér',
			'input.paste' => 'Sæt ind',
			'input.selectAll' => 'Vælg alt',
			'keyboardToolbar.done' => 'Færdig',
			'dialog.close' => 'Luk',
			'dialog.dismiss' => 'Luk',
			_ => null,
		};
	}
}
