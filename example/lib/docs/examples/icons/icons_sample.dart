import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A handful of the 1,512 icons, with the names they are found under. Names
/// are camelCase versions of the ones on phosphoricons.com.
class IconsSampleExample extends StatelessWidget {
  const IconsSampleExample({super.key});

  static const _icons = {
    'house': PhosphorIconsRegular.house,
    'magnifyingGlass': PhosphorIconsRegular.magnifyingGlass,
    'bell': PhosphorIconsRegular.bell,
    'chatCircleDots': PhosphorIconsRegular.chatCircleDots,
    'usersThree': PhosphorIconsRegular.usersThree,
    'briefcase': PhosphorIconsRegular.briefcase,
    'bookmarkSimple': PhosphorIconsRegular.bookmarkSimple,
    'heart': PhosphorIconsRegular.heart,
    'shareNetwork': PhosphorIconsRegular.shareNetwork,
    'paperPlaneTilt': PhosphorIconsRegular.paperPlaneTilt,
    'gear': PhosphorIconsRegular.gear,
    'calendarBlank': PhosphorIconsRegular.calendarBlank,
    'mapPin': PhosphorIconsRegular.mapPin,
    'image': PhosphorIconsRegular.image,
    'paperclip': PhosphorIconsRegular.paperclip,
    'plus': PhosphorIconsRegular.plus,
    'check': PhosphorIconsRegular.check,
    'x': PhosphorIconsRegular.x,
    'caretRight': PhosphorIconsRegular.caretRight,
    'arrowLeft': PhosphorIconsRegular.arrowLeft,
    'dotsThree': PhosphorIconsRegular.dotsThree,
    'trash': PhosphorIconsRegular.trash,
    'sun': PhosphorIconsRegular.sun,
    'moon': PhosphorIconsRegular.moon,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 4,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final MapEntry(key: name, value: icon) in _icons.entries)
          SizedBox(
            width: 112,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                PhosphorIcon(icon, size: 24),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
