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
class UnaLocalizationsDataTa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataTa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ta,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ta>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataTa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataTa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataTa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ta timePicker = _UnaLocalizationsData$timePicker$ta._(_root);
	@override late final _UnaLocalizationsData$datePicker$ta datePicker = _UnaLocalizationsData$datePicker$ta._(_root);
	@override late final _UnaLocalizationsData$input$ta input = _UnaLocalizationsData$input$ta._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ta keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ta._(_root);
	@override late final _UnaLocalizationsData$dialog$ta dialog = _UnaLocalizationsData$dialog$ta._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ta extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ta._(UnaLocalizationsDataTa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'மணி';
	@override String get minutes => 'நிமிடங்கள்';
	@override String get seconds => 'விநாடிகள்';
	@override String get period => 'காலம்';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ta extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ta._(UnaLocalizationsDataTa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'தேதியை தேர்ந்தெடுக்கவும்';
}

// Path: input
class _UnaLocalizationsData$input$ta extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ta._(UnaLocalizationsDataTa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'வெட்டு';
	@override String get copy => 'நகலெடு';
	@override String get paste => 'ஒட்டு';
	@override String get selectAll => 'அனைத்தையும் தேர்ந்தெடு';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ta extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ta._(UnaLocalizationsDataTa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTa _root; // ignore: unused_field

	// Translations
	@override String get done => 'முடிந்தது';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ta extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ta._(UnaLocalizationsDataTa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTa _root; // ignore: unused_field

	// Translations
	@override String get close => 'மூடுக';
	@override String get dismiss => 'நிராகரிக்கும்';
}

/// The flat map containing all translations for locale <ta>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataTa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'மணி',
			'timePicker.minutes' => 'நிமிடங்கள்',
			'timePicker.seconds' => 'விநாடிகள்',
			'timePicker.period' => 'காலம்',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'தேதியை தேர்ந்தெடுக்கவும்',
			'input.cut' => 'வெட்டு',
			'input.copy' => 'நகலெடு',
			'input.paste' => 'ஒட்டு',
			'input.selectAll' => 'அனைத்தையும் தேர்ந்தெடு',
			'keyboardToolbar.done' => 'முடிந்தது',
			'dialog.close' => 'மூடுக',
			'dialog.dismiss' => 'நிராகரிக்கும்',
			_ => null,
		};
	}
}
