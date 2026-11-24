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
class FinesseLocalizationsDataOr extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataOr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.or,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <or>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataOr _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataOr $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataOr(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$or timePicker = _FinesseLocalizationsData$timePicker$or._(_root);
	@override late final _FinesseLocalizationsData$datePicker$or datePicker = _FinesseLocalizationsData$datePicker$or._(_root);
	@override late final _FinesseLocalizationsData$input$or input = _FinesseLocalizationsData$input$or._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$or keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$or._(_root);
	@override late final _FinesseLocalizationsData$dialog$or dialog = _FinesseLocalizationsData$dialog$or._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$or extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$or._(FinesseLocalizationsDataOr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ଘଣ୍ଟା';
	@override String get minutes => 'ମିନିଟ';
	@override String get seconds => 'ସେକେଣ୍ଡ';
	@override String get period => 'ସମୟ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$or extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$or._(FinesseLocalizationsDataOr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ତାରିଖ ବାଛନ୍ତୁ';
}

// Path: input
class _FinesseLocalizationsData$input$or extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$or._(FinesseLocalizationsDataOr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'କଟ';
	@override String get copy => 'କପି';
	@override String get paste => 'ପେଷ୍ଟ';
	@override String get selectAll => 'ସବୁ ଚୟନ କରନ୍ତୁ';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$or extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$or._(FinesseLocalizationsDataOr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get done => 'ସମ୍ପନ୍ନ';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$or extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$or._(FinesseLocalizationsDataOr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get close => 'ବନ୍ଦ କରନ୍ତୁ';
	@override String get dismiss => 'ଖାରଜ କରନ୍ତୁ';
}

/// The flat map containing all translations for locale <or>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataOr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ଘଣ୍ଟା',
			'timePicker.minutes' => 'ମିନିଟ',
			'timePicker.seconds' => 'ସେକେଣ୍ଡ',
			'timePicker.period' => 'ସମୟ',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'ତାରିଖ ବାଛନ୍ତୁ',
			'input.cut' => 'କଟ',
			'input.copy' => 'କପି',
			'input.paste' => 'ପେଷ୍ଟ',
			'input.selectAll' => 'ସବୁ ଚୟନ କରନ୍ତୁ',
			'keyboardToolbar.done' => 'ସମ୍ପନ୍ନ',
			'dialog.close' => 'ବନ୍ଦ କରନ୍ତୁ',
			'dialog.dismiss' => 'ଖାରଜ କରନ୍ତୁ',
			_ => null,
		};
	}
}
