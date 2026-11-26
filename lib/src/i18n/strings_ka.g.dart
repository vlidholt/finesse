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
class UnaLocalizationsDataKa extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataKa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.ka,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ka>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataKa _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataKa $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataKa(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$ka timePicker = _UnaLocalizationsData$timePicker$ka._(_root);
	@override late final _UnaLocalizationsData$datePicker$ka datePicker = _UnaLocalizationsData$datePicker$ka._(_root);
	@override late final _UnaLocalizationsData$input$ka input = _UnaLocalizationsData$input$ka._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$ka keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$ka._(_root);
	@override late final _UnaLocalizationsData$dialog$ka dialog = _UnaLocalizationsData$dialog$ka._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$ka extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$ka._(UnaLocalizationsDataKa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKa _root; // ignore: unused_field

	// Translations
	@override String get hours => 'საათი';
	@override String get minutes => 'წუთი';
	@override String get seconds => 'წამი';
	@override String get period => 'პერიოდი';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$ka extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$ka._(UnaLocalizationsDataKa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKa _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'აირჩიეთ თარიღი';
}

// Path: input
class _UnaLocalizationsData$input$ka extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$ka._(UnaLocalizationsDataKa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKa _root; // ignore: unused_field

	// Translations
	@override String get cut => 'ამოჭრა';
	@override String get copy => 'კოპირება';
	@override String get paste => 'ჩასმა';
	@override String get selectAll => 'ყველაფრის მონიშვნა';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$ka extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$ka._(UnaLocalizationsDataKa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKa _root; // ignore: unused_field

	// Translations
	@override String get done => 'მზადაა';
}

// Path: dialog
class _UnaLocalizationsData$dialog$ka extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$ka._(UnaLocalizationsDataKa root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataKa _root; // ignore: unused_field

	// Translations
	@override String get close => 'დახურვა';
	@override String get dismiss => 'დახურვა';
}

/// The flat map containing all translations for locale <ka>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataKa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'საათი',
			'timePicker.minutes' => 'წუთი',
			'timePicker.seconds' => 'წამი',
			'timePicker.period' => 'პერიოდი',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'აირჩიეთ თარიღი',
			'input.cut' => 'ამოჭრა',
			'input.copy' => 'კოპირება',
			'input.paste' => 'ჩასმა',
			'input.selectAll' => 'ყველაფრის მონიშვნა',
			'keyboardToolbar.done' => 'მზადაა',
			'dialog.close' => 'დახურვა',
			'dialog.dismiss' => 'დახურვა',
			_ => null,
		};
	}
}
