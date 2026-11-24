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
class FinesseLocalizationsDataNl extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataNl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.nl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <nl>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataNl _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataNl $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataNl(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$nl timePicker = _FinesseLocalizationsData$timePicker$nl._(_root);
	@override late final _FinesseLocalizationsData$datePicker$nl datePicker = _FinesseLocalizationsData$datePicker$nl._(_root);
	@override late final _FinesseLocalizationsData$input$nl input = _FinesseLocalizationsData$input$nl._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$nl keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$nl._(_root);
	@override late final _FinesseLocalizationsData$dialog$nl dialog = _FinesseLocalizationsData$dialog$nl._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$nl extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$nl._(FinesseLocalizationsDataNl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Uren';
	@override String get minutes => 'Minuten';
	@override String get seconds => 'Seconden';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$nl extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$nl._(FinesseLocalizationsDataNl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Datum selecteren';
}

// Path: input
class _FinesseLocalizationsData$input$nl extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$nl._(FinesseLocalizationsDataNl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Knippen';
	@override String get copy => 'Kopiëren';
	@override String get paste => 'Plakken';
	@override String get selectAll => 'Alles selecteren';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$nl extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$nl._(FinesseLocalizationsDataNl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gereed';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$nl extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$nl._(FinesseLocalizationsDataNl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Sluiten';
	@override String get dismiss => 'Sluiten';
}

/// The flat map containing all translations for locale <nl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataNl {
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
