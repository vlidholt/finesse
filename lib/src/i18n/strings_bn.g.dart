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
class UnaLocalizationsDataBn extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataBn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.bn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bn>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataBn _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataBn $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataBn(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$bn timePicker = _UnaLocalizationsData$timePicker$bn._(_root);
	@override late final _UnaLocalizationsData$datePicker$bn datePicker = _UnaLocalizationsData$datePicker$bn._(_root);
	@override late final _UnaLocalizationsData$input$bn input = _UnaLocalizationsData$input$bn._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$bn keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$bn._(_root);
	@override late final _UnaLocalizationsData$dialog$bn dialog = _UnaLocalizationsData$dialog$bn._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$bn extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$bn._(UnaLocalizationsDataBn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ঘণ্টা';
	@override String get minutes => 'মিনিট';
	@override String get seconds => 'সেকেন্ড';
	@override String get period => 'সময়কাল';
	@override String get periodPlaceholder => 'পূর্বাহ্ন';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$bn extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$bn._(UnaLocalizationsDataBn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'তারিখ বেছে নিন';
}

// Path: input
class _UnaLocalizationsData$input$bn extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$bn._(UnaLocalizationsDataBn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get cut => 'কাট';
	@override String get copy => 'কপি';
	@override String get paste => 'পেস্ট';
	@override String get selectAll => 'সব নির্বাচন করুন';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$bn extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$bn._(UnaLocalizationsDataBn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get done => 'সম্পন্ন';
}

// Path: dialog
class _UnaLocalizationsData$dialog$bn extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$bn._(UnaLocalizationsDataBn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBn _root; // ignore: unused_field

	// Translations
	@override String get close => 'বন্ধ করুন';
	@override String get dismiss => 'খারিজ করুন';
}

/// The flat map containing all translations for locale <bn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataBn {
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
