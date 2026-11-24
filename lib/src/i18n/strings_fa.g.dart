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
class FinesseLocalizationsDataFa extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataFa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.fa,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fa>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataFa _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataFa $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataFa(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$fa timePicker = _FinesseLocalizationsData$timePicker$fa._(_root);
	@override late final _FinesseLocalizationsData$datePicker$fa datePicker = _FinesseLocalizationsData$datePicker$fa._(_root);
	@override late final _FinesseLocalizationsData$input$fa input = _FinesseLocalizationsData$input$fa._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$fa keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$fa._(_root);
	@override late final _FinesseLocalizationsData$dialog$fa dialog = _FinesseLocalizationsData$dialog$fa._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$fa extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$fa._(FinesseLocalizationsDataFa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ساعت';
	@override String get minutes => 'دقیقه';
	@override String get seconds => 'ثانیه';
	@override String get period => 'دوره';
	@override String get periodPlaceholder => 'ق.ظ';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$fa extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$fa._(FinesseLocalizationsDataFa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'انتخاب تاریخ';
}

// Path: input
class _FinesseLocalizationsData$input$fa extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$fa._(FinesseLocalizationsDataFa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'برش';
	@override String get copy => 'کپی';
	@override String get paste => 'چسباندن';
	@override String get selectAll => 'انتخاب همه';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$fa extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$fa._(FinesseLocalizationsDataFa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get done => 'تمام';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$fa extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$fa._(FinesseLocalizationsDataFa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get close => 'بستن';
	@override String get dismiss => 'بستن';
}

/// The flat map containing all translations for locale <fa>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataFa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ساعت',
			'timePicker.minutes' => 'دقیقه',
			'timePicker.seconds' => 'ثانیه',
			'timePicker.period' => 'دوره',
			'timePicker.periodPlaceholder' => 'ق.ظ',
			'datePicker.selectDate' => 'انتخاب تاریخ',
			'input.cut' => 'برش',
			'input.copy' => 'کپی',
			'input.paste' => 'چسباندن',
			'input.selectAll' => 'انتخاب همه',
			'keyboardToolbar.done' => 'تمام',
			'dialog.close' => 'بستن',
			'dialog.dismiss' => 'بستن',
			_ => null,
		};
	}
}
