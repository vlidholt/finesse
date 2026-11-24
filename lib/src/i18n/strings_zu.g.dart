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
class FinesseLocalizationsDataZu extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataZu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.zu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zu>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataZu _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataZu $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataZu(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$zu timePicker = _FinesseLocalizationsData$timePicker$zu._(_root);
	@override late final _FinesseLocalizationsData$datePicker$zu datePicker = _FinesseLocalizationsData$datePicker$zu._(_root);
	@override late final _FinesseLocalizationsData$input$zu input = _FinesseLocalizationsData$input$zu._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$zu keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$zu._(_root);
	@override late final _FinesseLocalizationsData$dialog$zu dialog = _FinesseLocalizationsData$dialog$zu._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$zu extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$zu._(FinesseLocalizationsDataZu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Amahora';
	@override String get minutes => 'Amaminithi';
	@override String get seconds => 'Amasekhondi';
	@override String get period => 'Isikhathi';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$zu extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$zu._(FinesseLocalizationsDataZu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Khetha usuku';
}

// Path: input
class _FinesseLocalizationsData$input$zu extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$zu._(FinesseLocalizationsDataZu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Sika';
	@override String get copy => 'Kopisha';
	@override String get paste => 'Namathisela';
	@override String get selectAll => 'Khetha konke';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$zu extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$zu._(FinesseLocalizationsDataZu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Kuqediwe';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$zu extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$zu._(FinesseLocalizationsDataZu root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Vala';
	@override String get dismiss => 'Cashisa';
}

/// The flat map containing all translations for locale <zu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataZu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Amahora',
			'timePicker.minutes' => 'Amaminithi',
			'timePicker.seconds' => 'Amasekhondi',
			'timePicker.period' => 'Isikhathi',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Khetha usuku',
			'input.cut' => 'Sika',
			'input.copy' => 'Kopisha',
			'input.paste' => 'Namathisela',
			'input.selectAll' => 'Khetha konke',
			'keyboardToolbar.done' => 'Kuqediwe',
			'dialog.close' => 'Vala',
			'dialog.dismiss' => 'Cashisa',
			_ => null,
		};
	}
}
