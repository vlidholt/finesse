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
class UnaLocalizationsDataLv extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataLv({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.lv,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <lv>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataLv _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataLv $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataLv(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$lv timePicker = _UnaLocalizationsData$timePicker$lv._(_root);
	@override late final _UnaLocalizationsData$datePicker$lv datePicker = _UnaLocalizationsData$datePicker$lv._(_root);
	@override late final _UnaLocalizationsData$input$lv input = _UnaLocalizationsData$input$lv._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$lv keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$lv._(_root);
	@override late final _UnaLocalizationsData$dialog$lv dialog = _UnaLocalizationsData$dialog$lv._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$lv extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$lv._(UnaLocalizationsDataLv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Stundas';
	@override String get minutes => 'Minūtes';
	@override String get seconds => 'Sekundes';
	@override String get period => 'Periods';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$lv extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$lv._(UnaLocalizationsDataLv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Atlasīt datumu';
}

// Path: input
class _UnaLocalizationsData$input$lv extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$lv._(UnaLocalizationsDataLv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Izgriezt';
	@override String get copy => 'Kopēt';
	@override String get paste => 'Ielīmēt';
	@override String get selectAll => 'Atlasīt visu';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$lv extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$lv._(UnaLocalizationsDataLv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gatavs';
}

// Path: dialog
class _UnaLocalizationsData$dialog$lv extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$lv._(UnaLocalizationsDataLv root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLv _root; // ignore: unused_field

	// Translations
	@override String get close => 'Aizvērt';
	@override String get dismiss => 'Nerādīt';
}

/// The flat map containing all translations for locale <lv>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataLv {
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
