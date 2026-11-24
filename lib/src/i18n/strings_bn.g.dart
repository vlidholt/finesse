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
class FinesseLocalizationsDataBn extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataBn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.bn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bn>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataBn _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataBn $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataBn(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$bn timePicker = _FinesseLocalizationsData$timePicker$bn._(_root);
	@override late final _FinesseLocalizationsData$datePicker$bn datePicker = _FinesseLocalizationsData$datePicker$bn._(_root);
	@override late final _FinesseLocalizationsData$input$bn input = _FinesseLocalizationsData$input$bn._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$bn keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$bn._(_root);
	@override late final _FinesseLocalizationsData$dialog$bn dialog = _FinesseLocalizationsData$dialog$bn._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$bn extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$bn._(FinesseLocalizationsDataBn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ঘণ্টা';
	@override String get minutes => 'মিনিট';
	@override String get seconds => 'সেকেন্ড';
	@override String get period => 'সময়কাল';
	@override String get periodPlaceholder => 'পূর্বাহ্ন';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$bn extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$bn._(FinesseLocalizationsDataBn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'তারিখ বেছে নিন';
}

// Path: input
class _FinesseLocalizationsData$input$bn extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$bn._(FinesseLocalizationsDataBn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get cut => 'কাট';
	@override String get copy => 'কপি';
	@override String get paste => 'পেস্ট';
	@override String get selectAll => 'সব নির্বাচন করুন';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$bn extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$bn._(FinesseLocalizationsDataBn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get done => 'সম্পন্ন';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$bn extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$bn._(FinesseLocalizationsDataBn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get close => 'বন্ধ করুন';
	@override String get dismiss => 'খারিজ করুন';
}

/// The flat map containing all translations for locale <bn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataBn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ঘণ্টা',
			'timePicker.minutes' => 'মিনিট',
			'timePicker.seconds' => 'সেকেন্ড',
			'timePicker.period' => 'সময়কাল',
			'timePicker.periodPlaceholder' => 'পূর্বাহ্ন',
			'datePicker.selectDate' => 'তারিখ বেছে নিন',
			'input.cut' => 'কাট',
			'input.copy' => 'কপি',
			'input.paste' => 'পেস্ট',
			'input.selectAll' => 'সব নির্বাচন করুন',
			'keyboardToolbar.done' => 'সম্পন্ন',
			'dialog.close' => 'বন্ধ করুন',
			'dialog.dismiss' => 'খারিজ করুন',
			_ => null,
		};
	}
}
