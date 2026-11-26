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
class UnaLocalizationsDataGl extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataGl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.gl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <gl>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataGl _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataGl $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataGl(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$gl timePicker = _UnaLocalizationsData$timePicker$gl._(_root);
	@override late final _UnaLocalizationsData$datePicker$gl datePicker = _UnaLocalizationsData$datePicker$gl._(_root);
	@override late final _UnaLocalizationsData$input$gl input = _UnaLocalizationsData$input$gl._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$gl keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$gl._(_root);
	@override late final _UnaLocalizationsData$dialog$gl dialog = _UnaLocalizationsData$dialog$gl._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$gl extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$gl._(UnaLocalizationsDataGl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
	@override String get period => 'Período';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$gl extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$gl._(UnaLocalizationsDataGl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Seleccionar data';
}

// Path: input
class _UnaLocalizationsData$input$gl extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$gl._(UnaLocalizationsDataGl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cortar';
	@override String get copy => 'Copiar';
	@override String get paste => 'Pegar';
	@override String get selectAll => 'Seleccionar todo';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$gl extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$gl._(UnaLocalizationsDataGl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Feito';
}

// Path: dialog
class _UnaLocalizationsData$dialog$gl extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$gl._(UnaLocalizationsDataGl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Pechar';
	@override String get dismiss => 'Pechar';
}

/// The flat map containing all translations for locale <gl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataGl {
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
