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
class UnaLocalizationsDataId extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataId({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.id,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <id>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataId _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataId $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataId(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$id timePicker = _UnaLocalizationsData$timePicker$id._(_root);
	@override late final _UnaLocalizationsData$datePicker$id datePicker = _UnaLocalizationsData$datePicker$id._(_root);
	@override late final _UnaLocalizationsData$input$id input = _UnaLocalizationsData$input$id._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$id keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$id._(_root);
	@override late final _UnaLocalizationsData$dialog$id dialog = _UnaLocalizationsData$dialog$id._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$id extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$id._(UnaLocalizationsDataId root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Jam';
	@override String get minutes => 'Menit';
	@override String get seconds => 'Detik';
	@override String get period => 'Periode';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$id extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$id._(UnaLocalizationsDataId root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pilih tanggal';
}

// Path: input
class _UnaLocalizationsData$input$id extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$id._(UnaLocalizationsDataId root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Potong';
	@override String get copy => 'Salin';
	@override String get paste => 'Tempel';
	@override String get selectAll => 'Pilih Semua';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$id extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$id._(UnaLocalizationsDataId root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get done => 'Selesai';
}

// Path: dialog
class _UnaLocalizationsData$dialog$id extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$id._(UnaLocalizationsDataId root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataId _root; // ignore: unused_field

	// Translations
	@override String get close => 'Tutup';
	@override String get dismiss => 'Tutup';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataId {
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
