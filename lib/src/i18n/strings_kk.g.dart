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
class UnaLocalizationsDataKk extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataKk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.kk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <kk>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataKk _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataKk $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataKk(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$kk timePicker = _UnaLocalizationsData$timePicker$kk._(_root);
	@override late final _UnaLocalizationsData$datePicker$kk datePicker = _UnaLocalizationsData$datePicker$kk._(_root);
	@override late final _UnaLocalizationsData$input$kk input = _UnaLocalizationsData$input$kk._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$kk keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$kk._(_root);
	@override late final _UnaLocalizationsData$dialog$kk dialog = _UnaLocalizationsData$dialog$kk._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$kk extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$kk._(UnaLocalizationsDataKk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Сағат';
	@override String get minutes => 'Минут';
	@override String get seconds => 'Секунд';
	@override String get period => 'Кезең';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$kk extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$kk._(UnaLocalizationsDataKk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Күнді таңдаңыз';
}

// Path: input
class _UnaLocalizationsData$input$kk extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$kk._(UnaLocalizationsDataKk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Кесу';
	@override String get copy => 'Көшіру';
	@override String get paste => 'Қою';
	@override String get selectAll => 'Барлығын таңдау';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$kk extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$kk._(UnaLocalizationsDataKk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get done => 'Дайын';
}

// Path: dialog
class _UnaLocalizationsData$dialog$kk extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$kk._(UnaLocalizationsDataKk root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKk _root; // ignore: unused_field

	// Translations
	@override String get close => 'Жабу';
	@override String get dismiss => 'Жабу';
}

/// The flat map containing all translations for locale <kk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataKk {
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
