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
class UnaLocalizationsDataBe extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataBe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.be,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <be>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataBe _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataBe $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataBe(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$be timePicker = _UnaLocalizationsData$timePicker$be._(_root);
	@override late final _UnaLocalizationsData$datePicker$be datePicker = _UnaLocalizationsData$datePicker$be._(_root);
	@override late final _UnaLocalizationsData$input$be input = _UnaLocalizationsData$input$be._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$be keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$be._(_root);
	@override late final _UnaLocalizationsData$dialog$be dialog = _UnaLocalizationsData$dialog$be._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$be extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$be._(UnaLocalizationsDataBe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Гадзіны';
	@override String get minutes => 'Хвіліны';
	@override String get seconds => 'Секунды';
	@override String get period => 'Перыяд';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$be extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$be._(UnaLocalizationsDataBe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Выберыце дату';
}

// Path: input
class _UnaLocalizationsData$input$be extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$be._(UnaLocalizationsDataBe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Выразаць';
	@override String get copy => 'Капіяваць';
	@override String get paste => 'Уставіць';
	@override String get selectAll => 'Вылучыць усё';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$be extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$be._(UnaLocalizationsDataBe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get done => 'Гатова';
}

// Path: dialog
class _UnaLocalizationsData$dialog$be extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$be._(UnaLocalizationsDataBe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get close => 'Закрыць';
	@override String get dismiss => 'Адхіліць';
}

/// The flat map containing all translations for locale <be>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataBe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Гадзіны',
			'timePicker.minutes' => 'Хвіліны',
			'timePicker.seconds' => 'Секунды',
			'timePicker.period' => 'Перыяд',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Выберыце дату',
			'input.cut' => 'Выразаць',
			'input.copy' => 'Капіяваць',
			'input.paste' => 'Уставіць',
			'input.selectAll' => 'Вылучыць усё',
			'keyboardToolbar.done' => 'Гатова',
			'dialog.close' => 'Закрыць',
			'dialog.dismiss' => 'Адхіліць',
			_ => null,
		};
	}
}
