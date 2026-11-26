import 'package:example/docs/phone_frame.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `extended: !scrolledDown`. The label gives the content room while it is
/// being read and comes back when the reader turns round.
class FloatingActionButtonExtendedExample extends StatefulWidget {
  const FloatingActionButtonExtendedExample({super.key});

  @override
  State<FloatingActionButtonExtendedExample> createState() =>
      _FloatingActionButtonExtendedExampleState();
}

class _FloatingActionButtonExtendedExampleState
    extends State<FloatingActionButtonExtendedExample> {
  bool _extended = true;

  bool _onScroll(UserScrollNotification notification) {
    final extended = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _extended,
    };
    if (extended != _extended) setState(() => _extended = extended);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 460,
      child: Scaffold(
        appBar: const AppBar(title: Text('Inbox')),
        floatingActionButton: FloatingActionButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
          label: const Text('Compose'),
          extended: _extended,
          onPressed: () {},
        ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: _onScroll,
          child: ListView(
            children: [
              for (var i = 1; i <= 24; i++)
                ListTile(
                  title: Text('Message $i'),
                  subtitle: const Text('Scroll down, then back up'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
