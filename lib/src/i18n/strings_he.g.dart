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
class UnaLocalizationsDataHe extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataHe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.he,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <he>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataHe _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataHe $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataHe(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$he timePicker = _UnaLocalizationsData$timePicker$he._(_root);
	@override late final _UnaLocalizationsData$datePicker$he datePicker = _UnaLocalizationsData$datePicker$he._(_root);
	@override late final _UnaLocalizationsData$input$he input = _UnaLocalizationsData$input$he._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$he keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$he._(_root);
	@override late final _UnaLocalizationsData$dialog$he dialog = _UnaLocalizationsData$dialog$he._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$he extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$he._(UnaLocalizationsDataHe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'שעות';
	@override String get minutes => 'דקות';
	@override String get seconds => 'שניות';
	@override String get period => 'תקופה';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$he extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$he._(UnaLocalizationsDataHe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'בחר תאריך';
}

// Path: input
class _UnaLocalizationsData$input$he extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$he._(UnaLocalizationsDataHe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'גזור';
	@override String get copy => 'העתק';
	@override String get paste => 'הדבק';
	@override String get selectAll => 'בחר הכל';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$he extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$he._(UnaLocalizationsDataHe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get done => 'סיום';
}

// Path: dialog
class _UnaLocalizationsData$dialog$he extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$he._(UnaLocalizationsDataHe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHe _root; // ignore: unused_field

	// Translations
	@override String get close => 'סגירה';
	@override String get dismiss => 'סגירה';
}

/// The flat map containing all translations for locale <he>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataHe {
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
