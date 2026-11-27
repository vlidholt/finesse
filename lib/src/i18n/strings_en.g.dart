///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef UnaLocalizationsDataEn = UnaLocalizationsData; // ignore: unused_element
class UnaLocalizationsData with BaseTranslations<UnaLocale, UnaLocalizationsData> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [UnaLocale.build] is preferred.
	UnaLocalizationsData({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: UnaLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<UnaLocale, UnaLocalizationsData> _meta;
	@override TranslationMetadata<UnaLocale, UnaLocalizationsData> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final UnaLocalizationsData _root = this; // ignore: unused_field

	UnaLocalizationsData $copyWith({TranslationMetadata<UnaLocale, UnaLocalizationsData>? meta}) => UnaLocalizationsData(meta: meta ?? this.$meta);

	// Translations
	late final UnaLocalizationsData$actionSheet$en actionSheet = UnaLocalizationsData$actionSheet$en.internal(_root);
	late final UnaLocalizationsData$alert$en alert = UnaLocalizationsData$alert$en.internal(_root);
	late final UnaLocalizationsData$timePicker$en timePicker = UnaLocalizationsData$timePicker$en.internal(_root);
	late final UnaLocalizationsData$datePicker$en datePicker = UnaLocalizationsData$datePicker$en.internal(_root);
	late final UnaLocalizationsData$calendar$en calendar = UnaLocalizationsData$calendar$en.internal(_root);
	late final UnaLocalizationsData$input$en input = UnaLocalizationsData$input$en.internal(_root);
	late final UnaLocalizationsData$autocomplete$en autocomplete = UnaLocalizationsData$autocomplete$en.internal(_root);
	late final UnaLocalizationsData$otpField$en otpField = UnaLocalizationsData$otpField$en.internal(_root);
	late final UnaLocalizationsData$numberField$en numberField = UnaLocalizationsData$numberField$en.internal(_root);
	late final UnaLocalizationsData$search$en search = UnaLocalizationsData$search$en.internal(_root);
	late final UnaLocalizationsData$tagField$en tagField = UnaLocalizationsData$tagField$en.internal(_root);
	late final UnaLocalizationsData$keyboardToolbar$en keyboardToolbar = UnaLocalizationsData$keyboardToolbar$en.internal(_root);
	late final UnaLocalizationsData$empty$en empty = UnaLocalizationsData$empty$en.internal(_root);
	late final UnaLocalizationsData$stepper$en stepper = UnaLocalizationsData$stepper$en.internal(_root);
	late final UnaLocalizationsData$toast$en toast = UnaLocalizationsData$toast$en.internal(_root);
	late final UnaLocalizationsData$chip$en chip = UnaLocalizationsData$chip$en.internal(_root);
	late final UnaLocalizationsData$command$en command = UnaLocalizationsData$command$en.internal(_root);
	late final UnaLocalizationsData$menu$en menu = UnaLocalizationsData$menu$en.internal(_root);
	late final UnaLocalizationsData$licensePage$en licensePage = UnaLocalizationsData$licensePage$en.internal(_root);
	late final UnaLocalizationsData$dataTable$en dataTable = UnaLocalizationsData$dataTable$en.internal(_root);
	late final UnaLocalizationsData$pagination$en pagination = UnaLocalizationsData$pagination$en.internal(_root);
	late final UnaLocalizationsData$carousel$en carousel = UnaLocalizationsData$carousel$en.internal(_root);
	late final UnaLocalizationsData$slider$en slider = UnaLocalizationsData$slider$en.internal(_root);
	late final UnaLocalizationsData$refreshIndicator$en refreshIndicator = UnaLocalizationsData$refreshIndicator$en.internal(_root);
	late final UnaLocalizationsData$reorder$en reorder = UnaLocalizationsData$reorder$en.internal(_root);
	late final UnaLocalizationsData$swipeActions$en swipeActions = UnaLocalizationsData$swipeActions$en.internal(_root);
	late final UnaLocalizationsData$rating$en rating = UnaLocalizationsData$rating$en.internal(_root);
	late final UnaLocalizationsData$colorPicker$en colorPicker = UnaLocalizationsData$colorPicker$en.internal(_root);
	late final UnaLocalizationsData$dialog$en dialog = UnaLocalizationsData$dialog$en.internal(_root);
	late final UnaLocalizationsData$sheet$en sheet = UnaLocalizationsData$sheet$en.internal(_root);
	late final UnaLocalizationsData$resizable$en resizable = UnaLocalizationsData$resizable$en.internal(_root);
	late final UnaLocalizationsData$chat$en chat = UnaLocalizationsData$chat$en.internal(_root);
	late final UnaLocalizationsData$button$en button = UnaLocalizationsData$button$en.internal(_root);
	late final UnaLocalizationsData$board$en board = UnaLocalizationsData$board$en.internal(_root);
	late final UnaLocalizationsData$navigation$en navigation = UnaLocalizationsData$navigation$en.internal(_root);
	late final UnaLocalizationsData$chart$en chart = UnaLocalizationsData$chart$en.internal(_root);
}

// Path: actionSheet
class UnaLocalizationsData$actionSheet$en {
	UnaLocalizationsData$actionSheet$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: alert
class UnaLocalizationsData$alert$en {
	UnaLocalizationsData$alert$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';
}

// Path: timePicker
class UnaLocalizationsData$timePicker$en {
	UnaLocalizationsData$timePicker$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$datePicker$en {
	UnaLocalizationsData$datePicker$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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

// Path: calendar
class UnaLocalizationsData$calendar$en {
	UnaLocalizationsData$calendar$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Previous month'
	String get previousMonth => 'Previous month';

	/// en: 'Next month'
	String get nextMonth => 'Next month';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Start of range'
	String get rangeStart => 'Start of range';

	/// en: 'End of range'
	String get rangeEnd => 'End of range';
}

// Path: input
class UnaLocalizationsData$input$en {
	UnaLocalizationsData$input$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$autocomplete$en {
	UnaLocalizationsData$autocomplete$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'No results'
	String get noResults => 'No results';

	/// en: '1 result available'
	String get oneResult => '1 result available';

	/// en: '$count results available'
	String results({required Object count}) => '${count} results available';

	/// en: '$option, $index of $count'
	String option({required Object option, required Object index, required Object count}) => '${option}, ${index} of ${count}';

	/// en: 'Loading…'
	String get loading => 'Loading…';
}

// Path: otpField
class UnaLocalizationsData$otpField$en {
	UnaLocalizationsData$otpField$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Digit $index of $count'
	String digit({required Object index, required Object count}) => 'Digit ${index} of ${count}';
}

// Path: numberField
class UnaLocalizationsData$numberField$en {
	UnaLocalizationsData$numberField$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Increase'
	String get increase => 'Increase';

	/// en: 'Decrease'
	String get decrease => 'Decrease';
}

// Path: search
class UnaLocalizationsData$search$en {
	UnaLocalizationsData$search$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$tagField$en {
	UnaLocalizationsData$tagField$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Remove $tag'
	String remove({required Object tag}) => 'Remove ${tag}';

	/// en: '$tag added'
	String added({required Object tag}) => '${tag} added';

	/// en: '$tag removed'
	String removed({required Object tag}) => '${tag} removed';
}

// Path: keyboardToolbar
class UnaLocalizationsData$keyboardToolbar$en {
	UnaLocalizationsData$keyboardToolbar$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Done'
	String get done => 'Done';
}

// Path: empty
class UnaLocalizationsData$empty$en {
	UnaLocalizationsData$empty$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'No results'
	String get title => 'No results';
}

// Path: stepper
class UnaLocalizationsData$stepper$en {
	UnaLocalizationsData$stepper$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$toast$en {
	UnaLocalizationsData$toast$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';
}

// Path: chip
class UnaLocalizationsData$chip$en {
	UnaLocalizationsData$chip$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Remove $label'
	String removeNamed({required Object label}) => 'Remove ${label}';
}

// Path: command
class UnaLocalizationsData$command$en {
	UnaLocalizationsData$command$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'No results found.'
	String get noResults => 'No results found.';

	/// en: 'Command palette'
	String get label => 'Command palette';

	/// en: '$label, $index of $count'
	String item({required Object label, required Object index, required Object count}) => '${label}, ${index} of ${count}';
}

// Path: menu
class UnaLocalizationsData$menu$en {
	UnaLocalizationsData$menu$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$licensePage$en {
	UnaLocalizationsData$licensePage$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Licenses'
	String get title => 'Licenses';

	/// en: '1 license'
	String get oneLicense => '1 license';

	/// en: '$count licenses'
	String licenses({required Object count}) => '${count} licenses';
}

// Path: dataTable
class UnaLocalizationsData$dataTable$en {
	UnaLocalizationsData$dataTable$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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

	/// en: 'Select row $row'
	String selectRow({required Object row}) => 'Select row ${row}';

	/// en: 'Select all rows'
	String get selectAll => 'Select all rows';
}

// Path: pagination
class UnaLocalizationsData$pagination$en {
	UnaLocalizationsData$pagination$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$carousel$en {
	UnaLocalizationsData$carousel$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Previous page'
	String get previous => 'Previous page';

	/// en: 'Next page'
	String get next => 'Next page';

	/// en: 'Page $page of $count'
	String page({required Object page, required Object count}) => 'Page ${page} of ${count}';

	/// en: '$index of $count'
	String item({required Object index, required Object count}) => '${index} of ${count}';

	/// en: 'Pause slide show'
	String get pause => 'Pause slide show';

	/// en: 'Play slide show'
	String get play => 'Play slide show';
}

// Path: slider
class UnaLocalizationsData$slider$en {
	UnaLocalizationsData$slider$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Minimum'
	String get minimum => 'Minimum';

	/// en: 'Maximum'
	String get maximum => 'Maximum';

	/// en: 'Thumb $index of $count'
	String thumb({required Object index, required Object count}) => 'Thumb ${index} of ${count}';

	/// en: '$label, $thumb'
	String named({required Object label, required Object thumb}) => '${label}, ${thumb}';
}

// Path: refreshIndicator
class UnaLocalizationsData$refreshIndicator$en {
	UnaLocalizationsData$refreshIndicator$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Refreshing'
	String get refreshing => 'Refreshing';
}

// Path: reorder
class UnaLocalizationsData$reorder$en {
	UnaLocalizationsData$reorder$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$swipeActions$en {
	UnaLocalizationsData$swipeActions$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'More actions'
	String get more => 'More actions';
}

// Path: rating
class UnaLocalizationsData$rating$en {
	UnaLocalizationsData$rating$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: '$value of $count'
	String value({required Object value, required Object count}) => '${value} of ${count}';
}

// Path: colorPicker
class UnaLocalizationsData$colorPicker$en {
	UnaLocalizationsData$colorPicker$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Blue'
	String get blue => 'Blue';

	/// en: 'Green'
	String get green => 'Green';

	/// en: 'Grid'
	String get grid => 'Grid';

	/// en: 'Hex'
	String get hex => 'Hex';

	/// en: 'Hue'
	String get hue => 'Hue';

	/// en: 'Opacity'
	String get opacity => 'Opacity';

	/// en: 'Red'
	String get red => 'Red';

	/// en: 'Saturation and brightness'
	String get saturationAndBrightness => 'Saturation and brightness';

	/// en: 'Saturation'
	String get saturation => 'Saturation';

	/// en: 'Brightness'
	String get brightness => 'Brightness';

	/// en: 'Select colour'
	String get selectColor => 'Select colour';

	/// en: 'Sliders'
	String get sliders => 'Sliders';

	/// en: 'Spectrum'
	String get spectrum => 'Spectrum';
}

// Path: dialog
class UnaLocalizationsData$dialog$en {
	UnaLocalizationsData$dialog$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';
}

// Path: sheet
class UnaLocalizationsData$sheet$en {
	UnaLocalizationsData$sheet$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Resize'
	String get resize => 'Resize';
}

// Path: resizable
class UnaLocalizationsData$resizable$en {
	UnaLocalizationsData$resizable$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Resize panel'
	String get resizePanel => 'Resize panel';
}

// Path: chat
class UnaLocalizationsData$chat$en {
	UnaLocalizationsData$chat$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Typing'
	String get typing => 'Typing';

	/// en: 'Jump to latest'
	String get jumpToLatest => 'Jump to latest';
}

// Path: button
class UnaLocalizationsData$button$en {
	UnaLocalizationsData$button$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Loading'
	String get loading => 'Loading';
}

// Path: board
class UnaLocalizationsData$board$en {
	UnaLocalizationsData$board$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

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
class UnaLocalizationsData$navigation$en {
	UnaLocalizationsData$navigation$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Open menu'
	String get openMenu => 'Open menu';

	/// en: 'Navigation menu'
	String get menu => 'Navigation menu';

	/// en: 'Toggle sidebar'
	String get toggleSidebar => 'Toggle sidebar';

	/// en: 'Main navigation'
	String get main => 'Main navigation';

	/// en: 'Sidebar'
	String get sidebar => 'Sidebar';

	/// en: 'Breadcrumb'
	String get breadcrumb => 'Breadcrumb';

	/// en: 'More pages'
	String get morePages => 'More pages';
}

// Path: chart
class UnaLocalizationsData$chart$en {
	UnaLocalizationsData$chart$en.internal(this._root);

	final UnaLocalizationsData _root; // ignore: unused_field

	// Translations

	/// en: 'Line chart'
	String get line => 'Line chart';

	/// en: 'Bar chart'
	String get bar => 'Bar chart';

	/// en: 'Donut chart'
	String get donut => 'Donut chart';

	/// en: 'Sparkline'
	String get sparkline => 'Sparkline';

	/// en: '$count points, $first to $last'
	String range({required Object count, required Object first, required Object last}) => '${count} points, ${first} to ${last}';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on UnaLocalizationsData {
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
			'calendar.previousMonth' => 'Previous month',
			'calendar.nextMonth' => 'Next month',
			'calendar.today' => 'Today',
			'calendar.rangeStart' => 'Start of range',
			'calendar.rangeEnd' => 'End of range',
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
			'autocomplete.option' => ({required Object option, required Object index, required Object count}) => '${option}, ${index} of ${count}',
			'autocomplete.loading' => 'Loading…',
			'otpField.digit' => ({required Object index, required Object count}) => 'Digit ${index} of ${count}',
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
			'chip.removeNamed' => ({required Object label}) => 'Remove ${label}',
			'command.noResults' => 'No results found.',
			'command.label' => 'Command palette',
			'command.item' => ({required Object label, required Object index, required Object count}) => '${label}, ${index} of ${count}',
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
			'dataTable.selectRow' => ({required Object row}) => 'Select row ${row}',
			'dataTable.selectAll' => 'Select all rows',
			'pagination.previous' => 'Previous',
			'pagination.next' => 'Next',
			'pagination.morePages' => 'More pages',
			'pagination.page' => 'Page',
			'carousel.previous' => 'Previous page',
			'carousel.next' => 'Next page',
			'carousel.page' => ({required Object page, required Object count}) => 'Page ${page} of ${count}',
			'carousel.item' => ({required Object index, required Object count}) => '${index} of ${count}',
			'carousel.pause' => 'Pause slide show',
			'carousel.play' => 'Play slide show',
			'slider.minimum' => 'Minimum',
			'slider.maximum' => 'Maximum',
			'slider.thumb' => ({required Object index, required Object count}) => 'Thumb ${index} of ${count}',
			'slider.named' => ({required Object label, required Object thumb}) => '${label}, ${thumb}',
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
			'colorPicker.blue' => 'Blue',
			'colorPicker.green' => 'Green',
			'colorPicker.grid' => 'Grid',
			'colorPicker.hex' => 'Hex',
			'colorPicker.hue' => 'Hue',
			'colorPicker.opacity' => 'Opacity',
			'colorPicker.red' => 'Red',
			'colorPicker.saturationAndBrightness' => 'Saturation and brightness',
			'colorPicker.saturation' => 'Saturation',
			'colorPicker.brightness' => 'Brightness',
			'colorPicker.selectColor' => 'Select colour',
			'colorPicker.sliders' => 'Sliders',
			'colorPicker.spectrum' => 'Spectrum',
			'dialog.close' => 'Close',
			'dialog.dismiss' => 'Dismiss',
			'sheet.resize' => 'Resize',
			'resizable.resizePanel' => 'Resize panel',
			'chat.typing' => 'Typing',
			'chat.jumpToLatest' => 'Jump to latest',
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
			'navigation.main' => 'Main navigation',
			'navigation.sidebar' => 'Sidebar',
			'navigation.breadcrumb' => 'Breadcrumb',
			'navigation.morePages' => 'More pages',
			'chart.line' => 'Line chart',
			'chart.bar' => 'Bar chart',
			'chart.donut' => 'Donut chart',
			'chart.sparkline' => 'Sparkline',
			'chart.range' => ({required Object count, required Object first, required Object last}) => '${count} points, ${first} to ${last}',
			_ => null,
		};
	}
}
