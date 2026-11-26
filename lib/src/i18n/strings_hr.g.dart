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
class UnaLocalizationsDataHr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataHr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.hr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hr>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataHr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataHr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataHr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$hr timePicker = _UnaLocalizationsData$timePicker$hr._(_root);
	@override late final _UnaLocalizationsData$datePicker$hr datePicker = _UnaLocalizationsData$datePicker$hr._(_root);
	@override late final _UnaLocalizationsData$input$hr input = _UnaLocalizationsData$input$hr._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$hr keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$hr._(_root);
	@override late final _UnaLocalizationsData$dialog$hr dialog = _UnaLocalizationsData$dialog$hr._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$hr extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$hr._(UnaLocalizationsDataHr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Sati';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Razdoblje';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$hr extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$hr._(UnaLocalizationsDataHr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Odaberite datum';
}

// Path: input
class _UnaLocalizationsData$input$hr extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$hr._(UnaLocalizationsDataHr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Izreži';
	@override String get copy => 'Kopiraj';
	@override String get paste => 'Zalijepi';
	@override String get selectAll => 'Odaberi sve';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$hr extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$hr._(UnaLocalizationsDataHr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gotovo';
}

// Path: dialog
class _UnaLocalizationsData$dialog$hr extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$hr._(UnaLocalizationsDataHr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHr _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zatvori';
	@override String get dismiss => 'Odbaci';
}

/// The flat map containing all translations for locale <hr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataHr {
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
