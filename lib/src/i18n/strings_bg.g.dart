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
class UnaLocalizationsDataBg extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataBg({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.bg,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bg>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataBg _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataBg $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataBg(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$bg timePicker = _UnaLocalizationsData$timePicker$bg._(_root);
	@override late final _UnaLocalizationsData$datePicker$bg datePicker = _UnaLocalizationsData$datePicker$bg._(_root);
	@override late final _UnaLocalizationsData$input$bg input = _UnaLocalizationsData$input$bg._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$bg keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$bg._(_root);
	@override late final _UnaLocalizationsData$dialog$bg dialog = _UnaLocalizationsData$dialog$bg._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$bg extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$bg._(UnaLocalizationsDataBg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Часове';
	@override String get minutes => 'Минути';
	@override String get seconds => 'Секунди';
	@override String get period => 'Период';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$bg extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$bg._(UnaLocalizationsDataBg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Изберете дата';
}

// Path: input
class _UnaLocalizationsData$input$bg extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$bg._(UnaLocalizationsDataBg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Изрежи';
	@override String get copy => 'Копирай';
	@override String get paste => 'Постави';
	@override String get selectAll => 'Избери всичко';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$bg extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$bg._(UnaLocalizationsDataBg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get done => 'Готово';
}

// Path: dialog
class _UnaLocalizationsData$dialog$bg extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$bg._(UnaLocalizationsDataBg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBg _root; // ignore: unused_field

	// Translations
	@override String get close => 'Затваряне';
	@override String get dismiss => 'Отхвърляне';
}

/// The flat map containing all translations for locale <bg>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataBg {
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
