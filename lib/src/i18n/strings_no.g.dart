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
class UnaLocalizationsDataNo extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataNo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.no,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <no>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataNo _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataNo $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataNo(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$no timePicker = _UnaLocalizationsData$timePicker$no._(_root);
	@override late final _UnaLocalizationsData$datePicker$no datePicker = _UnaLocalizationsData$datePicker$no._(_root);
	@override late final _UnaLocalizationsData$input$no input = _UnaLocalizationsData$input$no._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$no keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$no._(_root);
	@override late final _UnaLocalizationsData$dialog$no dialog = _UnaLocalizationsData$dialog$no._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$no extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$no._(UnaLocalizationsDataNo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Timer';
	@override String get minutes => 'Minutter';
	@override String get seconds => 'Sekunder';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$no extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$no._(UnaLocalizationsDataNo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Velg dato';
}

// Path: input
class _UnaLocalizationsData$input$no extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$no._(UnaLocalizationsDataNo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klipp ut';
	@override String get copy => 'Kopier';
	@override String get paste => 'Lim inn';
	@override String get selectAll => 'Merk alt';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$no extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$no._(UnaLocalizationsDataNo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get done => 'Ferdig';
}

// Path: dialog
class _UnaLocalizationsData$dialog$no extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$no._(UnaLocalizationsDataNo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataNo _root; // ignore: unused_field

	// Translations
	@override String get close => 'Lukk';
	@override String get dismiss => 'Avvis';
}

/// The flat map containing all translations for locale <no>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataNo {
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
