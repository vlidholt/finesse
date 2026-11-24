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
class FinesseLocalizationsDataNb extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataNb({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.nb,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <nb>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataNb _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataNb $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataNb(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$nb timePicker = _FinesseLocalizationsData$timePicker$nb._(_root);
	@override late final _FinesseLocalizationsData$datePicker$nb datePicker = _FinesseLocalizationsData$datePicker$nb._(_root);
	@override late final _FinesseLocalizationsData$input$nb input = _FinesseLocalizationsData$input$nb._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$nb keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$nb._(_root);
	@override late final _FinesseLocalizationsData$dialog$nb dialog = _FinesseLocalizationsData$dialog$nb._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$nb extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$nb._(FinesseLocalizationsDataNb root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNb _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Timer';
	@override String get minutes => 'Minutter';
	@override String get seconds => 'Sekunder';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$nb extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$nb._(FinesseLocalizationsDataNb root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNb _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Velg dato';
}

// Path: input
class _FinesseLocalizationsData$input$nb extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$nb._(FinesseLocalizationsDataNb root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNb _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klipp ut';
	@override String get copy => 'Kopier';
	@override String get paste => 'Lim inn';
	@override String get selectAll => 'Merk alt';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$nb extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$nb._(FinesseLocalizationsDataNb root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNb _root; // ignore: unused_field

	// Translations
	@override String get done => 'Ferdig';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$nb extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$nb._(FinesseLocalizationsDataNb root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNb _root; // ignore: unused_field

	// Translations
	@override String get close => 'Lukk';
	@override String get dismiss => 'Avvis';
}

/// The flat map containing all translations for locale <nb>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataNb {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Timer',
			'timePicker.minutes' => 'Minutter',
			'timePicker.seconds' => 'Sekunder',
			'timePicker.period' => 'Periode',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Velg dato',
			'input.cut' => 'Klipp ut',
			'input.copy' => 'Kopier',
			'input.paste' => 'Lim inn',
			'input.selectAll' => 'Merk alt',
			'keyboardToolbar.done' => 'Ferdig',
			'dialog.close' => 'Lukk',
			'dialog.dismiss' => 'Avvis',
			_ => null,
		};
	}
}
