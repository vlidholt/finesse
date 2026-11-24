# Phosphor icon fonts

The six weights of [Phosphor Icons](https://phosphoricons.com), copied
unchanged from the [`phosphor_flutter`](https://pub.dev/packages/phosphor_flutter)
package, version 2.1.0 (`lib/fonts/`).

| File | Font family | Dart class |
| --- | --- | --- |
| `Phosphor.ttf` | `PhosphorRegular` | `PhosphorIconsRegular` |
| `Phosphor-Bold.ttf` | `PhosphorBold` | `PhosphorIconsBold` |
| `Phosphor-Fill.ttf` | `PhosphorFill` | `PhosphorIconsFill` |
| `Phosphor-Light.ttf` | `PhosphorLight` | `PhosphorIconsLight` |
| `Phosphor-Thin.ttf` | `PhosphorThin` | `PhosphorIconsThin` |
| `Phosphor-Duotone.ttf` | `PhosphorDuotone` | `PhosphorIconsDuotone` |

The Dart constants in `lib/src/icons/` are generated from the same package's
code points.

Phosphor Icons are distributed under the MIT License, reproduced in
[`LICENSE`](LICENSE) next to this file and in the package's root `LICENSE`,
which is what Flutter bundles into an app's licence page.

To update: replace the six files and `LICENSE` from a newer release,
regenerate `lib/src/icons/phosphor_icons_*.dart` from its code points, and
update the version named here and in `pubspec.yaml`.
