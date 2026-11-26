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
class UnaLocalizationsDataHy extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataHy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.hy,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <hy>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataHy _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataHy $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataHy(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$hy timePicker = _UnaLocalizationsData$timePicker$hy._(_root);
	@override late final _UnaLocalizationsData$datePicker$hy datePicker = _UnaLocalizationsData$datePicker$hy._(_root);
	@override late final _UnaLocalizationsData$input$hy input = _UnaLocalizationsData$input$hy._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$hy keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$hy._(_root);
	@override late final _UnaLocalizationsData$dialog$hy dialog = _UnaLocalizationsData$dialog$hy._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$hy extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$hy._(UnaLocalizationsDataHy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Ժամ';
	@override String get minutes => 'Րոպե';
	@override String get seconds => 'Վայրկյան';
	@override String get period => 'Ժամաշրջան';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$hy extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$hy._(UnaLocalizationsDataHy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Ընտրեք ամսաթիվ';
}

// Path: input
class _UnaLocalizationsData$input$hy extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$hy._(UnaLocalizationsDataHy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Կտրել';
	@override String get copy => 'Պատճենել';
	@override String get paste => 'Տեղադրել';
	@override String get selectAll => 'Ընտրել բոլորը';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$hy extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$hy._(UnaLocalizationsDataHy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get done => 'Պատրաստ';
}

// Path: dialog
class _UnaLocalizationsData$dialog$hy extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$hy._(UnaLocalizationsDataHy root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataHy _root; // ignore: unused_field

	// Translations
	@override String get close => 'Փակել';
	@override String get dismiss => 'Փակել';
}

/// The flat map containing all translations for locale <hy>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataHy {
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
