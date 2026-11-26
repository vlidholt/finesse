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
class UnaLocalizationsDataBs extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataBs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.bs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bs>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataBs _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataBs $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataBs(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$bs timePicker = _UnaLocalizationsData$timePicker$bs._(_root);
	@override late final _UnaLocalizationsData$datePicker$bs datePicker = _UnaLocalizationsData$datePicker$bs._(_root);
	@override late final _UnaLocalizationsData$input$bs input = _UnaLocalizationsData$input$bs._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$bs keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$bs._(_root);
	@override late final _UnaLocalizationsData$dialog$bs dialog = _UnaLocalizationsData$dialog$bs._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$bs extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$bs._(UnaLocalizationsDataBs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Sati';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Period';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$bs extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$bs._(UnaLocalizationsDataBs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Odaberite datum';
}

// Path: input
class _UnaLocalizationsData$input$bs extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$bs._(UnaLocalizationsDataBs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Izreži';
	@override String get copy => 'Kopiraj';
	@override String get paste => 'Zalijepi';
	@override String get selectAll => 'Odaberi sve';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$bs extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$bs._(UnaLocalizationsDataBs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBs _root; // ignore: unused_field

	// Translations
	@override String get done => 'Gotovo';
}

// Path: dialog
class _UnaLocalizationsData$dialog$bs extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$bs._(UnaLocalizationsDataBs root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataBs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Zatvori';
	@override String get dismiss => 'Odbaci';
}

/// The flat map containing all translations for locale <bs>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataBs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Sati',
			'timePicker.minutes' => 'Minute',
			'timePicker.seconds' => 'Sekunde',
			'timePicker.period' => 'Period',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Odaberite datum',
			'input.cut' => 'Izreži',
			'input.copy' => 'Kopiraj',
			'input.paste' => 'Zalijepi',
			'input.selectAll' => 'Odaberi sve',
			'keyboardToolbar.done' => 'Gotovo',
			'dialog.close' => 'Zatvori',
			'dialog.dismiss' => 'Odbaci',
			_ => null,
		};
	}
}
