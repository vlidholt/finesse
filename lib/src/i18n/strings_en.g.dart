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
	late final FinesseLocalizationsData$autocomplete$en autocomplete = FinesseLocalizationsData$autocomplete$en.internal(_root);
	late final FinesseLocalizationsData$numberField$en numberField = FinesseLocalizationsData$numberField$en.internal(_root);
	late final FinesseLocalizationsData$search$en search = FinesseLocalizationsData$search$en.internal(_root);
	late final FinesseLocalizationsData$tagField$en tagField = FinesseLocalizationsData$tagField$en.internal(_root);
	late final FinesseLocalizationsData$keyboardToolbar$en keyboardToolbar = FinesseLocalizationsData$keyboardToolbar$en.internal(_root);
	late final FinesseLocalizationsData$empty$en empty = FinesseLocalizationsData$empty$en.internal(_root);
	late final FinesseLocalizationsData$command$en command = FinesseLocalizationsData$command$en.internal(_root);
	late final FinesseLocalizationsData$pagination$en pagination = FinesseLocalizationsData$pagination$en.internal(_root);
	late final FinesseLocalizationsData$dialog$en dialog = FinesseLocalizationsData$dialog$en.internal(_root);
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

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Look Up'
	String get lookUp => 'Look Up';

	/// en: 'Search Web'
	String get searchWeb => 'Search Web';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Scan Text'
	String get liveText => 'Scan Text';

	/// en: 'More'
	String get moreActions => 'More';

	/// en: 'Back'
	String get previousActions => 'Back';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Show password'
	String get showPassword => 'Show password';

	/// en: 'Hide password'
	String get hidePassword => 'Hide password';

	/// en: '$count of $max characters'
	String characterCount({required Object count, required Object max}) => '${count} of ${max} characters';

	/// en: 'Character limit reached'
	String get characterLimit => 'Character limit reached';
}

// Path: autocomplete
class FinesseLocalizationsData$autocomplete$en {
	FinesseLocalizationsData$autocomplete$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'No results'
	String get noResults => 'No results';

	/// en: '1 result available'
	String get oneResult => '1 result available';

	/// en: '$count results available'
	String results({required Object count}) => '${count} results available';

	/// en: 'Loading…'
	String get loading => 'Loading…';
}

// Path: numberField
class FinesseLocalizationsData$numberField$en {
	FinesseLocalizationsData$numberField$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Increase'
	String get increase => 'Increase';

	/// en: 'Decrease'
	String get decrease => 'Decrease';
}

// Path: search
class FinesseLocalizationsData$search$en {
	FinesseLocalizationsData$search$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Search'
	String get placeholder => 'Search';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Clear search'
	String get clear => 'Clear search';

	/// en: 'Close search'
	String get close => 'Close search';
}

// Path: tagField
class FinesseLocalizationsData$tagField$en {
	FinesseLocalizationsData$tagField$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Remove $tag'
	String remove({required Object tag}) => 'Remove ${tag}';

	/// en: '$tag added'
	String added({required Object tag}) => '${tag} added';

	/// en: '$tag removed'
	String removed({required Object tag}) => '${tag} removed';
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
			'input.delete' => 'Delete',
			'input.lookUp' => 'Look Up',
			'input.searchWeb' => 'Search Web',
			'input.share' => 'Share',
			'input.liveText' => 'Scan Text',
			'input.moreActions' => 'More',
			'input.previousActions' => 'Back',
			'input.clear' => 'Clear',
			'input.showPassword' => 'Show password',
			'input.hidePassword' => 'Hide password',
			'input.characterCount' => ({required Object count, required Object max}) => '${count} of ${max} characters',
			'input.characterLimit' => 'Character limit reached',
			'autocomplete.noResults' => 'No results',
			'autocomplete.oneResult' => '1 result available',
			'autocomplete.results' => ({required Object count}) => '${count} results available',
			'autocomplete.loading' => 'Loading…',
			'numberField.increase' => 'Increase',
			'numberField.decrease' => 'Decrease',
			'search.placeholder' => 'Search',
			'search.cancel' => 'Cancel',
			'search.clear' => 'Clear search',
			'search.close' => 'Close search',
			'tagField.remove' => ({required Object tag}) => 'Remove ${tag}',
			'tagField.added' => ({required Object tag}) => '${tag} added',
			'tagField.removed' => ({required Object tag}) => '${tag} removed',
			'keyboardToolbar.done' => 'Done',
			'empty.title' => 'No results',
			'command.noResults' => 'No results found.',
			'pagination.previous' => 'Previous',
			'pagination.next' => 'Next',
			'pagination.morePages' => 'More pages',
			'pagination.page' => 'Page',
			'dialog.close' => 'Close',
			'dialog.dismiss' => 'Dismiss',
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
