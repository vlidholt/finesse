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
class FinesseLocalizationsDataKy extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataKy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ky,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ky>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataKy _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataKy $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataKy(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ky timePicker = _FinesseLocalizationsData$timePicker$ky._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ky datePicker = _FinesseLocalizationsData$datePicker$ky._(_root);
	@override late final _FinesseLocalizationsData$input$ky input = _FinesseLocalizationsData$input$ky._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ky keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ky._(_root);
	@override late final _FinesseLocalizationsData$dialog$ky dialog = _FinesseLocalizationsData$dialog$ky._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ky extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ky._(FinesseLocalizationsDataKy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Саат';
	@override String get minutes => 'Мүнөт';
	@override String get seconds => 'Секунд';
	@override String get period => 'Мезгил';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ky extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ky._(FinesseLocalizationsDataKy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Күндү тандаңыз';
}

// Path: input
class _FinesseLocalizationsData$input$ky extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ky._(FinesseLocalizationsDataKy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Кесүү';
	@override String get copy => 'Көчүрүү';
	@override String get paste => 'Чаптоо';
	@override String get selectAll => 'Баарын тандоо';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ky extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ky._(FinesseLocalizationsDataKy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get done => 'Даяр';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ky extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ky._(FinesseLocalizationsDataKy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get close => 'Жабуу';
	@override String get dismiss => 'Жабуу';
}

/// The flat map containing all translations for locale <ky>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataKy {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Саат',
			'timePicker.minutes' => 'Мүнөт',
			'timePicker.seconds' => 'Секунд',
			'timePicker.period' => 'Мезгил',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Күндү тандаңыз',
			'input.cut' => 'Кесүү',
			'input.copy' => 'Көчүрүү',
			'input.paste' => 'Чаптоо',
			'input.selectAll' => 'Баарын тандоо',
			'keyboardToolbar.done' => 'Даяр',
			'dialog.close' => 'Жабуу',
			'dialog.dismiss' => 'Жабуу',
			_ => null,
		};
	}
}
