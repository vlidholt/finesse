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
class UnaLocalizationsDataTh extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataTh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.th,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <th>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataTh _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataTh $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataTh(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$th timePicker = _UnaLocalizationsData$timePicker$th._(_root);
	@override late final _UnaLocalizationsData$datePicker$th datePicker = _UnaLocalizationsData$datePicker$th._(_root);
	@override late final _UnaLocalizationsData$input$th input = _UnaLocalizationsData$input$th._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$th keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$th._(_root);
	@override late final _UnaLocalizationsData$dialog$th dialog = _UnaLocalizationsData$dialog$th._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$th extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$th._(UnaLocalizationsDataTh root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ชั่วโมง';
	@override String get minutes => 'นาที';
	@override String get seconds => 'วินาที';
	@override String get period => 'ช่วงเวลา';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$th extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$th._(UnaLocalizationsDataTh root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'เลือกวันที่';
}

// Path: input
class _UnaLocalizationsData$input$th extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$th._(UnaLocalizationsDataTh root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ตัด';
	@override String get copy => 'คัดลอก';
	@override String get paste => 'วาง';
	@override String get selectAll => 'เลือกทั้งหมด';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$th extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$th._(UnaLocalizationsDataTh root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get done => 'เสร็จสิ้น';
}

// Path: dialog
class _UnaLocalizationsData$dialog$th extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$th._(UnaLocalizationsDataTh root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTh _root; // ignore: unused_field

	// Translations
	@override String get close => 'ปิด';
	@override String get dismiss => 'ปิด';
}

/// The flat map containing all translations for locale <th>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataTh {
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
