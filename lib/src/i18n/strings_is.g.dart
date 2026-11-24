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
class FinesseLocalizationsDataIs extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataIs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.icelandic,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <is>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataIs _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataIs $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataIs(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$is timePicker = _FinesseLocalizationsData$timePicker$is._(_root);
	@override late final _FinesseLocalizationsData$datePicker$is datePicker = _FinesseLocalizationsData$datePicker$is._(_root);
	@override late final _FinesseLocalizationsData$input$is input = _FinesseLocalizationsData$input$is._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$is keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$is._(_root);
	@override late final _FinesseLocalizationsData$dialog$is dialog = _FinesseLocalizationsData$dialog$is._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$is extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$is._(FinesseLocalizationsDataIs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Klukkustundir';
	@override String get minutes => 'Mínútur';
	@override String get seconds => 'Sekúndur';
	@override String get period => 'Tímabil';
	@override String get periodPlaceholder => 'fh';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$is extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$is._(FinesseLocalizationsDataIs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Veldu dagsetningu';
}

// Path: input
class _FinesseLocalizationsData$input$is extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$is._(FinesseLocalizationsDataIs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klippa';
	@override String get copy => 'Afrita';
	@override String get paste => 'Líma';
	@override String get selectAll => 'Velja allt';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$is extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$is._(FinesseLocalizationsDataIs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Lokið';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$is extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$is._(FinesseLocalizationsDataIs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Loka';
	@override String get dismiss => 'Hunsa';
}

/// The flat map containing all translations for locale <is>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataIs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Klukkustundir',
			'timePicker.minutes' => 'Mínútur',
			'timePicker.seconds' => 'Sekúndur',
			'timePicker.period' => 'Tímabil',
			'timePicker.periodPlaceholder' => 'fh',
			'datePicker.selectDate' => 'Veldu dagsetningu',
			'input.cut' => 'Klippa',
			'input.copy' => 'Afrita',
			'input.paste' => 'Líma',
			'input.selectAll' => 'Velja allt',
			'keyboardToolbar.done' => 'Lokið',
			'dialog.close' => 'Loka',
			'dialog.dismiss' => 'Hunsa',
			_ => null,
		};
	}
}
