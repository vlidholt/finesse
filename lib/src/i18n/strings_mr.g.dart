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
class FinesseLocalizationsDataMr extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataMr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.mr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <mr>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataMr _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataMr $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataMr(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$mr timePicker = _FinesseLocalizationsData$timePicker$mr._(_root);
	@override late final _FinesseLocalizationsData$datePicker$mr datePicker = _FinesseLocalizationsData$datePicker$mr._(_root);
	@override late final _FinesseLocalizationsData$input$mr input = _FinesseLocalizationsData$input$mr._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$mr keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$mr._(_root);
	@override late final _FinesseLocalizationsData$dialog$mr dialog = _FinesseLocalizationsData$dialog$mr._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$mr extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$mr._(FinesseLocalizationsDataMr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'तास';
	@override String get minutes => 'मिनिटे';
	@override String get seconds => 'सेकंद';
	@override String get period => 'कालावधी';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$mr extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$mr._(FinesseLocalizationsDataMr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'तारीख निवडा';
}

// Path: input
class _FinesseLocalizationsData$input$mr extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$mr._(FinesseLocalizationsDataMr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'कट';
	@override String get copy => 'कॉपी';
	@override String get paste => 'पेस्ट';
	@override String get selectAll => 'सर्व निवडा';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$mr extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$mr._(FinesseLocalizationsDataMr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get done => 'पूर्ण';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$mr extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$mr._(FinesseLocalizationsDataMr root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get close => 'बंद करा';
	@override String get dismiss => 'डिसमिस करा';
}

/// The flat map containing all translations for locale <mr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataMr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'तास',
			'timePicker.minutes' => 'मिनिटे',
			'timePicker.seconds' => 'सेकंद',
			'timePicker.period' => 'कालावधी',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'तारीख निवडा',
			'input.cut' => 'कट',
			'input.copy' => 'कॉपी',
			'input.paste' => 'पेस्ट',
			'input.selectAll' => 'सर्व निवडा',
			'keyboardToolbar.done' => 'पूर्ण',
			'dialog.close' => 'बंद करा',
			'dialog.dismiss' => 'डिसमिस करा',
			_ => null,
		};
	}
}
