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
class FinesseLocalizationsDataRu extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataRu _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataRu $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataRu(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ru timePicker = _FinesseLocalizationsData$timePicker$ru._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ru datePicker = _FinesseLocalizationsData$datePicker$ru._(_root);
	@override late final _FinesseLocalizationsData$input$ru input = _FinesseLocalizationsData$input$ru._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ru keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ru._(_root);
	@override late final _FinesseLocalizationsData$dialog$ru dialog = _FinesseLocalizationsData$dialog$ru._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ru extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ru._(FinesseLocalizationsDataRu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Часы';
	@override String get minutes => 'Минуты';
	@override String get seconds => 'Секунды';
	@override String get period => 'Период';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ru extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ru._(FinesseLocalizationsDataRu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Выбрать дату';
}

// Path: input
class _FinesseLocalizationsData$input$ru extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ru._(FinesseLocalizationsDataRu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Вырезать';
	@override String get copy => 'Копировать';
	@override String get paste => 'Вставить';
	@override String get selectAll => 'Выбрать всё';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ru extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ru._(FinesseLocalizationsDataRu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Готово';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ru extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ru._(FinesseLocalizationsDataRu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Закрыть';
	@override String get dismiss => 'Закрыть';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Часы',
			'timePicker.minutes' => 'Минуты',
			'timePicker.seconds' => 'Секунды',
			'timePicker.period' => 'Период',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Выбрать дату',
			'input.cut' => 'Вырезать',
			'input.copy' => 'Копировать',
			'input.paste' => 'Вставить',
			'input.selectAll' => 'Выбрать всё',
			'keyboardToolbar.done' => 'Готово',
			'dialog.close' => 'Закрыть',
			'dialog.dismiss' => 'Закрыть',
			_ => null,
		};
	}
}
