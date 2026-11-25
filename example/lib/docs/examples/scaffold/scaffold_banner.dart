import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A banner under the app bar. The page makes room for it on the surface
/// spring when it comes and when it goes.
class ScaffoldBannerExample extends StatefulWidget {
  const ScaffoldBannerExample({super.key});

  @override
  State<ScaffoldBannerExample> createState() => _ScaffoldBannerExampleState();
}

class _ScaffoldBannerExampleState extends State<ScaffoldBannerExample> {
  bool _offline = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Inbox')),
        banner: _offline
            ? Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
                child: Glass(
                  level: GlassLevel.strong,
                  frosted: false,
                  borderRadius: theme.radii.lg,
                  padding: EdgeInsetsDirectional.only(
                    start: theme.layoutTheme.gap(GapSize.md),
                    end: theme.layoutTheme.gap(GapSize.xs),
                  ),
                  child: Row(
                    spacing: theme.layoutTheme.gap(GapSize.sm),
                    children: [
                      const PhosphorIcon(PhosphorIconsRegular.wifiSlash),
                      Expanded(
                        child: Text(
                          'You are offline',
                          style: theme.textTheme.small,
                        ),
                      ),
                      Button.ghost(
                        size: ButtonSize.sm,
                        onPressed: () => setState(() => _offline = false),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        body: ListView(
          children: [
            ListTile(
              title: const Text('Go offline'),
              subtitle: const Text('Shows the banner again'),
              leading: const PhosphorIcon(PhosphorIconsRegular.wifiSlash),
              onTap: () => setState(() => _offline = true),
            ),
            for (var i = 1; i <= 8; i++)
              ListTile(
                title: Text('Message $i'),
                subtitle: const Text('Saved on this phone'),
              ),
          ],
        ),
      ),
    );
  }
}
