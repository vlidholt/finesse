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
class FinesseLocalizationsDataUz extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataUz({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataUz _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataUz $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataUz(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$uz timePicker = _FinesseLocalizationsData$timePicker$uz._(_root);
	@override late final _FinesseLocalizationsData$datePicker$uz datePicker = _FinesseLocalizationsData$datePicker$uz._(_root);
	@override late final _FinesseLocalizationsData$input$uz input = _FinesseLocalizationsData$input$uz._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$uz keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$uz._(_root);
	@override late final _FinesseLocalizationsData$dialog$uz dialog = _FinesseLocalizationsData$dialog$uz._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$uz extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$uz._(FinesseLocalizationsDataUz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Soat';
	@override String get minutes => 'Daqiqa';
	@override String get seconds => 'Soniya';
	@override String get period => 'Davr';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$uz extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$uz._(FinesseLocalizationsDataUz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Sana tanlang';
}

// Path: input
class _FinesseLocalizationsData$input$uz extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$uz._(FinesseLocalizationsDataUz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kesish';
	@override String get copy => 'Nusxa olish';
	@override String get paste => 'Joylashtirish';
	@override String get selectAll => 'Hammasini tanlash';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$uz extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$uz._(FinesseLocalizationsDataUz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get done => 'Tayyor';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$uz extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$uz._(FinesseLocalizationsDataUz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get close => 'Yopish';
	@override String get dismiss => 'Yopish';
}

/// The flat map containing all translations for locale <uz>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataUz {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Soat',
			'timePicker.minutes' => 'Daqiqa',
			'timePicker.seconds' => 'Soniya',
			'timePicker.period' => 'Davr',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Sana tanlang',
			'input.cut' => 'Kesish',
			'input.copy' => 'Nusxa olish',
			'input.paste' => 'Joylashtirish',
			'input.selectAll' => 'Hammasini tanlash',
			'keyboardToolbar.done' => 'Tayyor',
			'dialog.close' => 'Yopish',
			'dialog.dismiss' => 'Yopish',
			_ => null,
		};
	}
}
