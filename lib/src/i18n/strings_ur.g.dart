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
class UnaLocalizationsDataUr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataUr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ur,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ur>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataUr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataUr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataUr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ur timePicker = _UnaLocalizationsData$timePicker$ur._(_root);
	@override late final _UnaLocalizationsData$datePicker$ur datePicker = _UnaLocalizationsData$datePicker$ur._(_root);
	@override late final _UnaLocalizationsData$input$ur input = _UnaLocalizationsData$input$ur._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ur keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ur._(_root);
	@override late final _UnaLocalizationsData$dialog$ur dialog = _UnaLocalizationsData$dialog$ur._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ur extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ur._(UnaLocalizationsDataUr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'گھنٹے';
	@override String get minutes => 'منٹ';
	@override String get seconds => 'سیکنڈ';
	@override String get period => 'وقت';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ur extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ur._(UnaLocalizationsDataUr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'تاریخ منتخب کریں';
}

// Path: input
class _UnaLocalizationsData$input$ur extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ur._(UnaLocalizationsDataUr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'کاٹیں';
	@override String get copy => 'کاپی کریں';
	@override String get paste => 'چسپاں کریں';
	@override String get selectAll => 'سب منتخب کریں';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ur extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ur._(UnaLocalizationsDataUr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get done => 'ہو گیا';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ur extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ur._(UnaLocalizationsDataUr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUr _root; // ignore: unused_field

	// Translations
	@override String get close => 'بند کریں';
	@override String get dismiss => 'برخاست کریں';
}

/// The flat map containing all translations for locale <ur>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataUr {
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
