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
class FinesseLocalizationsDataSw extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataSw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.sw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sw>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataSw _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataSw $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataSw(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$sw timePicker = _FinesseLocalizationsData$timePicker$sw._(_root);
	@override late final _FinesseLocalizationsData$datePicker$sw datePicker = _FinesseLocalizationsData$datePicker$sw._(_root);
	@override late final _FinesseLocalizationsData$input$sw input = _FinesseLocalizationsData$input$sw._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$sw keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$sw._(_root);
	@override late final _FinesseLocalizationsData$dialog$sw dialog = _FinesseLocalizationsData$dialog$sw._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$sw extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$sw._(FinesseLocalizationsDataSw root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Masaa';
	@override String get minutes => 'Dakika';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Kipindi';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$sw extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$sw._(FinesseLocalizationsDataSw root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Chagua tarehe';
}

// Path: input
class _FinesseLocalizationsData$input$sw extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$sw._(FinesseLocalizationsDataSw root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kata';
	@override String get copy => 'Nakili';
	@override String get paste => 'Bandika';
	@override String get selectAll => 'Chagua yote';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$sw extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$sw._(FinesseLocalizationsDataSw root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get done => 'Imekamilika';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$sw extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$sw._(FinesseLocalizationsDataSw root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get close => 'Funga';
	@override String get dismiss => 'Ondoa';
}

/// The flat map containing all translations for locale <sw>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataSw {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Masaa',
			'timePicker.minutes' => 'Dakika',
			'timePicker.seconds' => 'Sekunde',
			'timePicker.period' => 'Kipindi',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Chagua tarehe',
			'input.cut' => 'Kata',
			'input.copy' => 'Nakili',
			'input.paste' => 'Bandika',
			'input.selectAll' => 'Chagua yote',
			'keyboardToolbar.done' => 'Imekamilika',
			'dialog.close' => 'Funga',
			'dialog.dismiss' => 'Ondoa',
			_ => null,
		};
	}
}
