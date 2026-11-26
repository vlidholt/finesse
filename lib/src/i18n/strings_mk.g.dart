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
class UnaLocalizationsDataMk extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataMk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.mk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <mk>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataMk _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataMk $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataMk(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$mk timePicker = _UnaLocalizationsData$timePicker$mk._(_root);
	@override late final _UnaLocalizationsData$datePicker$mk datePicker = _UnaLocalizationsData$datePicker$mk._(_root);
	@override late final _UnaLocalizationsData$input$mk input = _UnaLocalizationsData$input$mk._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$mk keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$mk._(_root);
	@override late final _UnaLocalizationsData$dialog$mk dialog = _UnaLocalizationsData$dialog$mk._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$mk extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$mk._(UnaLocalizationsDataMk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Часови';
	@override String get minutes => 'Минути';
	@override String get seconds => 'Секунди';
	@override String get period => 'Период';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$mk extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$mk._(UnaLocalizationsDataMk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Изберете датум';
}

// Path: input
class _UnaLocalizationsData$input$mk extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$mk._(UnaLocalizationsDataMk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Исечи';
	@override String get copy => 'Копирај';
	@override String get paste => 'Залепи';
	@override String get selectAll => 'Избери сè';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$mk extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$mk._(UnaLocalizationsDataMk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get done => 'Готово';
}

// Path: dialog
class _UnaLocalizationsData$dialog$mk extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$mk._(UnaLocalizationsDataMk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMk _root; // ignore: unused_field

	// Translations
	@override String get close => 'Затвори';
	@override String get dismiss => 'Отфрли';
}

/// The flat map containing all translations for locale <mk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataMk {
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
