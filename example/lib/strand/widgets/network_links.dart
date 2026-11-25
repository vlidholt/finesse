import 'package:example/strand/data/network_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/network_section_view.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Opens one of the Network screen's lists from anywhere in Strand: the
/// home feed's "Groups" and "Events" shortcuts, a "See all" link, an event
/// reminder among the notifications.
///
/// A desktop switches to the Network destination with [section] in its
/// main column. A phone has no room for that arrangement, so there the
/// list opens as a page over whatever is showing.
void openNetworkSection(BuildContext context, NetworkSection section) {
  final network = context.strand.network;
  final mobile = Theme.of(context).formFactor == FormFactor.mobile;
  if (mobile && section != NetworkSection.grow) {
    context.pushFullScreen<void>(
      (context) => NetworkSectionPage(section: section, controller: network),
    );
    return;
  }
  network.section = section;
  context.leaveTo(StrandDestination.network);
}

/// Asks for an email address and "sends" an invitation to join Strand.
Future<void> showInviteDialog(BuildContext context) async {
  final email = await showDialog<String>(
    context: context,
    builder: (context) => const _InviteDialog(),
  );
  if (email != null && context.mounted) {
    showStrandToast(
      context,
      'Invitation sent',
      description: 'We will let you know when $email joins Strand.',
    );
  }
}

class _InviteDialog extends StatefulWidget {
  const _InviteDialog();

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _email = TextEditingController();

  bool get _valid {
    final text = _email.text.trim();
    final at = text.indexOf('@');
    return at > 0 && text.indexOf('.', at) > at + 1 && !text.endsWith('.');
  }

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    if (_valid) Navigator.of(context).pop(_email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      title: const Text('Invite someone to Strand'),
      description: const Text(
        'They get one email with a link to join and connect with you.',
      ),
      actions: [
        Button.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Button(
          enabled: _valid,
          leading: const PhosphorIcon(PhosphorIconsRegular.paperPlaneTilt),
          onPressed: _send,
          child: const Text('Send invitation'),
        ),
      ],
      child: TextField(
        controller: _email,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.send,
        placeholder: const Text('name@company.com'),
        leading: const PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
        onSubmitted: (_) => _send(),
      ),
    );
  }
}
