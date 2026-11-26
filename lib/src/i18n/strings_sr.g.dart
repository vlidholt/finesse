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
class UnaLocalizationsDataSr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataSr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.sr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sr>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataSr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataSr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataSr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$sr timePicker = _UnaLocalizationsData$timePicker$sr._(_root);
	@override late final _UnaLocalizationsData$datePicker$sr datePicker = _UnaLocalizationsData$datePicker$sr._(_root);
	@override late final _UnaLocalizationsData$input$sr input = _UnaLocalizationsData$input$sr._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$sr keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$sr._(_root);
	@override late final _UnaLocalizationsData$dialog$sr dialog = _UnaLocalizationsData$dialog$sr._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$sr extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$sr._(UnaLocalizationsDataSr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Sati';
	@override String get minutes => 'Minuti';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Period';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$sr extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$sr._(UnaLocalizationsDataSr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Izaberi datum';
}

// Path: input
class _UnaLocalizationsData$input$sr extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$sr._(UnaLocalizationsDataSr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Iseci';
	@override String get copy => 'Kopiraj';
	@override String get paste => 'Nalepi';
	@override String get selectAll => 'Izaberi sve';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$sr extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$sr._(UnaLocalizationsDataSr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gotovo';
}

// Path: dialog
class _UnaLocalizationsData$dialog$sr extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$sr._(UnaLocalizationsDataSr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSr _root; // ignore: unused_field

	// Translations
	@override String get close => 'Затвори';
	@override String get dismiss => 'Одбаци';
}

/// The flat map containing all translations for locale <sr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataSr {
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
