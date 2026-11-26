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
class UnaLocalizationsDataCa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataCa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ca,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ca>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataCa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataCa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataCa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ca timePicker = _UnaLocalizationsData$timePicker$ca._(_root);
	@override late final _UnaLocalizationsData$datePicker$ca datePicker = _UnaLocalizationsData$datePicker$ca._(_root);
	@override late final _UnaLocalizationsData$input$ca input = _UnaLocalizationsData$input$ca._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ca keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ca._(_root);
	@override late final _UnaLocalizationsData$dialog$ca dialog = _UnaLocalizationsData$dialog$ca._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ca extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ca._(UnaLocalizationsDataCa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Hores';
	@override String get minutes => 'Minuts';
	@override String get seconds => 'Segons';
	@override String get period => 'Període';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ca extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ca._(UnaLocalizationsDataCa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Selecciona una data';
}

// Path: input
class _UnaLocalizationsData$input$ca extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ca._(UnaLocalizationsDataCa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Retalla';
	@override String get copy => 'Copia';
	@override String get paste => 'Enganxa';
	@override String get selectAll => 'Selecciona-ho tot';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ca extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ca._(UnaLocalizationsDataCa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get done => 'Fet';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ca extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ca._(UnaLocalizationsDataCa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataCa _root; // ignore: unused_field

	// Translations
	@override String get close => 'Tanca';
	@override String get dismiss => 'Ignora';
}

/// The flat map containing all translations for locale <ca>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataCa {
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
