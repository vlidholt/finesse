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
class FinesseLocalizationsDataSk extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataSk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.sk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sk>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataSk _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataSk $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataSk(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$sk timePicker = _FinesseLocalizationsData$timePicker$sk._(_root);
	@override late final _FinesseLocalizationsData$datePicker$sk datePicker = _FinesseLocalizationsData$datePicker$sk._(_root);
	@override late final _FinesseLocalizationsData$input$sk input = _FinesseLocalizationsData$input$sk._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$sk keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$sk._(_root);
	@override late final _FinesseLocalizationsData$dialog$sk dialog = _FinesseLocalizationsData$dialog$sk._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$sk extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$sk._(FinesseLocalizationsDataSk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Hodiny';
	@override String get minutes => 'Minúty';
	@override String get seconds => 'Sekundy';
	@override String get period => 'Obdobie';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$sk extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$sk._(FinesseLocalizationsDataSk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vybrať dátum';
}

// Path: input
class _FinesseLocalizationsData$input$sk extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$sk._(FinesseLocalizationsDataSk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Vystrihnúť';
	@override String get copy => 'Kopírovať';
	@override String get paste => 'Vložiť';
	@override String get selectAll => 'Vybrať všetko';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$sk extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$sk._(FinesseLocalizationsDataSk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get done => 'Hotovo';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$sk extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$sk._(FinesseLocalizationsDataSk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zavrieť';
	@override String get dismiss => 'Odmietnuť';
}

/// The flat map containing all translations for locale <sk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataSk {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Hodiny',
			'timePicker.minutes' => 'Minúty',
			'timePicker.seconds' => 'Sekundy',
			'timePicker.period' => 'Obdobie',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Vybrať dátum',
			'input.cut' => 'Vystrihnúť',
			'input.copy' => 'Kopírovať',
			'input.paste' => 'Vložiť',
			'input.selectAll' => 'Vybrať všetko',
			'keyboardToolbar.done' => 'Hotovo',
			'dialog.close' => 'Zavrieť',
			'dialog.dismiss' => 'Odmietnuť',
			_ => null,
		};
	}
}
