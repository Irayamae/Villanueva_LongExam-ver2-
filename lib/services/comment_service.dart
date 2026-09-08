// lib/services/comment_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  Future<List<Comment>> getCommentsByPostId(
    int postId,
  ) async {
    final response = await http
        .get(
          Uri.parse('$host/comments/post/$postId'),
          headers: {
            'Content-Type': 'application/json',
          },
        )
        .timeout(apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final List commentsJson = data['comments'] ?? [];

      return commentsJson
          .map(
            (comment) => Comment.fromJson(
              comment as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load comments: ${response.statusCode}',
    );
  }

  Future<Comment> addComment({
    required int postId,
    required int userId,
    required String body,
  }) async {
    final response = await http
        .post(
          Uri.parse('$host/comments/add'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'body': body,
            'postId': postId,
            'userId': userId,
          }),
        )
        .timeout(apiTimeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Comment.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to add comment: ${response.statusCode}',
    );
  }
}