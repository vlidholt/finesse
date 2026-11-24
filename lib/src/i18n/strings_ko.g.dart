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
class FinesseLocalizationsDataKo extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataKo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataKo _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataKo $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataKo(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ko timePicker = _FinesseLocalizationsData$timePicker$ko._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ko datePicker = _FinesseLocalizationsData$datePicker$ko._(_root);
	@override late final _FinesseLocalizationsData$input$ko input = _FinesseLocalizationsData$input$ko._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ko keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ko._(_root);
	@override late final _FinesseLocalizationsData$dialog$ko dialog = _FinesseLocalizationsData$dialog$ko._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ko extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ko._(FinesseLocalizationsDataKo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get hours => '시간';
	@override String get minutes => '분';
	@override String get seconds => '초';
	@override String get period => '오전/오후';
	@override String get periodPlaceholder => '오전';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ko extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ko._(FinesseLocalizationsDataKo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get selectDate => '날짜 선택';
}

// Path: input
class _FinesseLocalizationsData$input$ko extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ko._(FinesseLocalizationsDataKo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get cut => '잘라내기';
	@override String get copy => '복사';
	@override String get paste => '붙여넣기';
	@override String get selectAll => '전체 선택';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ko extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ko._(FinesseLocalizationsDataKo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get done => '완료';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ko extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ko._(FinesseLocalizationsDataKo root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataKo _root; // ignore: unused_field

	// Translations
	@override String get close => '닫기';
	@override String get dismiss => '닫기';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataKo {
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
