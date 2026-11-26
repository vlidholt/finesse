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
class UnaLocalizationsDataNl extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataNl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.nl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <nl>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataNl _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataNl $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataNl(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$nl timePicker = _UnaLocalizationsData$timePicker$nl._(_root);
	@override late final _UnaLocalizationsData$datePicker$nl datePicker = _UnaLocalizationsData$datePicker$nl._(_root);
	@override late final _UnaLocalizationsData$input$nl input = _UnaLocalizationsData$input$nl._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$nl keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$nl._(_root);
	@override late final _UnaLocalizationsData$dialog$nl dialog = _UnaLocalizationsData$dialog$nl._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$nl extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$nl._(UnaLocalizationsDataNl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Uren';
	@override String get minutes => 'Minuten';
	@override String get seconds => 'Seconden';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$nl extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$nl._(UnaLocalizationsDataNl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Datum selecteren';
}

// Path: input
class _UnaLocalizationsData$input$nl extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$nl._(UnaLocalizationsDataNl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Knippen';
	@override String get copy => 'Kopiëren';
	@override String get paste => 'Plakken';
	@override String get selectAll => 'Alles selecteren';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$nl extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$nl._(UnaLocalizationsDataNl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gereed';
}

// Path: dialog
class _UnaLocalizationsData$dialog$nl extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$nl._(UnaLocalizationsDataNl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Sluiten';
	@override String get dismiss => 'Sluiten';
}

/// The flat map containing all translations for locale <nl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataNl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Uren',
			'timePicker.minutes' => 'Minuten',
			'timePicker.seconds' => 'Seconden',
			'timePicker.period' => 'Periode',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Datum selecteren',
			'input.cut' => 'Knippen',
			'input.copy' => 'Kopiëren',
			'input.paste' => 'Plakken',
			'input.selectAll' => 'Alles selecteren',
			'keyboardToolbar.done' => 'Gereed',
			'dialog.close' => 'Sluiten',
			'dialog.dismiss' => 'Sluiten',
			_ => null,
		};
	}
}
