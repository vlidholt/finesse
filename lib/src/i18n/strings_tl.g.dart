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
class FinesseLocalizationsDataTl extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataTl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.tl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tl>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataTl _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataTl $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataTl(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$tl timePicker = _FinesseLocalizationsData$timePicker$tl._(_root);
	@override late final _FinesseLocalizationsData$datePicker$tl datePicker = _FinesseLocalizationsData$datePicker$tl._(_root);
	@override late final _FinesseLocalizationsData$input$tl input = _FinesseLocalizationsData$input$tl._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$tl keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$tl._(_root);
	@override late final _FinesseLocalizationsData$dialog$tl dialog = _FinesseLocalizationsData$dialog$tl._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$tl extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$tl._(FinesseLocalizationsDataTl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Oras';
	@override String get minutes => 'Minuto';
	@override String get seconds => 'Segundo';
	@override String get period => 'Panahon';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$tl extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$tl._(FinesseLocalizationsDataTl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pumili ng petsa';
}

// Path: input
class _FinesseLocalizationsData$input$tl extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$tl._(FinesseLocalizationsDataTl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Gupitin';
	@override String get copy => 'Kopyahin';
	@override String get paste => 'I-paste';
	@override String get selectAll => 'Piliin lahat';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$tl extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$tl._(FinesseLocalizationsDataTl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Tapos na';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$tl extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$tl._(FinesseLocalizationsDataTl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Isara';
	@override String get dismiss => 'I-dismiss';
}

/// The flat map containing all translations for locale <tl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataTl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Oras',
			'timePicker.minutes' => 'Minuto',
			'timePicker.seconds' => 'Segundo',
			'timePicker.period' => 'Panahon',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Pumili ng petsa',
			'input.cut' => 'Gupitin',
			'input.copy' => 'Kopyahin',
			'input.paste' => 'I-paste',
			'input.selectAll' => 'Piliin lahat',
			'keyboardToolbar.done' => 'Tapos na',
			'dialog.close' => 'Isara',
			'dialog.dismiss' => 'I-dismiss',
			_ => null,
		};
	}
}
