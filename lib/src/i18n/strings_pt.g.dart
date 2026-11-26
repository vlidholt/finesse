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
class UnaLocalizationsDataPt extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataPt _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataPt $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataPt(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$pt timePicker = _UnaLocalizationsData$timePicker$pt._(_root);
	@override late final _UnaLocalizationsData$datePicker$pt datePicker = _UnaLocalizationsData$datePicker$pt._(_root);
	@override late final _UnaLocalizationsData$input$pt input = _UnaLocalizationsData$input$pt._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$pt keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$pt._(_root);
	@override late final _UnaLocalizationsData$dialog$pt dialog = _UnaLocalizationsData$dialog$pt._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$pt extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$pt._(UnaLocalizationsDataPt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
	@override String get period => 'Período';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$pt extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$pt._(UnaLocalizationsDataPt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Selecionar data';
}

// Path: input
class _UnaLocalizationsData$input$pt extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$pt._(UnaLocalizationsDataPt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cortar';
	@override String get copy => 'Copiar';
	@override String get paste => 'Colar';
	@override String get selectAll => 'Selecionar tudo';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$pt extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$pt._(UnaLocalizationsDataPt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Concluído';
}

// Path: dialog
class _UnaLocalizationsData$dialog$pt extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$pt._(UnaLocalizationsDataPt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataPt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Fechar';
	@override String get dismiss => 'Dispensar';
}

/// The flat map containing all translations for locale <pt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataPt {
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
