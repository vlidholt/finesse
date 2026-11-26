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
class UnaLocalizationsDataGu extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataGu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.gu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <gu>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataGu _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataGu $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataGu(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$gu timePicker = _UnaLocalizationsData$timePicker$gu._(_root);
	@override late final _UnaLocalizationsData$datePicker$gu datePicker = _UnaLocalizationsData$datePicker$gu._(_root);
	@override late final _UnaLocalizationsData$input$gu input = _UnaLocalizationsData$input$gu._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$gu keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$gu._(_root);
	@override late final _UnaLocalizationsData$dialog$gu dialog = _UnaLocalizationsData$dialog$gu._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$gu extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$gu._(UnaLocalizationsDataGu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'કલાક';
	@override String get minutes => 'મિનિટ';
	@override String get seconds => 'સેકન્ડ';
	@override String get period => 'સમયગાળો';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$gu extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$gu._(UnaLocalizationsDataGu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'તારીખ પસંદ કરો';
}

// Path: input
class _UnaLocalizationsData$input$gu extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$gu._(UnaLocalizationsDataGu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'કાપો';
	@override String get copy => 'કૉપિ કરો';
	@override String get paste => 'પેસ્ટ કરો';
	@override String get selectAll => 'બધું પસંદ કરો';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$gu extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$gu._(UnaLocalizationsDataGu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get done => 'થઈ ગયું';
}

// Path: dialog
class _UnaLocalizationsData$dialog$gu extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$gu._(UnaLocalizationsDataGu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get close => 'બંધ કરો';
	@override String get dismiss => 'છોડી દો';
}

/// The flat map containing all translations for locale <gu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataGu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'કલાક',
			'timePicker.minutes' => 'મિનિટ',
			'timePicker.seconds' => 'સેકન્ડ',
			'timePicker.period' => 'સમયગાળો',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'તારીખ પસંદ કરો',
			'input.cut' => 'કાપો',
			'input.copy' => 'કૉપિ કરો',
			'input.paste' => 'પેસ્ટ કરો',
			'input.selectAll' => 'બધું પસંદ કરો',
			'keyboardToolbar.done' => 'થઈ ગયું',
			'dialog.close' => 'બંધ કરો',
			'dialog.dismiss' => 'છોડી દો',
			_ => null,
		};
	}
}
