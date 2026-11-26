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
class UnaLocalizationsDataGsw extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataGsw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.gsw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <gsw>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataGsw _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataGsw $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataGsw(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$gsw timePicker = _UnaLocalizationsData$timePicker$gsw._(_root);
	@override late final _UnaLocalizationsData$datePicker$gsw datePicker = _UnaLocalizationsData$datePicker$gsw._(_root);
	@override late final _UnaLocalizationsData$input$gsw input = _UnaLocalizationsData$input$gsw._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$gsw keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$gsw._(_root);
	@override late final _UnaLocalizationsData$dialog$gsw dialog = _UnaLocalizationsData$dialog$gsw._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$gsw extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$gsw._(UnaLocalizationsDataGsw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGsw _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Stunde';
	@override String get minutes => 'Minuute';
	@override String get seconds => 'Sekunde';
	@override String get period => 'Ziitraum';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$gsw extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$gsw._(UnaLocalizationsDataGsw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGsw _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Datum uswähle';
}

// Path: input
class _UnaLocalizationsData$input$gsw extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$gsw._(UnaLocalizationsDataGsw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGsw _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Usschnide';
	@override String get copy => 'Kopiere';
	@override String get paste => 'Iifüege';
	@override String get selectAll => 'Alles uswähle';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$gsw extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$gsw._(UnaLocalizationsDataGsw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGsw _root; // ignore: unused_field

	// Translations
	@override String get done => 'Fertig';
}

// Path: dialog
class _UnaLocalizationsData$dialog$gsw extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$gsw._(UnaLocalizationsDataGsw root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataGsw _root; // ignore: unused_field

	// Translations
	@override String get close => 'Schließen';
	@override String get dismiss => 'Schließen';
}

/// The flat map containing all translations for locale <gsw>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataGsw {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Stunde',
			'timePicker.minutes' => 'Minuute',
			'timePicker.seconds' => 'Sekunde',
			'timePicker.period' => 'Ziitraum',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Datum uswähle',
			'input.cut' => 'Usschnide',
			'input.copy' => 'Kopiere',
			'input.paste' => 'Iifüege',
			'input.selectAll' => 'Alles uswähle',
			'keyboardToolbar.done' => 'Fertig',
			'dialog.close' => 'Schließen',
			'dialog.dismiss' => 'Schließen',
			_ => null,
		};
	}
}
