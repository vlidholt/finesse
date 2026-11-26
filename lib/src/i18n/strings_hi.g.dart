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
class UnaLocalizationsDataHi extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataHi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.hi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hi>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataHi _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataHi $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataHi(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$hi timePicker = _UnaLocalizationsData$timePicker$hi._(_root);
	@override late final _UnaLocalizationsData$datePicker$hi datePicker = _UnaLocalizationsData$datePicker$hi._(_root);
	@override late final _UnaLocalizationsData$input$hi input = _UnaLocalizationsData$input$hi._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$hi keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$hi._(_root);
	@override late final _UnaLocalizationsData$dialog$hi dialog = _UnaLocalizationsData$dialog$hi._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$hi extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$hi._(UnaLocalizationsDataHi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'घंटे';
	@override String get minutes => 'मिनट';
	@override String get seconds => 'सेकंड';
	@override String get period => 'अवधि';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$hi extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$hi._(UnaLocalizationsDataHi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'तारीख चुनें';
}

// Path: input
class _UnaLocalizationsData$input$hi extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$hi._(UnaLocalizationsDataHi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'काटें';
	@override String get copy => 'कॉपी करें';
	@override String get paste => 'पेस्ट करें';
	@override String get selectAll => 'सभी चुनें';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$hi extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$hi._(UnaLocalizationsDataHi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get done => 'हो गया';
}

// Path: dialog
class _UnaLocalizationsData$dialog$hi extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$hi._(UnaLocalizationsDataHi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHi _root; // ignore: unused_field

	// Translations
	@override String get close => 'बंद करें';
	@override String get dismiss => 'खारिज करें';
}

/// The flat map containing all translations for locale <hi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataHi {
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
