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
class UnaLocalizationsDataFil extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataFil({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.fil,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fil>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataFil _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataFil $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataFil(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$fil timePicker = _UnaLocalizationsData$timePicker$fil._(_root);
	@override late final _UnaLocalizationsData$datePicker$fil datePicker = _UnaLocalizationsData$datePicker$fil._(_root);
	@override late final _UnaLocalizationsData$input$fil input = _UnaLocalizationsData$input$fil._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$fil keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$fil._(_root);
	@override late final _UnaLocalizationsData$dialog$fil dialog = _UnaLocalizationsData$dialog$fil._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$fil extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$fil._(UnaLocalizationsDataFil root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Oras';
	@override String get minutes => 'Minuto';
	@override String get seconds => 'Segundo';
	@override String get period => 'Panahon';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$fil extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$fil._(UnaLocalizationsDataFil root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Pumili ng petsa';
}

// Path: input
class _UnaLocalizationsData$input$fil extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$fil._(UnaLocalizationsDataFil root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Gupitin';
	@override String get copy => 'Kopyahin';
	@override String get paste => 'I-paste';
	@override String get selectAll => 'Piliin lahat';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$fil extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$fil._(UnaLocalizationsDataFil root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get done => 'Tapos';
}

// Path: dialog
class _UnaLocalizationsData$dialog$fil extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$fil._(UnaLocalizationsDataFil root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFil _root; // ignore: unused_field

	// Translations
	@override String get close => 'Isara';
	@override String get dismiss => 'I-dismiss';
}

/// The flat map containing all translations for locale <fil>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataFil {
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
