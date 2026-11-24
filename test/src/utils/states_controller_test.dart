import 'package:finesse/finesse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatesController', () {
    test('emits a new Set instead of mutating in place', () {
      // Regression: update() mutated the Set held by the ValueNotifier and
      // then called notifyListeners, so a listener that captured the previous
      // value saw it change underneath and could not diff the two.
      final controller = StatesController();
      addTearDown(controller.dispose);

      final before = controller.value;
      controller.update(FinesseState.hovered, true);
      final after = controller.value;

      expect(identical(before, after), isFalse);
      expect(before, isEmpty, reason: 'the old Set must not be mutated');
      expect(after, contains(FinesseState.hovered));
    });

    test('notifies only when the state actually changes', () {
      final controller = StatesController();
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.update(FinesseState.pressed, true);
      expect(notifications, 1);

      // Already pressed — nothing changed, so no notification.
      controller.update(FinesseState.pressed, true);
      expect(notifications, 1);

      controller.update(FinesseState.pressed, false);
      expect(notifications, 2);

      // Already not pressed.
      controller.update(FinesseState.pressed, false);
      expect(notifications, 2);
    });

    test('seeds from the provided initial states', () {
      final controller = StatesController({FinesseState.disabled});
      addTearDown(controller.dispose);
      expect(controller.value, {FinesseState.disabled});
    });
  });
}
