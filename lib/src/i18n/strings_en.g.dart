///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef FinesseLocalizationsDataEn = FinesseLocalizationsData; // ignore: unused_element
class FinesseLocalizationsData with BaseTranslations<FinesseLocale, FinesseLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [FinesseLocale.build] is preferred.
	FinesseLocalizationsData({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: FinesseLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<FinesseLocale, FinesseLocalizationsData> _meta;
	@override TranslationMetadata<FinesseLocale, FinesseLocalizationsData> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final FinesseLocalizationsData _root = this; // ignore: unused_field

	FinesseLocalizationsData $copyWith({TranslationMetadata<FinesseLocale, FinesseLocalizationsData>? meta}) => FinesseLocalizationsData(meta: meta ?? this.$meta);

	// Translations
	late final FinesseLocalizationsData$timePicker$en timePicker = FinesseLocalizationsData$timePicker$en.internal(_root);
	late final FinesseLocalizationsData$datePicker$en datePicker = FinesseLocalizationsData$datePicker$en.internal(_root);
	late final FinesseLocalizationsData$input$en input = FinesseLocalizationsData$input$en.internal(_root);
	late final FinesseLocalizationsData$keyboardToolbar$en keyboardToolbar = FinesseLocalizationsData$keyboardToolbar$en.internal(_root);
	late final FinesseLocalizationsData$empty$en empty = FinesseLocalizationsData$empty$en.internal(_root);
	late final FinesseLocalizationsData$command$en command = FinesseLocalizationsData$command$en.internal(_root);
	late final FinesseLocalizationsData$pagination$en pagination = FinesseLocalizationsData$pagination$en.internal(_root);
	late final FinesseLocalizationsData$dialog$en dialog = FinesseLocalizationsData$dialog$en.internal(_root);
}

// Path: timePicker
class FinesseLocalizationsData$timePicker$en {
	FinesseLocalizationsData$timePicker$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Hours'
	String get hours => 'Hours';

	/// en: 'Minutes'
	String get minutes => 'Minutes';

	/// en: 'Seconds'
	String get seconds => 'Seconds';

	/// en: 'Period'
	String get period => 'Period';

	/// en: 'AM'
	String get periodPlaceholder => 'AM';
}

// Path: datePicker
class FinesseLocalizationsData$datePicker$en {
	FinesseLocalizationsData$datePicker$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Select date'
	String get selectDate => 'Select date';
}

// Path: input
class FinesseLocalizationsData$input$en {
	FinesseLocalizationsData$input$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Cut'
	String get cut => 'Cut';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Paste'
	String get paste => 'Paste';

	/// en: 'Select All'
	String get selectAll => 'Select All';
}

// Path: keyboardToolbar
class FinesseLocalizationsData$keyboardToolbar$en {
	FinesseLocalizationsData$keyboardToolbar$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Done'
	String get done => 'Done';
}

// Path: empty
class FinesseLocalizationsData$empty$en {
	FinesseLocalizationsData$empty$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'No results'
	String get title => 'No results';
}

// Path: command
class FinesseLocalizationsData$command$en {
	FinesseLocalizationsData$command$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'No results found.'
	String get noResults => 'No results found.';
}

// Path: pagination
class FinesseLocalizationsData$pagination$en {
	FinesseLocalizationsData$pagination$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Previous'
	String get previous => 'Previous';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'More pages'
	String get morePages => 'More pages';

	/// en: 'Page'
	String get page => 'Page';
}

// Path: dialog
class FinesseLocalizationsData$dialog$en {
	FinesseLocalizationsData$dialog$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsData {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'timePicker.hours' => 'Hours',
			'timePicker.minutes' => 'Minutes',
			'timePicker.seconds' => 'Seconds',
			'timePicker.period' => 'Period',
			'timePicker.periodPlaceholder' => 'AM',
			'datePicker.selectDate' => 'Select date',
			'input.cut' => 'Cut',
			'input.copy' => 'Copy',
			'input.paste' => 'Paste',
			'input.selectAll' => 'Select All',
			'keyboardToolbar.done' => 'Done',
			'empty.title' => 'No results',
			'command.noResults' => 'No results found.',
			'pagination.previous' => 'Previous',
			'pagination.next' => 'Next',
			'pagination.morePages' => 'More pages',
			'pagination.page' => 'Page',
			'dialog.close' => 'Close',
			'dialog.dismiss' => 'Dismiss',
			_ => null,
		};
	}
}
