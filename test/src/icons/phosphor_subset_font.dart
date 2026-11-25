import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Loads the regular Phosphor font as `packages/finesse/PhosphorRegular`,
/// the family an icon of this package names. Tests otherwise load no fonts
/// and draw every glyph as a box.
///
/// On the VM this is the font the package ships, from its asset bundle. A
/// browser test has no asset bundle, so there it is [phosphorRegularSubset].
Future<void> loadPhosphorRegular() async {
  final loader = FontLoader('packages/finesse/PhosphorRegular')
    ..addFont(
      kIsWeb
          ? Future.value(ByteData.sublistView(phosphorRegularSubset))
          : rootBundle.load('fonts/phosphor/Phosphor.ttf'),
    );
  await loader.load();
}

/// Five glyphs of `fonts/phosphor/Phosphor.ttf` — `minus`, `heart`,
/// `compassRose`, `circle` and `x` — with their outlines unchanged.
///
/// Cut with the tool Flutter subsets icon fonts with:
///
/// ```sh
/// echo "58154 58024 57798 57738 58614" | \
///   $FLUTTER_ROOT/bin/cache/artifacts/engine/<host>/font-subset \
///   subset.ttf fonts/phosphor/Phosphor.ttf
/// base64 -i subset.ttf
/// ```
///
/// Phosphor Icons — https://phosphoricons.com. Copyright (c) 2020-2021
/// Phosphor Icons. MIT License; the full text is in this package's LICENSE
/// file and in fonts/phosphor/LICENSE.
final Uint8List phosphorRegularSubset = base64Decode(
  // The font, base64.
  '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'
  'EKBAUTDQcLBf73AA==',
);
