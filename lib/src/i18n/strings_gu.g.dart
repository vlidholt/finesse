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
class FinesseLocalizationsDataGu extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataGu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.gu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <gu>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataGu _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataGu $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataGu(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$gu timePicker = _FinesseLocalizationsData$timePicker$gu._(_root);
	@override late final _FinesseLocalizationsData$datePicker$gu datePicker = _FinesseLocalizationsData$datePicker$gu._(_root);
	@override late final _FinesseLocalizationsData$input$gu input = _FinesseLocalizationsData$input$gu._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$gu keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$gu._(_root);
	@override late final _FinesseLocalizationsData$dialog$gu dialog = _FinesseLocalizationsData$dialog$gu._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$gu extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$gu._(FinesseLocalizationsDataGu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'કલાક';
	@override String get minutes => 'મિનિટ';
	@override String get seconds => 'સેકન્ડ';
	@override String get period => 'સમયગાળો';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$gu extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$gu._(FinesseLocalizationsDataGu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'તારીખ પસંદ કરો';
}

// Path: input
class _FinesseLocalizationsData$input$gu extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$gu._(FinesseLocalizationsDataGu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'કાપો';
	@override String get copy => 'કૉપિ કરો';
	@override String get paste => 'પેસ્ટ કરો';
	@override String get selectAll => 'બધું પસંદ કરો';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$gu extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$gu._(FinesseLocalizationsDataGu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get done => 'થઈ ગયું';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$gu extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$gu._(FinesseLocalizationsDataGu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGu _root; // ignore: unused_field

	// Translations
	@override String get close => 'બંધ કરો';
	@override String get dismiss => 'છોડી દો';
}

/// The flat map containing all translations for locale <gu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataGu {
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
