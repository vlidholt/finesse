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
class UnaLocalizationsDataHu extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataHu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.hu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hu>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataHu _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataHu $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataHu(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$hu timePicker = _UnaLocalizationsData$timePicker$hu._(_root);
	@override late final _UnaLocalizationsData$datePicker$hu datePicker = _UnaLocalizationsData$datePicker$hu._(_root);
	@override late final _UnaLocalizationsData$input$hu input = _UnaLocalizationsData$input$hu._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$hu keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$hu._(_root);
	@override late final _UnaLocalizationsData$dialog$hu dialog = _UnaLocalizationsData$dialog$hu._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$hu extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$hu._(UnaLocalizationsDataHu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Óra';
	@override String get minutes => 'Perc';
	@override String get seconds => 'Másodperc';
	@override String get period => 'Időszak';
	@override String get periodPlaceholder => 'DE';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$hu extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$hu._(UnaLocalizationsDataHu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Válasszon dátumot';
}

// Path: input
class _UnaLocalizationsData$input$hu extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$hu._(UnaLocalizationsDataHu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kivágás';
	@override String get copy => 'Másolás';
	@override String get paste => 'Beillesztés';
	@override String get selectAll => 'Összes kijelölése';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$hu extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$hu._(UnaLocalizationsDataHu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Kész';
}

// Path: dialog
class _UnaLocalizationsData$dialog$hu extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$hu._(UnaLocalizationsDataHu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Bezárás';
	@override String get dismiss => 'Elvetés';
}

/// The flat map containing all translations for locale <hu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataHu {
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
