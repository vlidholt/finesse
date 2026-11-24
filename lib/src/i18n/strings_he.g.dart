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
class FinesseLocalizationsDataHe extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataHe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.he,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <he>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataHe _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataHe $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataHe(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$he timePicker = _FinesseLocalizationsData$timePicker$he._(_root);
	@override late final _FinesseLocalizationsData$datePicker$he datePicker = _FinesseLocalizationsData$datePicker$he._(_root);
	@override late final _FinesseLocalizationsData$input$he input = _FinesseLocalizationsData$input$he._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$he keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$he._(_root);
	@override late final _FinesseLocalizationsData$dialog$he dialog = _FinesseLocalizationsData$dialog$he._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$he extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$he._(FinesseLocalizationsDataHe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'שעות';
	@override String get minutes => 'דקות';
	@override String get seconds => 'שניות';
	@override String get period => 'תקופה';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$he extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$he._(FinesseLocalizationsDataHe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'בחר תאריך';
}

// Path: input
class _FinesseLocalizationsData$input$he extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$he._(FinesseLocalizationsDataHe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'גזור';
	@override String get copy => 'העתק';
	@override String get paste => 'הדבק';
	@override String get selectAll => 'בחר הכל';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$he extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$he._(FinesseLocalizationsDataHe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get done => 'סיום';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$he extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$he._(FinesseLocalizationsDataHe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get close => 'סגירה';
	@override String get dismiss => 'סגירה';
}

/// The flat map containing all translations for locale <he>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataHe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'שעות',
			'timePicker.minutes' => 'דקות',
			'timePicker.seconds' => 'שניות',
			'timePicker.period' => 'תקופה',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'בחר תאריך',
			'input.cut' => 'גזור',
			'input.copy' => 'העתק',
			'input.paste' => 'הדבק',
			'input.selectAll' => 'בחר הכל',
			'keyboardToolbar.done' => 'סיום',
			'dialog.close' => 'סגירה',
			'dialog.dismiss' => 'סגירה',
			_ => null,
		};
	}
}
