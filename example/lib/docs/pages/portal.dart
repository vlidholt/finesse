import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/portal/portal_anchoring.dart';
import 'package:flutter/widgets.dart';

final portalDoc = ComponentDoc(
  slug: 'portal',
  title: 'Portal',
  description:
      'The raw overlay primitive underneath popover, select, tooltip, and '
      'menus: renders a follower widget anchored to its child, above '
      'everything else.',
  body: (context) => const DocParagraph(
    '`Portal` is a building block rather than an end-user component. '
    'Reach for `Popover`, `Tooltip`, or the menu components first. '
    'Use the portal directly only when you build a new floating surface.',
  ),
  examples: [
    ComponentExample(
      id: 'portal_anchoring',
      title: 'Anchoring modes',
      description:
          'Hover the red square. The portal cycles through '
          '`AnchorAuto` follower anchors every second.',
      minPreviewHeight: 360,
      padding: EdgeInsets.zero,
      builder: (_) => const PortalAnchoringExample(),
    ),
  ],
);
