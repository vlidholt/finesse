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
class FinesseLocalizationsDataAs extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataAs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.as,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <as>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataAs _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataAs $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataAs(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$as timePicker = _FinesseLocalizationsData$timePicker$as._(_root);
	@override late final _FinesseLocalizationsData$datePicker$as datePicker = _FinesseLocalizationsData$datePicker$as._(_root);
	@override late final _FinesseLocalizationsData$input$as input = _FinesseLocalizationsData$input$as._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$as keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$as._(_root);
	@override late final _FinesseLocalizationsData$dialog$as dialog = _FinesseLocalizationsData$dialog$as._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$as extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$as._(FinesseLocalizationsDataAs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ঘণ্টা';
	@override String get minutes => 'মিনিট';
	@override String get seconds => 'ছেকেণ্ড';
	@override String get period => 'সময়কাল';
	@override String get periodPlaceholder => 'পূৰ্বাহ্ন';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$as extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$as._(FinesseLocalizationsDataAs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'তাৰিখ বাছক';
}

// Path: input
class _FinesseLocalizationsData$input$as extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$as._(FinesseLocalizationsDataAs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'কাট';
	@override String get copy => 'কপি';
	@override String get paste => 'পেষ্ট';
	@override String get selectAll => 'সকলো বাছক';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$as extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$as._(FinesseLocalizationsDataAs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get done => 'সম্পন্ন';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$as extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$as._(FinesseLocalizationsDataAs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAs _root; // ignore: unused_field

	// Translations
	@override String get close => 'বন্ধ কৰক';
	@override String get dismiss => 'অগ্ৰাহ্য কৰক';
}

/// The flat map containing all translations for locale <as>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataAs {
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
