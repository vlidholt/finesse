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
class FinesseLocalizationsDataLv extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataLv({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.lv,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <lv>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataLv _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataLv $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataLv(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$lv timePicker = _FinesseLocalizationsData$timePicker$lv._(_root);
	@override late final _FinesseLocalizationsData$datePicker$lv datePicker = _FinesseLocalizationsData$datePicker$lv._(_root);
	@override late final _FinesseLocalizationsData$input$lv input = _FinesseLocalizationsData$input$lv._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$lv keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$lv._(_root);
	@override late final _FinesseLocalizationsData$dialog$lv dialog = _FinesseLocalizationsData$dialog$lv._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$lv extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$lv._(FinesseLocalizationsDataLv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Stundas';
	@override String get minutes => 'Minūtes';
	@override String get seconds => 'Sekundes';
	@override String get period => 'Periods';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$lv extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$lv._(FinesseLocalizationsDataLv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Atlasīt datumu';
}

// Path: input
class _FinesseLocalizationsData$input$lv extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$lv._(FinesseLocalizationsDataLv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Izgriezt';
	@override String get copy => 'Kopēt';
	@override String get paste => 'Ielīmēt';
	@override String get selectAll => 'Atlasīt visu';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$lv extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$lv._(FinesseLocalizationsDataLv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gatavs';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$lv extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$lv._(FinesseLocalizationsDataLv root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get close => 'Aizvērt';
	@override String get dismiss => 'Nerādīt';
}

/// The flat map containing all translations for locale <lv>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataLv {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Stundas',
			'timePicker.minutes' => 'Minūtes',
			'timePicker.seconds' => 'Sekundes',
			'timePicker.period' => 'Periods',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Atlasīt datumu',
			'input.cut' => 'Izgriezt',
			'input.copy' => 'Kopēt',
			'input.paste' => 'Ielīmēt',
			'input.selectAll' => 'Atlasīt visu',
			'keyboardToolbar.done' => 'Gatavs',
			'dialog.close' => 'Aizvērt',
			'dialog.dismiss' => 'Nerādīt',
			_ => null,
		};
	}
}
