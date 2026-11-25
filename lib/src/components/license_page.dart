import 'dart:async';
import 'dart:math' as math;

import 'package:finesse/src/components/app_bar.dart';
import 'package:finesse/src/components/divider.dart';
import 'package:finesse/src/components/list_section.dart';
import 'package:finesse/src/components/list_tile.dart';
import 'package:finesse/src/components/scaffold.dart';
import 'package:finesse/src/components/spinner.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/page_route.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Pushes a [LicensePage]: the licences of the software the app is built
/// from.
///
/// The arguments are those of [LicensePage.new]. The page is pushed on the
/// navigator nearest to [context], or on the root one with
/// [useRootNavigator]. The future completes when the page is popped.
///
/// ```dart
/// ListTile(
///   title: const Text('Licenses'),
///   onTap: () => showLicensePage(
///     context: context,
///     applicationName: 'Demo',
///     applicationVersion: '2.4.0',
///   ),
/// )
/// ```
Future<void> showLicensePage({
  required BuildContext context,
  String? applicationName,
  String? applicationVersion,
  Widget? applicationIcon,
  String? applicationLegalese,
  bool useRootNavigator = false,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<void>(
    FinessePageRoute<void>(
      builder: (context) => LicensePage(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
      ),
    ),
  );
}

/// A page that lists the licences of the software the app is built from.
///
/// It reads them from Flutter's `LicenseRegistry` — every package's
/// `LICENSE` file is registered there by the build, and an app adds its own
/// with `LicenseRegistry.addLicense` — groups them by package, and lists
/// the packages. A package opens on a page of its own with its licences in
/// full.
///
/// Above the list it shows what the app is: [applicationIcon],
/// [applicationName], [applicationVersion] and [applicationLegalese], each
/// only when given, except for the name, which falls back to the title of
/// the app's `Title` widget.
///
/// It is a whole page with its own `Scaffold` and `AppBar`; show it with
/// [showLicensePage], or build it as a destination of your own.
class LicensePage extends StatefulWidget {
  /// Creates a page of licences.
  const LicensePage({
    super.key,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
  });

  /// The name of the app. Defaults to the title given to the app widget.
  final String? applicationName;

  /// The version of this build of the app, as it should be read: "2.4.0".
  final String? applicationVersion;

  /// The app's icon, shown above its name.
  final Widget? applicationIcon;

  /// A line of small print under the name: a copyright notice.
  final String? applicationLegalese;

  @override
  State<LicensePage> createState() => _LicensePageState();
}

/// One package and its licences, each as its paragraphs.
class _PackageLicenses {
  _PackageLicenses(this.name);

  final String name;
  final licenses = <List<LicenseParagraph>>[];
}

class _LicensePageState extends State<LicensePage> {
  List<_PackageLicenses>? _packages;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _load() async {
    final byName = <String, _PackageLicenses>{};
    await for (final license in LicenseRegistry.licenses) {
      if (_disposed) return;
      // Splitting a licence into paragraphs is real work, and there are
      // hundreds: one at a time, between frames.
      final paragraphs = await SchedulerBinding.instance.scheduleTask(
        license.paragraphs.toList,
        Priority.animation,
        debugLabel: 'License',
      );
      if (_disposed) return;
      for (final package in license.packages) {
        (byName[package] ??= _PackageLicenses(package)).licenses.add(
          paragraphs,
        );
      }
    }
    if (_disposed) return;
    final name = _applicationName;
    final packages = byName.values.toList()
      ..sort((a, b) {
        // The app's own licence first, then the alphabet.
        if (a.name == name) return b.name == name ? 0 : -1;
        if (b.name == name) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    setState(() => _packages = packages);
  }

  String? get _applicationName =>
      widget.applicationName ??
      context.findAncestorWidgetOfExactType<Title>()?.title;

  Future<void> _open(_PackageLicenses package) {
    return Navigator.of(context).push<void>(
      FinessePageRoute<void>(
        builder: (context) => _PackageLicensePage(package: package),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final strings = FinesseLocalizations.of(context).licensePage;
    final packages = _packages;
    final name = _applicationName;

    final header = Padding(
      padding: EdgeInsets.only(bottom: theme.layoutTheme.gap(GapSize.xl)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.applicationIcon != null) ...[
            IconTheme.merge(
              data: const IconThemeData(size: 48),
              child: widget.applicationIcon!,
            ),
            SizedBox(height: theme.layoutTheme.gap(GapSize.md)),
          ],
          if (name != null && name.isNotEmpty)
            Text(
              name,
              style: theme.textTheme.h3,
              textAlign: TextAlign.center,
            ),
          if (widget.applicationVersion != null)
            Text(
              widget.applicationVersion!,
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
          if (widget.applicationLegalese != null) ...[
            SizedBox(height: theme.layoutTheme.gap(GapSize.sm)),
            Text(
              widget.applicationLegalese!,
              style: theme.textTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.title),
      ),
      body: _PageScroll(
        slivers: [
          SliverToBoxAdapter(child: header),
          if (packages == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.xl)),
                child: const Center(child: Spinner()),
              ),
            )
          else
            // Hundreds of packages: a section that builds the rows in view.
            SliverListSection.builder(
              margin: EdgeInsets.zero,
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                final count = package.licenses.length;
                return ListTile(
                  title: Text(package.name),
                  subtitle: Text(
                    count == 1
                        ? strings.oneLicense
                        : strings.licenses(count: count),
                  ),
                  showChevron: true,
                  onTap: () => _open(package),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// The licences of one package, in full.
class _PackageLicensePage extends StatelessWidget {
  const _PackageLicensePage({required this.package});

  final _PackageLicenses package;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // One row per paragraph, and a hairline between two licences: a long
    // licence is built as it is scrolled to.
    final rows = <LicenseParagraph?>[
      for (final (index, license) in package.licenses.indexed) ...[
        if (index > 0) null,
        ...license,
      ],
    ];
    final gap = theme.layoutTheme.gap(GapSize.md);
    return Scaffold(
      appBar: AppBar(
        title: Text(package.name, overflow: TextOverflow.ellipsis),
      ),
      body: _PageScroll(
        slivers: [
          SliverList.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final paragraph = rows[index];
              if (paragraph == null) {
                return Divider(margin: EdgeInsets.symmetric(vertical: gap));
              }
              final centred =
                  paragraph.indent == LicenseParagraph.centeredIndent;
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: centred ? 0 : gap * math.max(0, paragraph.indent),
                  bottom: gap,
                ),
                child: Text(
                  paragraph.text,
                  style: theme.textTheme.muted,
                  textAlign: centred ? TextAlign.center : TextAlign.start,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Lazy content laid out like a page: inside the page margins, no wider
/// than the page's width, and clear of the scaffold's bars.
class _PageScroll extends StatelessWidget {
  const _PageScroll({required this.slivers});

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final margin = (layout.pagePadding ?? const EdgeInsets.all(24)).resolve(
      Directionality.of(context),
    );
    final bars = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // The whole width scrolls, with the content in a column down its
        // middle.
        final maxWidth = math.min(layout.pageMaxWidth ?? 720, 720);
        final side = math.max(0, (constraints.maxWidth - maxWidth) / 2);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                math.max(margin.left, side + margin.left),
                margin.top + bars.top,
                math.max(margin.right, side + margin.right),
                margin.bottom + bars.bottom,
              ),
              sliver: SliverMainAxisGroup(slivers: slivers),
            ),
          ],
        );
      },
    );
  }
}
