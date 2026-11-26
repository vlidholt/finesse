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
class UnaLocalizationsDataTr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataTr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.tr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tr>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataTr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataTr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataTr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$tr timePicker = _UnaLocalizationsData$timePicker$tr._(_root);
	@override late final _UnaLocalizationsData$datePicker$tr datePicker = _UnaLocalizationsData$datePicker$tr._(_root);
	@override late final _UnaLocalizationsData$input$tr input = _UnaLocalizationsData$input$tr._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$tr keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$tr._(_root);
	@override late final _UnaLocalizationsData$dialog$tr dialog = _UnaLocalizationsData$dialog$tr._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$tr extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$tr._(UnaLocalizationsDataTr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Saat';
	@override String get minutes => 'Dakika';
	@override String get seconds => 'Saniye';
	@override String get period => 'Dönem';
	@override String get periodPlaceholder => 'ÖÖ';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$tr extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$tr._(UnaLocalizationsDataTr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Tarih seçin';
}

// Path: input
class _UnaLocalizationsData$input$tr extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$tr._(UnaLocalizationsDataTr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kes';
	@override String get copy => 'Kopyala';
	@override String get paste => 'Yapıştır';
	@override String get selectAll => 'Tümünü seç';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$tr extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$tr._(UnaLocalizationsDataTr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get done => 'Tamam';
}

// Path: dialog
class _UnaLocalizationsData$dialog$tr extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$tr._(UnaLocalizationsDataTr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTr _root; // ignore: unused_field

	// Translations
	@override String get close => 'Kapat';
	@override String get dismiss => 'Kapat';
}

/// The flat map containing all translations for locale <tr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataTr {
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
