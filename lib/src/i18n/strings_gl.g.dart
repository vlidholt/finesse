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
class FinesseLocalizationsDataGl extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataGl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.gl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <gl>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataGl _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataGl $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataGl(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$gl timePicker = _FinesseLocalizationsData$timePicker$gl._(_root);
	@override late final _FinesseLocalizationsData$datePicker$gl datePicker = _FinesseLocalizationsData$datePicker$gl._(_root);
	@override late final _FinesseLocalizationsData$input$gl input = _FinesseLocalizationsData$input$gl._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$gl keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$gl._(_root);
	@override late final _FinesseLocalizationsData$dialog$gl dialog = _FinesseLocalizationsData$dialog$gl._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$gl extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$gl._(FinesseLocalizationsDataGl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
	@override String get period => 'Período';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$gl extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$gl._(FinesseLocalizationsDataGl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Seleccionar data';
}

// Path: input
class _FinesseLocalizationsData$input$gl extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$gl._(FinesseLocalizationsDataGl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cortar';
	@override String get copy => 'Copiar';
	@override String get paste => 'Pegar';
	@override String get selectAll => 'Seleccionar todo';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$gl extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$gl._(FinesseLocalizationsDataGl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Feito';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$gl extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$gl._(FinesseLocalizationsDataGl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Pechar';
	@override String get dismiss => 'Pechar';
}

/// The flat map containing all translations for locale <gl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataGl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Horas',
			'timePicker.minutes' => 'Minutos',
			'timePicker.seconds' => 'Segundos',
			'timePicker.period' => 'Período',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Seleccionar data',
			'input.cut' => 'Cortar',
			'input.copy' => 'Copiar',
			'input.paste' => 'Pegar',
			'input.selectAll' => 'Seleccionar todo',
			'keyboardToolbar.done' => 'Feito',
			'dialog.close' => 'Pechar',
			'dialog.dismiss' => 'Pechar',
			_ => null,
		};
	}
}
