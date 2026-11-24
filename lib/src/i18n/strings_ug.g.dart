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
class FinesseLocalizationsDataUg extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataUg({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ug,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ug>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataUg _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataUg $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataUg(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ug timePicker = _FinesseLocalizationsData$timePicker$ug._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ug datePicker = _FinesseLocalizationsData$datePicker$ug._(_root);
	@override late final _FinesseLocalizationsData$input$ug input = _FinesseLocalizationsData$input$ug._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ug keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ug._(_root);
	@override late final _FinesseLocalizationsData$dialog$ug dialog = _FinesseLocalizationsData$dialog$ug._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ug extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ug._(FinesseLocalizationsDataUg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get hours => 'سائەت';
	@override String get minutes => 'مىنۇت';
	@override String get seconds => 'سېكۇنت';
	@override String get period => 'ۋاقىت';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ug extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ug._(FinesseLocalizationsDataUg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'چېسلا تاللاڭ';
}

// Path: input
class _FinesseLocalizationsData$input$ug extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ug._(FinesseLocalizationsDataUg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get cut => 'كەس';
	@override String get copy => 'كۆچۈر';
	@override String get paste => 'چاپلا';
	@override String get selectAll => 'ھەممىنى تاللا';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ug extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ug._(FinesseLocalizationsDataUg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get done => 'تامام';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ug extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ug._(FinesseLocalizationsDataUg root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get close => 'يېپىش';
	@override String get dismiss => 'بىكار قىلىش';
}

/// The flat map containing all translations for locale <ug>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataUg {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'سائەت',
			'timePicker.minutes' => 'مىنۇت',
			'timePicker.seconds' => 'سېكۇنت',
			'timePicker.period' => 'ۋاقىت',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'چېسلا تاللاڭ',
			'input.cut' => 'كەس',
			'input.copy' => 'كۆچۈر',
			'input.paste' => 'چاپلا',
			'input.selectAll' => 'ھەممىنى تاللا',
			'keyboardToolbar.done' => 'تامام',
			'dialog.close' => 'يېپىش',
			'dialog.dismiss' => 'بىكار قىلىش',
			_ => null,
		};
	}
}
