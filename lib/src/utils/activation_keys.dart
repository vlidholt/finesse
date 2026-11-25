import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The keys that press the control that has the focus: Enter, the number
/// pad's Enter and Space.
///
/// A control that handles its own keys binds these (in a
/// `CallbackShortcuts`), rather than answering `ActivateIntent`: the
/// app-wide shortcuts do not send that intent for the same keys on every
/// platform — on the web Enter is `ButtonActivateIntent` — and binding the
/// keys works everywhere.
const activationKeys = <ShortcutActivator>[
  SingleActivator(LogicalKeyboardKey.enter),
  SingleActivator(LogicalKeyboardKey.numpadEnter),
  SingleActivator(LogicalKeyboardKey.space),
];
