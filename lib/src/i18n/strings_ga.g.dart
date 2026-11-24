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
class FinesseLocalizationsDataGa extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataGa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ga,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ga>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataGa _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataGa $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataGa(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ga timePicker = _FinesseLocalizationsData$timePicker$ga._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ga datePicker = _FinesseLocalizationsData$datePicker$ga._(_root);
	@override late final _FinesseLocalizationsData$input$ga input = _FinesseLocalizationsData$input$ga._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ga keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ga._(_root);
	@override late final _FinesseLocalizationsData$dialog$ga dialog = _FinesseLocalizationsData$dialog$ga._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ga extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ga._(FinesseLocalizationsDataGa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Uaireanta';
	@override String get minutes => 'Nóiméid';
	@override String get seconds => 'Soicindí';
	@override String get period => 'Tréimhse';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ga extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ga._(FinesseLocalizationsDataGa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Roghnaigh dáta';
}

// Path: input
class _FinesseLocalizationsData$input$ga extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ga._(FinesseLocalizationsDataGa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Gearr';
	@override String get copy => 'Cóipeáil';
	@override String get paste => 'Greamaigh';
	@override String get selectAll => 'Roghnaigh uile';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ga extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ga._(FinesseLocalizationsDataGa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get done => 'Déanta';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ga extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ga._(FinesseLocalizationsDataGa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get close => 'Dún';
	@override String get dismiss => 'Ruaig';
}

/// The flat map containing all translations for locale <ga>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataGa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Uaireanta',
			'timePicker.minutes' => 'Nóiméid',
			'timePicker.seconds' => 'Soicindí',
			'timePicker.period' => 'Tréimhse',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Roghnaigh dáta',
			'input.cut' => 'Gearr',
			'input.copy' => 'Cóipeáil',
			'input.paste' => 'Greamaigh',
			'input.selectAll' => 'Roghnaigh uile',
			'keyboardToolbar.done' => 'Déanta',
			'dialog.close' => 'Dún',
			'dialog.dismiss' => 'Ruaig',
			_ => null,
		};
	}
}
