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
class UnaLocalizationsDataGa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataGa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ga,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ga>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataGa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataGa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataGa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ga timePicker = _UnaLocalizationsData$timePicker$ga._(_root);
	@override late final _UnaLocalizationsData$datePicker$ga datePicker = _UnaLocalizationsData$datePicker$ga._(_root);
	@override late final _UnaLocalizationsData$input$ga input = _UnaLocalizationsData$input$ga._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ga keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ga._(_root);
	@override late final _UnaLocalizationsData$dialog$ga dialog = _UnaLocalizationsData$dialog$ga._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ga extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ga._(UnaLocalizationsDataGa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Uaireanta';
	@override String get minutes => 'Nóiméid';
	@override String get seconds => 'Soicindí';
	@override String get period => 'Tréimhse';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ga extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ga._(UnaLocalizationsDataGa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Roghnaigh dáta';
}

// Path: input
class _UnaLocalizationsData$input$ga extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ga._(UnaLocalizationsDataGa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Gearr';
	@override String get copy => 'Cóipeáil';
	@override String get paste => 'Greamaigh';
	@override String get selectAll => 'Roghnaigh uile';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ga extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ga._(UnaLocalizationsDataGa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get done => 'Déanta';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ga extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ga._(UnaLocalizationsDataGa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGa _root; // ignore: unused_field

	// Translations
	@override String get close => 'Dún';
	@override String get dismiss => 'Ruaig';
}

/// The flat map containing all translations for locale <ga>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataGa {
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
