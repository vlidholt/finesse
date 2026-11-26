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
class UnaLocalizationsDataPa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataPa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.pa,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pa>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataPa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataPa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataPa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$pa timePicker = _UnaLocalizationsData$timePicker$pa._(_root);
	@override late final _UnaLocalizationsData$datePicker$pa datePicker = _UnaLocalizationsData$datePicker$pa._(_root);
	@override late final _UnaLocalizationsData$input$pa input = _UnaLocalizationsData$input$pa._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$pa keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$pa._(_root);
	@override late final _UnaLocalizationsData$dialog$pa dialog = _UnaLocalizationsData$dialog$pa._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$pa extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$pa._(UnaLocalizationsDataPa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ਘੰਟੇ';
	@override String get minutes => 'ਮਿੰਟ';
	@override String get seconds => 'ਸਕਿੰਟ';
	@override String get period => 'ਸਮਾਂ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$pa extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$pa._(UnaLocalizationsDataPa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ਮਿਤੀ ਚੁਣੋ';
}

// Path: input
class _UnaLocalizationsData$input$pa extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$pa._(UnaLocalizationsDataPa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ਕੱਟੋ';
	@override String get copy => 'ਕਾਪੀ ਕਰੋ';
	@override String get paste => 'ਪੇਸਟ ਕਰੋ';
	@override String get selectAll => 'ਸਭ ਚੁਣੋ';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$pa extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$pa._(UnaLocalizationsDataPa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get done => 'ਹੋ ਗਿਆ';
}

// Path: dialog
class _UnaLocalizationsData$dialog$pa extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$pa._(UnaLocalizationsDataPa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPa _root; // ignore: unused_field

	// Translations
	@override String get close => 'ਬੰਦ ਕਰੋ';
	@override String get dismiss => 'ਖਾਰਜ ਕਰੋ';
}

/// The flat map containing all translations for locale <pa>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataPa {
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
