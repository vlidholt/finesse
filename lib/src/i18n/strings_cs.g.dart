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
class FinesseLocalizationsDataCs extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataCs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.cs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cs>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataCs _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataCs $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataCs(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$cs timePicker = _FinesseLocalizationsData$timePicker$cs._(_root);
	@override late final _FinesseLocalizationsData$datePicker$cs datePicker = _FinesseLocalizationsData$datePicker$cs._(_root);
	@override late final _FinesseLocalizationsData$input$cs input = _FinesseLocalizationsData$input$cs._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$cs keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$cs._(_root);
	@override late final _FinesseLocalizationsData$dialog$cs dialog = _FinesseLocalizationsData$dialog$cs._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$cs extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$cs._(FinesseLocalizationsDataCs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Hodiny';
	@override String get minutes => 'Minuty';
	@override String get seconds => 'Sekundy';
	@override String get period => 'Perioda';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$cs extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$cs._(FinesseLocalizationsDataCs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vyberte datum';
}

// Path: input
class _FinesseLocalizationsData$input$cs extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$cs._(FinesseLocalizationsDataCs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Vyjmout';
	@override String get copy => 'Kopírovat';
	@override String get paste => 'Vložit';
	@override String get selectAll => 'Vybrat vše';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$cs extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$cs._(FinesseLocalizationsDataCs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Hotovo';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$cs extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$cs._(FinesseLocalizationsDataCs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zavřít';
	@override String get dismiss => 'Zavřít';
}

/// The flat map containing all translations for locale <cs>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataCs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Hodiny',
			'timePicker.minutes' => 'Minuty',
			'timePicker.seconds' => 'Sekundy',
			'timePicker.period' => 'Perioda',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Vyberte datum',
			'input.cut' => 'Vyjmout',
			'input.copy' => 'Kopírovat',
			'input.paste' => 'Vložit',
			'input.selectAll' => 'Vybrat vše',
			'keyboardToolbar.done' => 'Hotovo',
			'dialog.close' => 'Zavřít',
			'dialog.dismiss' => 'Zavřít',
			_ => null,
		};
	}
}
