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
class UnaLocalizationsDataNe extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataNe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ne,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ne>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataNe _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataNe $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataNe(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ne timePicker = _UnaLocalizationsData$timePicker$ne._(_root);
	@override late final _UnaLocalizationsData$datePicker$ne datePicker = _UnaLocalizationsData$datePicker$ne._(_root);
	@override late final _UnaLocalizationsData$input$ne input = _UnaLocalizationsData$input$ne._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ne keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ne._(_root);
	@override late final _UnaLocalizationsData$dialog$ne dialog = _UnaLocalizationsData$dialog$ne._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ne extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ne._(UnaLocalizationsDataNe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'घण्टा';
	@override String get minutes => 'मिनेट';
	@override String get seconds => 'सेकेन्ड';
	@override String get period => 'अवधि';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ne extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ne._(UnaLocalizationsDataNe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'मिति छान्नुहोस्';
}

// Path: input
class _UnaLocalizationsData$input$ne extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ne._(UnaLocalizationsDataNe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'काट्नुहोस्';
	@override String get copy => 'प्रतिलिपि गर्नुहोस्';
	@override String get paste => 'टाँस्नुहोस्';
	@override String get selectAll => 'सबै चयन गर्नुहोस्';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ne extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ne._(UnaLocalizationsDataNe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get done => 'सम्पन्न';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ne extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ne._(UnaLocalizationsDataNe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNe _root; // ignore: unused_field

	// Translations
	@override String get close => 'बन्द गर्नुहोस्';
	@override String get dismiss => 'खारेज गर्नुहोस्';
}

/// The flat map containing all translations for locale <ne>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataNe {
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
