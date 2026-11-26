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
class UnaLocalizationsDataOr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataOr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.or,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <or>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataOr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataOr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataOr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$or timePicker = _UnaLocalizationsData$timePicker$or._(_root);
	@override late final _UnaLocalizationsData$datePicker$or datePicker = _UnaLocalizationsData$datePicker$or._(_root);
	@override late final _UnaLocalizationsData$input$or input = _UnaLocalizationsData$input$or._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$or keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$or._(_root);
	@override late final _UnaLocalizationsData$dialog$or dialog = _UnaLocalizationsData$dialog$or._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$or extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$or._(UnaLocalizationsDataOr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ଘଣ୍ଟା';
	@override String get minutes => 'ମିନିଟ';
	@override String get seconds => 'ସେକେଣ୍ଡ';
	@override String get period => 'ସମୟ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$or extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$or._(UnaLocalizationsDataOr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ତାରିଖ ବାଛନ୍ତୁ';
}

// Path: input
class _UnaLocalizationsData$input$or extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$or._(UnaLocalizationsDataOr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'କଟ';
	@override String get copy => 'କପି';
	@override String get paste => 'ପେଷ୍ଟ';
	@override String get selectAll => 'ସବୁ ଚୟନ କରନ୍ତୁ';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$or extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$or._(UnaLocalizationsDataOr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get done => 'ସମ୍ପନ୍ନ';
}

// Path: dialog
class _UnaLocalizationsData$dialog$or extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$or._(UnaLocalizationsDataOr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataOr _root; // ignore: unused_field

	// Translations
	@override String get close => 'ବନ୍ଦ କରନ୍ତୁ';
	@override String get dismiss => 'ଖାରଜ କରନ୍ତୁ';
}

/// The flat map containing all translations for locale <or>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataOr {
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
