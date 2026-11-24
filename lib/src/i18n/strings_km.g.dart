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
class FinesseLocalizationsDataKm extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataKm({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.km,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <km>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataKm _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataKm $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataKm(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$km timePicker = _FinesseLocalizationsData$timePicker$km._(_root);
	@override late final _FinesseLocalizationsData$datePicker$km datePicker = _FinesseLocalizationsData$datePicker$km._(_root);
	@override late final _FinesseLocalizationsData$input$km input = _FinesseLocalizationsData$input$km._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$km keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$km._(_root);
	@override late final _FinesseLocalizationsData$dialog$km dialog = _FinesseLocalizationsData$dialog$km._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$km extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$km._(FinesseLocalizationsDataKm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ម៉ោង';
	@override String get minutes => 'នាទី';
	@override String get seconds => 'វិនាទី';
	@override String get period => 'វេលា';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$km extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$km._(FinesseLocalizationsDataKm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ជ្រើសរើសកាលបរិច្ឆេទ';
}

// Path: input
class _FinesseLocalizationsData$input$km extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$km._(FinesseLocalizationsDataKm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get cut => 'កាត់';
	@override String get copy => 'ចម្លង';
	@override String get paste => 'បិទភ្ជាប់';
	@override String get selectAll => 'ជ្រើសរើសទាំងអស់';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$km extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$km._(FinesseLocalizationsDataKm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get done => 'រួចរាល់';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$km extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$km._(FinesseLocalizationsDataKm root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get close => 'បិទ';
	@override String get dismiss => 'ច្រាន​ចោល';
}

/// The flat map containing all translations for locale <km>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataKm {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ម៉ោង',
			'timePicker.minutes' => 'នាទី',
			'timePicker.seconds' => 'វិនាទី',
			'timePicker.period' => 'វេលា',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'ជ្រើសរើសកាលបរិច្ឆេទ',
			'input.cut' => 'កាត់',
			'input.copy' => 'ចម្លង',
			'input.paste' => 'បិទភ្ជាប់',
			'input.selectAll' => 'ជ្រើសរើសទាំងអស់',
			'keyboardToolbar.done' => 'រួចរាល់',
			'dialog.close' => 'បិទ',
			'dialog.dismiss' => 'ច្រាន​ចោល',
			_ => null,
		};
	}
}
