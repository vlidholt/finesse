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
class FinesseLocalizationsDataTe extends FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsDataTe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.te,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <te>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final FinesseLocalizationsDataTe _root = this; // ignore: unused_field

	@override 
	FinesseLocalizationsDataTe $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsDataTe(meta: meta ?? this.$meta);

	// Translations
	@override late final _FinesseLocalizationsData$timePicker$te timePicker = _FinesseLocalizationsData$timePicker$te._(_root);
	@override late final _FinesseLocalizationsData$datePicker$te datePicker = _FinesseLocalizationsData$datePicker$te._(_root);
	@override late final _FinesseLocalizationsData$input$te input = _FinesseLocalizationsData$input$te._(_root);
	@override late final _FinesseLocalizationsData$keyboardToolbar$te keyboardToolbar = _FinesseLocalizationsData$keyboardToolbar$te._(_root);
	@override late final _FinesseLocalizationsData$dialog$te dialog = _FinesseLocalizationsData$dialog$te._(_root);
}

// Path: timePicker
class _FinesseLocalizationsData$timePicker$te extends FinesseLocalizationsData$timePicker$en {
	_FinesseLocalizationsData$timePicker$te._(FinesseLocalizationsDataTe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'గంటలు';
	@override String get minutes => 'నిమిషాలు';
	@override String get seconds => 'సెకన్లు';
	@override String get period => 'కాలం';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _FinesseLocalizationsData$datePicker$te extends FinesseLocalizationsData$datePicker$en {
	_FinesseLocalizationsData$datePicker$te._(FinesseLocalizationsDataTe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'తేదీని ఎంచుకోండి';
}

// Path: input
class _FinesseLocalizationsData$input$te extends FinesseLocalizationsData$input$en {
	_FinesseLocalizationsData$input$te._(FinesseLocalizationsDataTe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'కత్తిరించు';
	@override String get copy => 'కాపీ చేయి';
	@override String get paste => 'అతికించు';
	@override String get selectAll => 'అన్నీ ఎంచుకో';
}

// Path: keyboardToolbar
class _FinesseLocalizationsData$keyboardToolbar$te extends FinesseLocalizationsData$keyboardToolbar$en {
	_FinesseLocalizationsData$keyboardToolbar$te._(FinesseLocalizationsDataTe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get done => 'పూర్తయింది';
}

// Path: dialog
class _FinesseLocalizationsData$dialog$te extends FinesseLocalizationsData$dialog$en {
	_FinesseLocalizationsData$dialog$te._(FinesseLocalizationsDataTe root) : this._root = root, super.internal(root);

	final FinesseLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get close => 'మూసివేయండి';
	@override String get dismiss => 'విస్మరించు';
}

/// The flat map containing all translations for locale <te>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsDataTe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'గంటలు',
			'timePicker.minutes' => 'నిమిషాలు',
			'timePicker.seconds' => 'సెకన్లు',
			'timePicker.period' => 'కాలం',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'తేదీని ఎంచుకోండి',
			'input.cut' => 'కత్తిరించు',
			'input.copy' => 'కాపీ చేయి',
			'input.paste' => 'అతికించు',
			'input.selectAll' => 'అన్నీ ఎంచుకో',
			'keyboardToolbar.done' => 'పూర్తయింది',
			'dialog.close' => 'మూసివేయండి',
			'dialog.dismiss' => 'విస్మరించు',
			_ => null,
		};
	}
}
