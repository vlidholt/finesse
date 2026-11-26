import 'dart:typed_data';

import 'package:una/src/utils/clipboard/clipboard_service_stub.dart'
    if (dart.library.js_interop) 'package:una/src/utils/clipboard/clipboard_service_web.dart'
    as impl;

/// A single item read from the system clipboard.
typedef ClipboardItem = ({String mimeType, Uint8List bytes});

/// Callback for receiving pasted file items.
typedef PasteFilesCallback = void Function(List<ClipboardItem> files);

/// Callback for receiving errors during paste file extraction.
typedef PasteFilesErrorCallback = void Function(Object error);

/// Listens for files pasted into the app.
///
/// On web, listens to the browser `paste` event and extracts file items from
/// the clipboard data. On other platforms, every method is a no-op.
abstract final class UnaClipboard {
  /// Registers a listener for paste events containing file data.
  ///
  /// The [callback] is invoked only when the paste contains file items.
  static void addPasteFilesListener(PasteFilesCallback callback) =>
      impl.addPasteFilesListener(callback);

  /// Removes a previously registered paste files listener.
  static void removePasteFilesListener(PasteFilesCallback callback) =>
      impl.removePasteFilesListener(callback);

  /// Registers a listener for errors that occur during paste file
  /// extraction.
  static void addPasteFilesErrorListener(
    PasteFilesErrorCallback callback,
  ) => impl.addPasteFilesErrorListener(callback);

  /// Removes a previously registered paste files error listener.
  static void removePasteFilesErrorListener(
    PasteFilesErrorCallback callback,
  ) => impl.removePasteFilesErrorListener(callback);
}
