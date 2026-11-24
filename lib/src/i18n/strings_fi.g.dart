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
class FinesseLocalizationsDataFi extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataFi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.fi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fi>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataFi _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataFi $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataFi(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$fi timePicker = _FinesseLocalizationsData$timePicker$fi._(_root);
	@override late final _FinesseLocalizationsData$datePicker$fi datePicker = _FinesseLocalizationsData$datePicker$fi._(_root);
	@override late final _FinesseLocalizationsData$input$fi input = _FinesseLocalizationsData$input$fi._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$fi keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$fi._(_root);
	@override late final _FinesseLocalizationsData$dialog$fi dialog = _FinesseLocalizationsData$dialog$fi._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$fi extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$fi._(FinesseLocalizationsDataFi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Tunnit';
	@override String get minutes => 'Minuutit';
	@override String get seconds => 'Sekunnit';
	@override String get period => 'Jakso';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$fi extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$fi._(FinesseLocalizationsDataFi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Valitse päivämäärä';
}

// Path: input
class _FinesseLocalizationsData$input$fi extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$fi._(FinesseLocalizationsDataFi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Leikkaa';
	@override String get copy => 'Kopioi';
	@override String get paste => 'Liitä';
	@override String get selectAll => 'Valitse kaikki';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$fi extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$fi._(FinesseLocalizationsDataFi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get done => 'Valmis';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$fi extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$fi._(FinesseLocalizationsDataFi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get close => 'Sulje';
	@override String get dismiss => 'Ohita';
}

/// The flat map containing all translations for locale <fi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataFi {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Tunnit',
			'timePicker.minutes' => 'Minuutit',
			'timePicker.seconds' => 'Sekunnit',
			'timePicker.period' => 'Jakso',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Valitse päivämäärä',
			'input.cut' => 'Leikkaa',
			'input.copy' => 'Kopioi',
			'input.paste' => 'Liitä',
			'input.selectAll' => 'Valitse kaikki',
			'keyboardToolbar.done' => 'Valmis',
			'dialog.close' => 'Sulje',
			'dialog.dismiss' => 'Ohita',
			_ => null,
		};
	}
}
