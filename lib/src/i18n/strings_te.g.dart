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
class UnaLocalizationsDataTe extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataTe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.te,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <te>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataTe _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataTe $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataTe(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$te timePicker = _UnaLocalizationsData$timePicker$te._(_root);
	@override late final _UnaLocalizationsData$datePicker$te datePicker = _UnaLocalizationsData$datePicker$te._(_root);
	@override late final _UnaLocalizationsData$input$te input = _UnaLocalizationsData$input$te._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$te keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$te._(_root);
	@override late final _UnaLocalizationsData$dialog$te dialog = _UnaLocalizationsData$dialog$te._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$te extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$te._(UnaLocalizationsDataTe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'గంటలు';
	@override String get minutes => 'నిమిషాలు';
	@override String get seconds => 'సెకన్లు';
	@override String get period => 'కాలం';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$te extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$te._(UnaLocalizationsDataTe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'తేదీని ఎంచుకోండి';
}

// Path: input
class _UnaLocalizationsData$input$te extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$te._(UnaLocalizationsDataTe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get cut => 'కత్తిరించు';
	@override String get copy => 'కాపీ చేయి';
	@override String get paste => 'అతికించు';
	@override String get selectAll => 'అన్నీ ఎంచుకో';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$te extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$te._(UnaLocalizationsDataTe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get done => 'పూర్తయింది';
}

// Path: dialog
class _UnaLocalizationsData$dialog$te extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$te._(UnaLocalizationsDataTe root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataTe _root; // ignore: unused_field

	// Translations
	@override String get close => 'మూసివేయండి';
	@override String get dismiss => 'విస్మరించు';
}

/// The flat map containing all translations for locale <te>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataTe {
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
