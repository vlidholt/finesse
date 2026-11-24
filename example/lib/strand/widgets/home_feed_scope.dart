import 'package:example/strand/data.dart';
import 'package:example/strand/data/home_data.dart';
import 'package:flutter/widgets.dart';

/// The home feed's local state: which list is showing, how it is sorted, and
/// what the signed-in user has liked and whom they follow.
///
/// It lives above the whole screen because the pieces depend on each other:
/// following an author from a post adds that author's posts to the
/// "Following" list, and a like has to survive its card moving when the list
/// is re-sorted. Nothing here is persisted.
class HomeFeedModel extends ChangeNotifier {
  HomeFeedModel()
    : _liked = {
        for (final post in HomeData.posts)
          if (post.liked) post.id,
      },
      _following = {
        for (final post in HomeData.posts)
          if (!post.followable) post.author.name,
      };

  final Set<String> _liked;
  final Set<String> _following;

  HomeFeed _feed = HomeFeed.forYou;
  FeedSort _sort = FeedSort.top;

  /// The list the segmented control has selected.
  HomeFeed get feed => _feed;
  set feed(HomeFeed value) {
    if (_feed == value) return;
    _feed = value;
    notifyListeners();
  }

  /// The order the "Sort by" menu has selected.
  FeedSort get sort => _sort;
  set sort(FeedSort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
  }

  /// The posts of [feed], in [sort] order.
  ///
  /// * For you — every post, in the designed order.
  /// * Following — posts by the people the user follows.
  /// * Trending — every post, the most reacted-to first.
  ///
  /// "Recent" overrides either order with newest first.
  List<FeedPost> get posts {
    final posts = [
      for (final post in HomeData.posts)
        if (_feed != HomeFeed.following || isFollowing(post.author)) post,
    ];
    if (_sort == FeedSort.recent) {
      posts.sort((a, b) => a.hoursAgo.compareTo(b.hoursAgo));
    } else if (_feed == HomeFeed.trending) {
      posts.sort((a, b) => reactionCount(b).compareTo(reactionCount(a)));
    }
    return posts;
  }

  bool isLiked(FeedPost post) => _liked.contains(post.id);

  void toggleLike(FeedPost post) {
    if (!_liked.remove(post.id)) _liked.add(post.id);
    notifyListeners();
  }

  /// How many people other than the one the summary names have reacted:
  /// the "214" of "Sara Lindqvist and 214 others", following the user's own
  /// like.
  int otherReactions(FeedPost post) =>
      post.otherReactions + (isLiked(post) ? 1 : 0) - (post.liked ? 1 : 0);

  /// Every reaction on [post], the number beside the phone's like button.
  int reactionCount(FeedPost post) => otherReactions(post) + 1;

  bool isFollowing(Person person) => _following.contains(person.name);

  void toggleFollow(Person person) {
    if (!_following.remove(person.name)) _following.add(person.name);
    notifyListeners();
  }
}

/// Provides the [HomeFeedModel] to the home screen's widgets and rebuilds
/// those that read it when it changes.
class HomeFeedScope extends InheritedNotifier<HomeFeedModel> {
  const HomeFeedScope({
    required HomeFeedModel model,
    required super.child,
    super.key,
  }) : super(notifier: model);

  static HomeFeedModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HomeFeedScope>();
    assert(scope != null, 'No HomeFeedScope above this widget.');
    return scope!.notifier!;
  }
}
