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
class FinesseLocalizationsDataSi extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataSi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.si,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <si>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataSi _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataSi $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataSi(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$si timePicker = _FinesseLocalizationsData$timePicker$si._(_root);
	@override late final _FinesseLocalizationsData$datePicker$si datePicker = _FinesseLocalizationsData$datePicker$si._(_root);
	@override late final _FinesseLocalizationsData$input$si input = _FinesseLocalizationsData$input$si._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$si keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$si._(_root);
	@override late final _FinesseLocalizationsData$dialog$si dialog = _FinesseLocalizationsData$dialog$si._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$si extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$si._(FinesseLocalizationsDataSi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'පැය';
	@override String get minutes => 'මිනිත්තු';
	@override String get seconds => 'තත්පර';
	@override String get period => 'කාලය';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$si extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$si._(FinesseLocalizationsDataSi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'දිනය තෝරන්න';
}

// Path: input
class _FinesseLocalizationsData$input$si extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$si._(FinesseLocalizationsDataSi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'කපන්න';
	@override String get copy => 'පිටපත් කරන්න';
	@override String get paste => 'අලවන්න';
	@override String get selectAll => 'සියල්ල තෝරන්න';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$si extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$si._(FinesseLocalizationsDataSi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get done => 'සිදු විය';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$si extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$si._(FinesseLocalizationsDataSi root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get close => 'වසන්න';
	@override String get dismiss => 'ඉවත ලන්න';
}

/// The flat map containing all translations for locale <si>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataSi {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'පැය',
			'timePicker.minutes' => 'මිනිත්තු',
			'timePicker.seconds' => 'තත්පර',
			'timePicker.period' => 'කාලය',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'දිනය තෝරන්න',
			'input.cut' => 'කපන්න',
			'input.copy' => 'පිටපත් කරන්න',
			'input.paste' => 'අලවන්න',
			'input.selectAll' => 'සියල්ල තෝරන්න',
			'keyboardToolbar.done' => 'සිදු විය',
			'dialog.close' => 'වසන්න',
			'dialog.dismiss' => 'ඉවත ලන්න',
			_ => null,
		};
	}
}
