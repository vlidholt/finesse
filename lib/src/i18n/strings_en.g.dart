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
	late final FinesseLocalizationsData$menu$en menu = FinesseLocalizationsData$menu$en.internal(_root);
	late final FinesseLocalizationsData$pagination$en pagination = FinesseLocalizationsData$pagination$en.internal(_root);
	late final FinesseLocalizationsData$dialog$en dialog = FinesseLocalizationsData$dialog$en.internal(_root);
	late final FinesseLocalizationsData$sheet$en sheet = FinesseLocalizationsData$sheet$en.internal(_root);
	late final FinesseLocalizationsData$board$en board = FinesseLocalizationsData$board$en.internal(_root);
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

// Path: menu
class FinesseLocalizationsData$menu$en {
	FinesseLocalizationsData$menu$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Ctrl'
	String get control => 'Ctrl';

	/// en: 'Alt'
	String get alt => 'Alt';

	/// en: 'Shift'
	String get shift => 'Shift';

	/// en: 'Meta'
	String get meta => 'Meta';

	/// en: 'Enter'
	String get enter => 'Enter';

	/// en: 'Esc'
	String get escape => 'Esc';

	/// en: 'Space'
	String get space => 'Space';

	/// en: 'Tab'
	String get tab => 'Tab';

	/// en: 'Backspace'
	String get backspace => 'Backspace';

	/// en: 'Del'
	String get delete => 'Del';

	/// en: 'Ins'
	String get insert => 'Ins';

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'End'
	String get end => 'End';

	/// en: 'PgUp'
	String get pageUp => 'PgUp';

	/// en: 'PgDn'
	String get pageDown => 'PgDn';
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

// Path: sheet
class FinesseLocalizationsData$sheet$en {
	FinesseLocalizationsData$sheet$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Resize'
	String get resize => 'Resize';
}

// Path: board
class FinesseLocalizationsData$board$en {
	FinesseLocalizationsData$board$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Move up'
	String get moveUp => 'Move up';

	/// en: 'Move down'
	String get moveDown => 'Move down';

	/// en: 'Move to $column'
	String moveTo({required Object column}) => 'Move to ${column}';

	/// en: 'Picked up. Use the arrow keys to move, Space to drop, Escape to cancel.'
	String get pickedUp => 'Picked up. Use the arrow keys to move, Space to drop, Escape to cancel.';

	/// en: '$column, position $position of $count'
	String position({required Object column, required Object position, required Object count}) => '${column}, position ${position} of ${count}';

	/// en: 'Dropped in $column, position $position of $count'
	String dropped({required Object column, required Object position, required Object count}) => 'Dropped in ${column}, position ${position} of ${count}';

	/// en: 'Move cancelled'
	String get cancelled => 'Move cancelled';

	/// en: '$column does not accept this item'
	String refused({required Object column}) => '${column} does not accept this item';

	/// en: 'Drag to move'
	String get dragHandle => 'Drag to move';
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
			'menu.control' => 'Ctrl',
			'menu.alt' => 'Alt',
			'menu.shift' => 'Shift',
			'menu.meta' => 'Meta',
			'menu.enter' => 'Enter',
			'menu.escape' => 'Esc',
			'menu.space' => 'Space',
			'menu.tab' => 'Tab',
			'menu.backspace' => 'Backspace',
			'menu.delete' => 'Del',
			'menu.insert' => 'Ins',
			'menu.home' => 'Home',
			'menu.end' => 'End',
			'menu.pageUp' => 'PgUp',
			'menu.pageDown' => 'PgDn',
			'pagination.previous' => 'Previous',
			'pagination.next' => 'Next',
			'pagination.morePages' => 'More pages',
			'pagination.page' => 'Page',
			'dialog.close' => 'Close',
			'dialog.dismiss' => 'Dismiss',
			'sheet.resize' => 'Resize',
			'board.moveUp' => 'Move up',
			'board.moveDown' => 'Move down',
			'board.moveTo' => ({required Object column}) => 'Move to ${column}',
			'board.pickedUp' => 'Picked up. Use the arrow keys to move, Space to drop, Escape to cancel.',
			'board.position' => ({required Object column, required Object position, required Object count}) => '${column}, position ${position} of ${count}',
			'board.dropped' => ({required Object column, required Object position, required Object count}) => 'Dropped in ${column}, position ${position} of ${count}',
			'board.cancelled' => 'Move cancelled',
			'board.refused' => ({required Object column}) => '${column} does not accept this item',
			'board.dragHandle' => 'Drag to move',
			_ => null,
		};
	}
}
