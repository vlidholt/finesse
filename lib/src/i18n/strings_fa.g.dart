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
class UnaLocalizationsDataFa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataFa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.fa,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fa>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataFa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataFa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataFa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$fa timePicker = _UnaLocalizationsData$timePicker$fa._(_root);
	@override late final _UnaLocalizationsData$datePicker$fa datePicker = _UnaLocalizationsData$datePicker$fa._(_root);
	@override late final _UnaLocalizationsData$input$fa input = _UnaLocalizationsData$input$fa._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$fa keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$fa._(_root);
	@override late final _UnaLocalizationsData$dialog$fa dialog = _UnaLocalizationsData$dialog$fa._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$fa extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$fa._(UnaLocalizationsDataFa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ساعت';
	@override String get minutes => 'دقیقه';
	@override String get seconds => 'ثانیه';
	@override String get period => 'دوره';
	@override String get periodPlaceholder => 'ق.ظ';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$fa extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$fa._(UnaLocalizationsDataFa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'انتخاب تاریخ';
}

// Path: input
class _UnaLocalizationsData$input$fa extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$fa._(UnaLocalizationsDataFa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'برش';
	@override String get copy => 'کپی';
	@override String get paste => 'چسباندن';
	@override String get selectAll => 'انتخاب همه';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$fa extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$fa._(UnaLocalizationsDataFa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get done => 'تمام';
}

// Path: dialog
class _UnaLocalizationsData$dialog$fa extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$fa._(UnaLocalizationsDataFa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataFa _root; // ignore: unused_field

	// Translations
	@override String get close => 'بستن';
	@override String get dismiss => 'بستن';
}

/// The flat map containing all translations for locale <fa>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataFa {
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
