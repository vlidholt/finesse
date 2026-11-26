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
class UnaLocalizationsDataAf extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataAf({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.af,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <af>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataAf _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataAf $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataAf(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$af timePicker = _UnaLocalizationsData$timePicker$af._(_root);
	@override late final _UnaLocalizationsData$datePicker$af datePicker = _UnaLocalizationsData$datePicker$af._(_root);
	@override late final _UnaLocalizationsData$input$af input = _UnaLocalizationsData$input$af._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$af keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$af._(_root);
	@override late final _UnaLocalizationsData$dialog$af dialog = _UnaLocalizationsData$dialog$af._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$af extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$af._(UnaLocalizationsDataAf root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ure';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Sekondes';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'VM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$af extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$af._(UnaLocalizationsDataAf root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Kies datum';
}

// Path: input
class _UnaLocalizationsData$input$af extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$af._(UnaLocalizationsDataAf root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Knip';
	@override String get copy => 'Kopieer';
	@override String get paste => 'Plak';
	@override String get selectAll => 'Kies alles';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$af extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$af._(UnaLocalizationsDataAf root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get done => 'Klaar';
}

// Path: dialog
class _UnaLocalizationsData$dialog$af extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$af._(UnaLocalizationsDataAf root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAf _root; // ignore: unused_field

	// Translations
	@override String get close => 'Maak toe';
	@override String get dismiss => 'Maak toe';
}

/// The flat map containing all translations for locale <af>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataAf {
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
