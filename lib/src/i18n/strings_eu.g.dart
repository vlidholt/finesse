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
class FinesseLocalizationsDataEu extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataEu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.eu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <eu>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataEu _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataEu $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataEu(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$eu timePicker = _FinesseLocalizationsData$timePicker$eu._(_root);
	@override late final _FinesseLocalizationsData$datePicker$eu datePicker = _FinesseLocalizationsData$datePicker$eu._(_root);
	@override late final _FinesseLocalizationsData$input$eu input = _FinesseLocalizationsData$input$eu._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$eu keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$eu._(_root);
	@override late final _FinesseLocalizationsData$dialog$eu dialog = _FinesseLocalizationsData$dialog$eu._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$eu extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$eu._(FinesseLocalizationsDataEu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Orduak';
	@override String get minutes => 'Minutuak';
	@override String get seconds => 'Segundoak';
	@override String get period => 'Aldia';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$eu extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$eu._(FinesseLocalizationsDataEu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Hautatu data';
}

// Path: input
class _FinesseLocalizationsData$input$eu extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$eu._(FinesseLocalizationsDataEu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Ebaki';
	@override String get copy => 'Kopiatu';
	@override String get paste => 'Itsatsi';
	@override String get selectAll => 'Hautatu dena';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$eu extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$eu._(FinesseLocalizationsDataEu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Eginda';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$eu extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$eu._(FinesseLocalizationsDataEu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Itxi';
	@override String get dismiss => 'Baztertu';
}

/// The flat map containing all translations for locale <eu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataEu {
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
