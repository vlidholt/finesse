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
class FinesseLocalizationsDataTr extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataTr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.tr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tr>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataTr _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataTr $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataTr(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$tr timePicker = _FinesseLocalizationsData$timePicker$tr._(_root);
	@override late final _FinesseLocalizationsData$datePicker$tr datePicker = _FinesseLocalizationsData$datePicker$tr._(_root);
	@override late final _FinesseLocalizationsData$input$tr input = _FinesseLocalizationsData$input$tr._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$tr keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$tr._(_root);
	@override late final _FinesseLocalizationsData$dialog$tr dialog = _FinesseLocalizationsData$dialog$tr._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$tr extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$tr._(FinesseLocalizationsDataTr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Saat';
	@override String get minutes => 'Dakika';
	@override String get seconds => 'Saniye';
	@override String get period => 'Dönem';
	@override String get periodPlaceholder => 'ÖÖ';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$tr extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$tr._(FinesseLocalizationsDataTr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Tarih seçin';
}

// Path: input
class _FinesseLocalizationsData$input$tr extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$tr._(FinesseLocalizationsDataTr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kes';
	@override String get copy => 'Kopyala';
	@override String get paste => 'Yapıştır';
	@override String get selectAll => 'Tümünü seç';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$tr extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$tr._(FinesseLocalizationsDataTr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get done => 'Tamam';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$tr extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$tr._(FinesseLocalizationsDataTr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get close => 'Kapat';
	@override String get dismiss => 'Kapat';
}

/// The flat map containing all translations for locale <tr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataTr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Saat',
			'timePicker.minutes' => 'Dakika',
			'timePicker.seconds' => 'Saniye',
			'timePicker.period' => 'Dönem',
			'timePicker.periodPlaceholder' => 'ÖÖ',
			'datePicker.selectDate' => 'Tarih seçin',
			'input.cut' => 'Kes',
			'input.copy' => 'Kopyala',
			'input.paste' => 'Yapıştır',
			'input.selectAll' => 'Tümünü seç',
			'keyboardToolbar.done' => 'Tamam',
			'dialog.close' => 'Kapat',
			'dialog.dismiss' => 'Kapat',
			_ => null,
		};
	}
}
