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
class FinesseLocalizationsDataMk extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataMk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.mk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <mk>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataMk _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataMk $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataMk(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$mk timePicker = _FinesseLocalizationsData$timePicker$mk._(_root);
	@override late final _FinesseLocalizationsData$datePicker$mk datePicker = _FinesseLocalizationsData$datePicker$mk._(_root);
	@override late final _FinesseLocalizationsData$input$mk input = _FinesseLocalizationsData$input$mk._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$mk keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$mk._(_root);
	@override late final _FinesseLocalizationsData$dialog$mk dialog = _FinesseLocalizationsData$dialog$mk._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$mk extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$mk._(FinesseLocalizationsDataMk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Часови';
	@override String get minutes => 'Минути';
	@override String get seconds => 'Секунди';
	@override String get period => 'Период';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$mk extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$mk._(FinesseLocalizationsDataMk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Изберете датум';
}

// Path: input
class _FinesseLocalizationsData$input$mk extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$mk._(FinesseLocalizationsDataMk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Исечи';
	@override String get copy => 'Копирај';
	@override String get paste => 'Залепи';
	@override String get selectAll => 'Избери сè';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$mk extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$mk._(FinesseLocalizationsDataMk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get done => 'Готово';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$mk extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$mk._(FinesseLocalizationsDataMk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get close => 'Затвори';
	@override String get dismiss => 'Отфрли';
}

/// The flat map containing all translations for locale <mk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataMk {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Часови',
			'timePicker.minutes' => 'Минути',
			'timePicker.seconds' => 'Секунди',
			'timePicker.period' => 'Период',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Изберете датум',
			'input.cut' => 'Исечи',
			'input.copy' => 'Копирај',
			'input.paste' => 'Залепи',
			'input.selectAll' => 'Избери сè',
			'keyboardToolbar.done' => 'Готово',
			'dialog.close' => 'Затвори',
			'dialog.dismiss' => 'Отфрли',
			_ => null,
		};
	}
}
