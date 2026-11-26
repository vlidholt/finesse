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
class UnaLocalizationsDataSw extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataSw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.sw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sw>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataSw _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataSw $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataSw(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$sw timePicker = _UnaLocalizationsData$timePicker$sw._(_root);
	@override late final _UnaLocalizationsData$datePicker$sw datePicker = _UnaLocalizationsData$datePicker$sw._(_root);
	@override late final _UnaLocalizationsData$input$sw input = _UnaLocalizationsData$input$sw._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$sw keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$sw._(_root);
	@override late final _UnaLocalizationsData$dialog$sw dialog = _UnaLocalizationsData$dialog$sw._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$sw extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$sw._(UnaLocalizationsDataSw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Masaa';
	@override String get minutes => 'Dakika';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Kipindi';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$sw extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$sw._(UnaLocalizationsDataSw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Chagua tarehe';
}

// Path: input
class _UnaLocalizationsData$input$sw extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$sw._(UnaLocalizationsDataSw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kata';
	@override String get copy => 'Nakili';
	@override String get paste => 'Bandika';
	@override String get selectAll => 'Chagua yote';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$sw extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$sw._(UnaLocalizationsDataSw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get done => 'Imekamilika';
}

// Path: dialog
class _UnaLocalizationsData$dialog$sw extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$sw._(UnaLocalizationsDataSw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSw _root; // ignore: unused_field

	// Translations
	@override String get close => 'Funga';
	@override String get dismiss => 'Ondoa';
}

/// The flat map containing all translations for locale <sw>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataSw {
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
