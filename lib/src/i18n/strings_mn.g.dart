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
class FinesseLocalizationsDataMn extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataMn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.mn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <mn>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataMn _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataMn $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataMn(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$mn timePicker = _FinesseLocalizationsData$timePicker$mn._(_root);
	@override late final _FinesseLocalizationsData$datePicker$mn datePicker = _FinesseLocalizationsData$datePicker$mn._(_root);
	@override late final _FinesseLocalizationsData$input$mn input = _FinesseLocalizationsData$input$mn._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$mn keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$mn._(_root);
	@override late final _FinesseLocalizationsData$dialog$mn dialog = _FinesseLocalizationsData$dialog$mn._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$mn extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$mn._(FinesseLocalizationsDataMn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Цаг';
	@override String get minutes => 'Минут';
	@override String get seconds => 'Секунд';
	@override String get period => 'Хугацаа';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$mn extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$mn._(FinesseLocalizationsDataMn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Огноо сонгох';
}

// Path: input
class _FinesseLocalizationsData$input$mn extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$mn._(FinesseLocalizationsDataMn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Тайрах';
	@override String get copy => 'Хуулах';
	@override String get paste => 'Буулгах';
	@override String get selectAll => 'Бүгдийг сонгох';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$mn extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$mn._(FinesseLocalizationsDataMn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get done => 'Болсон';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$mn extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$mn._(FinesseLocalizationsDataMn root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get close => 'Хаах';
	@override String get dismiss => 'Үл хэрэгсэх';
}

/// The flat map containing all translations for locale <mn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataMn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Цаг',
			'timePicker.minutes' => 'Минут',
			'timePicker.seconds' => 'Секунд',
			'timePicker.period' => 'Хугацаа',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Огноо сонгох',
			'input.cut' => 'Тайрах',
			'input.copy' => 'Хуулах',
			'input.paste' => 'Буулгах',
			'input.selectAll' => 'Бүгдийг сонгох',
			'keyboardToolbar.done' => 'Болсон',
			'dialog.close' => 'Хаах',
			'dialog.dismiss' => 'Үл хэрэгсэх',
			_ => null,
		};
	}
}
