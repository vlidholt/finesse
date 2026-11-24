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
class FinesseLocalizationsDataSl extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataSl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.sl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sl>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataSl _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataSl $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataSl(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$sl timePicker = _FinesseLocalizationsData$timePicker$sl._(_root);
	@override late final _FinesseLocalizationsData$datePicker$sl datePicker = _FinesseLocalizationsData$datePicker$sl._(_root);
	@override late final _FinesseLocalizationsData$input$sl input = _FinesseLocalizationsData$input$sl._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$sl keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$sl._(_root);
	@override late final _FinesseLocalizationsData$dialog$sl dialog = _FinesseLocalizationsData$dialog$sl._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$sl extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$sl._(FinesseLocalizationsDataSl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ure';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Obdobje';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$sl extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$sl._(FinesseLocalizationsDataSl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Izberite datum';
}

// Path: input
class _FinesseLocalizationsData$input$sl extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$sl._(FinesseLocalizationsDataSl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Izreži';
	@override String get copy => 'Kopiraj';
	@override String get paste => 'Prilepi';
	@override String get selectAll => 'Izberi vse';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$sl extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$sl._(FinesseLocalizationsDataSl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Končano';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$sl extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$sl._(FinesseLocalizationsDataSl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zapri';
	@override String get dismiss => 'Opusti';
}

/// The flat map containing all translations for locale <sl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataSl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Ure',
			'timePicker.minutes' => 'Minute',
			'timePicker.seconds' => 'Sekunde',
			'timePicker.period' => 'Obdobje',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Izberite datum',
			'input.cut' => 'Izreži',
			'input.copy' => 'Kopiraj',
			'input.paste' => 'Prilepi',
			'input.selectAll' => 'Izberi vse',
			'keyboardToolbar.done' => 'Končano',
			'dialog.close' => 'Zapri',
			'dialog.dismiss' => 'Opusti',
			_ => null,
		};
	}
}
