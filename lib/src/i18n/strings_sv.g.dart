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
class UnaLocalizationsDataSv extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataSv({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.sv,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sv>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataSv _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataSv $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataSv(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$sv timePicker = _UnaLocalizationsData$timePicker$sv._(_root);
	@override late final _UnaLocalizationsData$datePicker$sv datePicker = _UnaLocalizationsData$datePicker$sv._(_root);
	@override late final _UnaLocalizationsData$input$sv input = _UnaLocalizationsData$input$sv._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$sv keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$sv._(_root);
	@override late final _UnaLocalizationsData$dialog$sv dialog = _UnaLocalizationsData$dialog$sv._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$sv extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$sv._(UnaLocalizationsDataSv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Timmar';
	@override String get minutes => 'Minuter';
	@override String get seconds => 'Sekunder';
	@override String get period => 'Period';
	@override String get periodPlaceholder => 'FM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$sv extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$sv._(UnaLocalizationsDataSv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Välj datum';
}

// Path: input
class _UnaLocalizationsData$input$sv extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$sv._(UnaLocalizationsDataSv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klipp ut';
	@override String get copy => 'Kopiera';
	@override String get paste => 'Klistra in';
	@override String get selectAll => 'Markera allt';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$sv extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$sv._(UnaLocalizationsDataSv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get done => 'Klar';
}

// Path: dialog
class _UnaLocalizationsData$dialog$sv extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$sv._(UnaLocalizationsDataSv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSv _root; // ignore: unused_field

	// Translations
	@override String get close => 'Stäng';
	@override String get dismiss => 'Stäng';
}

/// The flat map containing all translations for locale <sv>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataSv {
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
