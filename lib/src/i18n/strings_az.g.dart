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
class FinesseLocalizationsDataAz extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataAz({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.az,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <az>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataAz _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataAz $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataAz(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$az timePicker = _FinesseLocalizationsData$timePicker$az._(_root);
	@override late final _FinesseLocalizationsData$datePicker$az datePicker = _FinesseLocalizationsData$datePicker$az._(_root);
	@override late final _FinesseLocalizationsData$input$az input = _FinesseLocalizationsData$input$az._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$az keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$az._(_root);
	@override late final _FinesseLocalizationsData$dialog$az dialog = _FinesseLocalizationsData$dialog$az._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$az extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$az._(FinesseLocalizationsDataAz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Saat';
	@override String get minutes => 'Dəqiqə';
	@override String get seconds => 'Saniyə';
	@override String get period => 'Dövr';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$az extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$az._(FinesseLocalizationsDataAz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Tarix seçin';
}

// Path: input
class _FinesseLocalizationsData$input$az extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$az._(FinesseLocalizationsDataAz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kəs';
	@override String get copy => 'Kopyala';
	@override String get paste => 'Yapışdır';
	@override String get selectAll => 'Hamısını seç';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$az extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$az._(FinesseLocalizationsDataAz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get done => 'Hazır';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$az extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$az._(FinesseLocalizationsDataAz root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get close => 'Bağlayın';
	@override String get dismiss => 'İmtina edin';
}

/// The flat map containing all translations for locale <az>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataAz {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Saat',
			'timePicker.minutes' => 'Dəqiqə',
			'timePicker.seconds' => 'Saniyə',
			'timePicker.period' => 'Dövr',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Tarix seçin',
			'input.cut' => 'Kəs',
			'input.copy' => 'Kopyala',
			'input.paste' => 'Yapışdır',
			'input.selectAll' => 'Hamısını seç',
			'keyboardToolbar.done' => 'Hazır',
			'dialog.close' => 'Bağlayın',
			'dialog.dismiss' => 'İmtina edin',
			_ => null,
		};
	}
}
