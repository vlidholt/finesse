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
class FinesseLocalizationsDataEs extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataEs _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataEs $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$es timePicker = _FinesseLocalizationsData$timePicker$es._(_root);
	@override late final _FinesseLocalizationsData$datePicker$es datePicker = _FinesseLocalizationsData$datePicker$es._(_root);
	@override late final _FinesseLocalizationsData$input$es input = _FinesseLocalizationsData$input$es._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$es keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$es._(_root);
	@override late final _FinesseLocalizationsData$dialog$es dialog = _FinesseLocalizationsData$dialog$es._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$es extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$es._(FinesseLocalizationsDataEs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
	@override String get period => 'Período';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$es extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$es._(FinesseLocalizationsDataEs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Seleccionar fecha';
}

// Path: input
class _FinesseLocalizationsData$input$es extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$es._(FinesseLocalizationsDataEs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cortar';
	@override String get copy => 'Copiar';
	@override String get paste => 'Pegar';
	@override String get selectAll => 'Seleccionar todo';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$es extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$es._(FinesseLocalizationsDataEs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Listo';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$es extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$es._(FinesseLocalizationsDataEs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Cerrar';
	@override String get dismiss => 'Cerrar';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Horas',
			'timePicker.minutes' => 'Minutos',
			'timePicker.seconds' => 'Segundos',
			'timePicker.period' => 'Período',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Seleccionar fecha',
			'input.cut' => 'Cortar',
			'input.copy' => 'Copiar',
			'input.paste' => 'Pegar',
			'input.selectAll' => 'Seleccionar todo',
			'keyboardToolbar.done' => 'Listo',
			'dialog.close' => 'Cerrar',
			'dialog.dismiss' => 'Cerrar',
			_ => null,
		};
	}
}
