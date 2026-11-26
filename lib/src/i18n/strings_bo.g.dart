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
class UnaLocalizationsDataBo extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataBo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.bo,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bo>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataBo _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataBo $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataBo(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$bo timePicker = _UnaLocalizationsData$timePicker$bo._(_root);
	@override late final _UnaLocalizationsData$datePicker$bo datePicker = _UnaLocalizationsData$datePicker$bo._(_root);
	@override late final _UnaLocalizationsData$input$bo input = _UnaLocalizationsData$input$bo._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$bo keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$bo._(_root);
	@override late final _UnaLocalizationsData$dialog$bo dialog = _UnaLocalizationsData$dialog$bo._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$bo extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$bo._(UnaLocalizationsDataBo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ཆུ་ཚོད།';
	@override String get minutes => 'སྐར་མ།';
	@override String get seconds => 'སྐར་ཆ།';
	@override String get period => 'དུས་ཚོད།';
	@override String get periodPlaceholder => 'སྔ་དྲོ།';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$bo extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$bo._(UnaLocalizationsDataBo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ཚེས་གྲངས་འདེམས།';
}

// Path: input
class _UnaLocalizationsData$input$bo extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$bo._(UnaLocalizationsDataBo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'གཅོད།';
	@override String get copy => 'བེད་སྤྱོད།';
	@override String get paste => 'སྦྱར།';
	@override String get selectAll => 'ཚང་མ་འདེམས།';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$bo extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$bo._(UnaLocalizationsDataBo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get done => 'འགྲུབ།';
}

// Path: dialog
class _UnaLocalizationsData$dialog$bo extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$bo._(UnaLocalizationsDataBo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBo _root; // ignore: unused_field

	// Translations
	@override String get close => 'སྒོ་རྒྱག་པ།';
	@override String get dismiss => 'འདོར་བ།';
}

/// The flat map containing all translations for locale <bo>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataBo {
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
