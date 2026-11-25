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
	late final FinesseLocalizationsData$actionSheet$en actionSheet = FinesseLocalizationsData$actionSheet$en.internal(_root);
	late final FinesseLocalizationsData$alert$en alert = FinesseLocalizationsData$alert$en.internal(_root);
	late final FinesseLocalizationsData$timePicker$en timePicker = FinesseLocalizationsData$timePicker$en.internal(_root);
	late final FinesseLocalizationsData$datePicker$en datePicker = FinesseLocalizationsData$datePicker$en.internal(_root);
	late final FinesseLocalizationsData$input$en input = FinesseLocalizationsData$input$en.internal(_root);
	late final FinesseLocalizationsData$autocomplete$en autocomplete = FinesseLocalizationsData$autocomplete$en.internal(_root);
	late final FinesseLocalizationsData$numberField$en numberField = FinesseLocalizationsData$numberField$en.internal(_root);
	late final FinesseLocalizationsData$search$en search = FinesseLocalizationsData$search$en.internal(_root);
	late final FinesseLocalizationsData$tagField$en tagField = FinesseLocalizationsData$tagField$en.internal(_root);
	late final FinesseLocalizationsData$keyboardToolbar$en keyboardToolbar = FinesseLocalizationsData$keyboardToolbar$en.internal(_root);
	late final FinesseLocalizationsData$empty$en empty = FinesseLocalizationsData$empty$en.internal(_root);
	late final FinesseLocalizationsData$stepper$en stepper = FinesseLocalizationsData$stepper$en.internal(_root);
	late final FinesseLocalizationsData$toast$en toast = FinesseLocalizationsData$toast$en.internal(_root);
	late final FinesseLocalizationsData$chip$en chip = FinesseLocalizationsData$chip$en.internal(_root);
	late final FinesseLocalizationsData$command$en command = FinesseLocalizationsData$command$en.internal(_root);
	late final FinesseLocalizationsData$menu$en menu = FinesseLocalizationsData$menu$en.internal(_root);
	late final FinesseLocalizationsData$licensePage$en licensePage = FinesseLocalizationsData$licensePage$en.internal(_root);
	late final FinesseLocalizationsData$dataTable$en dataTable = FinesseLocalizationsData$dataTable$en.internal(_root);
	late final FinesseLocalizationsData$pagination$en pagination = FinesseLocalizationsData$pagination$en.internal(_root);
	late final FinesseLocalizationsData$carousel$en carousel = FinesseLocalizationsData$carousel$en.internal(_root);
	late final FinesseLocalizationsData$refreshIndicator$en refreshIndicator = FinesseLocalizationsData$refreshIndicator$en.internal(_root);
	late final FinesseLocalizationsData$reorder$en reorder = FinesseLocalizationsData$reorder$en.internal(_root);
	late final FinesseLocalizationsData$swipeActions$en swipeActions = FinesseLocalizationsData$swipeActions$en.internal(_root);
	late final FinesseLocalizationsData$rating$en rating = FinesseLocalizationsData$rating$en.internal(_root);
	late final FinesseLocalizationsData$colorPicker$en colorPicker = FinesseLocalizationsData$colorPicker$en.internal(_root);
	late final FinesseLocalizationsData$dialog$en dialog = FinesseLocalizationsData$dialog$en.internal(_root);
	late final FinesseLocalizationsData$sheet$en sheet = FinesseLocalizationsData$sheet$en.internal(_root);
	late final FinesseLocalizationsData$button$en button = FinesseLocalizationsData$button$en.internal(_root);
	late final FinesseLocalizationsData$board$en board = FinesseLocalizationsData$board$en.internal(_root);
	late final FinesseLocalizationsData$navigation$en navigation = FinesseLocalizationsData$navigation$en.internal(_root);
}

// Path: actionSheet
class FinesseLocalizationsData$actionSheet$en {
	FinesseLocalizationsData$actionSheet$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: alert
class FinesseLocalizationsData$alert$en {
	FinesseLocalizationsData$alert$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';
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

	/// en: 'AM'
	String get am => 'AM';

	/// en: 'PM'
	String get pm => 'PM';

	/// en: 'Select time'
	String get selectTime => 'Select time';
}

// Path: datePicker
class FinesseLocalizationsData$datePicker$en {
	FinesseLocalizationsData$datePicker$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Select date'
	String get selectDate => 'Select date';

	/// en: 'Select dates'
	String get selectDateRange => 'Select dates';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Day'
	String get day => 'Day';

	/// en: 'Month'
	String get month => 'Month';

	/// en: 'Year'
	String get year => 'Year';
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

// Path: stepper
class FinesseLocalizationsData$stepper$en {
	FinesseLocalizationsData$stepper$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Step $step of $count'
	String position({required Object step, required Object count}) => 'Step ${step} of ${count}';

	/// en: 'Completed'
	String get complete => 'Completed';

	/// en: 'Needs attention'
	String get error => 'Needs attention';

	/// en: 'Continue'
	String get next => 'Continue';

	/// en: 'Finish'
	String get finish => 'Finish';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: toast
class FinesseLocalizationsData$toast$en {
	FinesseLocalizationsData$toast$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';
}

// Path: chip
class FinesseLocalizationsData$chip$en {
	FinesseLocalizationsData$chip$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Remove'
	String get remove => 'Remove';
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

// Path: licensePage
class FinesseLocalizationsData$licensePage$en {
	FinesseLocalizationsData$licensePage$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Licenses'
	String get title => 'Licenses';

	/// en: '1 license'
	String get oneLicense => '1 license';

	/// en: '$count licenses'
	String licenses({required Object count}) => '${count} licenses';
}

// Path: dataTable
class FinesseLocalizationsData$dataTable$en {
	FinesseLocalizationsData$dataTable$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Loading rows'
	String get loading => 'Loading rows';

	/// en: 'These rows could not be loaded.'
	String get loadFailed => 'These rows could not be loaded.';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: '$selected of $total row(s) selected.'
	String selectedCount({required Object selected, required Object total}) => '${selected} of ${total} row(s) selected.';

	/// en: 'Sorted ascending'
	String get sortedAscending => 'Sorted ascending';

	/// en: 'Sorted descending'
	String get sortedDescending => 'Sorted descending';
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

// Path: carousel
class FinesseLocalizationsData$carousel$en {
	FinesseLocalizationsData$carousel$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Previous page'
	String get previous => 'Previous page';

	/// en: 'Next page'
	String get next => 'Next page';

	/// en: 'Page $page of $count'
	String page({required Object page, required Object count}) => 'Page ${page} of ${count}';

	/// en: '$index of $count'
	String item({required Object index, required Object count}) => '${index} of ${count}';
}

// Path: refreshIndicator
class FinesseLocalizationsData$refreshIndicator$en {
	FinesseLocalizationsData$refreshIndicator$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Refreshing'
	String get refreshing => 'Refreshing';
}

// Path: reorder
class FinesseLocalizationsData$reorder$en {
	FinesseLocalizationsData$reorder$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Move up'
	String get moveUp => 'Move up';

	/// en: 'Move down'
	String get moveDown => 'Move down';

	/// en: 'Move to top'
	String get moveToTop => 'Move to top';

	/// en: 'Move to bottom'
	String get moveToBottom => 'Move to bottom';

	/// en: 'Picked up. Use the arrow keys to move, Space to drop, Escape to cancel.'
	String get pickedUp => 'Picked up. Use the arrow keys to move, Space to drop, Escape to cancel.';

	/// en: 'Position $position of $count'
	String position({required Object position, required Object count}) => 'Position ${position} of ${count}';

	/// en: 'Dropped at position $position of $count'
	String dropped({required Object position, required Object count}) => 'Dropped at position ${position} of ${count}';

	/// en: 'Move cancelled'
	String get cancelled => 'Move cancelled';

	/// en: 'Drag to reorder'
	String get dragHandle => 'Drag to reorder';
}

// Path: swipeActions
class FinesseLocalizationsData$swipeActions$en {
	FinesseLocalizationsData$swipeActions$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'More actions'
	String get more => 'More actions';
}

// Path: rating
class FinesseLocalizationsData$rating$en {
	FinesseLocalizationsData$rating$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: '$value of $count'
	String value({required Object value, required Object count}) => '${value} of ${count}';
}

// Path: colorPicker
class FinesseLocalizationsData$colorPicker$en {
	FinesseLocalizationsData$colorPicker$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Hex'
	String get hex => 'Hex';

	/// en: 'Hue'
	String get hue => 'Hue';

	/// en: 'Opacity'
	String get opacity => 'Opacity';

	/// en: 'Saturation and brightness'
	String get saturationAndBrightness => 'Saturation and brightness';

	/// en: 'Select colour'
	String get selectColor => 'Select colour';
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

// Path: button
class FinesseLocalizationsData$button$en {
	FinesseLocalizationsData$button$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Loading'
	String get loading => 'Loading';
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

// Path: navigation
class FinesseLocalizationsData$navigation$en {
	FinesseLocalizationsData$navigation$en.internal(this._root);

	final FinesseLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Open menu'
	String get openMenu => 'Open menu';

	/// en: 'Navigation menu'
	String get menu => 'Navigation menu';

	/// en: 'Toggle sidebar'
	String get toggleSidebar => 'Toggle sidebar';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on FinesseLocalizationsData {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'actionSheet.cancel' => 'Cancel',
			'alert.dismiss' => 'Dismiss',
			'timePicker.hours' => 'Hours',
			'timePicker.minutes' => 'Minutes',
			'timePicker.seconds' => 'Seconds',
			'timePicker.period' => 'Period',
			'timePicker.periodPlaceholder' => 'AM',
			'timePicker.am' => 'AM',
			'timePicker.pm' => 'PM',
			'timePicker.selectTime' => 'Select time',
			'datePicker.selectDate' => 'Select date',
			'datePicker.selectDateRange' => 'Select dates',
			'datePicker.done' => 'Done',
			'datePicker.clear' => 'Clear',
			'datePicker.cancel' => 'Cancel',
			'datePicker.day' => 'Day',
			'datePicker.month' => 'Month',
			'datePicker.year' => 'Year',
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
			'stepper.position' => ({required Object step, required Object count}) => 'Step ${step} of ${count}',
			'stepper.complete' => 'Completed',
			'stepper.error' => 'Needs attention',
			'stepper.next' => 'Continue',
			'stepper.finish' => 'Finish',
			'stepper.cancel' => 'Cancel',
			'toast.dismiss' => 'Dismiss',
			'chip.remove' => 'Remove',
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
			'licensePage.title' => 'Licenses',
			'licensePage.oneLicense' => '1 license',
			'licensePage.licenses' => ({required Object count}) => '${count} licenses',
			'dataTable.loading' => 'Loading rows',
			'dataTable.loadFailed' => 'These rows could not be loaded.',
			'dataTable.retry' => 'Try again',
			'dataTable.selectedCount' => ({required Object selected, required Object total}) => '${selected} of ${total} row(s) selected.',
			'dataTable.sortedAscending' => 'Sorted ascending',
			'dataTable.sortedDescending' => 'Sorted descending',
			'pagination.previous' => 'Previous',
			'pagination.next' => 'Next',
			'pagination.morePages' => 'More pages',
			'pagination.page' => 'Page',
			'carousel.previous' => 'Previous page',
			'carousel.next' => 'Next page',
			'carousel.page' => ({required Object page, required Object count}) => 'Page ${page} of ${count}',
			'carousel.item' => ({required Object index, required Object count}) => '${index} of ${count}',
			'refreshIndicator.refresh' => 'Refresh',
			'refreshIndicator.refreshing' => 'Refreshing',
			'reorder.moveUp' => 'Move up',
			'reorder.moveDown' => 'Move down',
			'reorder.moveToTop' => 'Move to top',
			'reorder.moveToBottom' => 'Move to bottom',
			'reorder.pickedUp' => 'Picked up. Use the arrow keys to move, Space to drop, Escape to cancel.',
			'reorder.position' => ({required Object position, required Object count}) => 'Position ${position} of ${count}',
			'reorder.dropped' => ({required Object position, required Object count}) => 'Dropped at position ${position} of ${count}',
			'reorder.cancelled' => 'Move cancelled',
			'reorder.dragHandle' => 'Drag to reorder',
			'swipeActions.more' => 'More actions',
			'rating.value' => ({required Object value, required Object count}) => '${value} of ${count}',
			'colorPicker.hex' => 'Hex',
			'colorPicker.hue' => 'Hue',
			'colorPicker.opacity' => 'Opacity',
			'colorPicker.saturationAndBrightness' => 'Saturation and brightness',
			'colorPicker.selectColor' => 'Select colour',
			'dialog.close' => 'Close',
			'dialog.dismiss' => 'Dismiss',
			'sheet.resize' => 'Resize',
			'button.loading' => 'Loading',
			'board.moveUp' => 'Move up',
			'board.moveDown' => 'Move down',
			'board.moveTo' => ({required Object column}) => 'Move to ${column}',
			'board.pickedUp' => 'Picked up. Use the arrow keys to move, Space to drop, Escape to cancel.',
			'board.position' => ({required Object column, required Object position, required Object count}) => '${column}, position ${position} of ${count}',
			'board.dropped' => ({required Object column, required Object position, required Object count}) => 'Dropped in ${column}, position ${position} of ${count}',
			'board.cancelled' => 'Move cancelled',
			'board.refused' => ({required Object column}) => '${column} does not accept this item',
			'board.dragHandle' => 'Drag to move',
			'navigation.back' => 'Back',
			'navigation.openMenu' => 'Open menu',
			'navigation.menu' => 'Navigation menu',
			'navigation.toggleSidebar' => 'Toggle sidebar',
			_ => null,
		};
	}
}
