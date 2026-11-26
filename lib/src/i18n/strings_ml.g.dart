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
class UnaLocalizationsDataMl extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataMl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ml,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ml>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataMl _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataMl $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataMl(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ml timePicker = _UnaLocalizationsData$timePicker$ml._(_root);
	@override late final _UnaLocalizationsData$datePicker$ml datePicker = _UnaLocalizationsData$datePicker$ml._(_root);
	@override late final _UnaLocalizationsData$input$ml input = _UnaLocalizationsData$input$ml._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ml keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ml._(_root);
	@override late final _UnaLocalizationsData$dialog$ml dialog = _UnaLocalizationsData$dialog$ml._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ml extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ml._(UnaLocalizationsDataMl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get hours => 'മണിക്കൂർ';
	@override String get minutes => 'മിനിറ്റ്';
	@override String get seconds => 'സെക്കൻഡ്';
	@override String get period => 'കാലഘട്ടം';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ml extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ml._(UnaLocalizationsDataMl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'തീയതി തിരഞ്ഞെടുക്കുക';
}

// Path: input
class _UnaLocalizationsData$input$ml extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ml._(UnaLocalizationsDataMl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get cut => 'മുറിക്കുക';
	@override String get copy => 'പകർത്തുക';
	@override String get paste => 'ഒട്ടിക്കുക';
	@override String get selectAll => 'എല്ലാം തിരഞ്ഞെടുക്കുക';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ml extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ml._(UnaLocalizationsDataMl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get done => 'പൂർത്തിയായി';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ml extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ml._(UnaLocalizationsDataMl root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMl _root; // ignore: unused_field

	// Translations
	@override String get close => 'അടയ്ക്കുക';
	@override String get dismiss => 'നിരസിക്കുക';
}

/// The flat map containing all translations for locale <ml>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataMl {
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
