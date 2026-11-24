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
class FinesseLocalizationsDataMl extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataMl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ml,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ml>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataMl _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataMl $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataMl(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ml timePicker = _FinesseLocalizationsData$timePicker$ml._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ml datePicker = _FinesseLocalizationsData$datePicker$ml._(_root);
	@override late final _FinesseLocalizationsData$input$ml input = _FinesseLocalizationsData$input$ml._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ml keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ml._(_root);
	@override late final _FinesseLocalizationsData$dialog$ml dialog = _FinesseLocalizationsData$dialog$ml._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ml extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ml._(FinesseLocalizationsDataMl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'മണിക്കൂർ';
	@override String get minutes => 'മിനിറ്റ്';
	@override String get seconds => 'സെക്കൻഡ്';
	@override String get period => 'കാലഘട്ടം';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ml extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ml._(FinesseLocalizationsDataMl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'തീയതി തിരഞ്ഞെടുക്കുക';
}

// Path: input
class _FinesseLocalizationsData$input$ml extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ml._(FinesseLocalizationsDataMl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'മുറിക്കുക';
	@override String get copy => 'പകർത്തുക';
	@override String get paste => 'ഒട്ടിക്കുക';
	@override String get selectAll => 'എല്ലാം തിരഞ്ഞെടുക്കുക';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ml extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ml._(FinesseLocalizationsDataMl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get done => 'പൂർത്തിയായി';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ml extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ml._(FinesseLocalizationsDataMl root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get close => 'അടയ്ക്കുക';
	@override String get dismiss => 'നിരസിക്കുക';
}

/// The flat map containing all translations for locale <ml>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataMl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'മണിക്കൂർ',
			'timePicker.minutes' => 'മിനിറ്റ്',
			'timePicker.seconds' => 'സെക്കൻഡ്',
			'timePicker.period' => 'കാലഘട്ടം',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'തീയതി തിരഞ്ഞെടുക്കുക',
			'input.cut' => 'മുറിക്കുക',
			'input.copy' => 'പകർത്തുക',
			'input.paste' => 'ഒട്ടിക്കുക',
			'input.selectAll' => 'എല്ലാം തിരഞ്ഞെടുക്കുക',
			'keyboardToolbar.done' => 'പൂർത്തിയായി',
			'dialog.close' => 'അടയ്ക്കുക',
			'dialog.dismiss' => 'നിരസിക്കുക',
			_ => null,
		};
	}
}
