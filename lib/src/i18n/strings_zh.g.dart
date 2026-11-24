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
class FinesseLocalizationsDataZh extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataZh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataZh _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataZh $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataZh(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$zh timePicker = _FinesseLocalizationsData$timePicker$zh._(_root);
	@override late final _FinesseLocalizationsData$datePicker$zh datePicker = _FinesseLocalizationsData$datePicker$zh._(_root);
	@override late final _FinesseLocalizationsData$input$zh input = _FinesseLocalizationsData$input$zh._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$zh keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$zh._(_root);
	@override late final _FinesseLocalizationsData$dialog$zh dialog = _FinesseLocalizationsData$dialog$zh._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$zh extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$zh._(FinesseLocalizationsDataZh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZh _root; // ignore: unused_field

	// Translations
	@override String get hours => '时';
	@override String get minutes => '分';
	@override String get seconds => '秒';
	@override String get period => '时段';
	@override String get periodPlaceholder => '上午';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$zh extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$zh._(FinesseLocalizationsDataZh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZh _root; // ignore: unused_field

	// Translations
	@override String get selectDate => '选择日期';
}

// Path: input
class _FinesseLocalizationsData$input$zh extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$zh._(FinesseLocalizationsDataZh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZh _root; // ignore: unused_field

	// Translations
	@override String get cut => '剪切';
	@override String get copy => '复制';
	@override String get paste => '粘贴';
	@override String get selectAll => '全选';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$zh extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$zh._(FinesseLocalizationsDataZh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZh _root; // ignore: unused_field

	// Translations
	@override String get done => '完成';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$zh extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$zh._(FinesseLocalizationsDataZh root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZh _root; // ignore: unused_field

	// Translations
	@override String get close => '关闭';
	@override String get dismiss => '关闭';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataZh {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => '时',
			'timePicker.minutes' => '分',
			'timePicker.seconds' => '秒',
			'timePicker.period' => '时段',
			'timePicker.periodPlaceholder' => '上午',
			'datePicker.selectDate' => '选择日期',
			'input.cut' => '剪切',
			'input.copy' => '复制',
			'input.paste' => '粘贴',
			'input.selectAll' => '全选',
			'keyboardToolbar.done' => '完成',
			'dialog.close' => '关闭',
			'dialog.dismiss' => '关闭',
			_ => null,
		};
	}
}
