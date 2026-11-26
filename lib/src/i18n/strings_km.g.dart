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
class UnaLocalizationsDataKm extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataKm({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.km,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <km>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataKm _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataKm $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataKm(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$km timePicker = _UnaLocalizationsData$timePicker$km._(_root);
	@override late final _UnaLocalizationsData$datePicker$km datePicker = _UnaLocalizationsData$datePicker$km._(_root);
	@override late final _UnaLocalizationsData$input$km input = _UnaLocalizationsData$input$km._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$km keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$km._(_root);
	@override late final _UnaLocalizationsData$dialog$km dialog = _UnaLocalizationsData$dialog$km._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$km extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$km._(UnaLocalizationsDataKm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ម៉ោង';
	@override String get minutes => 'នាទី';
	@override String get seconds => 'វិនាទី';
	@override String get period => 'វេលា';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$km extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$km._(UnaLocalizationsDataKm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ជ្រើសរើសកាលបរិច្ឆេទ';
}

// Path: input
class _UnaLocalizationsData$input$km extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$km._(UnaLocalizationsDataKm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get cut => 'កាត់';
	@override String get copy => 'ចម្លង';
	@override String get paste => 'បិទភ្ជាប់';
	@override String get selectAll => 'ជ្រើសរើសទាំងអស់';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$km extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$km._(UnaLocalizationsDataKm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get done => 'រួចរាល់';
}

// Path: dialog
class _UnaLocalizationsData$dialog$km extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$km._(UnaLocalizationsDataKm root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKm _root; // ignore: unused_field

	// Translations
	@override String get close => 'បិទ';
	@override String get dismiss => 'ច្រាន​ចោល';
}

/// The flat map containing all translations for locale <km>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataKm {
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
