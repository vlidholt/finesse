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
class FinesseLocalizationsDataMy extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataMy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.my,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <my>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataMy _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataMy $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataMy(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$my timePicker = _FinesseLocalizationsData$timePicker$my._(_root);
	@override late final _FinesseLocalizationsData$datePicker$my datePicker = _FinesseLocalizationsData$datePicker$my._(_root);
	@override late final _FinesseLocalizationsData$input$my input = _FinesseLocalizationsData$input$my._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$my keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$my._(_root);
	@override late final _FinesseLocalizationsData$dialog$my dialog = _FinesseLocalizationsData$dialog$my._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$my extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$my._(FinesseLocalizationsDataMy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'နာရီ';
	@override String get minutes => 'မိနစ်';
	@override String get seconds => 'စက္ကန့်';
	@override String get period => 'အချိန်ကာလ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$my extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$my._(FinesseLocalizationsDataMy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ရက်စွဲရွေးချယ်ပါ';
}

// Path: input
class _FinesseLocalizationsData$input$my extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$my._(FinesseLocalizationsDataMy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ဖြတ်';
	@override String get copy => 'မိတ္တူကူး';
	@override String get paste => 'ကူးထည့်';
	@override String get selectAll => 'အားလုံးရွေးချယ်';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$my extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$my._(FinesseLocalizationsDataMy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get done => 'ပြီးပြီ';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$my extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$my._(FinesseLocalizationsDataMy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get close => 'ပိတ်ရန်';
	@override String get dismiss => 'ပယ်ရန်';
}

/// The flat map containing all translations for locale <my>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataMy {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'နာရီ',
			'timePicker.minutes' => 'မိနစ်',
			'timePicker.seconds' => 'စက္ကန့်',
			'timePicker.period' => 'အချိန်ကာလ',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'ရက်စွဲရွေးချယ်ပါ',
			'input.cut' => 'ဖြတ်',
			'input.copy' => 'မိတ္တူကူး',
			'input.paste' => 'ကူးထည့်',
			'input.selectAll' => 'အားလုံးရွေးချယ်',
			'keyboardToolbar.done' => 'ပြီးပြီ',
			'dialog.close' => 'ပိတ်ရန်',
			'dialog.dismiss' => 'ပယ်ရန်',
			_ => null,
		};
	}
}
