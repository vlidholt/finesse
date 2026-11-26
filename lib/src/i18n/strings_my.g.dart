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
class UnaLocalizationsDataMy extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataMy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.my,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <my>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataMy _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataMy $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataMy(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$my timePicker = _UnaLocalizationsData$timePicker$my._(_root);
	@override late final _UnaLocalizationsData$datePicker$my datePicker = _UnaLocalizationsData$datePicker$my._(_root);
	@override late final _UnaLocalizationsData$input$my input = _UnaLocalizationsData$input$my._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$my keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$my._(_root);
	@override late final _UnaLocalizationsData$dialog$my dialog = _UnaLocalizationsData$dialog$my._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$my extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$my._(UnaLocalizationsDataMy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'နာရီ';
	@override String get minutes => 'မိနစ်';
	@override String get seconds => 'စက္ကန့်';
	@override String get period => 'အချိန်ကာလ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$my extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$my._(UnaLocalizationsDataMy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ရက်စွဲရွေးချယ်ပါ';
}

// Path: input
class _UnaLocalizationsData$input$my extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$my._(UnaLocalizationsDataMy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ဖြတ်';
	@override String get copy => 'မိတ္တူကူး';
	@override String get paste => 'ကူးထည့်';
	@override String get selectAll => 'အားလုံးရွေးချယ်';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$my extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$my._(UnaLocalizationsDataMy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get done => 'ပြီးပြီ';
}

// Path: dialog
class _UnaLocalizationsData$dialog$my extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$my._(UnaLocalizationsDataMy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMy _root; // ignore: unused_field

	// Translations
	@override String get close => 'ပိတ်ရန်';
	@override String get dismiss => 'ပယ်ရန်';
}

/// The flat map containing all translations for locale <my>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataMy {
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
