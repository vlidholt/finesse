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
class UnaLocalizationsDataMr extends UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsDataMr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.mr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <mr>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final UnaLocalizationsDataMr _root = this; // ignore: unused_field

	@override 
	UnaLocalizationsDataMr $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsDataMr(meta: meta ?? this.$meta);

	// Translations
	@override late final _UnaLocalizationsData$timePicker$mr timePicker = _UnaLocalizationsData$timePicker$mr._(_root);
	@override late final _UnaLocalizationsData$datePicker$mr datePicker = _UnaLocalizationsData$datePicker$mr._(_root);
	@override late final _UnaLocalizationsData$input$mr input = _UnaLocalizationsData$input$mr._(_root);
	@override late final _UnaLocalizationsData$keyboardToolbar$mr keyboardToolbar = _UnaLocalizationsData$keyboardToolbar$mr._(_root);
	@override late final _UnaLocalizationsData$dialog$mr dialog = _UnaLocalizationsData$dialog$mr._(_root);
}

// Path: timePicker
class _UnaLocalizationsData$timePicker$mr extends UnaLocalizationsData$timePicker$en {
	_UnaLocalizationsData$timePicker$mr._(UnaLocalizationsDataMr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'तास';
	@override String get minutes => 'मिनिटे';
	@override String get seconds => 'सेकंद';
	@override String get period => 'कालावधी';
	@override String get periodPlaceholder => 'AM';
}

// Path: datePicker
class _UnaLocalizationsData$datePicker$mr extends UnaLocalizationsData$datePicker$en {
	_UnaLocalizationsData$datePicker$mr._(UnaLocalizationsDataMr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get selectDate => 'तारीख निवडा';
}

// Path: input
class _UnaLocalizationsData$input$mr extends UnaLocalizationsData$input$en {
	_UnaLocalizationsData$input$mr._(UnaLocalizationsDataMr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get cut => 'कट';
	@override String get copy => 'कॉपी';
	@override String get paste => 'पेस्ट';
	@override String get selectAll => 'सर्व निवडा';
}

// Path: keyboardToolbar
class _UnaLocalizationsData$keyboardToolbar$mr extends UnaLocalizationsData$keyboardToolbar$en {
	_UnaLocalizationsData$keyboardToolbar$mr._(UnaLocalizationsDataMr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get done => 'पूर्ण';
}

// Path: dialog
class _UnaLocalizationsData$dialog$mr extends UnaLocalizationsData$dialog$en {
	_UnaLocalizationsData$dialog$mr._(UnaLocalizationsDataMr root) : this._root = root, super.internal(root);

	final UnaLocalizationsDataMr _root; // ignore: unused_field

	// Translations
	@override String get close => 'बंद करा';
	@override String get dismiss => 'डिसमिस करा';
}

/// The flat map containing all translations for locale <mr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsDataMr {
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
