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
class UnaLocalizationsDataIt extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataIt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <it>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataIt _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataIt $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataIt(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$it timePicker = _UnaLocalizationsData$timePicker$it._(_root);
	@override late final _UnaLocalizationsData$datePicker$it datePicker = _UnaLocalizationsData$datePicker$it._(_root);
	@override late final _UnaLocalizationsData$input$it input = _UnaLocalizationsData$input$it._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$it keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$it._(_root);
	@override late final _UnaLocalizationsData$dialog$it dialog = _UnaLocalizationsData$dialog$it._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$it extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$it._(UnaLocalizationsDataIt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ore';
	@override String get minutes => 'Minuti';
	@override String get seconds => 'Secondi';
	@override String get period => 'Periodo';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$it extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$it._(UnaLocalizationsDataIt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Seleziona data';
}

// Path: input
class _UnaLocalizationsData$input$it extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$it._(UnaLocalizationsDataIt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Taglia';
	@override String get copy => 'Copia';
	@override String get paste => 'Incolla';
	@override String get selectAll => 'Seleziona tutto';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$it extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$it._(UnaLocalizationsDataIt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Fine';
}

// Path: dialog
class _UnaLocalizationsData$dialog$it extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$it._(UnaLocalizationsDataIt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Chiudi';
	@override String get dismiss => 'Ignora';
}

/// The flat map containing all translations for locale <it>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataIt {
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
