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
class UnaLocalizationsDataCs extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataCs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.cs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cs>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataCs _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataCs $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataCs(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$cs timePicker = _UnaLocalizationsData$timePicker$cs._(_root);
	@override late final _UnaLocalizationsData$datePicker$cs datePicker = _UnaLocalizationsData$datePicker$cs._(_root);
	@override late final _UnaLocalizationsData$input$cs input = _UnaLocalizationsData$input$cs._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$cs keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$cs._(_root);
	@override late final _UnaLocalizationsData$dialog$cs dialog = _UnaLocalizationsData$dialog$cs._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$cs extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$cs._(UnaLocalizationsDataCs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Hodiny';
	@override String get minutes => 'Minuty';
	@override String get seconds => 'Sekundy';
	@override String get period => 'Perioda';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$cs extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$cs._(UnaLocalizationsDataCs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vyberte datum';
}

// Path: input
class _UnaLocalizationsData$input$cs extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$cs._(UnaLocalizationsDataCs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Vyjmout';
	@override String get copy => 'Kopírovat';
	@override String get paste => 'Vložit';
	@override String get selectAll => 'Vybrat vše';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$cs extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$cs._(UnaLocalizationsDataCs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Hotovo';
}

// Path: dialog
class _UnaLocalizationsData$dialog$cs extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$cs._(UnaLocalizationsDataCs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zavřít';
	@override String get dismiss => 'Zavřít';
}

/// The flat map containing all translations for locale <cs>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataCs {
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
