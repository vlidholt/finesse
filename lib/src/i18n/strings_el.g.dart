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
class FinesseLocalizationsDataEl extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataEl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.el,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <el>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataEl _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataEl $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataEl(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$el timePicker = _FinesseLocalizationsData$timePicker$el._(_root);
	@override late final _FinesseLocalizationsData$datePicker$el datePicker = _FinesseLocalizationsData$datePicker$el._(_root);
	@override late final _FinesseLocalizationsData$input$el input = _FinesseLocalizationsData$input$el._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$el keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$el._(_root);
	@override late final _FinesseLocalizationsData$dialog$el dialog = _FinesseLocalizationsData$dialog$el._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$el extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$el._(FinesseLocalizationsDataEl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ώρες';
	@override String get minutes => 'Λεπτά';
	@override String get seconds => 'Δευτερόλεπτα';
	@override String get period => 'Περίοδος';
	@override String get periodPlaceholder => 'πμ';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$el extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$el._(FinesseLocalizationsDataEl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Επιλογή ημερομηνίας';
}

// Path: input
class _FinesseLocalizationsData$input$el extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$el._(FinesseLocalizationsDataEl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Αποκοπή';
	@override String get copy => 'Αντιγραφή';
	@override String get paste => 'Επικόλληση';
	@override String get selectAll => 'Επιλογή όλων';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$el extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$el._(FinesseLocalizationsDataEl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get done => 'Τέλος';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$el extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$el._(FinesseLocalizationsDataEl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataEl _root; // ignore: unused_field

	// Translations
	@override String get close => 'Κλείσιμο';
	@override String get dismiss => 'Παράβλεψη';
}

/// The flat map containing all translations for locale <el>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataEl {
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
