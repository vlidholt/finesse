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
class FinesseLocalizationsDataPa extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataPa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.pa,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pa>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataPa _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataPa $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataPa(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$pa timePicker = _FinesseLocalizationsData$timePicker$pa._(_root);
	@override late final _FinesseLocalizationsData$datePicker$pa datePicker = _FinesseLocalizationsData$datePicker$pa._(_root);
	@override late final _FinesseLocalizationsData$input$pa input = _FinesseLocalizationsData$input$pa._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$pa keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$pa._(_root);
	@override late final _FinesseLocalizationsData$dialog$pa dialog = _FinesseLocalizationsData$dialog$pa._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$pa extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$pa._(FinesseLocalizationsDataPa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ਘੰਟੇ';
	@override String get minutes => 'ਮਿੰਟ';
	@override String get seconds => 'ਸਕਿੰਟ';
	@override String get period => 'ਸਮਾਂ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$pa extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$pa._(FinesseLocalizationsDataPa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ਮਿਤੀ ਚੁਣੋ';
}

// Path: input
class _FinesseLocalizationsData$input$pa extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$pa._(FinesseLocalizationsDataPa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ਕੱਟੋ';
	@override String get copy => 'ਕਾਪੀ ਕਰੋ';
	@override String get paste => 'ਪੇਸਟ ਕਰੋ';
	@override String get selectAll => 'ਸਭ ਚੁਣੋ';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$pa extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$pa._(FinesseLocalizationsDataPa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get done => 'ਹੋ ਗਿਆ';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$pa extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$pa._(FinesseLocalizationsDataPa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get close => 'ਬੰਦ ਕਰੋ';
	@override String get dismiss => 'ਖਾਰਜ ਕਰੋ';
}

/// The flat map containing all translations for locale <pa>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataPa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ਘੰਟੇ',
			'timePicker.minutes' => 'ਮਿੰਟ',
			'timePicker.seconds' => 'ਸਕਿੰਟ',
			'timePicker.period' => 'ਸਮਾਂ',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'ਮਿਤੀ ਚੁਣੋ',
			'input.cut' => 'ਕੱਟੋ',
			'input.copy' => 'ਕਾਪੀ ਕਰੋ',
			'input.paste' => 'ਪੇਸਟ ਕਰੋ',
			'input.selectAll' => 'ਸਭ ਚੁਣੋ',
			'keyboardToolbar.done' => 'ਹੋ ਗਿਆ',
			'dialog.close' => 'ਬੰਦ ਕਰੋ',
			'dialog.dismiss' => 'ਖਾਰਜ ਕਰੋ',
			_ => null,
		};
	}
}
