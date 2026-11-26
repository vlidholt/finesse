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
class UnaLocalizationsDataSi extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataSi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.si,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <si>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataSi _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataSi $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataSi(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$si timePicker = _UnaLocalizationsData$timePicker$si._(_root);
	@override late final _UnaLocalizationsData$datePicker$si datePicker = _UnaLocalizationsData$datePicker$si._(_root);
	@override late final _UnaLocalizationsData$input$si input = _UnaLocalizationsData$input$si._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$si keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$si._(_root);
	@override late final _UnaLocalizationsData$dialog$si dialog = _UnaLocalizationsData$dialog$si._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$si extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$si._(UnaLocalizationsDataSi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get hours => 'පැය';
	@override String get minutes => 'මිනිත්තු';
	@override String get seconds => 'තත්පර';
	@override String get period => 'කාලය';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$si extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$si._(UnaLocalizationsDataSi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'දිනය තෝරන්න';
}

// Path: input
class _UnaLocalizationsData$input$si extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$si._(UnaLocalizationsDataSi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get cut => 'කපන්න';
	@override String get copy => 'පිටපත් කරන්න';
	@override String get paste => 'අලවන්න';
	@override String get selectAll => 'සියල්ල තෝරන්න';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$si extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$si._(UnaLocalizationsDataSi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get done => 'සිදු විය';
}

// Path: dialog
class _UnaLocalizationsData$dialog$si extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$si._(UnaLocalizationsDataSi root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataSi _root; // ignore: unused_field

	// Translations
	@override String get close => 'වසන්න';
	@override String get dismiss => 'ඉවත ලන්න';
}

/// The flat map containing all translations for locale <si>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataSi {
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
