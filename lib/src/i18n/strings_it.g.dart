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
class FinesseLocalizationsDataIt extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataIt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <it>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataIt _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataIt $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataIt(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$it timePicker = _FinesseLocalizationsData$timePicker$it._(_root);
	@override late final _FinesseLocalizationsData$datePicker$it datePicker = _FinesseLocalizationsData$datePicker$it._(_root);
	@override late final _FinesseLocalizationsData$input$it input = _FinesseLocalizationsData$input$it._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$it keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$it._(_root);
	@override late final _FinesseLocalizationsData$dialog$it dialog = _FinesseLocalizationsData$dialog$it._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$it extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$it._(FinesseLocalizationsDataIt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ore';
	@override String get minutes => 'Minuti';
	@override String get seconds => 'Secondi';
	@override String get period => 'Periodo';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$it extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$it._(FinesseLocalizationsDataIt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Seleziona data';
}

// Path: input
class _FinesseLocalizationsData$input$it extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$it._(FinesseLocalizationsDataIt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Taglia';
	@override String get copy => 'Copia';
	@override String get paste => 'Incolla';
	@override String get selectAll => 'Seleziona tutto';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$it extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$it._(FinesseLocalizationsDataIt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Fine';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$it extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$it._(FinesseLocalizationsDataIt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Chiudi';
	@override String get dismiss => 'Ignora';
}

/// The flat map containing all translations for locale <it>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataIt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Ore',
			'timePicker.minutes' => 'Minuti',
			'timePicker.seconds' => 'Secondi',
			'timePicker.period' => 'Periodo',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Seleziona data',
			'input.cut' => 'Taglia',
			'input.copy' => 'Copia',
			'input.paste' => 'Incolla',
			'input.selectAll' => 'Seleziona tutto',
			'keyboardToolbar.done' => 'Fine',
			'dialog.close' => 'Chiudi',
			'dialog.dismiss' => 'Ignora',
			_ => null,
		};
	}
}
