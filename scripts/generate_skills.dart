// ignore_for_file: avoid_print
//
// Regenerates skills/finesse-overview/components/*.md from the example app's
// documentation pages, which are the single source of truth for component
// descriptions and sample code (see CLAUDE.md: "the code shown is the code
// that runs").
//
// Run from the repository root:
//   dart run scripts/generate_skills.dart          # write the files
//   dart run scripts/generate_skills.dart --check  # fail if they are stale
//
// The set of pages is read from `example/lib/docs/registry.dart`: every
// entry of `componentDocs` becomes `components/<slug>.md`, and every other
// page of `docGroups` (the guides) must be named in [guidePages], which says
// which hand-written file of the skill covers it. SKILL.md and guides/ carry
// prose the example app has no source for, so they are written by hand, but
// the check fails when SKILL.md does not link a component page, when any
// file of the skill links a page that does not exist, or when a guide page
// is added to the docs without a counterpart here.
//
// `test/scripts/generate_skills_test.dart` runs the check.

import 'dart:io';

/// The docs app's guide pages (everything in `docGroups` that is not a
/// component reference), and the file of the skill that covers each one.
/// A new guide page in the registry fails the check until it is listed.
const guidePages = {
  'introduction': 'SKILL.md',
  'installation': 'guides/installation.md',
  'theming': 'guides/theming.md',
  'styles': 'guides/styles.md',
  'typography': 'guides/typography.md',
  'fonts': 'guides/typography.md',
  'icons': 'guides/icons.md',
  'layout': 'guides/layout.md',
  'form_factors': 'guides/form-factors.md',
  'responsive': 'guides/form-factors.md',
  'motion': 'guides/motion.md',
  'form': 'guides/forms.md',
  'portal': 'guides/overlays.md',
  'building_blocks': 'guides/building-blocks.md',
  'overview': 'SKILL.md',
};

const _skillDir = 'skills/finesse-overview';
const _pagesDir = 'example/lib/docs/pages';
const _examplesDir = 'example/lib/docs/examples';
const _registry = 'example/lib/docs/registry.dart';

void main(List<String> args) {
  final check = args.contains('--check');
  final result = generateSkills();

  result.problems.forEach(stderr.writeln);

  final outDir = Directory('$_skillDir/components');
  final stale = <String>[];
  final existing = {
    if (outDir.existsSync())
      for (final f in outDir.listSync().whereType<File>())
        if (f.path.endsWith('.md')) _relative(f.path),
  };

  for (final MapEntry(key: path, value: content) in result.files.entries) {
    final file = File(path);
    if (file.existsSync() && file.readAsStringSync() == content) continue;
    stale.add(path);
    if (!check) {
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
      print('Wrote $path');
    }
  }
  for (final path in existing.difference(result.files.keys.toSet())) {
    stale.add(path);
    if (!check) {
      File(path).deleteSync();
      print('Deleted $path');
    }
  }

  if (check) {
    for (final path in stale) {
      stderr.writeln('Out of date: $path');
    }
    if (stale.isNotEmpty) {
      stderr.writeln('Run `dart run scripts/generate_skills.dart`.');
    }
    if (stale.isNotEmpty || result.problems.isNotEmpty) exitCode = 1;
    return;
  }

  print(
    '${result.files.length} component pages, '
    '${stale.length} changed.',
  );
  if (result.problems.isNotEmpty) exitCode = 1;
}

/// What a run produces: the generated files by path, relative to the
/// repository root, and everything that is out of step.
class SkillsOutput {
  /// Creates the result of a run.
  SkillsOutput(this.files, this.problems);

  /// The content of every generated file, by path.
  final Map<String, String> files;

  /// Pages missing from the skill, broken links and unreadable pages.
  final List<String> problems;
}

/// Reads the docs registry and pages from the current directory (the
/// repository root) and renders the component pages of the skill. Writes
/// nothing.
SkillsOutput generateSkills() {
  final problems = <String>[];
  final registry = File(_registry).readAsStringSync();

  // Every page variable in the registry, by name, from the page files.
  final pages = <String, _Page>{};
  for (final file in Directory(_pagesDir).listSync().whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    final source = file.readAsStringSync();
    for (final match in RegExp(
      r'final\s+(\w+)\s*=\s*ComponentDoc\(',
    ).allMatches(source)) {
      pages[match.group(1)!] = _parsePage(source, match.end - 1);
    }
  }
  // The overview page is declared in the registry itself.
  for (final match in RegExp(
    r'final\s+(\w+)\s*=\s*ComponentDoc\(',
  ).allMatches(registry)) {
    pages[match.group(1)!] = _parsePage(registry, match.end - 1);
  }

  final componentNames = _identifiersOfList(registry, 'componentDocs');
  final groupNames = _identifiersOfList(
    registry,
    'docGroups',
  ).where((name) => name.endsWith('Doc')).toList();
  if (componentNames.isEmpty) {
    problems.add('No `componentDocs` list found in $_registry.');
  }

  final files = <String, String>{};
  final componentFiles = <String>[];
  for (final name in componentNames) {
    final page = pages[name];
    if (page == null) {
      problems.add('$_registry lists $name, but no page declares it.');
      continue;
    }
    final fileName = '${page.slug.replaceAll('_', '-')}.md';
    componentFiles.add(fileName);
    files['$_skillDir/components/$fileName'] = _render(page, problems);
  }

  for (final name in groupNames) {
    final page = pages[name];
    if (page == null) {
      problems.add('$_registry lists $name, but no page declares it.');
      continue;
    }
    final covered = guidePages[page.slug];
    if (covered == null) {
      problems.add(
        'The docs page `${page.slug}` has no counterpart in the skill: '
        'add it to `guidePages` in scripts/generate_skills.dart and cover '
        'it in a guide.',
      );
    } else if (!File('$_skillDir/$covered').existsSync()) {
      problems.add(
        '`guidePages` maps ${page.slug} to $covered, which is '
        'missing.',
      );
    }
  }
  final slugs = {for (final name in groupNames) pages[name]?.slug};
  for (final slug in guidePages.keys) {
    if (!slugs.contains(slug)) {
      problems.add(
        '`guidePages` names `$slug`, which the registry does not '
        'list.',
      );
    }
  }

  // SKILL.md is the map: it links every component page.
  final skill = File('$_skillDir/SKILL.md');
  final skillText = skill.existsSync() ? skill.readAsStringSync() : '';
  for (final fileName in componentFiles) {
    if (!skillText.contains('components/$fileName')) {
      problems.add('SKILL.md does not link components/$fileName.');
    }
  }

  // No hand-written file links a page that does not exist.
  final handWritten = [
    skill,
    ...Directory('$_skillDir/guides').listSync().whereType<File>(),
  ];
  for (final file in handWritten) {
    if (!file.existsSync() || !file.path.endsWith('.md')) continue;
    final text = file.readAsStringSync();
    for (final link in RegExp(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)').allMatches(
      text,
    )) {
      final target = link.group(1)!;
      if (target.startsWith('http')) continue;
      final resolved = Uri.file(file.path).resolve(target).toFilePath();
      final relative = _relative(resolved);
      final exists = File(resolved).existsSync() || files.containsKey(relative);
      if (!exists) {
        problems.add(
          '${_relative(file.path)} links $target, which does not '
          'exist.',
        );
      }
    }
  }

  return SkillsOutput(files, problems);
}

String _relative(String path) {
  final root = '${Directory.current.absolute.path}/';
  final absolute = File(path).absolute.path;
  final normalized = Uri.file(absolute).normalizePath().toFilePath();
  return normalized.startsWith(root) ? normalized.substring(root.length) : path;
}

// ---------------------------------------------------------------------------
// Reading the pages.

class _Page {
  _Page({
    required this.source,
    required this.slug,
    required this.title,
    required this.description,
    required this.examples,
    required this.body,
  });

  /// The whole file the page is declared in, for its constants.
  final String source;
  final String slug;
  final String title;
  final String description;
  final List<_Example> examples;

  /// The `body:` builder's source, if the page has prose of its own.
  final String? body;
}

class _Example {
  _Example({
    required this.slug,
    required this.id,
    required this.title,
    this.description,
  });

  /// The directory under `example/lib/docs/examples/` the source is in.
  final String slug;
  final String id;
  final String title;
  final String? description;
}

/// Parses the `ComponentDoc(` call whose parenthesis is at [open].
_Page _parsePage(String source, int open) {
  final args = _callArguments(source, open);
  final slug = _resolve(args['slug'], source) ?? '';
  final examplesSource = args['examples'];
  return _Page(
    source: source,
    slug: slug,
    title: _resolve(args['title'], source) ?? slug,
    description: _resolve(args['description'], source) ?? '',
    examples: examplesSource == null
        ? const []
        : [
            for (final call in _calls(examplesSource, 'ComponentExample'))
              _example(slug, call),
          ],
    body: args['body'],
  );
}

_Example _example(String slug, Map<String, String> args) => _Example(
  slug: slug,
  id: _stringValue(args['id']) ?? '',
  title: _stringValue(args['title']) ?? '',
  description: _stringValue(args['description']),
);

/// The identifiers listed in `final <name> = <...>[ ... ];`, in order.
List<String> _identifiersOfList(String source, String name) {
  final match = RegExp(
    'final\\s+$name\\s*=\\s*(?:<[^>]*>)?\\[',
  ).firstMatch(source);
  if (match == null) return const [];
  final open = match.end - 1;
  final close = _matching(source, open);
  final inner = _stripStrings(source.substring(open + 1, close));
  return [
    for (final m in RegExp(r'(?<![\w.])([a-z]\w*Doc)\b').allMatches(inner))
      m.group(1)!,
  ];
}

/// The named arguments of the call whose opening parenthesis is at [open],
/// as source text. A positional argument is stored under its index.
Map<String, String> _callArguments(String source, int open) {
  final close = _matching(source, open);
  final args = <String, String>{};
  var start = open + 1;
  var position = 0;
  void take(int end) {
    final text = source.substring(start, end).trim();
    if (text.isEmpty) return;
    final named = RegExp(r'^(\w+)\s*:(?!:)').firstMatch(text);
    if (named != null) {
      args[named.group(1)!] = text.substring(named.end).trim();
    } else {
      args['${position++}'] = text;
    }
  }

  var i = open + 1;
  while (i < close) {
    final c = source[i];
    if (_startsString(source, i)) {
      i = _skipString(source, i);
      continue;
    }
    if (c == '/' && i + 1 < close && source[i + 1] == '/') {
      i = source.indexOf('\n', i);
      if (i == -1) break;
      continue;
    }
    if (c == '(' || c == '[' || c == '{') {
      i = _matching(source, i) + 1;
      continue;
    }
    if (c == ',') {
      take(i);
      start = i + 1;
    }
    i++;
  }
  take(close);
  return args;
}

/// Every call to [constructor] in [source] that is not inside another one,
/// in order, with its arguments.
List<Map<String, String>> _calls(String source, String constructor) {
  final calls = <Map<String, String>>[];
  final pattern = RegExp('(?<![\\w.])$constructor\\(');
  var from = 0;
  while (true) {
    final match = _nextOutsideStrings(source, pattern, from);
    if (match == null) break;
    final open = match.end - 1;
    calls.add(_callArguments(source, open));
    from = _matching(source, open) + 1;
  }
  return calls;
}

/// The value of [expression]: adjacent string literals, or the name of a
/// string constant declared in [source].
String? _resolve(String? expression, String source) {
  final value = _stringValue(expression);
  if (value != null || expression == null) return value;
  final name = expression.trim();
  if (!RegExp(r'^\w+$').hasMatch(name)) return null;
  final declaration = RegExp(
    '(?:const|final)\\s+(?:String\\s+)?$name\\s*=\\s*',
  ).firstMatch(source);
  if (declaration == null) return null;
  final end = source.indexOf(';', declaration.end);
  return _stringValue(source.substring(declaration.end, end));
}

/// The value of an expression made of adjacent string literals, or null
/// when [expression] is not one.
String? _stringValue(String? expression) {
  if (expression == null) return null;
  final buffer = StringBuffer();
  var i = 0;
  var any = false;
  while (i < expression.length) {
    final c = expression[i];
    if (c.trim().isEmpty) {
      i++;
      continue;
    }
    if (!_startsString(expression, i)) return any ? buffer.toString() : null;
    final end = _skipString(expression, i);
    buffer.write(_literalValue(expression.substring(i, end)));
    any = true;
    i = end;
  }
  return any ? buffer.toString() : null;
}

/// The list of string values in a `[ '...', '...' ]` expression.
List<String> _stringList(String expression) {
  final open = expression.indexOf('[');
  if (open == -1) return const [];
  final args = _callArguments(expression, open);
  return [
    for (var i = 0; args.containsKey('$i'); i++)
      _stringValue(args['$i']) ?? args['$i']!,
  ];
}

bool _startsString(String s, int i) {
  final c = s[i];
  if (c == "'" || c == '"') return true;
  return c == 'r' &&
      i + 1 < s.length &&
      (s[i + 1] == "'" || s[i + 1] == '"') &&
      (i == 0 || !RegExp(r'\w').hasMatch(s[i - 1]));
}

/// The index just after the string literal that starts at [start].
int _skipString(String s, int start) {
  var i = start;
  var raw = false;
  if (s[i] == 'r') {
    raw = true;
    i++;
  }
  final quote = s[i];
  final triple = s.startsWith(quote * 3, i);
  final delimiter = triple ? quote * 3 : quote;
  var j = i + delimiter.length;
  while (j < s.length) {
    if (!raw && s[j] == r'\') {
      j += 2;
      continue;
    }
    if (!raw && s[j] == r'$' && j + 1 < s.length && s[j + 1] == '{') {
      j = _matching(s, j + 1) + 1;
      continue;
    }
    if (s.startsWith(delimiter, j)) return j + delimiter.length;
    j++;
  }
  throw StateError('Unterminated string literal at $start');
}

String _literalValue(String literal) {
  var raw = false;
  var body = literal;
  if (body.startsWith('r')) {
    raw = true;
    body = body.substring(1);
  }
  final quote = body[0];
  final triple = body.startsWith(quote * 3);
  final delimiter = triple ? 3 : 1;
  body = body.substring(delimiter, body.length - delimiter);
  if (raw) return body;
  return body.replaceAllMapped(RegExp(r'\\(.)'), (m) {
    switch (m.group(1)) {
      case 'n':
        return '\n';
      case 't':
        return '\t';
      default:
        return m.group(1)!;
    }
  });
}

/// The index of the bracket that closes the one at [open], skipping
/// strings and comments.
int _matching(String s, int open) {
  const pairs = {'(': ')', '[': ']', '{': '}'};
  final stack = <String>[];
  var i = open;
  while (i < s.length) {
    final c = s[i];
    if (_startsString(s, i)) {
      i = _skipString(s, i);
      continue;
    }
    if (c == '/' && i + 1 < s.length && s[i + 1] == '/') {
      final end = s.indexOf('\n', i);
      if (end == -1) break;
      i = end;
      continue;
    }
    if (pairs.containsKey(c)) {
      stack.add(pairs[c]!);
    } else if (stack.isNotEmpty && c == stack.last) {
      stack.removeLast();
      if (stack.isEmpty) return i;
    }
    i++;
  }
  throw StateError('Unbalanced brackets from index $open');
}

/// [source] with the content of every string literal blanked out.
String _stripStrings(String source) {
  final buffer = StringBuffer();
  var i = 0;
  while (i < source.length) {
    if (_startsString(source, i)) {
      final end = _skipString(source, i);
      buffer.write(' ' * (end - i));
      i = end;
    } else {
      buffer.write(source[i]);
      i++;
    }
  }
  return buffer.toString();
}

RegExpMatch? _nextOutsideStrings(String source, RegExp pattern, int from) {
  final blanked = _stripStrings(source);
  for (final match in pattern.allMatches(blanked, from)) {
    return match;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Rendering.

String _render(_Page page, List<String> problems) {
  final buffer = StringBuffer()
    ..writeln('# ${page.title}')
    ..writeln()
    ..writeln(page.description)
    ..writeln();

  for (final example in page.examples) {
    _renderExample(buffer, example, problems, level: 2);
  }
  if (page.body != null) _renderBody(buffer, page, problems);

  return '${buffer.toString().trimRight()}\n';
}

void _renderExample(
  StringBuffer buffer,
  _Example example,
  List<String> problems, {
  required int level,
}) {
  buffer
    ..writeln('${'#' * level} ${example.title}')
    ..writeln();
  if (example.description != null) {
    buffer
      ..writeln(example.description)
      ..writeln();
  }
  final file = File('$_examplesDir/${example.slug}/${example.id}.dart');
  if (file.existsSync()) {
    buffer
      ..writeln('```dart')
      ..writeln(file.readAsStringSync().trimRight())
      ..writeln('```')
      ..writeln();
  } else {
    problems.add('Missing example source: ${file.path}');
  }
}

/// Renders the prose of a page's `body:` in source order: a `DocSection`
/// is a heading, a `DocParagraph` a paragraph, `DocBullets` a list,
/// `DocTable` a table and a `DocExample` an example with its source.
void _renderBody(StringBuffer buffer, _Page page, List<String> problems) {
  final source = page.body!;
  final blanked = _stripStrings(source);
  final pattern = RegExp(
    r'(?<![\w.])(DocSection|DocParagraph|DocBullets|DocTable|DocExample)\(',
  );
  var from = 0;
  while (true) {
    final match = pattern.firstMatch(blanked.substring(from));
    if (match == null) break;
    final open = from + match.end - 1;
    final args = _callArguments(source, open);
    final kind = match.group(1)!;
    var next = _matching(source, open) + 1;
    switch (kind) {
      case 'DocSection':
        buffer
          ..writeln('## ${_stringValue(args['title']) ?? ''}')
          ..writeln();
        // Its children are rendered as the scan goes on inside it.
        next = open + 1;
      case 'DocParagraph':
        buffer
          ..writeln(_stringValue(args['0']) ?? '')
          ..writeln();
      case 'DocBullets':
        for (final item in _stringList(args['items'] ?? '')) {
          buffer.writeln('- $item');
        }
        buffer.writeln();
      case 'DocTable':
        final columns = _stringList(args['columns'] ?? '');
        final rows = <List<String>>[];
        final rowsSource = args['rows'] ?? '';
        final rowsOpen = rowsSource.indexOf('[');
        if (rowsOpen != -1) {
          final rowArgs = _callArguments(rowsSource, rowsOpen);
          for (var i = 0; rowArgs.containsKey('$i'); i++) {
            rows.add(_stringList(rowArgs['$i']!));
          }
        }
        String row(List<String> cells) =>
            '| ${cells.map((c) => c.replaceAll('|', r'\|')).join(' | ')} |';
        buffer
          ..writeln(row(columns))
          ..writeln(row([for (final _ in columns) '---']));
        for (final cells in rows) {
          buffer.writeln(row(cells));
        }
        buffer.writeln();
      case 'DocExample':
        final slug = _resolve(args['slug'], page.source) ?? page.slug;
        final exampleSource = args['example'] ?? '';
        for (final call in _calls(exampleSource, 'ComponentExample')) {
          _renderExample(
            buffer,
            _example(slug, call),
            problems,
            level: 3,
          );
        }
    }
    from = next;
  }
}
