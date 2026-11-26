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
class UnaLocalizationsDataJa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataJa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataJa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataJa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ja timePicker = _UnaLocalizationsData$timePicker$ja._(_root);
	@override late final _UnaLocalizationsData$datePicker$ja datePicker = _UnaLocalizationsData$datePicker$ja._(_root);
	@override late final _UnaLocalizationsData$input$ja input = _UnaLocalizationsData$input$ja._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ja keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ja._(_root);
	@override late final _UnaLocalizationsData$dialog$ja dialog = _UnaLocalizationsData$dialog$ja._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ja extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ja._(UnaLocalizationsDataJa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get hours => '時';
	@override String get minutes => '分';
	@override String get seconds => '秒';
	@override String get period => '午前/午後';
	@override String get periodPlaceholder => '午前';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ja extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ja._(UnaLocalizationsDataJa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => '日付を選択';
}

// Path: input
class _UnaLocalizationsData$input$ja extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ja._(UnaLocalizationsDataJa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'カット';
	@override String get copy => 'コピー';
	@override String get paste => 'ペースト';
	@override String get selectAll => 'すべて選択';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ja extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ja._(UnaLocalizationsDataJa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get done => '完了';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ja extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ja._(UnaLocalizationsDataJa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataJa _root; // ignore: unused_field

	// Translations
	@override String get close => '閉じる';
	@override String get dismiss => '閉じる';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataJa {
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
