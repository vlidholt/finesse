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
class FinesseLocalizationsDataEt extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataEt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.et,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <et>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataEt _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataEt $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataEt(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$et timePicker = _FinesseLocalizationsData$timePicker$et._(_root);
	@override late final _FinesseLocalizationsData$datePicker$et datePicker = _FinesseLocalizationsData$datePicker$et._(_root);
	@override late final _FinesseLocalizationsData$input$et input = _FinesseLocalizationsData$input$et._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$et keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$et._(_root);
	@override late final _FinesseLocalizationsData$dialog$et dialog = _FinesseLocalizationsData$dialog$et._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$et extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$et._(FinesseLocalizationsDataEt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Tunnid';
	@override String get minutes => 'Minutid';
	@override String get seconds => 'Sekundid';
	@override String get period => 'Periood';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$et extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$et._(FinesseLocalizationsDataEt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vali kuupäev';
}

// Path: input
class _FinesseLocalizationsData$input$et extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$et._(FinesseLocalizationsDataEt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Lõika';
	@override String get copy => 'Kopeeri';
	@override String get paste => 'Kleebi';
	@override String get selectAll => 'Vali kõik';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$et extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$et._(FinesseLocalizationsDataEt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Valmis';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$et extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$et._(FinesseLocalizationsDataEt root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Sule';
	@override String get dismiss => 'Loobu';
}

/// The flat map containing all translations for locale <et>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataEt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Tunnid',
			'timePicker.minutes' => 'Minutid',
			'timePicker.seconds' => 'Sekundid',
			'timePicker.period' => 'Periood',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Vali kuupäev',
			'input.cut' => 'Lõika',
			'input.copy' => 'Kopeeri',
			'input.paste' => 'Kleebi',
			'input.selectAll' => 'Vali kõik',
			'keyboardToolbar.done' => 'Valmis',
			'dialog.close' => 'Sule',
			'dialog.dismiss' => 'Loobu',
			_ => null,
		};
	}
}
