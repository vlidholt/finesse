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
class UnaLocalizationsDataIs extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataIs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.icelandic,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <is>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataIs _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataIs $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataIs(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$is timePicker = _UnaLocalizationsData$timePicker$is._(_root);
	@override late final _UnaLocalizationsData$datePicker$is datePicker = _UnaLocalizationsData$datePicker$is._(_root);
	@override late final _UnaLocalizationsData$input$is input = _UnaLocalizationsData$input$is._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$is keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$is._(_root);
	@override late final _UnaLocalizationsData$dialog$is dialog = _UnaLocalizationsData$dialog$is._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$is extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$is._(UnaLocalizationsDataIs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Klukkustundir';
	@override String get minutes => 'Mínútur';
	@override String get seconds => 'Sekúndur';
	@override String get period => 'Tímabil';
	@override String get periodPlaceholder => 'fh';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$is extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$is._(UnaLocalizationsDataIs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Veldu dagsetningu';
}

// Path: input
class _UnaLocalizationsData$input$is extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$is._(UnaLocalizationsDataIs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Klippa';
	@override String get copy => 'Afrita';
	@override String get paste => 'Líma';
	@override String get selectAll => 'Velja allt';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$is extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$is._(UnaLocalizationsDataIs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Lokið';
}

// Path: dialog
class _UnaLocalizationsData$dialog$is extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$is._(UnaLocalizationsDataIs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataIs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Loka';
	@override String get dismiss => 'Hunsa';
}

/// The flat map containing all translations for locale <is>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataIs {
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
