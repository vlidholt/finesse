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
class UnaLocalizationsDataEu extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataEu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.eu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <eu>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataEu _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataEu $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataEu(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$eu timePicker = _UnaLocalizationsData$timePicker$eu._(_root);
	@override late final _UnaLocalizationsData$datePicker$eu datePicker = _UnaLocalizationsData$datePicker$eu._(_root);
	@override late final _UnaLocalizationsData$input$eu input = _UnaLocalizationsData$input$eu._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$eu keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$eu._(_root);
	@override late final _UnaLocalizationsData$dialog$eu dialog = _UnaLocalizationsData$dialog$eu._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$eu extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$eu._(UnaLocalizationsDataEu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Orduak';
	@override String get minutes => 'Minutuak';
	@override String get seconds => 'Segundoak';
	@override String get period => 'Aldia';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$eu extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$eu._(UnaLocalizationsDataEu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Hautatu data';
}

// Path: input
class _UnaLocalizationsData$input$eu extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$eu._(UnaLocalizationsDataEu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Ebaki';
	@override String get copy => 'Kopiatu';
	@override String get paste => 'Itsatsi';
	@override String get selectAll => 'Hautatu dena';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$eu extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$eu._(UnaLocalizationsDataEu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Eginda';
}

// Path: dialog
class _UnaLocalizationsData$dialog$eu extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$eu._(UnaLocalizationsDataEu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Itxi';
	@override String get dismiss => 'Baztertu';
}

/// The flat map containing all translations for locale <eu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataEu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Orduak',
			'timePicker.minutes' => 'Minutuak',
			'timePicker.seconds' => 'Segundoak',
			'timePicker.period' => 'Aldia',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Hautatu data',
			'input.cut' => 'Ebaki',
			'input.copy' => 'Kopiatu',
			'input.paste' => 'Itsatsi',
			'input.selectAll' => 'Hautatu dena',
			'keyboardToolbar.done' => 'Eginda',
			'dialog.close' => 'Itxi',
			'dialog.dismiss' => 'Baztertu',
			_ => null,
		};
	}
}
