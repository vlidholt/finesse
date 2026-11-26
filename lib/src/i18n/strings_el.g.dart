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
class UnaLocalizationsDataEl extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataEl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.el,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <el>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataEl _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataEl $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataEl(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$el timePicker = _UnaLocalizationsData$timePicker$el._(_root);
	@override late final _UnaLocalizationsData$datePicker$el datePicker = _UnaLocalizationsData$datePicker$el._(_root);
	@override late final _UnaLocalizationsData$input$el input = _UnaLocalizationsData$input$el._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$el keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$el._(_root);
	@override late final _UnaLocalizationsData$dialog$el dialog = _UnaLocalizationsData$dialog$el._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$el extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$el._(UnaLocalizationsDataEl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ώρες';
	@override String get minutes => 'Λεπτά';
	@override String get seconds => 'Δευτερόλεπτα';
	@override String get period => 'Περίοδος';
	@override String get periodPlaceholder => 'πμ';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$el extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$el._(UnaLocalizationsDataEl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Επιλογή ημερομηνίας';
}

// Path: input
class _UnaLocalizationsData$input$el extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$el._(UnaLocalizationsDataEl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Αποκοπή';
	@override String get copy => 'Αντιγραφή';
	@override String get paste => 'Επικόλληση';
	@override String get selectAll => 'Επιλογή όλων';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$el extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$el._(UnaLocalizationsDataEl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Τέλος';
}

// Path: dialog
class _UnaLocalizationsData$dialog$el extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$el._(UnaLocalizationsDataEl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Κλείσιμο';
	@override String get dismiss => 'Παράβλεψη';
}

/// The flat map containing all translations for locale <el>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataEl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Ώρες',
			'timePicker.minutes' => 'Λεπτά',
			'timePicker.seconds' => 'Δευτερόλεπτα',
			'timePicker.period' => 'Περίοδος',
			'timePicker.periodPlaceholder' => 'πμ',
			'datePicker.selectDate' => 'Επιλογή ημερομηνίας',
			'input.cut' => 'Αποκοπή',
			'input.copy' => 'Αντιγραφή',
			'input.paste' => 'Επικόλληση',
			'input.selectAll' => 'Επιλογή όλων',
			'keyboardToolbar.done' => 'Τέλος',
			'dialog.close' => 'Κλείσιμο',
			'dialog.dismiss' => 'Παράβλεψη',
			_ => null,
		};
	}
}
