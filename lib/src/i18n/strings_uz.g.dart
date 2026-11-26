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
class UnaLocalizationsDataUz extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataUz({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataUz _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataUz $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataUz(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$uz timePicker = _UnaLocalizationsData$timePicker$uz._(_root);
	@override late final _UnaLocalizationsData$datePicker$uz datePicker = _UnaLocalizationsData$datePicker$uz._(_root);
	@override late final _UnaLocalizationsData$input$uz input = _UnaLocalizationsData$input$uz._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$uz keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$uz._(_root);
	@override late final _UnaLocalizationsData$dialog$uz dialog = _UnaLocalizationsData$dialog$uz._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$uz extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$uz._(UnaLocalizationsDataUz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Soat';
	@override String get minutes => 'Daqiqa';
	@override String get seconds => 'Soniya';
	@override String get period => 'Davr';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$uz extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$uz._(UnaLocalizationsDataUz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Sana tanlang';
}

// Path: input
class _UnaLocalizationsData$input$uz extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$uz._(UnaLocalizationsDataUz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kesish';
	@override String get copy => 'Nusxa olish';
	@override String get paste => 'Joylashtirish';
	@override String get selectAll => 'Hammasini tanlash';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$uz extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$uz._(UnaLocalizationsDataUz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get done => 'Tayyor';
}

// Path: dialog
class _UnaLocalizationsData$dialog$uz extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$uz._(UnaLocalizationsDataUz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUz _root; // ignore: unused_field

	// Translations
	@override String get close => 'Yopish';
	@override String get dismiss => 'Yopish';
}

/// The flat map containing all translations for locale <uz>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataUz {
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
