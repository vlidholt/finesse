// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'data.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ThemeData {
  bool get canMerge => true;

  static ThemeData? lerp(ThemeData? a, ThemeData? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ThemeData(
      variant: t < 0.5 ? a.variant : b.variant,
      commandTheme: CommandTheme.lerp(a.commandTheme, b.commandTheme, t)!,
      sidebarTheme: SidebarTheme.lerp(a.sidebarTheme, b.sidebarTheme, t)!,
      skeletonTheme: SkeletonTheme.lerp(a.skeletonTheme, b.skeletonTheme, t)!,
      kbdTheme: KbdTheme.lerp(a.kbdTheme, b.kbdTheme, t)!,
      glassTheme: GlassTheme.lerp(a.glassTheme, b.glassTheme, t)!,
      appBarTheme: AppBarTheme.lerp(a.appBarTheme, b.appBarTheme, t)!,
      floatingActionButtonTheme: FloatingActionButtonTheme.lerp(
        a.floatingActionButtonTheme,
        b.floatingActionButtonTheme,
        t,
      )!,
      navigationBarTheme: NavigationBarTheme.lerp(
        a.navigationBarTheme,
        b.navigationBarTheme,
        t,
      )!,
      bottomNavigationBarTheme: BottomNavigationBarTheme.lerp(
        a.bottomNavigationBarTheme,
        b.bottomNavigationBarTheme,
        t,
      )!,
      chipTheme: ChipTheme.lerp(a.chipTheme, b.chipTheme, t)!,
      listTileTheme: ListTileTheme.lerp(a.listTileTheme, b.listTileTheme, t)!,
      chatBubbleTheme: ChatBubbleTheme.lerp(
        a.chatBubbleTheme,
        b.chatBubbleTheme,
        t,
      )!,
      chatListTheme: ChatListTheme.lerp(a.chatListTheme, b.chatListTheme, t)!,
      streamingTextTheme: StreamingTextTheme.lerp(
        a.streamingTextTheme,
        b.streamingTextTheme,
        t,
      )!,
      indicatorBadgeTheme: IndicatorBadgeTheme.lerp(
        a.indicatorBadgeTheme,
        b.indicatorBadgeTheme,
        t,
      )!,
      iconTileTheme: IconTileTheme.lerp(a.iconTileTheme, b.iconTileTheme, t)!,
      phosphorIconTheme: PhosphorIconTheme.lerp(
        a.phosphorIconTheme,
        b.phosphorIconTheme,
        t,
      )!,
      timelineTheme: TimelineTheme.lerp(a.timelineTheme, b.timelineTheme, t)!,
      boardTheme: BoardTheme.lerp(a.boardTheme, b.boardTheme, t)!,
      layoutTheme: LayoutTheme.lerp(a.layoutTheme, b.layoutTheme, t)!,
      scrollAreaTheme: ScrollAreaTheme.lerp(
        a.scrollAreaTheme,
        b.scrollAreaTheme,
        t,
      )!,
      spinnerTheme: SpinnerTheme.lerp(a.spinnerTheme, b.spinnerTheme, t)!,
      toggleTheme: ToggleTheme.lerp(a.toggleTheme, b.toggleTheme, t)!,
      outlineToggleTheme: ToggleTheme.lerp(
        a.outlineToggleTheme,
        b.outlineToggleTheme,
        t,
      )!,
      emptyTheme: EmptyTheme.lerp(a.emptyTheme, b.emptyTheme, t)!,
      paginationTheme: PaginationTheme.lerp(
        a.paginationTheme,
        b.paginationTheme,
        t,
      )!,
      collapsibleTheme: CollapsibleTheme.lerp(
        a.collapsibleTheme,
        b.collapsibleTheme,
        t,
      )!,
      colorScheme: ColorScheme.lerp(a.colorScheme, b.colorScheme, t),
      brightness: t < 0.5 ? a.brightness : b.brightness,
      primaryButtonTheme: ButtonTheme.lerp(
        a.primaryButtonTheme,
        b.primaryButtonTheme,
        t,
      )!,
      secondaryButtonTheme: ButtonTheme.lerp(
        a.secondaryButtonTheme,
        b.secondaryButtonTheme,
        t,
      )!,
      destructiveButtonTheme: ButtonTheme.lerp(
        a.destructiveButtonTheme,
        b.destructiveButtonTheme,
        t,
      )!,
      outlineButtonTheme: ButtonTheme.lerp(
        a.outlineButtonTheme,
        b.outlineButtonTheme,
        t,
      )!,
      ghostButtonTheme: ButtonTheme.lerp(
        a.ghostButtonTheme,
        b.ghostButtonTheme,
        t,
      )!,
      linkButtonTheme: ButtonTheme.lerp(
        a.linkButtonTheme,
        b.linkButtonTheme,
        t,
      )!,
      primaryBadgeTheme: BadgeTheme.lerp(
        a.primaryBadgeTheme,
        b.primaryBadgeTheme,
        t,
      )!,
      secondaryBadgeTheme: BadgeTheme.lerp(
        a.secondaryBadgeTheme,
        b.secondaryBadgeTheme,
        t,
      )!,
      destructiveBadgeTheme: BadgeTheme.lerp(
        a.destructiveBadgeTheme,
        b.destructiveBadgeTheme,
        t,
      )!,
      outlineBadgeTheme: BadgeTheme.lerp(
        a.outlineBadgeTheme,
        b.outlineBadgeTheme,
        t,
      )!,
      breadcrumbTheme: BreadcrumbTheme.lerp(
        a.breadcrumbTheme,
        b.breadcrumbTheme,
        t,
      )!,
      radius: BorderRadius.lerp(a.radius, b.radius, t)!,
      avatarTheme: AvatarTheme.lerp(a.avatarTheme, b.avatarTheme, t)!,
      buttonSizesTheme: ButtonSizesTheme.lerp(
        a.buttonSizesTheme,
        b.buttonSizesTheme,
        t,
      )!,
      tooltipTheme: TooltipTheme.lerp(a.tooltipTheme, b.tooltipTheme, t)!,
      popoverTheme: PopoverTheme.lerp(a.popoverTheme, b.popoverTheme, t)!,
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t)!,
      textTheme: TextTheme.lerp(a.textTheme, b.textTheme, t)!,
      disabledOpacity: lerpDouble$(a.disabledOpacity, b.disabledOpacity, t)!,
      selectTheme: SelectTheme.lerp(a.selectTheme, b.selectTheme, t)!,
      selectOptionTheme: SelectOptionTheme.lerp(
        a.selectOptionTheme,
        b.selectOptionTheme,
        t,
      )!,
      cardTheme: CardTheme.lerp(a.cardTheme, b.cardTheme, t)!,
      switchTheme: SwitchTheme.lerp(a.switchTheme, b.switchTheme, t)!,
      checkboxTheme: CheckboxTheme.lerp(a.checkboxTheme, b.checkboxTheme, t)!,
      textFieldTheme: TextFieldTheme.lerp(
        a.textFieldTheme,
        b.textFieldTheme,
        t,
      )!,
      radioTheme: RadioTheme.lerp(a.radioTheme, b.radioTheme, t)!,
      primaryToastTheme: ToastTheme.lerp(
        a.primaryToastTheme,
        b.primaryToastTheme,
        t,
      )!,
      destructiveToastTheme: ToastTheme.lerp(
        a.destructiveToastTheme,
        b.destructiveToastTheme,
        t,
      )!,
      breakpoints: Breakpoints.lerp(a.breakpoints, b.breakpoints, t)!,
      primaryAlertTheme: AlertTheme.lerp(
        a.primaryAlertTheme,
        b.primaryAlertTheme,
        t,
      )!,
      destructiveAlertTheme: AlertTheme.lerp(
        a.destructiveAlertTheme,
        b.destructiveAlertTheme,
        t,
      )!,
      primaryDialogTheme: DialogTheme.lerp(
        a.primaryDialogTheme,
        b.primaryDialogTheme,
        t,
      )!,
      alertDialogTheme: DialogTheme.lerp(
        a.alertDialogTheme,
        b.alertDialogTheme,
        t,
      )!,
      sliderTheme: SliderTheme.lerp(a.sliderTheme, b.sliderTheme, t)!,
      sheetTheme: SheetTheme.lerp(a.sheetTheme, b.sheetTheme, t)!,
      progressBarTheme: ProgressBarTheme.lerp(
        a.progressBarTheme,
        b.progressBarTheme,
        t,
      )!,
      accordionTheme: AccordionTheme.lerp(
        a.accordionTheme,
        b.accordionTheme,
        t,
      )!,
      tableTheme: TableTheme.lerp(a.tableTheme, b.tableTheme, t)!,
      resizableTheme: ResizableTheme.lerp(
        a.resizableTheme,
        b.resizableTheme,
        t,
      )!,
      hoverStrategies: t < 0.5 ? a.hoverStrategies : b.hoverStrategies,
      disableSecondaryBorder: t < 0.5
          ? a.disableSecondaryBorder
          : b.disableSecondaryBorder,
      tabsTheme: TabsTheme.lerp(a.tabsTheme, b.tabsTheme, t)!,
      contextMenuTheme: ContextMenuTheme.lerp(
        a.contextMenuTheme,
        b.contextMenuTheme,
        t,
      )!,
      calendarTheme: CalendarTheme.lerp(a.calendarTheme, b.calendarTheme, t)!,
      datePickerTheme: DatePickerTheme.lerp(
        a.datePickerTheme,
        b.datePickerTheme,
        t,
      )!,
      timePickerTheme: TimePickerTheme.lerp(
        a.timePickerTheme,
        b.timePickerTheme,
        t,
      )!,
      otpFieldTheme: OtpFieldTheme.lerp(a.otpFieldTheme, b.otpFieldTheme, t)!,
      menubarTheme: MenubarTheme.lerp(a.menubarTheme, b.menubarTheme, t)!,
      dividerTheme: DividerTheme.lerp(a.dividerTheme, b.dividerTheme, t)!,
      sonnerTheme: SonnerTheme.lerp(a.sonnerTheme, b.sonnerTheme, t)!,
      textareaTheme: TextareaTheme.lerp(a.textareaTheme, b.textareaTheme, t)!,
      defaultKeyboardToolbarTheme: DefaultKeyboardToolbarTheme.lerp(
        a.defaultKeyboardToolbarTheme,
        b.defaultKeyboardToolbarTheme,
        t,
      )!,
    );
  }

  ThemeData copyWith({
    ThemeVariant? variant,
    CommandTheme? commandTheme,
    SidebarTheme? sidebarTheme,
    SkeletonTheme? skeletonTheme,
    KbdTheme? kbdTheme,
    GlassTheme? glassTheme,
    AppBarTheme? appBarTheme,
    FloatingActionButtonTheme? floatingActionButtonTheme,
    NavigationBarTheme? navigationBarTheme,
    BottomNavigationBarTheme? bottomNavigationBarTheme,
    ChipTheme? chipTheme,
    ListTileTheme? listTileTheme,
    ChatBubbleTheme? chatBubbleTheme,
    ChatListTheme? chatListTheme,
    StreamingTextTheme? streamingTextTheme,
    IndicatorBadgeTheme? indicatorBadgeTheme,
    IconTileTheme? iconTileTheme,
    PhosphorIconTheme? phosphorIconTheme,
    TimelineTheme? timelineTheme,
    BoardTheme? boardTheme,
    LayoutTheme? layoutTheme,
    ScrollAreaTheme? scrollAreaTheme,
    SpinnerTheme? spinnerTheme,
    ToggleTheme? toggleTheme,
    ToggleTheme? outlineToggleTheme,
    EmptyTheme? emptyTheme,
    PaginationTheme? paginationTheme,
    CollapsibleTheme? collapsibleTheme,
    ColorScheme? colorScheme,
    Brightness? brightness,
    ButtonTheme? primaryButtonTheme,
    ButtonTheme? secondaryButtonTheme,
    ButtonTheme? destructiveButtonTheme,
    ButtonTheme? outlineButtonTheme,
    ButtonTheme? ghostButtonTheme,
    ButtonTheme? linkButtonTheme,
    BadgeTheme? primaryBadgeTheme,
    BadgeTheme? secondaryBadgeTheme,
    BadgeTheme? destructiveBadgeTheme,
    BadgeTheme? outlineBadgeTheme,
    BreadcrumbTheme? breadcrumbTheme,
    BorderRadius? radius,
    AvatarTheme? avatarTheme,
    ButtonSizesTheme? buttonSizesTheme,
    TooltipTheme? tooltipTheme,
    PopoverTheme? popoverTheme,
    FinesseDecoration? decoration,
    TextTheme? textTheme,
    double? disabledOpacity,
    SelectTheme? selectTheme,
    SelectOptionTheme? selectOptionTheme,
    CardTheme? cardTheme,
    SwitchTheme? switchTheme,
    CheckboxTheme? checkboxTheme,
    TextFieldTheme? textFieldTheme,
    RadioTheme? radioTheme,
    ToastTheme? primaryToastTheme,
    ToastTheme? destructiveToastTheme,
    Breakpoints? breakpoints,
    AlertTheme? primaryAlertTheme,
    AlertTheme? destructiveAlertTheme,
    DialogTheme? primaryDialogTheme,
    DialogTheme? alertDialogTheme,
    SliderTheme? sliderTheme,
    SheetTheme? sheetTheme,
    ProgressBarTheme? progressBarTheme,
    AccordionTheme? accordionTheme,
    TableTheme? tableTheme,
    ResizableTheme? resizableTheme,
    HoverStrategies? hoverStrategies,
    bool? disableSecondaryBorder,
    TabsTheme? tabsTheme,
    ContextMenuTheme? contextMenuTheme,
    CalendarTheme? calendarTheme,
    DatePickerTheme? datePickerTheme,
    TimePickerTheme? timePickerTheme,
    OtpFieldTheme? otpFieldTheme,
    MenubarTheme? menubarTheme,
    DividerTheme? dividerTheme,
    SonnerTheme? sonnerTheme,
    TextareaTheme? textareaTheme,
    DefaultKeyboardToolbarTheme? defaultKeyboardToolbarTheme,
  }) {
    final _this = (this as ThemeData);

    return ThemeData(
      variant: variant ?? _this.variant,
      commandTheme: commandTheme ?? _this.commandTheme,
      sidebarTheme: sidebarTheme ?? _this.sidebarTheme,
      skeletonTheme: skeletonTheme ?? _this.skeletonTheme,
      kbdTheme: kbdTheme ?? _this.kbdTheme,
      glassTheme: glassTheme ?? _this.glassTheme,
      appBarTheme: appBarTheme ?? _this.appBarTheme,
      floatingActionButtonTheme:
          floatingActionButtonTheme ?? _this.floatingActionButtonTheme,
      navigationBarTheme: navigationBarTheme ?? _this.navigationBarTheme,
      bottomNavigationBarTheme:
          bottomNavigationBarTheme ?? _this.bottomNavigationBarTheme,
      chipTheme: chipTheme ?? _this.chipTheme,
      listTileTheme: listTileTheme ?? _this.listTileTheme,
      chatBubbleTheme: chatBubbleTheme ?? _this.chatBubbleTheme,
      chatListTheme: chatListTheme ?? _this.chatListTheme,
      streamingTextTheme: streamingTextTheme ?? _this.streamingTextTheme,
      indicatorBadgeTheme: indicatorBadgeTheme ?? _this.indicatorBadgeTheme,
      iconTileTheme: iconTileTheme ?? _this.iconTileTheme,
      phosphorIconTheme: phosphorIconTheme ?? _this.phosphorIconTheme,
      timelineTheme: timelineTheme ?? _this.timelineTheme,
      boardTheme: boardTheme ?? _this.boardTheme,
      layoutTheme: layoutTheme ?? _this.layoutTheme,
      scrollAreaTheme: scrollAreaTheme ?? _this.scrollAreaTheme,
      spinnerTheme: spinnerTheme ?? _this.spinnerTheme,
      toggleTheme: toggleTheme ?? _this.toggleTheme,
      outlineToggleTheme: outlineToggleTheme ?? _this.outlineToggleTheme,
      emptyTheme: emptyTheme ?? _this.emptyTheme,
      paginationTheme: paginationTheme ?? _this.paginationTheme,
      collapsibleTheme: collapsibleTheme ?? _this.collapsibleTheme,
      colorScheme: colorScheme ?? _this.colorScheme,
      brightness: brightness ?? _this.brightness,
      primaryButtonTheme: primaryButtonTheme ?? _this.primaryButtonTheme,
      secondaryButtonTheme: secondaryButtonTheme ?? _this.secondaryButtonTheme,
      destructiveButtonTheme:
          destructiveButtonTheme ?? _this.destructiveButtonTheme,
      outlineButtonTheme: outlineButtonTheme ?? _this.outlineButtonTheme,
      ghostButtonTheme: ghostButtonTheme ?? _this.ghostButtonTheme,
      linkButtonTheme: linkButtonTheme ?? _this.linkButtonTheme,
      primaryBadgeTheme: primaryBadgeTheme ?? _this.primaryBadgeTheme,
      secondaryBadgeTheme: secondaryBadgeTheme ?? _this.secondaryBadgeTheme,
      destructiveBadgeTheme:
          destructiveBadgeTheme ?? _this.destructiveBadgeTheme,
      outlineBadgeTheme: outlineBadgeTheme ?? _this.outlineBadgeTheme,
      breadcrumbTheme: breadcrumbTheme ?? _this.breadcrumbTheme,
      radius: radius ?? _this.radius,
      avatarTheme: avatarTheme ?? _this.avatarTheme,
      buttonSizesTheme: buttonSizesTheme ?? _this.buttonSizesTheme,
      tooltipTheme: tooltipTheme ?? _this.tooltipTheme,
      popoverTheme: popoverTheme ?? _this.popoverTheme,
      decoration: decoration ?? _this.decoration,
      textTheme: textTheme ?? _this.textTheme,
      disabledOpacity: disabledOpacity ?? _this.disabledOpacity,
      selectTheme: selectTheme ?? _this.selectTheme,
      selectOptionTheme: selectOptionTheme ?? _this.selectOptionTheme,
      cardTheme: cardTheme ?? _this.cardTheme,
      switchTheme: switchTheme ?? _this.switchTheme,
      checkboxTheme: checkboxTheme ?? _this.checkboxTheme,
      textFieldTheme: textFieldTheme ?? _this.textFieldTheme,
      radioTheme: radioTheme ?? _this.radioTheme,
      primaryToastTheme: primaryToastTheme ?? _this.primaryToastTheme,
      destructiveToastTheme:
          destructiveToastTheme ?? _this.destructiveToastTheme,
      breakpoints: breakpoints ?? _this.breakpoints,
      primaryAlertTheme: primaryAlertTheme ?? _this.primaryAlertTheme,
      destructiveAlertTheme:
          destructiveAlertTheme ?? _this.destructiveAlertTheme,
      primaryDialogTheme: primaryDialogTheme ?? _this.primaryDialogTheme,
      alertDialogTheme: alertDialogTheme ?? _this.alertDialogTheme,
      sliderTheme: sliderTheme ?? _this.sliderTheme,
      sheetTheme: sheetTheme ?? _this.sheetTheme,
      progressBarTheme: progressBarTheme ?? _this.progressBarTheme,
      accordionTheme: accordionTheme ?? _this.accordionTheme,
      tableTheme: tableTheme ?? _this.tableTheme,
      resizableTheme: resizableTheme ?? _this.resizableTheme,
      hoverStrategies: hoverStrategies ?? _this.hoverStrategies,
      disableSecondaryBorder:
          disableSecondaryBorder ?? _this.disableSecondaryBorder,
      tabsTheme: tabsTheme ?? _this.tabsTheme,
      contextMenuTheme: contextMenuTheme ?? _this.contextMenuTheme,
      calendarTheme: calendarTheme ?? _this.calendarTheme,
      datePickerTheme: datePickerTheme ?? _this.datePickerTheme,
      timePickerTheme: timePickerTheme ?? _this.timePickerTheme,
      otpFieldTheme: otpFieldTheme ?? _this.otpFieldTheme,
      menubarTheme: menubarTheme ?? _this.menubarTheme,
      dividerTheme: dividerTheme ?? _this.dividerTheme,
      sonnerTheme: sonnerTheme ?? _this.sonnerTheme,
      textareaTheme: textareaTheme ?? _this.textareaTheme,
      defaultKeyboardToolbarTheme:
          defaultKeyboardToolbarTheme ?? _this.defaultKeyboardToolbarTheme,
    );
  }

  ThemeData merge(ThemeData? other) {
    final _this = (this as ThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      variant: other.variant,
      commandTheme: _this.commandTheme.merge(other.commandTheme),
      sidebarTheme: _this.sidebarTheme.merge(other.sidebarTheme),
      skeletonTheme: _this.skeletonTheme.merge(other.skeletonTheme),
      kbdTheme: _this.kbdTheme.merge(other.kbdTheme),
      glassTheme: _this.glassTheme.merge(other.glassTheme),
      appBarTheme: _this.appBarTheme.merge(other.appBarTheme),
      floatingActionButtonTheme: _this.floatingActionButtonTheme.merge(
        other.floatingActionButtonTheme,
      ),
      navigationBarTheme: _this.navigationBarTheme.merge(
        other.navigationBarTheme,
      ),
      bottomNavigationBarTheme: _this.bottomNavigationBarTheme.merge(
        other.bottomNavigationBarTheme,
      ),
      chipTheme: _this.chipTheme.merge(other.chipTheme),
      listTileTheme: _this.listTileTheme.merge(other.listTileTheme),
      chatBubbleTheme: _this.chatBubbleTheme.merge(other.chatBubbleTheme),
      chatListTheme: _this.chatListTheme.merge(other.chatListTheme),
      streamingTextTheme: _this.streamingTextTheme.merge(
        other.streamingTextTheme,
      ),
      indicatorBadgeTheme: _this.indicatorBadgeTheme.merge(
        other.indicatorBadgeTheme,
      ),
      iconTileTheme: _this.iconTileTheme.merge(other.iconTileTheme),
      phosphorIconTheme: _this.phosphorIconTheme.merge(other.phosphorIconTheme),
      timelineTheme: _this.timelineTheme.merge(other.timelineTheme),
      boardTheme: _this.boardTheme.merge(other.boardTheme),
      layoutTheme: _this.layoutTheme.merge(other.layoutTheme),
      scrollAreaTheme: _this.scrollAreaTheme.merge(other.scrollAreaTheme),
      spinnerTheme: _this.spinnerTheme.merge(other.spinnerTheme),
      toggleTheme: _this.toggleTheme.merge(other.toggleTheme),
      outlineToggleTheme: _this.outlineToggleTheme.merge(
        other.outlineToggleTheme,
      ),
      emptyTheme: _this.emptyTheme.merge(other.emptyTheme),
      paginationTheme: _this.paginationTheme.merge(other.paginationTheme),
      collapsibleTheme: _this.collapsibleTheme.merge(other.collapsibleTheme),
      colorScheme: _this.colorScheme.merge(other.colorScheme),
      brightness: other.brightness,
      primaryButtonTheme: _this.primaryButtonTheme.merge(
        other.primaryButtonTheme,
      ),
      secondaryButtonTheme: _this.secondaryButtonTheme.merge(
        other.secondaryButtonTheme,
      ),
      destructiveButtonTheme: _this.destructiveButtonTheme.merge(
        other.destructiveButtonTheme,
      ),
      outlineButtonTheme: _this.outlineButtonTheme.merge(
        other.outlineButtonTheme,
      ),
      ghostButtonTheme: _this.ghostButtonTheme.merge(other.ghostButtonTheme),
      linkButtonTheme: _this.linkButtonTheme.merge(other.linkButtonTheme),
      primaryBadgeTheme: _this.primaryBadgeTheme.merge(other.primaryBadgeTheme),
      secondaryBadgeTheme: _this.secondaryBadgeTheme.merge(
        other.secondaryBadgeTheme,
      ),
      destructiveBadgeTheme: _this.destructiveBadgeTheme.merge(
        other.destructiveBadgeTheme,
      ),
      outlineBadgeTheme: _this.outlineBadgeTheme.merge(other.outlineBadgeTheme),
      breadcrumbTheme: _this.breadcrumbTheme.merge(other.breadcrumbTheme),
      radius: other.radius,
      avatarTheme: _this.avatarTheme.merge(other.avatarTheme),
      buttonSizesTheme: _this.buttonSizesTheme.merge(other.buttonSizesTheme),
      tooltipTheme: _this.tooltipTheme.merge(other.tooltipTheme),
      popoverTheme: _this.popoverTheme.merge(other.popoverTheme),
      decoration: _this.decoration.merge(other.decoration),
      textTheme: _this.textTheme.merge(other.textTheme),
      disabledOpacity: other.disabledOpacity,
      selectTheme: _this.selectTheme.merge(other.selectTheme),
      selectOptionTheme: _this.selectOptionTheme.merge(other.selectOptionTheme),
      cardTheme: _this.cardTheme.merge(other.cardTheme),
      switchTheme: _this.switchTheme.merge(other.switchTheme),
      checkboxTheme: _this.checkboxTheme.merge(other.checkboxTheme),
      textFieldTheme: _this.textFieldTheme.merge(other.textFieldTheme),
      radioTheme: _this.radioTheme.merge(other.radioTheme),
      primaryToastTheme: _this.primaryToastTheme.merge(other.primaryToastTheme),
      destructiveToastTheme: _this.destructiveToastTheme.merge(
        other.destructiveToastTheme,
      ),
      breakpoints: other.breakpoints,
      primaryAlertTheme: _this.primaryAlertTheme.merge(other.primaryAlertTheme),
      destructiveAlertTheme: _this.destructiveAlertTheme.merge(
        other.destructiveAlertTheme,
      ),
      primaryDialogTheme: _this.primaryDialogTheme.merge(
        other.primaryDialogTheme,
      ),
      alertDialogTheme: _this.alertDialogTheme.merge(other.alertDialogTheme),
      sliderTheme: _this.sliderTheme.merge(other.sliderTheme),
      sheetTheme: _this.sheetTheme.merge(other.sheetTheme),
      progressBarTheme: _this.progressBarTheme.merge(other.progressBarTheme),
      accordionTheme: _this.accordionTheme.merge(other.accordionTheme),
      tableTheme: _this.tableTheme.merge(other.tableTheme),
      resizableTheme: _this.resizableTheme.merge(other.resizableTheme),
      hoverStrategies: other.hoverStrategies,
      disableSecondaryBorder: other.disableSecondaryBorder,
      tabsTheme: _this.tabsTheme.merge(other.tabsTheme),
      contextMenuTheme: _this.contextMenuTheme.merge(other.contextMenuTheme),
      calendarTheme: _this.calendarTheme.merge(other.calendarTheme),
      datePickerTheme: _this.datePickerTheme.merge(other.datePickerTheme),
      timePickerTheme: _this.timePickerTheme.merge(other.timePickerTheme),
      otpFieldTheme: _this.otpFieldTheme.merge(other.otpFieldTheme),
      menubarTheme: _this.menubarTheme.merge(other.menubarTheme),
      dividerTheme: _this.dividerTheme.merge(other.dividerTheme),
      sonnerTheme: _this.sonnerTheme.merge(other.sonnerTheme),
      textareaTheme: _this.textareaTheme.merge(other.textareaTheme),
      defaultKeyboardToolbarTheme: _this.defaultKeyboardToolbarTheme.merge(
        other.defaultKeyboardToolbarTheme,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as ThemeData);
    final _other = (other as ThemeData);

    return _other.variant == _this.variant &&
        _other.commandTheme == _this.commandTheme &&
        _other.sidebarTheme == _this.sidebarTheme &&
        _other.skeletonTheme == _this.skeletonTheme &&
        _other.kbdTheme == _this.kbdTheme &&
        _other.glassTheme == _this.glassTheme &&
        _other.appBarTheme == _this.appBarTheme &&
        _other.floatingActionButtonTheme == _this.floatingActionButtonTheme &&
        _other.navigationBarTheme == _this.navigationBarTheme &&
        _other.bottomNavigationBarTheme == _this.bottomNavigationBarTheme &&
        _other.chipTheme == _this.chipTheme &&
        _other.listTileTheme == _this.listTileTheme &&
        _other.chatBubbleTheme == _this.chatBubbleTheme &&
        _other.chatListTheme == _this.chatListTheme &&
        _other.streamingTextTheme == _this.streamingTextTheme &&
        _other.indicatorBadgeTheme == _this.indicatorBadgeTheme &&
        _other.iconTileTheme == _this.iconTileTheme &&
        _other.phosphorIconTheme == _this.phosphorIconTheme &&
        _other.timelineTheme == _this.timelineTheme &&
        _other.boardTheme == _this.boardTheme &&
        _other.layoutTheme == _this.layoutTheme &&
        _other.scrollAreaTheme == _this.scrollAreaTheme &&
        _other.spinnerTheme == _this.spinnerTheme &&
        _other.toggleTheme == _this.toggleTheme &&
        _other.outlineToggleTheme == _this.outlineToggleTheme &&
        _other.emptyTheme == _this.emptyTheme &&
        _other.paginationTheme == _this.paginationTheme &&
        _other.collapsibleTheme == _this.collapsibleTheme &&
        _other.colorScheme == _this.colorScheme &&
        _other.brightness == _this.brightness &&
        _other.primaryButtonTheme == _this.primaryButtonTheme &&
        _other.secondaryButtonTheme == _this.secondaryButtonTheme &&
        _other.destructiveButtonTheme == _this.destructiveButtonTheme &&
        _other.outlineButtonTheme == _this.outlineButtonTheme &&
        _other.ghostButtonTheme == _this.ghostButtonTheme &&
        _other.linkButtonTheme == _this.linkButtonTheme &&
        _other.primaryBadgeTheme == _this.primaryBadgeTheme &&
        _other.secondaryBadgeTheme == _this.secondaryBadgeTheme &&
        _other.destructiveBadgeTheme == _this.destructiveBadgeTheme &&
        _other.outlineBadgeTheme == _this.outlineBadgeTheme &&
        _other.breadcrumbTheme == _this.breadcrumbTheme &&
        _other.radius == _this.radius &&
        _other.avatarTheme == _this.avatarTheme &&
        _other.buttonSizesTheme == _this.buttonSizesTheme &&
        _other.tooltipTheme == _this.tooltipTheme &&
        _other.popoverTheme == _this.popoverTheme &&
        _other.decoration == _this.decoration &&
        _other.textTheme == _this.textTheme &&
        _other.disabledOpacity == _this.disabledOpacity &&
        _other.selectTheme == _this.selectTheme &&
        _other.selectOptionTheme == _this.selectOptionTheme &&
        _other.cardTheme == _this.cardTheme &&
        _other.switchTheme == _this.switchTheme &&
        _other.checkboxTheme == _this.checkboxTheme &&
        _other.textFieldTheme == _this.textFieldTheme &&
        _other.radioTheme == _this.radioTheme &&
        _other.primaryToastTheme == _this.primaryToastTheme &&
        _other.destructiveToastTheme == _this.destructiveToastTheme &&
        _other.breakpoints == _this.breakpoints &&
        _other.primaryAlertTheme == _this.primaryAlertTheme &&
        _other.destructiveAlertTheme == _this.destructiveAlertTheme &&
        _other.primaryDialogTheme == _this.primaryDialogTheme &&
        _other.alertDialogTheme == _this.alertDialogTheme &&
        _other.sliderTheme == _this.sliderTheme &&
        _other.sheetTheme == _this.sheetTheme &&
        _other.progressBarTheme == _this.progressBarTheme &&
        _other.accordionTheme == _this.accordionTheme &&
        _other.tableTheme == _this.tableTheme &&
        _other.resizableTheme == _this.resizableTheme &&
        _other.hoverStrategies == _this.hoverStrategies &&
        _other.disableSecondaryBorder == _this.disableSecondaryBorder &&
        _other.tabsTheme == _this.tabsTheme &&
        _other.contextMenuTheme == _this.contextMenuTheme &&
        _other.calendarTheme == _this.calendarTheme &&
        _other.datePickerTheme == _this.datePickerTheme &&
        _other.timePickerTheme == _this.timePickerTheme &&
        _other.otpFieldTheme == _this.otpFieldTheme &&
        _other.menubarTheme == _this.menubarTheme &&
        _other.dividerTheme == _this.dividerTheme &&
        _other.sonnerTheme == _this.sonnerTheme &&
        _other.textareaTheme == _this.textareaTheme &&
        _other.defaultKeyboardToolbarTheme == _this.defaultKeyboardToolbarTheme;
  }

  @override
  int get hashCode {
    final _this = (this as ThemeData);

    return Object.hashAll([
      runtimeType,
      _this.variant,
      _this.commandTheme,
      _this.sidebarTheme,
      _this.skeletonTheme,
      _this.kbdTheme,
      _this.glassTheme,
      _this.appBarTheme,
      _this.floatingActionButtonTheme,
      _this.navigationBarTheme,
      _this.bottomNavigationBarTheme,
      _this.chipTheme,
      _this.listTileTheme,
      _this.chatBubbleTheme,
      _this.chatListTheme,
      _this.streamingTextTheme,
      _this.indicatorBadgeTheme,
      _this.iconTileTheme,
      _this.phosphorIconTheme,
      _this.timelineTheme,
      _this.boardTheme,
      _this.layoutTheme,
      _this.scrollAreaTheme,
      _this.spinnerTheme,
      _this.toggleTheme,
      _this.outlineToggleTheme,
      _this.emptyTheme,
      _this.paginationTheme,
      _this.collapsibleTheme,
      _this.colorScheme,
      _this.brightness,
      _this.primaryButtonTheme,
      _this.secondaryButtonTheme,
      _this.destructiveButtonTheme,
      _this.outlineButtonTheme,
      _this.ghostButtonTheme,
      _this.linkButtonTheme,
      _this.primaryBadgeTheme,
      _this.secondaryBadgeTheme,
      _this.destructiveBadgeTheme,
      _this.outlineBadgeTheme,
      _this.breadcrumbTheme,
      _this.radius,
      _this.avatarTheme,
      _this.buttonSizesTheme,
      _this.tooltipTheme,
      _this.popoverTheme,
      _this.decoration,
      _this.textTheme,
      _this.disabledOpacity,
      _this.selectTheme,
      _this.selectOptionTheme,
      _this.cardTheme,
      _this.switchTheme,
      _this.checkboxTheme,
      _this.textFieldTheme,
      _this.radioTheme,
      _this.primaryToastTheme,
      _this.destructiveToastTheme,
      _this.breakpoints,
      _this.primaryAlertTheme,
      _this.destructiveAlertTheme,
      _this.primaryDialogTheme,
      _this.alertDialogTheme,
      _this.sliderTheme,
      _this.sheetTheme,
      _this.progressBarTheme,
      _this.accordionTheme,
      _this.tableTheme,
      _this.resizableTheme,
      _this.hoverStrategies,
      _this.disableSecondaryBorder,
      _this.tabsTheme,
      _this.contextMenuTheme,
      _this.calendarTheme,
      _this.datePickerTheme,
      _this.timePickerTheme,
      _this.otpFieldTheme,
      _this.menubarTheme,
      _this.dividerTheme,
      _this.sonnerTheme,
      _this.textareaTheme,
      _this.defaultKeyboardToolbarTheme,
    ]);
  }
}
