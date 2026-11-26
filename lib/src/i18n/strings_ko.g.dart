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
class UnaLocalizationsDataKo extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataKo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataKo _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataKo $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataKo(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ko timePicker = _UnaLocalizationsData$timePicker$ko._(_root);
	@override late final _UnaLocalizationsData$datePicker$ko datePicker = _UnaLocalizationsData$datePicker$ko._(_root);
	@override late final _UnaLocalizationsData$input$ko input = _UnaLocalizationsData$input$ko._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ko keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ko._(_root);
	@override late final _UnaLocalizationsData$dialog$ko dialog = _UnaLocalizationsData$dialog$ko._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ko extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ko._(UnaLocalizationsDataKo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get hours => '시간';
	@override String get minutes => '분';
	@override String get seconds => '초';
	@override String get period => '오전/오후';
	@override String get periodPlaceholder => '오전';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ko extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ko._(UnaLocalizationsDataKo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => '날짜 선택';
}

// Path: input
class _UnaLocalizationsData$input$ko extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ko._(UnaLocalizationsDataKo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get cut => '잘라내기';
	@override String get copy => '복사';
	@override String get paste => '붙여넣기';
	@override String get selectAll => '전체 선택';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ko extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ko._(UnaLocalizationsDataKo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get done => '완료';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ko extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ko._(UnaLocalizationsDataKo root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get close => '닫기';
	@override String get dismiss => '닫기';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataKo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => '시간',
			'timePicker.minutes' => '분',
			'timePicker.seconds' => '초',
			'timePicker.period' => '오전/오후',
			'timePicker.periodPlaceholder' => '오전',
			'datePicker.selectDate' => '날짜 선택',
			'input.cut' => '잘라내기',
			'input.copy' => '복사',
			'input.paste' => '붙여넣기',
			'input.selectAll' => '전체 선택',
			'keyboardToolbar.done' => '완료',
			'dialog.close' => '닫기',
			'dialog.dismiss' => '닫기',
			_ => null,
		};
	}
}
