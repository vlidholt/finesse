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
class UnaLocalizationsDataKn extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataKn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.kn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <kn>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataKn _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataKn $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataKn(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$kn timePicker = _UnaLocalizationsData$timePicker$kn._(_root);
	@override late final _UnaLocalizationsData$datePicker$kn datePicker = _UnaLocalizationsData$datePicker$kn._(_root);
	@override late final _UnaLocalizationsData$input$kn input = _UnaLocalizationsData$input$kn._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$kn keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$kn._(_root);
	@override late final _UnaLocalizationsData$dialog$kn dialog = _UnaLocalizationsData$dialog$kn._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$kn extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$kn._(UnaLocalizationsDataKn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ಗಂಟೆಗಳು';
	@override String get minutes => 'ನಿಮಿಷಗಳು';
	@override String get seconds => 'ಸೆಕೆಂಡುಗಳು';
	@override String get period => 'ಅವಧಿ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$kn extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$kn._(UnaLocalizationsDataKn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ದಿನಾಂಕ ಆಯ್ಕೆಮಾಡಿ';
}

// Path: input
class _UnaLocalizationsData$input$kn extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$kn._(UnaLocalizationsDataKn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ಕಟ್';
	@override String get copy => 'ಕಾಪಿ';
	@override String get paste => 'ಪೇಸ್ಟ್';
	@override String get selectAll => 'ಎಲ್ಲವನ್ನೂ ಆಯ್ಕೆಮಾಡಿ';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$kn extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$kn._(UnaLocalizationsDataKn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get done => 'ಮುಗಿದಿದೆ';
}

// Path: dialog
class _UnaLocalizationsData$dialog$kn extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$kn._(UnaLocalizationsDataKn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKn _root; // ignore: unused_field

	// Translations
	@override String get close => 'ಮುಚ್ಚಿರಿ';
	@override String get dismiss => 'ವಜಾಗೊಳಿಸಿ';
}

/// The flat map containing all translations for locale <kn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataKn {
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
