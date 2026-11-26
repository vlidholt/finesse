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
class UnaLocalizationsDataFi extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataFi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.fi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fi>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataFi _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataFi $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataFi(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$fi timePicker = _UnaLocalizationsData$timePicker$fi._(_root);
	@override late final _UnaLocalizationsData$datePicker$fi datePicker = _UnaLocalizationsData$datePicker$fi._(_root);
	@override late final _UnaLocalizationsData$input$fi input = _UnaLocalizationsData$input$fi._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$fi keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$fi._(_root);
	@override late final _UnaLocalizationsData$dialog$fi dialog = _UnaLocalizationsData$dialog$fi._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$fi extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$fi._(UnaLocalizationsDataFi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Tunnit';
	@override String get minutes => 'Minuutit';
	@override String get seconds => 'Sekunnit';
	@override String get period => 'Jakso';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$fi extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$fi._(UnaLocalizationsDataFi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Valitse päivämäärä';
}

// Path: input
class _UnaLocalizationsData$input$fi extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$fi._(UnaLocalizationsDataFi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Leikkaa';
	@override String get copy => 'Kopioi';
	@override String get paste => 'Liitä';
	@override String get selectAll => 'Valitse kaikki';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$fi extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$fi._(UnaLocalizationsDataFi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get done => 'Valmis';
}

// Path: dialog
class _UnaLocalizationsData$dialog$fi extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$fi._(UnaLocalizationsDataFi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFi _root; // ignore: unused_field

	// Translations
	@override String get close => 'Sulje';
	@override String get dismiss => 'Ohita';
}

/// The flat map containing all translations for locale <fi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataFi {
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
