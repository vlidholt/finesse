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
class FinesseLocalizationsDataUk extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataUk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.uk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uk>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataUk _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataUk $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataUk(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$uk timePicker = _FinesseLocalizationsData$timePicker$uk._(_root);
	@override late final _FinesseLocalizationsData$datePicker$uk datePicker = _FinesseLocalizationsData$datePicker$uk._(_root);
	@override late final _FinesseLocalizationsData$input$uk input = _FinesseLocalizationsData$input$uk._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$uk keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$uk._(_root);
	@override late final _FinesseLocalizationsData$dialog$uk dialog = _FinesseLocalizationsData$dialog$uk._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$uk extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$uk._(FinesseLocalizationsDataUk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUk _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Години';
	@override String get minutes => 'Хвилини';
	@override String get seconds => 'Секунди';
	@override String get period => 'Період';
	@override String get periodPlaceholder => 'ДП';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$uk extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$uk._(FinesseLocalizationsDataUk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUk _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Виберіть дату';
}

// Path: input
class _FinesseLocalizationsData$input$uk extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$uk._(FinesseLocalizationsDataUk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUk _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Вирізати';
	@override String get copy => 'Копіювати';
	@override String get paste => 'Вставити';
	@override String get selectAll => 'Вибрати все';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$uk extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$uk._(FinesseLocalizationsDataUk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUk _root; // ignore: unused_field

	// Translations
	@override String get done => 'Готово';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$uk extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$uk._(FinesseLocalizationsDataUk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUk _root; // ignore: unused_field

	// Translations
	@override String get close => 'Закрити';
	@override String get dismiss => 'Закрити';
}

/// The flat map containing all translations for locale <uk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataUk {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Години',
			'timePicker.minutes' => 'Хвилини',
			'timePicker.seconds' => 'Секунди',
			'timePicker.period' => 'Період',
			'timePicker.periodPlaceholder' => 'ДП',
			'datePicker.selectDate' => 'Виберіть дату',
			'input.cut' => 'Вирізати',
			'input.copy' => 'Копіювати',
			'input.paste' => 'Вставити',
			'input.selectAll' => 'Вибрати все',
			'keyboardToolbar.done' => 'Готово',
			'dialog.close' => 'Закрити',
			'dialog.dismiss' => 'Закрити',
			_ => null,
		};
	}
}
