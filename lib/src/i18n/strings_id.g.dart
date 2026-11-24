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
class FinesseLocalizationsDataId extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataId({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.id,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <id>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataId _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataId $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataId(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$id timePicker = _FinesseLocalizationsData$timePicker$id._(_root);
	@override late final _FinesseLocalizationsData$datePicker$id datePicker = _FinesseLocalizationsData$datePicker$id._(_root);
	@override late final _FinesseLocalizationsData$input$id input = _FinesseLocalizationsData$input$id._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$id keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$id._(_root);
	@override late final _FinesseLocalizationsData$dialog$id dialog = _FinesseLocalizationsData$dialog$id._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$id extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$id._(FinesseLocalizationsDataId root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Jam';
	@override String get minutes => 'Menit';
	@override String get seconds => 'Detik';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$id extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$id._(FinesseLocalizationsDataId root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pilih tanggal';
}

// Path: input
class _FinesseLocalizationsData$input$id extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$id._(FinesseLocalizationsDataId root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Potong';
	@override String get copy => 'Salin';
	@override String get paste => 'Tempel';
	@override String get selectAll => 'Pilih Semua';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$id extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$id._(FinesseLocalizationsDataId root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get done => 'Selesai';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$id extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$id._(FinesseLocalizationsDataId root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get close => 'Tutup';
	@override String get dismiss => 'Tutup';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataId {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Jam',
			'timePicker.minutes' => 'Menit',
			'timePicker.seconds' => 'Detik',
			'timePicker.period' => 'Periode',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Pilih tanggal',
			'input.cut' => 'Potong',
			'input.copy' => 'Salin',
			'input.paste' => 'Tempel',
			'input.selectAll' => 'Pilih Semua',
			'keyboardToolbar.done' => 'Selesai',
			'dialog.close' => 'Tutup',
			'dialog.dismiss' => 'Tutup',
			_ => null,
		};
	}
}
