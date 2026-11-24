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
class FinesseLocalizationsDataNe extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataNe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ne,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ne>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataNe _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataNe $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataNe(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ne timePicker = _FinesseLocalizationsData$timePicker$ne._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ne datePicker = _FinesseLocalizationsData$datePicker$ne._(_root);
	@override late final _FinesseLocalizationsData$input$ne input = _FinesseLocalizationsData$input$ne._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ne keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ne._(_root);
	@override late final _FinesseLocalizationsData$dialog$ne dialog = _FinesseLocalizationsData$dialog$ne._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ne extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ne._(FinesseLocalizationsDataNe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'घण्टा';
	@override String get minutes => 'मिनेट';
	@override String get seconds => 'सेकेन्ड';
	@override String get period => 'अवधि';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ne extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ne._(FinesseLocalizationsDataNe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'मिति छान्नुहोस्';
}

// Path: input
class _FinesseLocalizationsData$input$ne extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ne._(FinesseLocalizationsDataNe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'काट्नुहोस्';
	@override String get copy => 'प्रतिलिपि गर्नुहोस्';
	@override String get paste => 'टाँस्नुहोस्';
	@override String get selectAll => 'सबै चयन गर्नुहोस्';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ne extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ne._(FinesseLocalizationsDataNe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get done => 'सम्पन्न';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ne extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ne._(FinesseLocalizationsDataNe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get close => 'बन्द गर्नुहोस्';
	@override String get dismiss => 'खारेज गर्नुहोस्';
}

/// The flat map containing all translations for locale <ne>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataNe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'घण्टा',
			'timePicker.minutes' => 'मिनेट',
			'timePicker.seconds' => 'सेकेन्ड',
			'timePicker.period' => 'अवधि',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'मिति छान्नुहोस्',
			'input.cut' => 'काट्नुहोस्',
			'input.copy' => 'प्रतिलिपि गर्नुहोस्',
			'input.paste' => 'टाँस्नुहोस्',
			'input.selectAll' => 'सबै चयन गर्नुहोस्',
			'keyboardToolbar.done' => 'सम्पन्न',
			'dialog.close' => 'बन्द गर्नुहोस्',
			'dialog.dismiss' => 'खारेज गर्नुहोस्',
			_ => null,
		};
	}
}
