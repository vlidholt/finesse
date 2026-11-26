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
class UnaLocalizationsDataRu extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataRu _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataRu $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataRu(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ru timePicker = _UnaLocalizationsData$timePicker$ru._(_root);
	@override late final _UnaLocalizationsData$datePicker$ru datePicker = _UnaLocalizationsData$datePicker$ru._(_root);
	@override late final _UnaLocalizationsData$input$ru input = _UnaLocalizationsData$input$ru._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ru keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ru._(_root);
	@override late final _UnaLocalizationsData$dialog$ru dialog = _UnaLocalizationsData$dialog$ru._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ru extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ru._(UnaLocalizationsDataRu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Часы';
	@override String get minutes => 'Минуты';
	@override String get seconds => 'Секунды';
	@override String get period => 'Период';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ru extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ru._(UnaLocalizationsDataRu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Выбрать дату';
}

// Path: input
class _UnaLocalizationsData$input$ru extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ru._(UnaLocalizationsDataRu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Вырезать';
	@override String get copy => 'Копировать';
	@override String get paste => 'Вставить';
	@override String get selectAll => 'Выбрать всё';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ru extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ru._(UnaLocalizationsDataRu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Готово';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ru extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ru._(UnaLocalizationsDataRu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Закрыть';
	@override String get dismiss => 'Закрыть';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataRu {
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
