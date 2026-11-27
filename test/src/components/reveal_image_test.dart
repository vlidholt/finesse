import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// An image that arrives when the test says so.
class _LateImage extends ImageProvider<_LateImage> {
  final completer = Completer<ImageInfo>();

  @override
  Future<_LateImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_LateImage key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(completer.future);
}

void main() {
  late ui.Image picture;

  setUpAll(() async {
    picture = await createTestImage(width: 20, height: 20);
  });

  Iterable<ColorFiltered> filters(WidgetTester tester) =>
      tester.widgetList<ColorFiltered>(find.byType(ColorFiltered));

  for (final reveal in ImageReveal.values) {
    testWidgets('a $reveal reveal plays once the image arrives', (
      tester,
    ) async {
      final image = _LateImage();
      await pumpUna(
        tester,
        Center(
          child: RevealImage(
            image: image,
            reveal: reveal,
            width: 100,
            height: 100,
            semanticLabel: 'A picture',
          ),
        ),
      );
      // The placeholder, and no picture yet.
      expect(find.byType(RawImage), findsNothing);
      expect(tester.getSize(find.byType(RevealImage)), const Size(100, 100));

      image.completer.complete(ImageInfo(image: picture.clone()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(RawImage), findsOneWidget);
      final filter = filters(tester).single;
      // Part way: the picture is still partly transparent.
      final matrix = filter.colorFilter.toString();
      expect(matrix, contains('matrix'));

      await tester.pump(const Duration(seconds: 2));
      expect(filters(tester), isEmpty);
      expect(find.byType(RawImage), findsOneWidget);
      expect(find.bySemanticsLabel('A picture'), findsOneWidget);
    });
  }

  testWidgets('an image already in the cache shows at once', (tester) async {
    final image = MemoryImage(Uint8List.fromList(kTransparentImage));
    await pumpUna(
      tester,
      Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () {},
            child: const Text('x'),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await RevealImage.precache(tester.element(find.byType(Button)), image);
    });
    await tester.pumpWidget(
      UnaApp(
        home: Center(child: RevealImage(image: image, width: 10, height: 10)),
      ),
    );
    expect(find.byType(RawImage), findsOneWidget);
    expect(filters(tester), isEmpty);
  });

  testWidgets('no motion shows the image without a reveal', (tester) async {
    final image = _LateImage();
    await pumpUna(
      tester,
      Center(child: RevealImage(image: image, width: 10, height: 10)),
      theme: ThemeData(motion: Motion.none),
    );
    image.completer.complete(ImageInfo(image: picture.clone()));
    await tester.pump();
    await tester.pump();
    expect(find.byType(RawImage), findsOneWidget);
    expect(filters(tester), isEmpty);
  });
}

/// A 1×1 transparent PNG.
const kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, //
];
