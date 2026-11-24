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
class FinesseLocalizationsDataNo extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataNo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.no,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <no>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataNo _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataNo $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataNo(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$no timePicker = _FinesseLocalizationsData$timePicker$no._(_root);
	@override late final _FinesseLocalizationsData$datePicker$no datePicker = _FinesseLocalizationsData$datePicker$no._(_root);
	@override late final _FinesseLocalizationsData$input$no input = _FinesseLocalizationsData$input$no._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$no keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$no._(_root);
	@override late final _FinesseLocalizationsData$dialog$no dialog = _FinesseLocalizationsData$dialog$no._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$no extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$no._(FinesseLocalizationsDataNo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Timer';
	@override String get minutes => 'Minutter';
	@override String get seconds => 'Sekunder';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$no extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$no._(FinesseLocalizationsDataNo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Velg dato';
}

// Path: input
class _FinesseLocalizationsData$input$no extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$no._(FinesseLocalizationsDataNo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klipp ut';
	@override String get copy => 'Kopier';
	@override String get paste => 'Lim inn';
	@override String get selectAll => 'Merk alt';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$no extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$no._(FinesseLocalizationsDataNo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get done => 'Ferdig';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$no extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$no._(FinesseLocalizationsDataNo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get close => 'Lukk';
	@override String get dismiss => 'Avvis';
}

/// The flat map containing all translations for locale <no>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataNo {
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
