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
class UnaLocalizationsDataAz extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataAz({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.az,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <az>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataAz _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataAz $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataAz(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$az timePicker = _UnaLocalizationsData$timePicker$az._(_root);
	@override late final _UnaLocalizationsData$datePicker$az datePicker = _UnaLocalizationsData$datePicker$az._(_root);
	@override late final _UnaLocalizationsData$input$az input = _UnaLocalizationsData$input$az._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$az keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$az._(_root);
	@override late final _UnaLocalizationsData$dialog$az dialog = _UnaLocalizationsData$dialog$az._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$az extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$az._(UnaLocalizationsDataAz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Saat';
	@override String get minutes => 'Dəqiqə';
	@override String get seconds => 'Saniyə';
	@override String get period => 'Dövr';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$az extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$az._(UnaLocalizationsDataAz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Tarix seçin';
}

// Path: input
class _UnaLocalizationsData$input$az extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$az._(UnaLocalizationsDataAz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Kəs';
	@override String get copy => 'Kopyala';
	@override String get paste => 'Yapışdır';
	@override String get selectAll => 'Hamısını seç';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$az extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$az._(UnaLocalizationsDataAz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get done => 'Hazır';
}

// Path: dialog
class _UnaLocalizationsData$dialog$az extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$az._(UnaLocalizationsDataAz root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAz _root; // ignore: unused_field

	// Translations
	@override String get close => 'Bağlayın';
	@override String get dismiss => 'İmtina edin';
}

/// The flat map containing all translations for locale <az>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataAz {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Saat',
			'timePicker.minutes' => 'Dəqiqə',
			'timePicker.seconds' => 'Saniyə',
			'timePicker.period' => 'Dövr',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Tarix seçin',
			'input.cut' => 'Kəs',
			'input.copy' => 'Kopyala',
			'input.paste' => 'Yapışdır',
			'input.selectAll' => 'Hamısını seç',
			'keyboardToolbar.done' => 'Hazır',
			'dialog.close' => 'Bağlayın',
			'dialog.dismiss' => 'İmtina edin',
			_ => null,
		};
	}
}
