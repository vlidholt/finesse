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
class FinesseLocalizationsDataMs extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataMs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ms,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ms>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataMs _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataMs $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataMs(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ms timePicker = _FinesseLocalizationsData$timePicker$ms._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ms datePicker = _FinesseLocalizationsData$datePicker$ms._(_root);
	@override late final _FinesseLocalizationsData$input$ms input = _FinesseLocalizationsData$input$ms._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ms keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ms._(_root);
	@override late final _FinesseLocalizationsData$dialog$ms dialog = _FinesseLocalizationsData$dialog$ms._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ms extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ms._(FinesseLocalizationsDataMs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Jam';
	@override String get minutes => 'Minit';
	@override String get seconds => 'Saat';
	@override String get period => 'Tempoh';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ms extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ms._(FinesseLocalizationsDataMs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pilih tarikh';
}

// Path: input
class _FinesseLocalizationsData$input$ms extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ms._(FinesseLocalizationsDataMs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Potong';
	@override String get copy => 'Salin';
	@override String get paste => 'Tampal';
	@override String get selectAll => 'Pilih Semua';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ms extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ms._(FinesseLocalizationsDataMs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Selesai';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ms extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ms._(FinesseLocalizationsDataMs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Tutup';
	@override String get dismiss => 'Tolak';
}

/// The flat map containing all translations for locale <ms>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataMs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Jam',
			'timePicker.minutes' => 'Minit',
			'timePicker.seconds' => 'Saat',
			'timePicker.period' => 'Tempoh',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Pilih tarikh',
			'input.cut' => 'Potong',
			'input.copy' => 'Salin',
			'input.paste' => 'Tampal',
			'input.selectAll' => 'Pilih Semua',
			'keyboardToolbar.done' => 'Selesai',
			'dialog.close' => 'Tutup',
			'dialog.dismiss' => 'Tolak',
			_ => null,
		};
	}
}
