// lib/providers/post_provider.dart

import 'package:flutter/foundation.dart';

import '../models/post.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => List.unmodifiable(_posts);

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadPosts({
    int limit = 30,
    int skip = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postService.getPosts(
        limit: limit,
        skip: skip,
      );
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost(Post post) async {
    final index = _posts.indexWhere(
      (item) => item.id == post.id,
    );

    if (index == -1) {
      return;
    }

    // Optimistic UI update.
    final updatedPost = post.copyWith(
      likes: post.likes + 1,
    );

    _posts[index] = updatedPost;
    notifyListeners();

    try {
      await _postService.likePost(post.id);
    } catch (_) {
      // DummyJSON mutations are simulated.
      // Keep the UI update so the like remains visible.
    }
  }

  void clear() {
    _posts = [];
    _error = null;
    notifyListeners();
  }
}