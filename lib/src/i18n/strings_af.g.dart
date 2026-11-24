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
class FinesseLocalizationsDataAf extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataAf({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.af,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <af>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataAf _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataAf $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataAf(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$af timePicker = _FinesseLocalizationsData$timePicker$af._(_root);
	@override late final _FinesseLocalizationsData$datePicker$af datePicker = _FinesseLocalizationsData$datePicker$af._(_root);
	@override late final _FinesseLocalizationsData$input$af input = _FinesseLocalizationsData$input$af._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$af keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$af._(_root);
	@override late final _FinesseLocalizationsData$dialog$af dialog = _FinesseLocalizationsData$dialog$af._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$af extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$af._(FinesseLocalizationsDataAf root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ure';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Sekondes';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'VM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$af extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$af._(FinesseLocalizationsDataAf root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Kies datum';
}

// Path: input
class _FinesseLocalizationsData$input$af extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$af._(FinesseLocalizationsDataAf root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Knip';
	@override String get copy => 'Kopieer';
	@override String get paste => 'Plak';
	@override String get selectAll => 'Kies alles';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$af extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$af._(FinesseLocalizationsDataAf root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get done => 'Klaar';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$af extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$af._(FinesseLocalizationsDataAf root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get close => 'Maak toe';
	@override String get dismiss => 'Maak toe';
}

/// The flat map containing all translations for locale <af>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataAf {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Ure',
			'timePicker.minutes' => 'Minute',
			'timePicker.seconds' => 'Sekondes',
			'timePicker.period' => 'Periode',
			'timePicker.periodPlaceholder' => 'VM',
			'datePicker.selectDate' => 'Kies datum',
			'input.cut' => 'Knip',
			'input.copy' => 'Kopieer',
			'input.paste' => 'Plak',
			'input.selectAll' => 'Kies alles',
			'keyboardToolbar.done' => 'Klaar',
			'dialog.close' => 'Maak toe',
			'dialog.dismiss' => 'Maak toe',
			_ => null,
		};
	}
}
