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
class UnaLocalizationsDataSk extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataSk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.sk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sk>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataSk _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataSk $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataSk(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$sk timePicker = _UnaLocalizationsData$timePicker$sk._(_root);
	@override late final _UnaLocalizationsData$datePicker$sk datePicker = _UnaLocalizationsData$datePicker$sk._(_root);
	@override late final _UnaLocalizationsData$input$sk input = _UnaLocalizationsData$input$sk._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$sk keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$sk._(_root);
	@override late final _UnaLocalizationsData$dialog$sk dialog = _UnaLocalizationsData$dialog$sk._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$sk extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$sk._(UnaLocalizationsDataSk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Hodiny';
	@override String get minutes => 'Minúty';
	@override String get seconds => 'Sekundy';
	@override String get period => 'Obdobie';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$sk extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$sk._(UnaLocalizationsDataSk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vybrať dátum';
}

// Path: input
class _UnaLocalizationsData$input$sk extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$sk._(UnaLocalizationsDataSk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Vystrihnúť';
	@override String get copy => 'Kopírovať';
	@override String get paste => 'Vložiť';
	@override String get selectAll => 'Vybrať všetko';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$sk extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$sk._(UnaLocalizationsDataSk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get done => 'Hotovo';
}

// Path: dialog
class _UnaLocalizationsData$dialog$sk extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$sk._(UnaLocalizationsDataSk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSk _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zavrieť';
	@override String get dismiss => 'Odmietnuť';
}

/// The flat map containing all translations for locale <sk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataSk {
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
