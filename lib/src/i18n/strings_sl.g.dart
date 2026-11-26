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
class UnaLocalizationsDataSl extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataSl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.sl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sl>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataSl _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataSl $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataSl(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$sl timePicker = _UnaLocalizationsData$timePicker$sl._(_root);
	@override late final _UnaLocalizationsData$datePicker$sl datePicker = _UnaLocalizationsData$datePicker$sl._(_root);
	@override late final _UnaLocalizationsData$input$sl input = _UnaLocalizationsData$input$sl._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$sl keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$sl._(_root);
	@override late final _UnaLocalizationsData$dialog$sl dialog = _UnaLocalizationsData$dialog$sl._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$sl extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$sl._(UnaLocalizationsDataSl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ure';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Obdobje';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$sl extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$sl._(UnaLocalizationsDataSl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Izberite datum';
}

// Path: input
class _UnaLocalizationsData$input$sl extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$sl._(UnaLocalizationsDataSl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Izreži';
	@override String get copy => 'Kopiraj';
	@override String get paste => 'Prilepi';
	@override String get selectAll => 'Izberi vse';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$sl extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$sl._(UnaLocalizationsDataSl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Končano';
}

// Path: dialog
class _UnaLocalizationsData$dialog$sl extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$sl._(UnaLocalizationsDataSl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zapri';
	@override String get dismiss => 'Opusti';
}

/// The flat map containing all translations for locale <sl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataSl {
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
