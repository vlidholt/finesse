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
class UnaLocalizationsDataUg extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataUg({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ug,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ug>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataUg _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataUg $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataUg(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ug timePicker = _UnaLocalizationsData$timePicker$ug._(_root);
	@override late final _UnaLocalizationsData$datePicker$ug datePicker = _UnaLocalizationsData$datePicker$ug._(_root);
	@override late final _UnaLocalizationsData$input$ug input = _UnaLocalizationsData$input$ug._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ug keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ug._(_root);
	@override late final _UnaLocalizationsData$dialog$ug dialog = _UnaLocalizationsData$dialog$ug._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ug extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ug._(UnaLocalizationsDataUg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get hours => 'سائەت';
	@override String get minutes => 'مىنۇت';
	@override String get seconds => 'سېكۇنت';
	@override String get period => 'ۋاقىت';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ug extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ug._(UnaLocalizationsDataUg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'چېسلا تاللاڭ';
}

// Path: input
class _UnaLocalizationsData$input$ug extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ug._(UnaLocalizationsDataUg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get cut => 'كەس';
	@override String get copy => 'كۆچۈر';
	@override String get paste => 'چاپلا';
	@override String get selectAll => 'ھەممىنى تاللا';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ug extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ug._(UnaLocalizationsDataUg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get done => 'تامام';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ug extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ug._(UnaLocalizationsDataUg root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataUg _root; // ignore: unused_field

	// Translations
	@override String get close => 'يېپىش';
	@override String get dismiss => 'بىكار قىلىش';
}

/// The flat map containing all translations for locale <ug>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataUg {
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
