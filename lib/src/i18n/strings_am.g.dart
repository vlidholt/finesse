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
class UnaLocalizationsDataAm extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataAm({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.am,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <am>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataAm _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataAm $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataAm(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$am timePicker = _UnaLocalizationsData$timePicker$am._(_root);
	@override late final _UnaLocalizationsData$datePicker$am datePicker = _UnaLocalizationsData$datePicker$am._(_root);
	@override late final _UnaLocalizationsData$input$am input = _UnaLocalizationsData$input$am._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$am keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$am._(_root);
	@override late final _UnaLocalizationsData$dialog$am dialog = _UnaLocalizationsData$dialog$am._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$am extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$am._(UnaLocalizationsDataAm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ሰዓቶች';
	@override String get minutes => 'ደቂቃዎች';
	@override String get seconds => 'ሰከንዶች';
	@override String get period => 'ወቅት';
	@override String get periodPlaceholder => 'ጥዋት';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$am extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$am._(UnaLocalizationsDataAm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ቀን ይምረጡ';
}

// Path: input
class _UnaLocalizationsData$input$am extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$am._(UnaLocalizationsDataAm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ቁረጥ';
	@override String get copy => 'ቅዳ';
	@override String get paste => 'ለጥፍ';
	@override String get selectAll => 'ሁሉንም ይምረጡ';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$am extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$am._(UnaLocalizationsDataAm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get done => 'ተከናውኗል';
}

// Path: dialog
class _UnaLocalizationsData$dialog$am extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$am._(UnaLocalizationsDataAm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get close => 'ዝጋ';
	@override String get dismiss => 'አሰናብት';
}

/// The flat map containing all translations for locale <am>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataAm {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ሰዓቶች',
			'timePicker.minutes' => 'ደቂቃዎች',
			'timePicker.seconds' => 'ሰከንዶች',
			'timePicker.period' => 'ወቅት',
			'timePicker.periodPlaceholder' => 'ጥዋት',
			'datePicker.selectDate' => 'ቀን ይምረጡ',
			'input.cut' => 'ቁረጥ',
			'input.copy' => 'ቅዳ',
			'input.paste' => 'ለጥፍ',
			'input.selectAll' => 'ሁሉንም ይምረጡ',
			'keyboardToolbar.done' => 'ተከናውኗል',
			'dialog.close' => 'ዝጋ',
			'dialog.dismiss' => 'አሰናብት',
			_ => null,
		};
	}
}
