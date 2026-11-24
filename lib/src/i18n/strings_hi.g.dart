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
class FinesseLocalizationsDataHi extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataHi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.hi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hi>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataHi _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataHi $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataHi(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$hi timePicker = _FinesseLocalizationsData$timePicker$hi._(_root);
	@override late final _FinesseLocalizationsData$datePicker$hi datePicker = _FinesseLocalizationsData$datePicker$hi._(_root);
	@override late final _FinesseLocalizationsData$input$hi input = _FinesseLocalizationsData$input$hi._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$hi keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$hi._(_root);
	@override late final _FinesseLocalizationsData$dialog$hi dialog = _FinesseLocalizationsData$dialog$hi._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$hi extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$hi._(FinesseLocalizationsDataHi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'घंटे';
	@override String get minutes => 'मिनट';
	@override String get seconds => 'सेकंड';
	@override String get period => 'अवधि';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$hi extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$hi._(FinesseLocalizationsDataHi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'तारीख चुनें';
}

// Path: input
class _FinesseLocalizationsData$input$hi extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$hi._(FinesseLocalizationsDataHi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'काटें';
	@override String get copy => 'कॉपी करें';
	@override String get paste => 'पेस्ट करें';
	@override String get selectAll => 'सभी चुनें';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$hi extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$hi._(FinesseLocalizationsDataHi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get done => 'हो गया';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$hi extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$hi._(FinesseLocalizationsDataHi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get close => 'बंद करें';
	@override String get dismiss => 'खारिज करें';
}

/// The flat map containing all translations for locale <hi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataHi {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'घंटे',
			'timePicker.minutes' => 'मिनट',
			'timePicker.seconds' => 'सेकंड',
			'timePicker.period' => 'अवधि',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'तारीख चुनें',
			'input.cut' => 'काटें',
			'input.copy' => 'कॉपी करें',
			'input.paste' => 'पेस्ट करें',
			'input.selectAll' => 'सभी चुनें',
			'keyboardToolbar.done' => 'हो गया',
			'dialog.close' => 'बंद करें',
			'dialog.dismiss' => 'खारिज करें',
			_ => null,
		};
	}
}
