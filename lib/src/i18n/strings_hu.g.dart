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
class FinesseLocalizationsDataHu extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataHu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.hu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hu>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataHu _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataHu $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataHu(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$hu timePicker = _FinesseLocalizationsData$timePicker$hu._(_root);
	@override late final _FinesseLocalizationsData$datePicker$hu datePicker = _FinesseLocalizationsData$datePicker$hu._(_root);
	@override late final _FinesseLocalizationsData$input$hu input = _FinesseLocalizationsData$input$hu._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$hu keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$hu._(_root);
	@override late final _FinesseLocalizationsData$dialog$hu dialog = _FinesseLocalizationsData$dialog$hu._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$hu extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$hu._(FinesseLocalizationsDataHu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Óra';
	@override String get minutes => 'Perc';
	@override String get seconds => 'Másodperc';
	@override String get period => 'Időszak';
	@override String get periodPlaceholder => 'DE';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$hu extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$hu._(FinesseLocalizationsDataHu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Válasszon dátumot';
}

// Path: input
class _FinesseLocalizationsData$input$hu extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$hu._(FinesseLocalizationsDataHu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kivágás';
	@override String get copy => 'Másolás';
	@override String get paste => 'Beillesztés';
	@override String get selectAll => 'Összes kijelölése';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$hu extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$hu._(FinesseLocalizationsDataHu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Kész';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$hu extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$hu._(FinesseLocalizationsDataHu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Bezárás';
	@override String get dismiss => 'Elvetés';
}

/// The flat map containing all translations for locale <hu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataHu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Óra',
			'timePicker.minutes' => 'Perc',
			'timePicker.seconds' => 'Másodperc',
			'timePicker.period' => 'Időszak',
			'timePicker.periodPlaceholder' => 'DE',
			'datePicker.selectDate' => 'Válasszon dátumot',
			'input.cut' => 'Kivágás',
			'input.copy' => 'Másolás',
			'input.paste' => 'Beillesztés',
			'input.selectAll' => 'Összes kijelölése',
			'keyboardToolbar.done' => 'Kész',
			'dialog.close' => 'Bezárás',
			'dialog.dismiss' => 'Elvetés',
			_ => null,
		};
	}
}
