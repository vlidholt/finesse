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
class FinesseLocalizationsDataBe extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataBe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.be,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <be>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataBe _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataBe $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataBe(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$be timePicker = _FinesseLocalizationsData$timePicker$be._(_root);
	@override late final _FinesseLocalizationsData$datePicker$be datePicker = _FinesseLocalizationsData$datePicker$be._(_root);
	@override late final _FinesseLocalizationsData$input$be input = _FinesseLocalizationsData$input$be._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$be keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$be._(_root);
	@override late final _FinesseLocalizationsData$dialog$be dialog = _FinesseLocalizationsData$dialog$be._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$be extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$be._(FinesseLocalizationsDataBe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Гадзіны';
	@override String get minutes => 'Хвіліны';
	@override String get seconds => 'Секунды';
	@override String get period => 'Перыяд';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$be extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$be._(FinesseLocalizationsDataBe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Выберыце дату';
}

// Path: input
class _FinesseLocalizationsData$input$be extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$be._(FinesseLocalizationsDataBe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Выразаць';
	@override String get copy => 'Капіяваць';
	@override String get paste => 'Уставіць';
	@override String get selectAll => 'Вылучыць усё';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$be extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$be._(FinesseLocalizationsDataBe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get done => 'Гатова';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$be extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$be._(FinesseLocalizationsDataBe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBe _root; // ignore: unused_field

	// Translations
	@override String get close => 'Закрыць';
	@override String get dismiss => 'Адхіліць';
}

/// The flat map containing all translations for locale <be>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataBe {
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
