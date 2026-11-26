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
class UnaLocalizationsDataMs extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataMs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ms,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ms>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataMs _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataMs $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataMs(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ms timePicker = _UnaLocalizationsData$timePicker$ms._(_root);
	@override late final _UnaLocalizationsData$datePicker$ms datePicker = _UnaLocalizationsData$datePicker$ms._(_root);
	@override late final _UnaLocalizationsData$input$ms input = _UnaLocalizationsData$input$ms._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ms keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ms._(_root);
	@override late final _UnaLocalizationsData$dialog$ms dialog = _UnaLocalizationsData$dialog$ms._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ms extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ms._(UnaLocalizationsDataMs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Jam';
	@override String get minutes => 'Minit';
	@override String get seconds => 'Saat';
	@override String get period => 'Tempoh';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ms extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ms._(UnaLocalizationsDataMs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pilih tarikh';
}

// Path: input
class _UnaLocalizationsData$input$ms extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ms._(UnaLocalizationsDataMs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Potong';
	@override String get copy => 'Salin';
	@override String get paste => 'Tampal';
	@override String get selectAll => 'Pilih Semua';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ms extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ms._(UnaLocalizationsDataMs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Selesai';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ms extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ms._(UnaLocalizationsDataMs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Tutup';
	@override String get dismiss => 'Tolak';
}

/// The flat map containing all translations for locale <ms>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataMs {
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
