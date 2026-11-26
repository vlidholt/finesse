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
class UnaLocalizationsDataEs extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataEs _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataEs $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$es timePicker = _UnaLocalizationsData$timePicker$es._(_root);
	@override late final _UnaLocalizationsData$datePicker$es datePicker = _UnaLocalizationsData$datePicker$es._(_root);
	@override late final _UnaLocalizationsData$input$es input = _UnaLocalizationsData$input$es._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$es keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$es._(_root);
	@override late final _UnaLocalizationsData$dialog$es dialog = _UnaLocalizationsData$dialog$es._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$es extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$es._(UnaLocalizationsDataEs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
	@override String get period => 'Período';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$es extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$es._(UnaLocalizationsDataEs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Seleccionar fecha';
}

// Path: input
class _UnaLocalizationsData$input$es extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$es._(UnaLocalizationsDataEs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cortar';
	@override String get copy => 'Copiar';
	@override String get paste => 'Pegar';
	@override String get selectAll => 'Seleccionar todo';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$es extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$es._(UnaLocalizationsDataEs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Listo';
}

// Path: dialog
class _UnaLocalizationsData$dialog$es extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$es._(UnaLocalizationsDataEs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Cerrar';
	@override String get dismiss => 'Cerrar';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataEs {
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
