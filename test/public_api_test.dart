@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The names `package:finesse/finesse.dart` exports are pinned in
// `test/public_api.txt`, so that the public surface changes only on purpose:
// a state class, a render object or a helper that becomes public by accident
// fails here, and so does a name that disappears.
//
// After a deliberate change, rewrite the list with
//
//     FINESSE_UPDATE_PUBLIC_API=1 flutter test test/public_api_test.dart
//
// and read the diff: every added line is something users can now depend on.
//
// The scan is textual, not resolved (the package has no analyzer dependency
// to keep in step with the Flutter floor). It relies on `dart format`, which
// CI enforces: a top-level declaration starts in column 0.

const _barrel = 'lib/finesse.dart';
const _pinned = 'test/public_api.txt';

void main() {
  test('the barrel exports exactly the pinned names', () {
    final actual = exportedNames(_barrel).toList()..sort();
    final file = File(_pinned);

    if (Platform.environment['FINESSE_UPDATE_PUBLIC_API'] == '1') {
      file.writeAsStringSync('${actual.join('\n')}\n');
      return;
    }

    final expected = file
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .toSet();
    final added = actual.where((name) => !expected.contains(name)).toList();
    final removed = expected.where((name) => !actual.contains(name)).toList()
      ..sort();

    expect(
      added.isEmpty && removed.isEmpty,
      isTrue,
      reason:
          'The public API of package:finesse/finesse.dart changed.\n'
          '${added.isEmpty ? '' : 'Now exported, not in $_pinned:\n'
                    '  ${added.join('\n  ')}\n'}'
          '${removed.isEmpty ? '' : 'In $_pinned, no longer exported:\n'
                    '  ${removed.join('\n  ')}\n'}'
          'If that is intended, run\n'
          '  FINESSE_UPDATE_PUBLIC_API=1 flutter test '
          'test/public_api_test.dart\n'
          'and commit $_pinned. Otherwise make the new name private, or '
          'hide it in $_barrel.',
    );
  });

  test('the pinned list is sorted and has no duplicates', () {
    final lines = File(
      _pinned,
    ).readAsLinesSync().where((line) => line.trim().isNotEmpty).toList();
    expect(lines, [...lines]..sort());
    expect(lines.toSet().length, lines.length);
  });

  test('the scan finds each kind of top-level declaration', () {
    expect(
      declaredNames('''
import 'a.dart';
/// A doc comment mentioning class Nope.
// class Commented {}
@immutable
class A extends B<C> {}
abstract class A2 {}
abstract interface class A3 {}
final class A4 {}
sealed class A5 {}
base mixin class A6 {}
mixin M on A {}
enum E { a, b }
extension X on A {}
extension on A {}
extension type T(int i) {}
typedef F = void Function(int);
typedef G<T> =
    Widget Function(BuildContext context, T value);
Future<T?> showIt<T>({
  required BuildContext context,
}) async => null;
void plain() {}
List<({int index, double start})>
debugDots(Object tester) => const [];
const answer = 42;
final Expando<Object> cache = Expando();
bool get flag => true;
Map<String, List<int>> table = {};
class _Private {}
void _hidden() {}
const _secret = 1;
  class Indented {}
'''),
      {
        'A',
        'A2',
        'A3',
        'A4',
        'A5',
        'A6',
        'M',
        'E',
        'X',
        'T',
        'F',
        'G',
        'showIt',
        'plain',
        'debugDots',
        'answer',
        'cache',
        'flag',
        'table',
      },
    );
  });
}

/// The names the library at [path] exports: its own `export` directives
/// only, as a barrel has no declarations.
Set<String> exportedNames(String path) => _exportsOf(File(path), {});

final _directive = RegExp(
  r'''^(export|part)\s+'([^']+)'((?:\s+(?:show|hide)\s+[\w\s,]+?)*)\s*;''',
  multiLine: true,
);
final _combinator = RegExp(r'(show|hide)\s+([\w\s,]+?)(?=\s+(?:show|hide)|$)');

Set<String> _exportsOf(File file, Set<String> visiting) {
  final names = <String>{};
  if (!visiting.add(file.absolute.path)) return names;
  final source = file.readAsStringSync();
  for (final match in _directive.allMatches(source)) {
    if (match[1] != 'export') continue;
    final uri = match[2]!;
    Set<String>? show;
    final hide = <String>{};
    for (final c in _combinator.allMatches(match[3]!.trim())) {
      final list = c[2]!
          .split(',')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toSet();
      if (c[1] == 'show') {
        show = list;
      } else {
        hide.addAll(list);
      }
    }
    if (uri.startsWith('package:') || uri.startsWith('dart:')) {
      // Another package's names are not scanned: a `show` list is taken as
      // written and anything wider is recorded as the directive itself.
      if (show != null) {
        names.addAll(show);
      } else {
        final hidden = (hide.toList()..sort()).join(', ');
        names.add('* $uri${hidden.isEmpty ? '' : ' hide $hidden'}');
      }
      continue;
    }
    final target = File.fromUri(file.absolute.uri.resolve(uri));
    final all = {
      ..._declarationsOf(target),
      ..._exportsOf(target, visiting),
    };
    names.addAll(
      all.where(
        (name) => (show == null || show.contains(name)) && !hide.contains(name),
      ),
    );
  }
  return names;
}

/// The public names [file] and its parts declare.
Set<String> _declarationsOf(File file) {
  final source = file.readAsStringSync();
  final names = declaredNames(source);
  for (final match in _directive.allMatches(source)) {
    if (match[1] != 'part') continue;
    final part = File.fromUri(file.absolute.uri.resolve(match[2]!));
    names.addAll(declaredNames(part.readAsStringSync()));
  }
  return names;
}

final _type = RegExp(
  r'^(?:(?:abstract|base|final|sealed|interface|mixin) )*class (\w+)'
  r'|^(?:base )?mixin (\w+)'
  r'|^enum (\w+)'
  r'|^extension type (?:const )?(\w+)'
  r'|^extension (\w+) on '
  r'|^typedef (\w+)',
);
final _notADeclaration = RegExp(
  r'^(?:import|export|part|library|extension|return|if|for|while|switch)\b',
);
final _generics = RegExp('<[^<>]*>');
final _accessor = RegExp(r'\b(?:get|set) (\w+)');
final _bareType = RegExp(r'^[\w.]+\??$');
final _member = RegExp(r'(\w+)\s*(?:\(|=(?!=)|;|$)');

/// The public names declared at the top level of [source].
///
/// Formatted source only: a declaration starts in column 0 and nothing else
/// that starts there begins with a letter.
Set<String> declaredNames(String source) {
  final names = <String>{};
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.isEmpty || !RegExp('^[A-Za-z]').hasMatch(line)) continue;
    String? name;
    final type = _type.firstMatch(line);
    if (type != null) {
      name = [
        for (var i = 1; i <= type.groupCount; i++) type[i],
      ].nonNulls.first;
    } else if (!_notADeclaration.hasMatch(line)) {
      var rest = line;
      while (_generics.hasMatch(rest)) {
        rest = rest.replaceAll(_generics, '');
      }
      if (_bareType.hasMatch(rest) && i + 1 < lines.length) {
        // A return type too long to share a line with the name.
        rest = lines[i + 1];
      }
      name = (_accessor.firstMatch(rest) ?? _member.firstMatch(rest))?[1];
    }
    if (name != null && !name.startsWith('_')) names.add(name);
  }
  return names;
}
