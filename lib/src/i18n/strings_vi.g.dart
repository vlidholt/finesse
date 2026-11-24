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
class FinesseLocalizationsDataVi extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataVi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.vi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <vi>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataVi _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataVi $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataVi(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$vi timePicker = _FinesseLocalizationsData$timePicker$vi._(_root);
	@override late final _FinesseLocalizationsData$datePicker$vi datePicker = _FinesseLocalizationsData$datePicker$vi._(_root);
	@override late final _FinesseLocalizationsData$input$vi input = _FinesseLocalizationsData$input$vi._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$vi keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$vi._(_root);
	@override late final _FinesseLocalizationsData$dialog$vi dialog = _FinesseLocalizationsData$dialog$vi._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$vi extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$vi._(FinesseLocalizationsDataVi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Giờ';
	@override String get minutes => 'Phút';
	@override String get seconds => 'Giây';
	@override String get period => 'Buổi';
	@override String get periodPlaceholder => 'SA';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$vi extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$vi._(FinesseLocalizationsDataVi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Chọn ngày';
}

// Path: input
class _FinesseLocalizationsData$input$vi extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$vi._(FinesseLocalizationsDataVi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cắt';
	@override String get copy => 'Sao chép';
	@override String get paste => 'Dán';
	@override String get selectAll => 'Chọn tất cả';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$vi extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$vi._(FinesseLocalizationsDataVi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get done => 'Xong';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$vi extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$vi._(FinesseLocalizationsDataVi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get close => 'Đóng';
	@override String get dismiss => 'Bỏ qua';
}

/// The flat map containing all translations for locale <vi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataVi {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Giờ',
			'timePicker.minutes' => 'Phút',
			'timePicker.seconds' => 'Giây',
			'timePicker.period' => 'Buổi',
			'timePicker.periodPlaceholder' => 'SA',
			'datePicker.selectDate' => 'Chọn ngày',
			'input.cut' => 'Cắt',
			'input.copy' => 'Sao chép',
			'input.paste' => 'Dán',
			'input.selectAll' => 'Chọn tất cả',
			'keyboardToolbar.done' => 'Xong',
			'dialog.close' => 'Đóng',
			'dialog.dismiss' => 'Bỏ qua',
			_ => null,
		};
	}
}
