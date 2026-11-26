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
class UnaLocalizationsDataMn extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataMn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.mn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <mn>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataMn _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataMn $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataMn(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$mn timePicker = _UnaLocalizationsData$timePicker$mn._(_root);
	@override late final _UnaLocalizationsData$datePicker$mn datePicker = _UnaLocalizationsData$datePicker$mn._(_root);
	@override late final _UnaLocalizationsData$input$mn input = _UnaLocalizationsData$input$mn._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$mn keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$mn._(_root);
	@override late final _UnaLocalizationsData$dialog$mn dialog = _UnaLocalizationsData$dialog$mn._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$mn extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$mn._(UnaLocalizationsDataMn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Цаг';
	@override String get minutes => 'Минут';
	@override String get seconds => 'Секунд';
	@override String get period => 'Хугацаа';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$mn extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$mn._(UnaLocalizationsDataMn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Огноо сонгох';
}

// Path: input
class _UnaLocalizationsData$input$mn extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$mn._(UnaLocalizationsDataMn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Тайрах';
	@override String get copy => 'Хуулах';
	@override String get paste => 'Буулгах';
	@override String get selectAll => 'Бүгдийг сонгох';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$mn extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$mn._(UnaLocalizationsDataMn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get done => 'Болсон';
}

// Path: dialog
class _UnaLocalizationsData$dialog$mn extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$mn._(UnaLocalizationsDataMn root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMn _root; // ignore: unused_field

	// Translations
	@override String get close => 'Хаах';
	@override String get dismiss => 'Үл хэрэгсэх';
}

/// The flat map containing all translations for locale <mn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataMn {
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
