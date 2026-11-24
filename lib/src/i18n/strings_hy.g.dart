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
class FinesseLocalizationsDataHy extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataHy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.hy,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hy>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataHy _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataHy $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataHy(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$hy timePicker = _FinesseLocalizationsData$timePicker$hy._(_root);
	@override late final _FinesseLocalizationsData$datePicker$hy datePicker = _FinesseLocalizationsData$datePicker$hy._(_root);
	@override late final _FinesseLocalizationsData$input$hy input = _FinesseLocalizationsData$input$hy._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$hy keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$hy._(_root);
	@override late final _FinesseLocalizationsData$dialog$hy dialog = _FinesseLocalizationsData$dialog$hy._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$hy extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$hy._(FinesseLocalizationsDataHy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ժամ';
	@override String get minutes => 'Րոպե';
	@override String get seconds => 'Վայրկյան';
	@override String get period => 'Ժամաշրջան';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$hy extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$hy._(FinesseLocalizationsDataHy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Ընտրեք ամսաթիվ';
}

// Path: input
class _FinesseLocalizationsData$input$hy extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$hy._(FinesseLocalizationsDataHy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Կտրել';
	@override String get copy => 'Պատճենել';
	@override String get paste => 'Տեղադրել';
	@override String get selectAll => 'Ընտրել բոլորը';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$hy extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$hy._(FinesseLocalizationsDataHy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get done => 'Պատրաստ';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$hy extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$hy._(FinesseLocalizationsDataHy root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get close => 'Փակել';
	@override String get dismiss => 'Փակել';
}

/// The flat map containing all translations for locale <hy>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataHy {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Ժամ',
			'timePicker.minutes' => 'Րոպե',
			'timePicker.seconds' => 'Վայրկյան',
			'timePicker.period' => 'Ժամաշրջան',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Ընտրեք ամսաթիվ',
			'input.cut' => 'Կտրել',
			'input.copy' => 'Պատճենել',
			'input.paste' => 'Տեղադրել',
			'input.selectAll' => 'Ընտրել բոլորը',
			'keyboardToolbar.done' => 'Պատրաստ',
			'dialog.close' => 'Փակել',
			'dialog.dismiss' => 'Փակել',
			_ => null,
		};
	}
}
