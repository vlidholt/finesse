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
class UnaLocalizationsDataKy extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataKy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ky,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ky>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataKy _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataKy $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataKy(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ky timePicker = _UnaLocalizationsData$timePicker$ky._(_root);
	@override late final _UnaLocalizationsData$datePicker$ky datePicker = _UnaLocalizationsData$datePicker$ky._(_root);
	@override late final _UnaLocalizationsData$input$ky input = _UnaLocalizationsData$input$ky._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ky keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ky._(_root);
	@override late final _UnaLocalizationsData$dialog$ky dialog = _UnaLocalizationsData$dialog$ky._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ky extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ky._(UnaLocalizationsDataKy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Саат';
	@override String get minutes => 'Мүнөт';
	@override String get seconds => 'Секунд';
	@override String get period => 'Мезгил';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ky extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ky._(UnaLocalizationsDataKy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Күндү тандаңыз';
}

// Path: input
class _UnaLocalizationsData$input$ky extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ky._(UnaLocalizationsDataKy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Кесүү';
	@override String get copy => 'Көчүрүү';
	@override String get paste => 'Чаптоо';
	@override String get selectAll => 'Баарын тандоо';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ky extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ky._(UnaLocalizationsDataKy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get done => 'Даяр';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ky extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ky._(UnaLocalizationsDataKy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKy _root; // ignore: unused_field

	// Translations
	@override String get close => 'Жабуу';
	@override String get dismiss => 'Жабуу';
}

/// The flat map containing all translations for locale <ky>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataKy {
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
