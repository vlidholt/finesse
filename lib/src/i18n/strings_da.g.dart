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
class UnaLocalizationsDataDa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataDa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.da,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <da>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataDa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataDa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataDa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$da timePicker = _UnaLocalizationsData$timePicker$da._(_root);
	@override late final _UnaLocalizationsData$datePicker$da datePicker = _UnaLocalizationsData$datePicker$da._(_root);
	@override late final _UnaLocalizationsData$input$da input = _UnaLocalizationsData$input$da._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$da keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$da._(_root);
	@override late final _UnaLocalizationsData$dialog$da dialog = _UnaLocalizationsData$dialog$da._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$da extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$da._(UnaLocalizationsDataDa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Timer';
	@override String get minutes => 'Minutter';
	@override String get seconds => 'Sekunder';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$da extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$da._(UnaLocalizationsDataDa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vælg dato';
}

// Path: input
class _UnaLocalizationsData$input$da extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$da._(UnaLocalizationsDataDa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klip';
	@override String get copy => 'Kopiér';
	@override String get paste => 'Sæt ind';
	@override String get selectAll => 'Vælg alt';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$da extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$da._(UnaLocalizationsDataDa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get done => 'Færdig';
}

// Path: dialog
class _UnaLocalizationsData$dialog$da extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$da._(UnaLocalizationsDataDa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDa _root; // ignore: unused_field

	// Translations
	@override String get close => 'Luk';
	@override String get dismiss => 'Luk';
}

/// The flat map containing all translations for locale <da>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataDa {
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
