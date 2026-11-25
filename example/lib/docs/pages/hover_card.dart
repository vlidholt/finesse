import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/hover_card/hover_card_arrow.dart';
import 'package:example/docs/examples/hover_card/hover_card_basic.dart';
import 'package:example/docs/examples/hover_card/hover_card_term.dart';
import 'package:flutter/widgets.dart';

final hoverCardDoc = ComponentDoc(
  slug: 'hover_card',
  title: 'Hover Card',
  description:
      'A card of supplementary content that opens when the pointer rests on '
      'its trigger, when the keyboard focuses it, or on a long press.',
  examples: [
    ComponentExample(
      id: 'hover_card_basic',
      title: 'Default',
      description:
          'Hover the name, Tab to it, or press and hold it on a touch '
          'screen. The card never takes the focus, and closes a moment '
          'after the pointer has left both the name and the card.',
      builder: (_) => const HoverCardBasicExample(),
      minPreviewHeight: 280,
    ),
    ComponentExample(
      id: 'hover_card_arrow',
      title: 'With an arrow',
      description:
          'An arrow says which of several triggers the card belongs to. '
          'The card can hold controls: the pointer can travel into it, and '
          'Tab reaches them after the trigger.',
      builder: (_) => const HoverCardArrowExample(),
      minPreviewHeight: 260,
    ),
    ComponentExample(
      id: 'hover_card_term',
      title: 'Placement and delays',
      description:
          'An anchor puts the card above its trigger, with a fallback '
          'below; openDelay and closeDelay tune how eager it is.',
      builder: (_) => const HoverCardTermExample(),
      minPreviewHeight: 320,
      padding: const EdgeInsets.fromLTRB(32, 140, 32, 32),
    ),
  ],
);
