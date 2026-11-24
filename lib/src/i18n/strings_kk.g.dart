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
class FinesseLocalizationsDataKk extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataKk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.kk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <kk>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataKk _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataKk $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataKk(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$kk timePicker = _FinesseLocalizationsData$timePicker$kk._(_root);
	@override late final _FinesseLocalizationsData$datePicker$kk datePicker = _FinesseLocalizationsData$datePicker$kk._(_root);
	@override late final _FinesseLocalizationsData$input$kk input = _FinesseLocalizationsData$input$kk._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$kk keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$kk._(_root);
	@override late final _FinesseLocalizationsData$dialog$kk dialog = _FinesseLocalizationsData$dialog$kk._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$kk extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$kk._(FinesseLocalizationsDataKk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Сағат';
	@override String get minutes => 'Минут';
	@override String get seconds => 'Секунд';
	@override String get period => 'Кезең';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$kk extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$kk._(FinesseLocalizationsDataKk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Күнді таңдаңыз';
}

// Path: input
class _FinesseLocalizationsData$input$kk extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$kk._(FinesseLocalizationsDataKk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Кесу';
	@override String get copy => 'Көшіру';
	@override String get paste => 'Қою';
	@override String get selectAll => 'Барлығын таңдау';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$kk extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$kk._(FinesseLocalizationsDataKk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get done => 'Дайын';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$kk extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$kk._(FinesseLocalizationsDataKk root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get close => 'Жабу';
	@override String get dismiss => 'Жабу';
}

/// The flat map containing all translations for locale <kk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataKk {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Сағат',
			'timePicker.minutes' => 'Минут',
			'timePicker.seconds' => 'Секунд',
			'timePicker.period' => 'Кезең',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Күнді таңдаңыз',
			'input.cut' => 'Кесу',
			'input.copy' => 'Көшіру',
			'input.paste' => 'Қою',
			'input.selectAll' => 'Барлығын таңдау',
			'keyboardToolbar.done' => 'Дайын',
			'dialog.close' => 'Жабу',
			'dialog.dismiss' => 'Жабу',
			_ => null,
		};
	}
}
