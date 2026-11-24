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
class FinesseLocalizationsDataPl extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataPl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.pl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pl>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataPl _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataPl $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataPl(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$pl timePicker = _FinesseLocalizationsData$timePicker$pl._(_root);
	@override late final _FinesseLocalizationsData$datePicker$pl datePicker = _FinesseLocalizationsData$datePicker$pl._(_root);
	@override late final _FinesseLocalizationsData$input$pl input = _FinesseLocalizationsData$input$pl._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$pl keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$pl._(_root);
	@override late final _FinesseLocalizationsData$dialog$pl dialog = _FinesseLocalizationsData$dialog$pl._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$pl extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$pl._(FinesseLocalizationsDataPl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Godziny';
	@override String get minutes => 'Minuty';
	@override String get seconds => 'Sekundy';
	@override String get period => 'Okres';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$pl extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$pl._(FinesseLocalizationsDataPl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Wybierz datę';
}

// Path: input
class _FinesseLocalizationsData$input$pl extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$pl._(FinesseLocalizationsDataPl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Wytnij';
	@override String get copy => 'Kopiuj';
	@override String get paste => 'Wklej';
	@override String get selectAll => 'Zaznacz wszystko';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$pl extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$pl._(FinesseLocalizationsDataPl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gotowe';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$pl extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$pl._(FinesseLocalizationsDataPl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zamknij';
	@override String get dismiss => 'Zamknij';
}

/// The flat map containing all translations for locale <pl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataPl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Godziny',
			'timePicker.minutes' => 'Minuty',
			'timePicker.seconds' => 'Sekundy',
			'timePicker.period' => 'Okres',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Wybierz datę',
			'input.cut' => 'Wytnij',
			'input.copy' => 'Kopiuj',
			'input.paste' => 'Wklej',
			'input.selectAll' => 'Zaznacz wszystko',
			'keyboardToolbar.done' => 'Gotowe',
			'dialog.close' => 'Zamknij',
			'dialog.dismiss' => 'Zamknij',
			_ => null,
		};
	}
}
