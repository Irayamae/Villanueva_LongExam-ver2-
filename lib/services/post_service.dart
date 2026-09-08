// lib/services/post_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/post.dart';

class PostService {
  Future<List<Post>> getPosts({
    int limit = 30,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$host/posts?limit=$limit&skip=$skip',
    );

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
        )
        .timeout(apiTimeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List postsJson = data['posts'] ?? [];

      return postsJson
          .map(
            (p) => Post.fromJson(
              p as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load posts: ${response.statusCode}',
    );
  }

  Future<List<Post>> getPostsByUserId(
    int userId, {
    int limit = 30,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$host/posts/user/$userId?limit=$limit&skip=$skip',
    );

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
        )
        .timeout(apiTimeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List postsJson = data['posts'] ?? [];

      return postsJson
          .map(
            (p) => Post.fromJson(
              p as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load user posts: ${response.statusCode}',
    );
  }

  Future<Post> likePost(int postId) async {
    final response = await http
        .post(
          Uri.parse('$host/posts/$postId'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'reactions': {
              'likes': 1,
            },
          }),
        )
        .timeout(apiTimeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Post.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to like post: ${response.statusCode}',
    );
  }
}