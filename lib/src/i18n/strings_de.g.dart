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
class FinesseLocalizationsDataDe extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataDe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <de>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataDe _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataDe $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataDe(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$de timePicker = _FinesseLocalizationsData$timePicker$de._(_root);
	@override late final _FinesseLocalizationsData$datePicker$de datePicker = _FinesseLocalizationsData$datePicker$de._(_root);
	@override late final _FinesseLocalizationsData$input$de input = _FinesseLocalizationsData$input$de._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$de keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$de._(_root);
	@override late final _FinesseLocalizationsData$dialog$de dialog = _FinesseLocalizationsData$dialog$de._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$de extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$de._(FinesseLocalizationsDataDe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Stunden';
	@override String get minutes => 'Minuten';
	@override String get seconds => 'Sekunden';
	@override String get period => 'Zeitraum';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$de extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$de._(FinesseLocalizationsDataDe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Datum auswählen';
}

// Path: input
class _FinesseLocalizationsData$input$de extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$de._(FinesseLocalizationsDataDe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Ausschneiden';
	@override String get copy => 'Kopieren';
	@override String get paste => 'Einfügen';
	@override String get selectAll => 'Alles auswählen';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$de extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$de._(FinesseLocalizationsDataDe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get done => 'Fertig';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$de extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$de._(FinesseLocalizationsDataDe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get close => 'Schließen';
	@override String get dismiss => 'Schließen';
}

/// The flat map containing all translations for locale <de>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataDe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Stunden',
			'timePicker.minutes' => 'Minuten',
			'timePicker.seconds' => 'Sekunden',
			'timePicker.period' => 'Zeitraum',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Datum auswählen',
			'input.cut' => 'Ausschneiden',
			'input.copy' => 'Kopieren',
			'input.paste' => 'Einfügen',
			'input.selectAll' => 'Alles auswählen',
			'keyboardToolbar.done' => 'Fertig',
			'dialog.close' => 'Schließen',
			'dialog.dismiss' => 'Schließen',
			_ => null,
		};
	}
}
