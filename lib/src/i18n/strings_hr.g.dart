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
class FinesseLocalizationsDataHr extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataHr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.hr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hr>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataHr _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataHr $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataHr(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$hr timePicker = _FinesseLocalizationsData$timePicker$hr._(_root);
	@override late final _FinesseLocalizationsData$datePicker$hr datePicker = _FinesseLocalizationsData$datePicker$hr._(_root);
	@override late final _FinesseLocalizationsData$input$hr input = _FinesseLocalizationsData$input$hr._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$hr keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$hr._(_root);
	@override late final _FinesseLocalizationsData$dialog$hr dialog = _FinesseLocalizationsData$dialog$hr._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$hr extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$hr._(FinesseLocalizationsDataHr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Sati';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Razdoblje';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$hr extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$hr._(FinesseLocalizationsDataHr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Odaberite datum';
}

// Path: input
class _FinesseLocalizationsData$input$hr extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$hr._(FinesseLocalizationsDataHr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Izreži';
	@override String get copy => 'Kopiraj';
	@override String get paste => 'Zalijepi';
	@override String get selectAll => 'Odaberi sve';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$hr extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$hr._(FinesseLocalizationsDataHr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gotovo';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$hr extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$hr._(FinesseLocalizationsDataHr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zatvori';
	@override String get dismiss => 'Odbaci';
}

/// The flat map containing all translations for locale <hr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataHr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Sati',
			'timePicker.minutes' => 'Minute',
			'timePicker.seconds' => 'Sekunde',
			'timePicker.period' => 'Razdoblje',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Odaberite datum',
			'input.cut' => 'Izreži',
			'input.copy' => 'Kopiraj',
			'input.paste' => 'Zalijepi',
			'input.selectAll' => 'Odaberi sve',
			'keyboardToolbar.done' => 'Gotovo',
			'dialog.close' => 'Zatvori',
			'dialog.dismiss' => 'Odbaci',
			_ => null,
		};
	}
}
