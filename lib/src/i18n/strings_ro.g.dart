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
class FinesseLocalizationsDataRo extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataRo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ro,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ro>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataRo _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataRo $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataRo(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ro timePicker = _FinesseLocalizationsData$timePicker$ro._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ro datePicker = _FinesseLocalizationsData$datePicker$ro._(_root);
	@override late final _FinesseLocalizationsData$input$ro input = _FinesseLocalizationsData$input$ro._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ro keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ro._(_root);
	@override late final _FinesseLocalizationsData$dialog$ro dialog = _FinesseLocalizationsData$dialog$ro._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ro extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ro._(FinesseLocalizationsDataRo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ore';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Secunde';
	@override String get period => 'Perioadă';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ro extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ro._(FinesseLocalizationsDataRo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Selectați data';
}

// Path: input
class _FinesseLocalizationsData$input$ro extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ro._(FinesseLocalizationsDataRo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Taie';
	@override String get copy => 'Copiază';
	@override String get paste => 'Lipește';
	@override String get selectAll => 'Selectează tot';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ro extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ro._(FinesseLocalizationsDataRo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get done => 'Terminat';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ro extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ro._(FinesseLocalizationsDataRo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get close => 'Închideți';
	@override String get dismiss => 'Închideți';
}

/// The flat map containing all translations for locale <ro>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataRo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Ore',
			'timePicker.minutes' => 'Minute',
			'timePicker.seconds' => 'Secunde',
			'timePicker.period' => 'Perioadă',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Selectați data',
			'input.cut' => 'Taie',
			'input.copy' => 'Copiază',
			'input.paste' => 'Lipește',
			'input.selectAll' => 'Selectează tot',
			'keyboardToolbar.done' => 'Terminat',
			'dialog.close' => 'Închideți',
			'dialog.dismiss' => 'Închideți',
			_ => null,
		};
	}
}
