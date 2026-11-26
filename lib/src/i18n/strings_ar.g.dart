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
class UnaLocalizationsDataAr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataAr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ar,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ar>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataAr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataAr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataAr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ar timePicker = _UnaLocalizationsData$timePicker$ar._(_root);
	@override late final _UnaLocalizationsData$datePicker$ar datePicker = _UnaLocalizationsData$datePicker$ar._(_root);
	@override late final _UnaLocalizationsData$input$ar input = _UnaLocalizationsData$input$ar._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ar keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ar._(_root);
	@override late final _UnaLocalizationsData$dialog$ar dialog = _UnaLocalizationsData$dialog$ar._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ar extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ar._(UnaLocalizationsDataAr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ساعات';
	@override String get minutes => 'دقائق';
	@override String get seconds => 'ثواني';
	@override String get period => 'الفترة';
	@override String get periodPlaceholder => 'ص';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ar extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ar._(UnaLocalizationsDataAr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'اختر تاريخاً';
}

// Path: input
class _UnaLocalizationsData$input$ar extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ar._(UnaLocalizationsDataAr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'قص';
	@override String get copy => 'نسخ';
	@override String get paste => 'لصق';
	@override String get selectAll => 'تحديد الكل';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ar extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ar._(UnaLocalizationsDataAr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get done => 'تم';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ar extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ar._(UnaLocalizationsDataAr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAr _root; // ignore: unused_field

	// Translations
	@override String get close => 'الإغلاق';
	@override String get dismiss => 'رفض';
}

/// The flat map containing all translations for locale <ar>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataAr {
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
