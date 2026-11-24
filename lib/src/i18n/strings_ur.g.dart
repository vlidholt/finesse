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
class FinesseLocalizationsDataUr extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataUr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ur,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ur>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataUr _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataUr $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataUr(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ur timePicker = _FinesseLocalizationsData$timePicker$ur._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ur datePicker = _FinesseLocalizationsData$datePicker$ur._(_root);
	@override late final _FinesseLocalizationsData$input$ur input = _FinesseLocalizationsData$input$ur._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ur keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ur._(_root);
	@override late final _FinesseLocalizationsData$dialog$ur dialog = _FinesseLocalizationsData$dialog$ur._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ur extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ur._(FinesseLocalizationsDataUr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'گھنٹے';
	@override String get minutes => 'منٹ';
	@override String get seconds => 'سیکنڈ';
	@override String get period => 'وقت';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ur extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ur._(FinesseLocalizationsDataUr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'تاریخ منتخب کریں';
}

// Path: input
class _FinesseLocalizationsData$input$ur extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ur._(FinesseLocalizationsDataUr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'کاٹیں';
	@override String get copy => 'کاپی کریں';
	@override String get paste => 'چسپاں کریں';
	@override String get selectAll => 'سب منتخب کریں';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ur extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ur._(FinesseLocalizationsDataUr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get done => 'ہو گیا';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ur extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ur._(FinesseLocalizationsDataUr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get close => 'بند کریں';
	@override String get dismiss => 'برخاست کریں';
}

/// The flat map containing all translations for locale <ur>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataUr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'گھنٹے',
			'timePicker.minutes' => 'منٹ',
			'timePicker.seconds' => 'سیکنڈ',
			'timePicker.period' => 'وقت',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'تاریخ منتخب کریں',
			'input.cut' => 'کاٹیں',
			'input.copy' => 'کاپی کریں',
			'input.paste' => 'چسپاں کریں',
			'input.selectAll' => 'سب منتخب کریں',
			'keyboardToolbar.done' => 'ہو گیا',
			'dialog.close' => 'بند کریں',
			'dialog.dismiss' => 'برخاست کریں',
			_ => null,
		};
	}
}
