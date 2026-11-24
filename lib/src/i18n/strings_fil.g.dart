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
class FinesseLocalizationsDataFil extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataFil({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.fil,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fil>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataFil _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataFil $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataFil(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$fil timePicker = _FinesseLocalizationsData$timePicker$fil._(_root);
	@override late final _FinesseLocalizationsData$datePicker$fil datePicker = _FinesseLocalizationsData$datePicker$fil._(_root);
	@override late final _FinesseLocalizationsData$input$fil input = _FinesseLocalizationsData$input$fil._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$fil keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$fil._(_root);
	@override late final _FinesseLocalizationsData$dialog$fil dialog = _FinesseLocalizationsData$dialog$fil._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$fil extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$fil._(FinesseLocalizationsDataFil root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Oras';
	@override String get minutes => 'Minuto';
	@override String get seconds => 'Segundo';
	@override String get period => 'Panahon';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$fil extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$fil._(FinesseLocalizationsDataFil root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pumili ng petsa';
}

// Path: input
class _FinesseLocalizationsData$input$fil extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$fil._(FinesseLocalizationsDataFil root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Gupitin';
	@override String get copy => 'Kopyahin';
	@override String get paste => 'I-paste';
	@override String get selectAll => 'Piliin lahat';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$fil extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$fil._(FinesseLocalizationsDataFil root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get done => 'Tapos';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$fil extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$fil._(FinesseLocalizationsDataFil root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get close => 'Isara';
	@override String get dismiss => 'I-dismiss';
}

/// The flat map containing all translations for locale <fil>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataFil {
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
			'keyboardToolbar.done' => 'Tapos',
			'dialog.close' => 'Isara',
			'dialog.dismiss' => 'I-dismiss',
			_ => null,
		};
	}
}
