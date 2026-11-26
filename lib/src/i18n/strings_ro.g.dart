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
class UnaLocalizationsDataRo extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataRo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ro,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ro>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataRo _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataRo $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataRo(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ro timePicker = _UnaLocalizationsData$timePicker$ro._(_root);
	@override late final _UnaLocalizationsData$datePicker$ro datePicker = _UnaLocalizationsData$datePicker$ro._(_root);
	@override late final _UnaLocalizationsData$input$ro input = _UnaLocalizationsData$input$ro._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ro keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ro._(_root);
	@override late final _UnaLocalizationsData$dialog$ro dialog = _UnaLocalizationsData$dialog$ro._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ro extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ro._(UnaLocalizationsDataRo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ore';
	@override String get minutes => 'Minute';
	@override String get seconds => 'Secunde';
	@override String get period => 'Perioadă';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ro extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ro._(UnaLocalizationsDataRo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Selectați data';
}

// Path: input
class _UnaLocalizationsData$input$ro extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ro._(UnaLocalizationsDataRo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Taie';
	@override String get copy => 'Copiază';
	@override String get paste => 'Lipește';
	@override String get selectAll => 'Selectează tot';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ro extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ro._(UnaLocalizationsDataRo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get done => 'Terminat';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ro extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ro._(UnaLocalizationsDataRo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataRo _root; // ignore: unused_field

	// Translations
	@override String get close => 'Închideți';
	@override String get dismiss => 'Închideți';
}

/// The flat map containing all translations for locale <ro>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataRo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Ore',
			'timePicker.minutes' => 'Minute',
			'timePicker.seconds' => 'Secunde',
			'timePicker.period' => 'Perioadă',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Selectați data',
			'input.cut' => 'Taie',
			'input.copy' => 'Copiază',
			'input.paste' => 'Lipește',
			'input.selectAll' => 'Selectează tot',
			'keyboardToolbar.done' => 'Terminat',
			'dialog.close' => 'Închideți',
			'dialog.dismiss' => 'Închideți',
			_ => null,
		};
	}
}
