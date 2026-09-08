// lib/models/comment.dart

class Comment {
  final int id;
  final int userId;
  final String body;
  final String username;
  final String userFullName;

  const Comment({
    required this.id,
    required this.userId,
    required this.body,
    required this.username,
    required this.userFullName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return Comment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: user is Map<String, dynamic>
          ? (user['id'] as num?)?.toInt() ?? 0
          : (json['userId'] as num?)?.toInt() ?? 0,
      body: json['body']?.toString() ?? '',
      username: user is Map<String, dynamic>
          ? user['username']?.toString() ?? 'User'
          : json['username']?.toString() ?? 'User',
      userFullName: user is Map<String, dynamic>
          ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()
          : json['userFullName']?.toString() ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'body': body,
      'username': username,
      'userFullName': userFullName,
    };
  }
}