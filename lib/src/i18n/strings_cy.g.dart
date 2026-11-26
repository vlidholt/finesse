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
class UnaLocalizationsDataCy extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataCy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.cy,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cy>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataCy _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataCy $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataCy(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$cy timePicker = _UnaLocalizationsData$timePicker$cy._(_root);
	@override late final _UnaLocalizationsData$datePicker$cy datePicker = _UnaLocalizationsData$datePicker$cy._(_root);
	@override late final _UnaLocalizationsData$input$cy input = _UnaLocalizationsData$input$cy._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$cy keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$cy._(_root);
	@override late final _UnaLocalizationsData$dialog$cy dialog = _UnaLocalizationsData$dialog$cy._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$cy extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$cy._(UnaLocalizationsDataCy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Oriau';
	@override String get minutes => 'Munudau';
	@override String get seconds => 'Eiliadau';
	@override String get period => 'Cyfnod';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$cy extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$cy._(UnaLocalizationsDataCy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Dewiswch ddyddiad';
}

// Path: input
class _UnaLocalizationsData$input$cy extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$cy._(UnaLocalizationsDataCy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Torri';
	@override String get copy => 'Copïo';
	@override String get paste => 'Gludo';
	@override String get selectAll => 'Dewis y cyfan';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$cy extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$cy._(UnaLocalizationsDataCy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gorffen';
}

// Path: dialog
class _UnaLocalizationsData$dialog$cy extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$cy._(UnaLocalizationsDataCy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCy _root; // ignore: unused_field

	// Translations
	@override String get close => 'Cau';
	@override String get dismiss => 'Diystyru';
}

/// The flat map containing all translations for locale <cy>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataCy {
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
