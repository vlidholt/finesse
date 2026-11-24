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
class FinesseLocalizationsDataSv extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataSv({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.sv,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sv>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataSv _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataSv $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataSv(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$sv timePicker = _FinesseLocalizationsData$timePicker$sv._(_root);
	@override late final _FinesseLocalizationsData$datePicker$sv datePicker = _FinesseLocalizationsData$datePicker$sv._(_root);
	@override late final _FinesseLocalizationsData$input$sv input = _FinesseLocalizationsData$input$sv._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$sv keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$sv._(_root);
	@override late final _FinesseLocalizationsData$dialog$sv dialog = _FinesseLocalizationsData$dialog$sv._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$sv extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$sv._(FinesseLocalizationsDataSv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Timmar';
	@override String get minutes => 'Minuter';
	@override String get seconds => 'Sekunder';
	@override String get period => 'Period';
	@override String get periodPlaceholder => 'FM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$sv extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$sv._(FinesseLocalizationsDataSv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Välj datum';
}

// Path: input
class _FinesseLocalizationsData$input$sv extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$sv._(FinesseLocalizationsDataSv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klipp ut';
	@override String get copy => 'Kopiera';
	@override String get paste => 'Klistra in';
	@override String get selectAll => 'Markera allt';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$sv extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$sv._(FinesseLocalizationsDataSv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get done => 'Klar';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$sv extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$sv._(FinesseLocalizationsDataSv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get close => 'Stäng';
	@override String get dismiss => 'Stäng';
}

/// The flat map containing all translations for locale <sv>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataSv {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Timmar',
			'timePicker.minutes' => 'Minuter',
			'timePicker.seconds' => 'Sekunder',
			'timePicker.period' => 'Period',
			'timePicker.periodPlaceholder' => 'FM',
			'datePicker.selectDate' => 'Välj datum',
			'input.cut' => 'Klipp ut',
			'input.copy' => 'Kopiera',
			'input.paste' => 'Klistra in',
			'input.selectAll' => 'Markera allt',
			'keyboardToolbar.done' => 'Klar',
			'dialog.close' => 'Stäng',
			'dialog.dismiss' => 'Stäng',
			_ => null,
		};
	}
}
