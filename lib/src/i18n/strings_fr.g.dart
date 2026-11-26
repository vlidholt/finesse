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
class UnaLocalizationsDataFr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataFr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataFr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataFr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$fr timePicker = _UnaLocalizationsData$timePicker$fr._(_root);
	@override late final _UnaLocalizationsData$datePicker$fr datePicker = _UnaLocalizationsData$datePicker$fr._(_root);
	@override late final _UnaLocalizationsData$input$fr input = _UnaLocalizationsData$input$fr._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$fr keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$fr._(_root);
	@override late final _UnaLocalizationsData$dialog$fr dialog = _UnaLocalizationsData$dialog$fr._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$fr extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$fr._(UnaLocalizationsDataFr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Heures';
	@override String get minutes => 'Minutes';
	@override String get seconds => 'Secondes';
	@override String get period => 'Période';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$fr extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$fr._(UnaLocalizationsDataFr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Sélectionner une date';
}

// Path: input
class _UnaLocalizationsData$input$fr extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$fr._(UnaLocalizationsDataFr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Couper';
	@override String get copy => 'Copier';
	@override String get paste => 'Coller';
	@override String get selectAll => 'Tout sélectionner';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$fr extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$fr._(UnaLocalizationsDataFr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFr _root; // ignore: unused_field

	// Translations
	@override String get done => 'Terminé';
}

// Path: dialog
class _UnaLocalizationsData$dialog$fr extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$fr._(UnaLocalizationsDataFr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFr _root; // ignore: unused_field

	// Translations
	@override String get close => 'Fermer';
	@override String get dismiss => 'Ignorer';
}

/// The flat map containing all translations for locale <fr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataFr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Heures',
			'timePicker.minutes' => 'Minutes',
			'timePicker.seconds' => 'Secondes',
			'timePicker.period' => 'Période',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Sélectionner une date',
			'input.cut' => 'Couper',
			'input.copy' => 'Copier',
			'input.paste' => 'Coller',
			'input.selectAll' => 'Tout sélectionner',
			'keyboardToolbar.done' => 'Terminé',
			'dialog.close' => 'Fermer',
			'dialog.dismiss' => 'Ignorer',
			_ => null,
		};
	}
}
