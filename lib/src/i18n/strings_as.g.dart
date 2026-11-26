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
class UnaLocalizationsDataAs extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataAs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.as,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <as>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataAs _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataAs $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataAs(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$as timePicker = _UnaLocalizationsData$timePicker$as._(_root);
	@override late final _UnaLocalizationsData$datePicker$as datePicker = _UnaLocalizationsData$datePicker$as._(_root);
	@override late final _UnaLocalizationsData$input$as input = _UnaLocalizationsData$input$as._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$as keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$as._(_root);
	@override late final _UnaLocalizationsData$dialog$as dialog = _UnaLocalizationsData$dialog$as._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$as extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$as._(UnaLocalizationsDataAs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ঘণ্টা';
	@override String get minutes => 'মিনিট';
	@override String get seconds => 'ছেকেণ্ড';
	@override String get period => 'সময়কাল';
	@override String get periodPlaceholder => 'পূৰ্বাহ্ন';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$as extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$as._(UnaLocalizationsDataAs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'তাৰিখ বাছক';
}

// Path: input
class _UnaLocalizationsData$input$as extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$as._(UnaLocalizationsDataAs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'কাট';
	@override String get copy => 'কপি';
	@override String get paste => 'পেষ্ট';
	@override String get selectAll => 'সকলো বাছক';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$as extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$as._(UnaLocalizationsDataAs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get done => 'সম্পন্ন';
}

// Path: dialog
class _UnaLocalizationsData$dialog$as extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$as._(UnaLocalizationsDataAs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get close => 'বন্ধ কৰক';
	@override String get dismiss => 'অগ্ৰাহ্য কৰক';
}

/// The flat map containing all translations for locale <as>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataAs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ঘণ্টা',
			'timePicker.minutes' => 'মিনিট',
			'timePicker.seconds' => 'ছেকেণ্ড',
			'timePicker.period' => 'সময়কাল',
			'timePicker.periodPlaceholder' => 'পূৰ্বাহ্ন',
			'datePicker.selectDate' => 'তাৰিখ বাছক',
			'input.cut' => 'কাট',
			'input.copy' => 'কপি',
			'input.paste' => 'পেষ্ট',
			'input.selectAll' => 'সকলো বাছক',
			'keyboardToolbar.done' => 'সম্পন্ন',
			'dialog.close' => 'বন্ধ কৰক',
			'dialog.dismiss' => 'অগ্ৰাহ্য কৰক',
			_ => null,
		};
	}
}
