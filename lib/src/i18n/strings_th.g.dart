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
class FinesseLocalizationsDataTh extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataTh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.th,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <th>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataTh _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataTh $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataTh(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$th timePicker = _FinesseLocalizationsData$timePicker$th._(_root);
	@override late final _FinesseLocalizationsData$datePicker$th datePicker = _FinesseLocalizationsData$datePicker$th._(_root);
	@override late final _FinesseLocalizationsData$input$th input = _FinesseLocalizationsData$input$th._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$th keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$th._(_root);
	@override late final _FinesseLocalizationsData$dialog$th dialog = _FinesseLocalizationsData$dialog$th._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$th extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$th._(FinesseLocalizationsDataTh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ชั่วโมง';
	@override String get minutes => 'นาที';
	@override String get seconds => 'วินาที';
	@override String get period => 'ช่วงเวลา';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$th extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$th._(FinesseLocalizationsDataTh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'เลือกวันที่';
}

// Path: input
class _FinesseLocalizationsData$input$th extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$th._(FinesseLocalizationsDataTh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ตัด';
	@override String get copy => 'คัดลอก';
	@override String get paste => 'วาง';
	@override String get selectAll => 'เลือกทั้งหมด';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$th extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$th._(FinesseLocalizationsDataTh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get done => 'เสร็จสิ้น';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$th extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$th._(FinesseLocalizationsDataTh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get close => 'ปิด';
	@override String get dismiss => 'ปิด';
}

/// The flat map containing all translations for locale <th>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataTh {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ชั่วโมง',
			'timePicker.minutes' => 'นาที',
			'timePicker.seconds' => 'วินาที',
			'timePicker.period' => 'ช่วงเวลา',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'เลือกวันที่',
			'input.cut' => 'ตัด',
			'input.copy' => 'คัดลอก',
			'input.paste' => 'วาง',
			'input.selectAll' => 'เลือกทั้งหมด',
			'keyboardToolbar.done' => 'เสร็จสิ้น',
			'dialog.close' => 'ปิด',
			'dialog.dismiss' => 'ปิด',
			_ => null,
		};
	}
}
