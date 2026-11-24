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
class FinesseLocalizationsDataLo extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataLo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.lo,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <lo>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataLo _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataLo $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataLo(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$lo timePicker = _FinesseLocalizationsData$timePicker$lo._(_root);
	@override late final _FinesseLocalizationsData$datePicker$lo datePicker = _FinesseLocalizationsData$datePicker$lo._(_root);
	@override late final _FinesseLocalizationsData$input$lo input = _FinesseLocalizationsData$input$lo._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$lo keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$lo._(_root);
	@override late final _FinesseLocalizationsData$dialog$lo dialog = _FinesseLocalizationsData$dialog$lo._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$lo extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$lo._(FinesseLocalizationsDataLo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ຊົ່ວໂມງ';
	@override String get minutes => 'ນາທີ';
	@override String get seconds => 'ວິນາທີ';
	@override String get period => 'ຊ່ວງເວລາ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$lo extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$lo._(FinesseLocalizationsDataLo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ເລືອກວັນທີ';
}

// Path: input
class _FinesseLocalizationsData$input$lo extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$lo._(FinesseLocalizationsDataLo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ຕັດ';
	@override String get copy => 'ຄັດລອກ';
	@override String get paste => 'ວາງ';
	@override String get selectAll => 'ເລືອກທັງໝົດ';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$lo extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$lo._(FinesseLocalizationsDataLo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get done => 'ສຳເລັດ';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$lo extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$lo._(FinesseLocalizationsDataLo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get close => 'ປິດ';
	@override String get dismiss => 'ປິດໄວ້';
}

/// The flat map containing all translations for locale <lo>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataLo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'ຊົ່ວໂມງ',
			'timePicker.minutes' => 'ນາທີ',
			'timePicker.seconds' => 'ວິນາທີ',
			'timePicker.period' => 'ຊ່ວງເວລາ',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'ເລືອກວັນທີ',
			'input.cut' => 'ຕັດ',
			'input.copy' => 'ຄັດລອກ',
			'input.paste' => 'ວາງ',
			'input.selectAll' => 'ເລືອກທັງໝົດ',
			'keyboardToolbar.done' => 'ສຳເລັດ',
			'dialog.close' => 'ປິດ',
			'dialog.dismiss' => 'ປິດໄວ້',
			_ => null,
		};
	}
}
