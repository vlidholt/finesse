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
class UnaLocalizationsDataLo extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataLo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.lo,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <lo>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataLo _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataLo $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataLo(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$lo timePicker = _UnaLocalizationsData$timePicker$lo._(_root);
	@override late final _UnaLocalizationsData$datePicker$lo datePicker = _UnaLocalizationsData$datePicker$lo._(_root);
	@override late final _UnaLocalizationsData$input$lo input = _UnaLocalizationsData$input$lo._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$lo keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$lo._(_root);
	@override late final _UnaLocalizationsData$dialog$lo dialog = _UnaLocalizationsData$dialog$lo._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$lo extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$lo._(UnaLocalizationsDataLo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get hours => 'ຊົ່ວໂມງ';
	@override String get minutes => 'ນາທີ';
	@override String get seconds => 'ວິນາທີ';
	@override String get period => 'ຊ່ວງເວລາ';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$lo extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$lo._(UnaLocalizationsDataLo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'ເລືອກວັນທີ';
}

// Path: input
class _UnaLocalizationsData$input$lo extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$lo._(UnaLocalizationsDataLo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ຕັດ';
	@override String get copy => 'ຄັດລອກ';
	@override String get paste => 'ວາງ';
	@override String get selectAll => 'ເລືອກທັງໝົດ';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$lo extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$lo._(UnaLocalizationsDataLo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get done => 'ສຳເລັດ';
}

// Path: dialog
class _UnaLocalizationsData$dialog$lo extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$lo._(UnaLocalizationsDataLo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataLo _root; // ignore: unused_field

	// Translations
	@override String get close => 'ປິດ';
	@override String get dismiss => 'ປິດໄວ້';
}

/// The flat map containing all translations for locale <lo>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataLo {
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
