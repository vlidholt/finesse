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
class FinesseLocalizationsDataBg extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataBg({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.bg,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bg>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataBg _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataBg $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataBg(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$bg timePicker = _FinesseLocalizationsData$timePicker$bg._(_root);
	@override late final _FinesseLocalizationsData$datePicker$bg datePicker = _FinesseLocalizationsData$datePicker$bg._(_root);
	@override late final _FinesseLocalizationsData$input$bg input = _FinesseLocalizationsData$input$bg._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$bg keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$bg._(_root);
	@override late final _FinesseLocalizationsData$dialog$bg dialog = _FinesseLocalizationsData$dialog$bg._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$bg extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$bg._(FinesseLocalizationsDataBg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Часове';
	@override String get minutes => 'Минути';
	@override String get seconds => 'Секунди';
	@override String get period => 'Период';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$bg extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$bg._(FinesseLocalizationsDataBg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Изберете дата';
}

// Path: input
class _FinesseLocalizationsData$input$bg extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$bg._(FinesseLocalizationsDataBg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Изрежи';
	@override String get copy => 'Копирай';
	@override String get paste => 'Постави';
	@override String get selectAll => 'Избери всичко';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$bg extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$bg._(FinesseLocalizationsDataBg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get done => 'Готово';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$bg extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$bg._(FinesseLocalizationsDataBg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get close => 'Затваряне';
	@override String get dismiss => 'Отхвърляне';
}

/// The flat map containing all translations for locale <bg>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataBg {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Часове',
			'timePicker.minutes' => 'Минути',
			'timePicker.seconds' => 'Секунди',
			'timePicker.period' => 'Период',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Изберете дата',
			'input.cut' => 'Изрежи',
			'input.copy' => 'Копирай',
			'input.paste' => 'Постави',
			'input.selectAll' => 'Избери всичко',
			'keyboardToolbar.done' => 'Готово',
			'dialog.close' => 'Затваряне',
			'dialog.dismiss' => 'Отхвърляне',
			_ => null,
		};
	}
}
