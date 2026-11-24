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
class FinesseLocalizationsDataCa extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataCa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ca,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ca>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataCa _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataCa $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataCa(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ca timePicker = _FinesseLocalizationsData$timePicker$ca._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ca datePicker = _FinesseLocalizationsData$datePicker$ca._(_root);
	@override late final _FinesseLocalizationsData$input$ca input = _FinesseLocalizationsData$input$ca._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ca keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ca._(_root);
	@override late final _FinesseLocalizationsData$dialog$ca dialog = _FinesseLocalizationsData$dialog$ca._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ca extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ca._(FinesseLocalizationsDataCa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Hores';
	@override String get minutes => 'Minuts';
	@override String get seconds => 'Segons';
	@override String get period => 'Període';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ca extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ca._(FinesseLocalizationsDataCa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Selecciona una data';
}

// Path: input
class _FinesseLocalizationsData$input$ca extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ca._(FinesseLocalizationsDataCa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Retalla';
	@override String get copy => 'Copia';
	@override String get paste => 'Enganxa';
	@override String get selectAll => 'Selecciona-ho tot';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ca extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ca._(FinesseLocalizationsDataCa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get done => 'Fet';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ca extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ca._(FinesseLocalizationsDataCa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get close => 'Tanca';
	@override String get dismiss => 'Ignora';
}

/// The flat map containing all translations for locale <ca>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataCa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Hores',
			'timePicker.minutes' => 'Minuts',
			'timePicker.seconds' => 'Segons',
			'timePicker.period' => 'Període',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Selecciona una data',
			'input.cut' => 'Retalla',
			'input.copy' => 'Copia',
			'input.paste' => 'Enganxa',
			'input.selectAll' => 'Selecciona-ho tot',
			'keyboardToolbar.done' => 'Fet',
			'dialog.close' => 'Tanca',
			'dialog.dismiss' => 'Ignora',
			_ => null,
		};
	}
}
