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
class UnaLocalizationsDataZu extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataZu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.zu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zu>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataZu _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataZu $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataZu(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$zu timePicker = _UnaLocalizationsData$timePicker$zu._(_root);
	@override late final _UnaLocalizationsData$datePicker$zu datePicker = _UnaLocalizationsData$datePicker$zu._(_root);
	@override late final _UnaLocalizationsData$input$zu input = _UnaLocalizationsData$input$zu._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$zu keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$zu._(_root);
	@override late final _UnaLocalizationsData$dialog$zu dialog = _UnaLocalizationsData$dialog$zu._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$zu extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$zu._(UnaLocalizationsDataZu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Amahora';
	@override String get minutes => 'Amaminithi';
	@override String get seconds => 'Amasekhondi';
	@override String get period => 'Isikhathi';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$zu extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$zu._(UnaLocalizationsDataZu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'Khetha usuku';
}

// Path: input
class _UnaLocalizationsData$input$zu extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$zu._(UnaLocalizationsDataZu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get cut => 'Sika';
	@override String get copy => 'Kopisha';
	@override String get paste => 'Namathisela';
	@override String get selectAll => 'Khetha konke';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$zu extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$zu._(UnaLocalizationsDataZu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get done => 'Kuqediwe';
}

// Path: dialog
class _UnaLocalizationsData$dialog$zu extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$zu._(UnaLocalizationsDataZu root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataZu _root; // ignore: unused_field

	// Translations
	@override String get close => 'Vala';
	@override String get dismiss => 'Cashisa';
}

/// The flat map containing all translations for locale <zu>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataZu {
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
