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
class FinesseLocalizationsDataPt extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataPt _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataPt $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataPt(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$pt timePicker = _FinesseLocalizationsData$timePicker$pt._(_root);
	@override late final _FinesseLocalizationsData$datePicker$pt datePicker = _FinesseLocalizationsData$datePicker$pt._(_root);
	@override late final _FinesseLocalizationsData$input$pt input = _FinesseLocalizationsData$input$pt._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$pt keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$pt._(_root);
	@override late final _FinesseLocalizationsData$dialog$pt dialog = _FinesseLocalizationsData$dialog$pt._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$pt extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$pt._(FinesseLocalizationsDataPt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
	@override String get period => 'Período';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$pt extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$pt._(FinesseLocalizationsDataPt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Selecionar data';
}

// Path: input
class _FinesseLocalizationsData$input$pt extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$pt._(FinesseLocalizationsDataPt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cortar';
	@override String get copy => 'Copiar';
	@override String get paste => 'Colar';
	@override String get selectAll => 'Selecionar tudo';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$pt extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$pt._(FinesseLocalizationsDataPt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Concluído';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$pt extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$pt._(FinesseLocalizationsDataPt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Fechar';
	@override String get dismiss => 'Dispensar';
}

/// The flat map containing all translations for locale <pt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataPt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Horas',
			'timePicker.minutes' => 'Minutos',
			'timePicker.seconds' => 'Segundos',
			'timePicker.period' => 'Período',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Selecionar data',
			'input.cut' => 'Cortar',
			'input.copy' => 'Copiar',
			'input.paste' => 'Colar',
			'input.selectAll' => 'Selecionar tudo',
			'keyboardToolbar.done' => 'Concluído',
			'dialog.close' => 'Fechar',
			'dialog.dismiss' => 'Dispensar',
			_ => null,
		};
	}
}
