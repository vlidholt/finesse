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
class FinesseLocalizationsDataCy extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataCy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.cy,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cy>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataCy _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataCy $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataCy(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$cy timePicker = _FinesseLocalizationsData$timePicker$cy._(_root);
	@override late final _FinesseLocalizationsData$datePicker$cy datePicker = _FinesseLocalizationsData$datePicker$cy._(_root);
	@override late final _FinesseLocalizationsData$input$cy input = _FinesseLocalizationsData$input$cy._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$cy keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$cy._(_root);
	@override late final _FinesseLocalizationsData$dialog$cy dialog = _FinesseLocalizationsData$dialog$cy._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$cy extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$cy._(FinesseLocalizationsDataCy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Oriau';
	@override String get minutes => 'Munudau';
	@override String get seconds => 'Eiliadau';
	@override String get period => 'Cyfnod';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$cy extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$cy._(FinesseLocalizationsDataCy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Dewiswch ddyddiad';
}

// Path: input
class _FinesseLocalizationsData$input$cy extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$cy._(FinesseLocalizationsDataCy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Torri';
	@override String get copy => 'Copïo';
	@override String get paste => 'Gludo';
	@override String get selectAll => 'Dewis y cyfan';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$cy extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$cy._(FinesseLocalizationsDataCy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gorffen';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$cy extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$cy._(FinesseLocalizationsDataCy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get close => 'Cau';
	@override String get dismiss => 'Diystyru';
}

/// The flat map containing all translations for locale <cy>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataCy {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Oriau',
			'timePicker.minutes' => 'Munudau',
			'timePicker.seconds' => 'Eiliadau',
			'timePicker.period' => 'Cyfnod',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Dewiswch ddyddiad',
			'input.cut' => 'Torri',
			'input.copy' => 'Copïo',
			'input.paste' => 'Gludo',
			'input.selectAll' => 'Dewis y cyfan',
			'keyboardToolbar.done' => 'Gorffen',
			'dialog.close' => 'Cau',
			'dialog.dismiss' => 'Diystyru',
			_ => null,
		};
	}
}
