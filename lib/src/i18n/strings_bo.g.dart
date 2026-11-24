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
class FinesseLocalizationsDataBo extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataBo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.bo,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bo>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataBo _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataBo $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataBo(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$bo timePicker = _FinesseLocalizationsData$timePicker$bo._(_root);
	@override late final _FinesseLocalizationsData$datePicker$bo datePicker = _FinesseLocalizationsData$datePicker$bo._(_root);
	@override late final _FinesseLocalizationsData$input$bo input = _FinesseLocalizationsData$input$bo._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$bo keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$bo._(_root);
	@override late final _FinesseLocalizationsData$dialog$bo dialog = _FinesseLocalizationsData$dialog$bo._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$bo extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$bo._(FinesseLocalizationsDataBo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ཆུ་ཚོད།';
	@override String get minutes => 'སྐར་མ།';
	@override String get seconds => 'སྐར་ཆ།';
	@override String get period => 'དུས་ཚོད།';
	@override String get periodPlaceholder => 'སྔ་དྲོ།';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$bo extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$bo._(FinesseLocalizationsDataBo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ཚེས་གྲངས་འདེམས།';
}

// Path: input
class _FinesseLocalizationsData$input$bo extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$bo._(FinesseLocalizationsDataBo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'གཅོད།';
	@override String get copy => 'བེད་སྤྱོད།';
	@override String get paste => 'སྦྱར།';
	@override String get selectAll => 'ཚང་མ་འདེམས།';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$bo extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$bo._(FinesseLocalizationsDataBo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get done => 'འགྲུབ།';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$bo extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$bo._(FinesseLocalizationsDataBo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get close => 'སྒོ་རྒྱག་པ།';
	@override String get dismiss => 'འདོར་བ།';
}

/// The flat map containing all translations for locale <bo>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataBo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ཆུ་ཚོད།',
			'timePicker.minutes' => 'སྐར་མ།',
			'timePicker.seconds' => 'སྐར་ཆ།',
			'timePicker.period' => 'དུས་ཚོད།',
			'timePicker.periodPlaceholder' => 'སྔ་དྲོ།',
			'datePicker.selectDate' => 'ཚེས་གྲངས་འདེམས།',
			'input.cut' => 'གཅོད།',
			'input.copy' => 'བེད་སྤྱོད།',
			'input.paste' => 'སྦྱར།',
			'input.selectAll' => 'ཚང་མ་འདེམས།',
			'keyboardToolbar.done' => 'འགྲུབ།',
			'dialog.close' => 'སྒོ་རྒྱག་པ།',
			'dialog.dismiss' => 'འདོར་བ།',
			_ => null,
		};
	}
}
