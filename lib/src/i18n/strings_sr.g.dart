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
class FinesseLocalizationsDataSr extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataSr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.sr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sr>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataSr _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataSr $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataSr(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$sr timePicker = _FinesseLocalizationsData$timePicker$sr._(_root);
	@override late final _FinesseLocalizationsData$datePicker$sr datePicker = _FinesseLocalizationsData$datePicker$sr._(_root);
	@override late final _FinesseLocalizationsData$input$sr input = _FinesseLocalizationsData$input$sr._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$sr keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$sr._(_root);
	@override late final _FinesseLocalizationsData$dialog$sr dialog = _FinesseLocalizationsData$dialog$sr._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$sr extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$sr._(FinesseLocalizationsDataSr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Sati';
	@override String get minutes => 'Minuti';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Period';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$sr extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$sr._(FinesseLocalizationsDataSr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Izaberi datum';
}

// Path: input
class _FinesseLocalizationsData$input$sr extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$sr._(FinesseLocalizationsDataSr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Iseci';
	@override String get copy => 'Kopiraj';
	@override String get paste => 'Nalepi';
	@override String get selectAll => 'Izaberi sve';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$sr extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$sr._(FinesseLocalizationsDataSr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gotovo';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$sr extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$sr._(FinesseLocalizationsDataSr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get close => 'Затвори';
	@override String get dismiss => 'Одбаци';
}

/// The flat map containing all translations for locale <sr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataSr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Sati',
			'timePicker.minutes' => 'Minuti',
			'timePicker.seconds' => 'Sekunde',
			'timePicker.period' => 'Period',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Izaberi datum',
			'input.cut' => 'Iseci',
			'input.copy' => 'Kopiraj',
			'input.paste' => 'Nalepi',
			'input.selectAll' => 'Izaberi sve',
			'keyboardToolbar.done' => 'Gotovo',
			'dialog.close' => 'Затвори',
			'dialog.dismiss' => 'Одбаци',
			_ => null,
		};
	}
}
