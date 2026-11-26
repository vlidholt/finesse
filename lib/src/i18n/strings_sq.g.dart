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
class UnaLocalizationsDataSq extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataSq({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.sq,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sq>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataSq _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataSq $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataSq(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$sq timePicker = _UnaLocalizationsData$timePicker$sq._(_root);
	@override late final _UnaLocalizationsData$datePicker$sq datePicker = _UnaLocalizationsData$datePicker$sq._(_root);
	@override late final _UnaLocalizationsData$input$sq input = _UnaLocalizationsData$input$sq._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$sq keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$sq._(_root);
	@override late final _UnaLocalizationsData$dialog$sq dialog = _UnaLocalizationsData$dialog$sq._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$sq extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$sq._(UnaLocalizationsDataSq root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSq _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Orët';
	@override String get minutes => 'Minutat';
	@override String get seconds => 'Sekondat';
	@override String get period => 'Periudha';
	@override String get periodPlaceholder => 'PD';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$sq extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$sq._(UnaLocalizationsDataSq root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSq _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Zgjidh datën';
}

// Path: input
class _UnaLocalizationsData$input$sq extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$sq._(UnaLocalizationsDataSq root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSq _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Prit';
	@override String get copy => 'Kopjo';
	@override String get paste => 'Ngjit';
	@override String get selectAll => 'Zgjidh të gjitha';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$sq extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$sq._(UnaLocalizationsDataSq root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSq _root; // ignore: unused_field

	// Translations
	@override String get done => 'U krye';
}

// Path: dialog
class _UnaLocalizationsData$dialog$sq extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$sq._(UnaLocalizationsDataSq root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSq _root; // ignore: unused_field

	// Translations
	@override String get close => 'Mbyll';
	@override String get dismiss => 'Hiq';
}

/// The flat map containing all translations for locale <sq>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataSq {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Orët',
			'timePicker.minutes' => 'Minutat',
			'timePicker.seconds' => 'Sekondat',
			'timePicker.period' => 'Periudha',
			'timePicker.periodPlaceholder' => 'PD',
			'datePicker.selectDate' => 'Zgjidh datën',
			'input.cut' => 'Prit',
			'input.copy' => 'Kopjo',
			'input.paste' => 'Ngjit',
			'input.selectAll' => 'Zgjidh të gjitha',
			'keyboardToolbar.done' => 'U krye',
			'dialog.close' => 'Mbyll',
			'dialog.dismiss' => 'Hiq',
			_ => null,
		};
	}
}
