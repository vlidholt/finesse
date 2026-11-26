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
class UnaLocalizationsDataDe extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataDe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <de>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataDe _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataDe $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataDe(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$de timePicker = _UnaLocalizationsData$timePicker$de._(_root);
	@override late final _UnaLocalizationsData$datePicker$de datePicker = _UnaLocalizationsData$datePicker$de._(_root);
	@override late final _UnaLocalizationsData$input$de input = _UnaLocalizationsData$input$de._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$de keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$de._(_root);
	@override late final _UnaLocalizationsData$dialog$de dialog = _UnaLocalizationsData$dialog$de._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$de extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$de._(UnaLocalizationsDataDe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Stunden';
	@override String get minutes => 'Minuten';
	@override String get seconds => 'Sekunden';
	@override String get period => 'Zeitraum';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$de extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$de._(UnaLocalizationsDataDe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Datum auswählen';
}

// Path: input
class _UnaLocalizationsData$input$de extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$de._(UnaLocalizationsDataDe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Ausschneiden';
	@override String get copy => 'Kopieren';
	@override String get paste => 'Einfügen';
	@override String get selectAll => 'Alles auswählen';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$de extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$de._(UnaLocalizationsDataDe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get done => 'Fertig';
}

// Path: dialog
class _UnaLocalizationsData$dialog$de extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$de._(UnaLocalizationsDataDe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataDe _root; // ignore: unused_field

	// Translations
	@override String get close => 'Schließen';
	@override String get dismiss => 'Schließen';
}

/// The flat map containing all translations for locale <de>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataDe {
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
