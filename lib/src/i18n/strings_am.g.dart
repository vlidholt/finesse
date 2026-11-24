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
class FinesseLocalizationsDataAm extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataAm({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.am,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <am>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataAm _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataAm $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataAm(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$am timePicker = _FinesseLocalizationsData$timePicker$am._(_root);
	@override late final _FinesseLocalizationsData$datePicker$am datePicker = _FinesseLocalizationsData$datePicker$am._(_root);
	@override late final _FinesseLocalizationsData$input$am input = _FinesseLocalizationsData$input$am._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$am keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$am._(_root);
	@override late final _FinesseLocalizationsData$dialog$am dialog = _FinesseLocalizationsData$dialog$am._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$am extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$am._(FinesseLocalizationsDataAm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ሰዓቶች';
	@override String get minutes => 'ደቂቃዎች';
	@override String get seconds => 'ሰከንዶች';
	@override String get period => 'ወቅት';
	@override String get periodPlaceholder => 'ጥዋት';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$am extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$am._(FinesseLocalizationsDataAm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ቀን ይምረጡ';
}

// Path: input
class _FinesseLocalizationsData$input$am extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$am._(FinesseLocalizationsDataAm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ቁረጥ';
	@override String get copy => 'ቅዳ';
	@override String get paste => 'ለጥፍ';
	@override String get selectAll => 'ሁሉንም ይምረጡ';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$am extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$am._(FinesseLocalizationsDataAm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get done => 'ተከናውኗል';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$am extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$am._(FinesseLocalizationsDataAm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataAm _root; // ignore: unused_field

	// Translations
	@override String get close => 'ዝጋ';
	@override String get dismiss => 'አሰናብት';
}

/// The flat map containing all translations for locale <am>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataAm {
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
