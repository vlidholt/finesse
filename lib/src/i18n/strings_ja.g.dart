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
class FinesseLocalizationsDataJa extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataJa _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataJa $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataJa(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$ja timePicker = _FinesseLocalizationsData$timePicker$ja._(_root);
	@override late final _FinesseLocalizationsData$datePicker$ja datePicker = _FinesseLocalizationsData$datePicker$ja._(_root);
	@override late final _FinesseLocalizationsData$input$ja input = _FinesseLocalizationsData$input$ja._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$ja keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$ja._(_root);
	@override late final _FinesseLocalizationsData$dialog$ja dialog = _FinesseLocalizationsData$dialog$ja._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$ja extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$ja._(FinesseLocalizationsDataJa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get hours => '時';
	@override String get minutes => '分';
	@override String get seconds => '秒';
	@override String get period => '午前/午後';
	@override String get periodPlaceholder => '午前';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$ja extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$ja._(FinesseLocalizationsDataJa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => '日付を選択';
}

// Path: input
class _FinesseLocalizationsData$input$ja extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$ja._(FinesseLocalizationsDataJa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'カット';
	@override String get copy => 'コピー';
	@override String get paste => 'ペースト';
	@override String get selectAll => 'すべて選択';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$ja extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$ja._(FinesseLocalizationsDataJa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get done => '完了';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$ja extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$ja._(FinesseLocalizationsDataJa root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get close => '閉じる';
	@override String get dismiss => '閉じる';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataJa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => '時',
			'timePicker.minutes' => '分',
			'timePicker.seconds' => '秒',
			'timePicker.period' => '午前/午後',
			'timePicker.periodPlaceholder' => '午前',
			'datePicker.selectDate' => '日付を選択',
			'input.cut' => 'カット',
			'input.copy' => 'コピー',
			'input.paste' => 'ペースト',
			'input.selectAll' => 'すべて選択',
			'keyboardToolbar.done' => '完了',
			'dialog.close' => '閉じる',
			'dialog.dismiss' => '閉じる',
			_ => null,
		};
	}
}
