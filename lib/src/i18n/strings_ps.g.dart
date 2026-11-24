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
class FinesseLocalizationsDataPs extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataPs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ps,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ps>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataPs _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataPs $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataPs(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ps timePicker = _FinesseLocalizationsData$timePicker$ps._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ps datePicker = _FinesseLocalizationsData$datePicker$ps._(_root);
	@override late final _FinesseLocalizationsData$input$ps input = _FinesseLocalizationsData$input$ps._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ps keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ps._(_root);
	@override late final _FinesseLocalizationsData$dialog$ps dialog = _FinesseLocalizationsData$dialog$ps._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ps extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ps._(FinesseLocalizationsDataPs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ساعتونه';
	@override String get minutes => 'دقیقې';
	@override String get seconds => 'ثانیې';
	@override String get period => 'وخت';
	@override String get periodPlaceholder => 'غ.م';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ps extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ps._(FinesseLocalizationsDataPs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPs _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'نیټه غوره کړئ';
}

// Path: input
class _FinesseLocalizationsData$input$ps extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ps._(FinesseLocalizationsDataPs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPs _root; // ignore: unused_field

	// Translations
	@override String get cut => 'پرې کړئ';
	@override String get copy => 'کاپي کړئ';
	@override String get paste => 'پیسټ کړئ';
	@override String get selectAll => 'ټول غوره کړئ';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ps extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ps._(FinesseLocalizationsDataPs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPs _root; // ignore: unused_field

	// Translations
	@override String get done => 'سم دی';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ps extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ps._(FinesseLocalizationsDataPs root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataPs _root; // ignore: unused_field

	// Translations
	@override String get close => 'تړل';
	@override String get dismiss => 'رد کړه';
}

/// The flat map containing all translations for locale <ps>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataPs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ساعتونه',
			'timePicker.minutes' => 'دقیقې',
			'timePicker.seconds' => 'ثانیې',
			'timePicker.period' => 'وخت',
			'timePicker.periodPlaceholder' => 'غ.م',
			'datePicker.selectDate' => 'نیټه غوره کړئ',
			'input.cut' => 'پرې کړئ',
			'input.copy' => 'کاپي کړئ',
			'input.paste' => 'پیسټ کړئ',
			'input.selectAll' => 'ټول غوره کړئ',
			'keyboardToolbar.done' => 'سم دی',
			'dialog.close' => 'تړل',
			'dialog.dismiss' => 'رد کړه',
			_ => null,
		};
	}
}
