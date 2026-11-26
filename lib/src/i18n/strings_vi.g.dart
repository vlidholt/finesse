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
class UnaLocalizationsDataVi extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataVi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.vi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <vi>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataVi _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataVi $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataVi(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$vi timePicker = _UnaLocalizationsData$timePicker$vi._(_root);
	@override late final _UnaLocalizationsData$datePicker$vi datePicker = _UnaLocalizationsData$datePicker$vi._(_root);
	@override late final _UnaLocalizationsData$input$vi input = _UnaLocalizationsData$input$vi._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$vi keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$vi._(_root);
	@override late final _UnaLocalizationsData$dialog$vi dialog = _UnaLocalizationsData$dialog$vi._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$vi extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$vi._(UnaLocalizationsDataVi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Giờ';
	@override String get minutes => 'Phút';
	@override String get seconds => 'Giây';
	@override String get period => 'Buổi';
	@override String get periodPlaceholder => 'SA';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$vi extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$vi._(UnaLocalizationsDataVi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Chọn ngày';
}

// Path: input
class _UnaLocalizationsData$input$vi extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$vi._(UnaLocalizationsDataVi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Cắt';
	@override String get copy => 'Sao chép';
	@override String get paste => 'Dán';
	@override String get selectAll => 'Chọn tất cả';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$vi extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$vi._(UnaLocalizationsDataVi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get done => 'Xong';
}

// Path: dialog
class _UnaLocalizationsData$dialog$vi extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$vi._(UnaLocalizationsDataVi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataVi _root; // ignore: unused_field

	// Translations
	@override String get close => 'Đóng';
	@override String get dismiss => 'Bỏ qua';
}

/// The flat map containing all translations for locale <vi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataVi {
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
