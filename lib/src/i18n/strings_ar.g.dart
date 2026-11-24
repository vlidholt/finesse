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
class FinesseLocalizationsDataAr extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataAr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ar,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ar>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataAr _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataAr $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataAr(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ar timePicker = _FinesseLocalizationsData$timePicker$ar._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ar datePicker = _FinesseLocalizationsData$datePicker$ar._(_root);
	@override late final _FinesseLocalizationsData$input$ar input = _FinesseLocalizationsData$input$ar._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ar keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ar._(_root);
	@override late final _FinesseLocalizationsData$dialog$ar dialog = _FinesseLocalizationsData$dialog$ar._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ar extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ar._(FinesseLocalizationsDataAr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ساعات';
	@override String get minutes => 'دقائق';
	@override String get seconds => 'ثواني';
	@override String get period => 'الفترة';
	@override String get periodPlaceholder => 'ص';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ar extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ar._(FinesseLocalizationsDataAr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'اختر تاريخاً';
}

// Path: input
class _FinesseLocalizationsData$input$ar extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ar._(FinesseLocalizationsDataAr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'قص';
	@override String get copy => 'نسخ';
	@override String get paste => 'لصق';
	@override String get selectAll => 'تحديد الكل';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ar extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ar._(FinesseLocalizationsDataAr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get done => 'تم';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ar extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ar._(FinesseLocalizationsDataAr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get close => 'الإغلاق';
	@override String get dismiss => 'رفض';
}

/// The flat map containing all translations for locale <ar>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataAr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ساعات',
			'timePicker.minutes' => 'دقائق',
			'timePicker.seconds' => 'ثواني',
			'timePicker.period' => 'الفترة',
			'timePicker.periodPlaceholder' => 'ص',
			'datePicker.selectDate' => 'اختر تاريخاً',
			'input.cut' => 'قص',
			'input.copy' => 'نسخ',
			'input.paste' => 'لصق',
			'input.selectAll' => 'تحديد الكل',
			'keyboardToolbar.done' => 'تم',
			'dialog.close' => 'الإغلاق',
			'dialog.dismiss' => 'رفض',
			_ => null,
		};
	}
}
