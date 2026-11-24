import 'package:example/strand/data/applications_data.dart';
import 'package:example/strand/data/jobs_data.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';

/// How a column of the board can be ordered from its menu.
enum ApplicationSort { updated, company }

/// The applications on the board, by stage.
///
/// The `Board` only reports what the user did; this is where a move is
/// carried out. It is a [ChangeNotifier] owned by the Jobs screen, so the
/// board keeps its state while the screen shows "Find jobs", and a listing
/// saved or applied to over there turns up here.
class ApplicationsController extends ChangeNotifier {
  final Map<ApplicationStage, List<JobApplication>> _stages = {
    for (final stage in ApplicationStage.values)
      stage: [...?ApplicationsData.initial[stage]],
  };

  final List<JobApplication> _suggestions = [...ApplicationsData.suggestions];

  /// The applications at [stage], first on top.
  List<JobApplication> at(ApplicationStage stage) => _stages[stage]!;

  /// Whether "Add from job alerts" has anything left to add.
  bool get hasSuggestions => _suggestions.isNotEmpty;

  ApplicationStage? stageOf(String id) {
    for (final MapEntry(key: stage, value: list) in _stages.entries) {
      if (list.any((application) => application.id == id)) return stage;
    }
    return null;
  }

  /// Carries out a move the board asked for. A card that changes stage
  /// takes that stage's status line.
  void move(BoardMove<JobApplication> move) {
    final from = move.fromColumn as ApplicationStage;
    final to = move.toColumn as ApplicationStage;
    final application = _stages[from]!.removeAt(move.fromIndex);
    _stages[to]!.insert(
      move.toIndex.clamp(0, _stages[to]!.length),
      from == to ? application : application.movedTo(to),
    );
    notifyListeners();
  }

  /// Puts the next role from the user's job alerts on top of "Saved".
  void addSuggestion() {
    if (_suggestions.isEmpty) return;
    _stages[ApplicationStage.saved]!.insert(0, _suggestions.removeAt(0));
    notifyListeners();
  }

  void sort(ApplicationStage stage, ApplicationSort order) {
    _stages[stage]!.sort(
      (a, b) => switch (order) {
        ApplicationSort.updated => a.updatedHoursAgo.compareTo(
          b.updatedHoursAgo,
        ),
        ApplicationSort.company => a.company.name.compareTo(b.company.name),
      },
    );
    notifyListeners();
  }

  /// Moves every application at [stage] to the archive.
  void archiveAll(ApplicationStage stage) {
    if (stage == ApplicationStage.archived) return;
    final list = _stages[stage]!;
    _stages[ApplicationStage.archived]!.insertAll(0, [
      for (final application in list)
        application.movedTo(ApplicationStage.archived),
    ]);
    list.clear();
    notifyListeners();
  }

  void clearArchive() {
    if (_stages[ApplicationStage.archived]!.isEmpty) return;
    _stages[ApplicationStage.archived]!.clear();
    notifyListeners();
  }

  /// Brings the board in line with a listing on the "Find jobs" side:
  /// applied to, it is under "Applied"; only saved, under "Saved"; neither,
  /// it is gone unless the user has since dragged it further along.
  void track(Job job, {required bool saved, required bool applied}) {
    final stage = stageOf(job.id);
    if (applied) {
      if (stage == null || stage == ApplicationStage.saved) {
        _stages[ApplicationStage.saved]!.removeWhere((a) => a.id == job.id);
        _stages[ApplicationStage.applied]!.insert(
          0,
          ApplicationsData.fromJob(job, applied: true),
        );
        notifyListeners();
      }
    } else if (saved) {
      if (stage == null) {
        _stages[ApplicationStage.saved]!.insert(
          0,
          ApplicationsData.fromJob(job, applied: false),
        );
        notifyListeners();
      }
    } else if (stage == ApplicationStage.saved) {
      _stages[ApplicationStage.saved]!.removeWhere((a) => a.id == job.id);
      notifyListeners();
    }
  }
}
