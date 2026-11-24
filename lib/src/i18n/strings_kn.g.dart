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
class FinesseLocalizationsDataKn extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataKn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.kn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <kn>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataKn _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataKn $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataKn(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$kn timePicker = _FinesseLocalizationsData$timePicker$kn._(_root);
	@override late final _FinesseLocalizationsData$datePicker$kn datePicker = _FinesseLocalizationsData$datePicker$kn._(_root);
	@override late final _FinesseLocalizationsData$input$kn input = _FinesseLocalizationsData$input$kn._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$kn keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$kn._(_root);
	@override late final _FinesseLocalizationsData$dialog$kn dialog = _FinesseLocalizationsData$dialog$kn._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$kn extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$kn._(FinesseLocalizationsDataKn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ಗಂಟೆಗಳು';
	@override String get minutes => 'ನಿಮಿಷಗಳು';
	@override String get seconds => 'ಸೆಕೆಂಡುಗಳು';
	@override String get period => 'ಅವಧಿ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$kn extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$kn._(FinesseLocalizationsDataKn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ದಿನಾಂಕ ಆಯ್ಕೆಮಾಡಿ';
}

// Path: input
class _FinesseLocalizationsData$input$kn extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$kn._(FinesseLocalizationsDataKn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ಕಟ್';
	@override String get copy => 'ಕಾಪಿ';
	@override String get paste => 'ಪೇಸ್ಟ್';
	@override String get selectAll => 'ಎಲ್ಲವನ್ನೂ ಆಯ್ಕೆಮಾಡಿ';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$kn extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$kn._(FinesseLocalizationsDataKn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get done => 'ಮುಗಿದಿದೆ';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$kn extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$kn._(FinesseLocalizationsDataKn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get close => 'ಮುಚ್ಚಿರಿ';
	@override String get dismiss => 'ವಜಾಗೊಳಿಸಿ';
}

/// The flat map containing all translations for locale <kn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataKn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ಗಂಟೆಗಳು',
			'timePicker.minutes' => 'ನಿಮಿಷಗಳು',
			'timePicker.seconds' => 'ಸೆಕೆಂಡುಗಳು',
			'timePicker.period' => 'ಅವಧಿ',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'ದಿನಾಂಕ ಆಯ್ಕೆಮಾಡಿ',
			'input.cut' => 'ಕಟ್',
			'input.copy' => 'ಕಾಪಿ',
			'input.paste' => 'ಪೇಸ್ಟ್',
			'input.selectAll' => 'ಎಲ್ಲವನ್ನೂ ಆಯ್ಕೆಮಾಡಿ',
			'keyboardToolbar.done' => 'ಮುಗಿದಿದೆ',
			'dialog.close' => 'ಮುಚ್ಚಿರಿ',
			'dialog.dismiss' => 'ವಜಾಗೊಳಿಸಿ',
			_ => null,
		};
	}
}
