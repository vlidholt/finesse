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
class UnaLocalizationsDataEt extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataEt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.et,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <et>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataEt _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataEt $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataEt(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$et timePicker = _UnaLocalizationsData$timePicker$et._(_root);
	@override late final _UnaLocalizationsData$datePicker$et datePicker = _UnaLocalizationsData$datePicker$et._(_root);
	@override late final _UnaLocalizationsData$input$et input = _UnaLocalizationsData$input$et._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$et keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$et._(_root);
	@override late final _UnaLocalizationsData$dialog$et dialog = _UnaLocalizationsData$dialog$et._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$et extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$et._(UnaLocalizationsDataEt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Tunnid';
	@override String get minutes => 'Minutid';
	@override String get seconds => 'Sekundid';
	@override String get period => 'Periood';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$et extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$et._(UnaLocalizationsDataEt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Vali kuupäev';
}

// Path: input
class _UnaLocalizationsData$input$et extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$et._(UnaLocalizationsDataEt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Lõika';
	@override String get copy => 'Kopeeri';
	@override String get paste => 'Kleebi';
	@override String get selectAll => 'Vali kõik';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$et extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$et._(UnaLocalizationsDataEt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get done => 'Valmis';
}

// Path: dialog
class _UnaLocalizationsData$dialog$et extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$et._(UnaLocalizationsDataEt root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Sule';
	@override String get dismiss => 'Loobu';
}

/// The flat map containing all translations for locale <et>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataEt {
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
