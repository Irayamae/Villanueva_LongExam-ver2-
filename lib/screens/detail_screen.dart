import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../services/comment_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textformfield.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  final String userName;
  final String? userImage;

  const DetailScreen({
    super.key,
    required this.post,
    required this.userName,
    this.userImage,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CommentService _commentService = CommentService();

  final TextEditingController _commentController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  List<Comment> _comments = [];

  bool _isLoadingComments = true;
  bool _isAddingComment = false;
  bool _isLiked = false;

  late int _likeCount;

  String? _error;

  String get _likeKey =>
      'liked_post_${widget.post.id}';

  String get _likeCountKey =>
      'like_count_post_${widget.post.id}';

  String get _commentKey =>
    'local_comments_post_${widget.post.id}';

  @override
  void initState() {
    super.initState();

    _likeCount = widget.post.likes;

    _loadSavedInteractions();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedInteractions() async {
  final preferences =
      await SharedPreferences.getInstance();

  final savedLiked =
      preferences.getBool(_likeKey);

  final savedLikeCount =
      preferences.getInt(_likeCountKey);

  debugPrint(
    'LIKE LOADED: post=${widget.post.id}, '
    'liked=$savedLiked, count=$savedLikeCount',
  );

  if (!mounted) {
    return;
  }

  setState(() {
    _isLiked = savedLiked ?? false;
    _likeCount =
        savedLikeCount ?? widget.post.likes;
  });

  await _loadComments();
}

  Future<List<Comment>> _getSavedComments() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedData =
        preferences.getString(_commentKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(savedData);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Comment.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveComments(
    List<Comment> comments,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final data = comments
        .map((comment) => comment.toJson())
        .toList();

    await preferences.setString(
      _commentKey,
      jsonEncode(data),
    );
  }

  Future<void> _loadComments() async {
  if (mounted) {
    setState(() {
      _isLoadingComments = true;
      _error = null;
    });
  }

  final savedComments =
      await _getSavedComments();

  try {
    final apiComments =
        await _commentService.getCommentsByPostId(
      widget.post.id,
    );

    final mergedComments =
        <Comment>[];

    // Keep all locally added comments.
    mergedComments.addAll(savedComments);

    // Add API comments that are not already
    // represented by a locally added comment.
    for (final apiComment in apiComments) {
      final alreadySaved =
          savedComments.any(
        (savedComment) =>
            savedComment.userId ==
                apiComment.userId &&
            savedComment.body.trim() ==
                apiComment.body.trim(),
      );

      if (!alreadySaved) {
        mergedComments.add(apiComment);
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _comments = mergedComments;
      _isLoadingComments = false;
    });
  } catch (e) {
    if (!mounted) {
      return;
    }

    setState(() {
      _comments = savedComments;
      _isLoadingComments = false;

      if (savedComments.isEmpty) {
        _error = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      }
    });
  }
}

  Future<void> _toggleLike() async {
  final preferences =
      await SharedPreferences.getInstance();

  final newLikedState = !_isLiked;

  final newLikeCount = newLikedState
      ? _likeCount + 1
      : (_likeCount > 0 ? _likeCount - 1 : 0);

  await preferences.setBool(
    _likeKey,
    newLikedState,
  );

  await preferences.setInt(
    _likeCountKey,
    newLikeCount,
  );

  if (!mounted) {
    return;
  }

  setState(() {
    _isLiked = newLikedState;
    _likeCount = newLikeCount;
  });

  debugPrint(
    'LIKE SAVED: post=${widget.post.id}, '
    'liked=$newLikedState, count=$newLikeCount',
  );
}

  Future<void> _addComment() async {
  final body =
      _commentController.text.trim();

  if (body.isEmpty) {
    return;
  }

  final user =
      context.read<AuthProvider>().user;

  if (user == null) {
    return;
  }

  setState(() {
    _isAddingComment = true;
  });

  try {
    final comment =
        await _commentService.addComment(
      postId: widget.post.id,
      userId: user.id,
      body: body,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _comments.insert(0, comment);
      _commentController.clear();
      _isAddingComment = false;
    });

    // Save the complete local comment list.
    await _saveComments(_comments);

    _scrollToComments();
  } catch (e) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isAddingComment = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to add comment: '
          '${e.toString().replaceFirst(
            'Exception: ',
            '',
          )}',
        ),
      ),
    );
  }
}

  void _scrollToComments() {
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadComments,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 20,
                ),
                children: [
                  _buildPost(context),
                  const SizedBox(height: 16),
                  _buildCommentsHeader(context),
                  _buildComments(context),
                ],
              ),
            ),
          ),
          _buildCommentComposer(context),
        ],
      ),
    );
  }

  Widget _buildPost(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(context),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Post #${widget.post.id}',
                        style: theme
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.post.body,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 50,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 18,
                  color: theme
                      .colorScheme
                      .primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_likeCount likes',
                ),
                const Spacer(),
                Text(
                  '${_comments.length} comments',
                ),
              ],
            ),
            const Divider(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _toggleLike,
                    icon: Icon(
                      _isLiked
                          ? Icons.thumb_up
                          : Icons
                              .thumb_up_outlined,
                      color: _isLiked
                          ? theme
                              .colorScheme
                              .primary
                          : null,
                    ),
                    label: Text(
                      'Like',
                      style: TextStyle(
                        color: _isLiked
                            ? theme
                                .colorScheme
                                .primary
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _scrollToComments,
                    icon: const Icon(
                      Icons
                          .mode_comment_outlined,
                    ),
                    label: const Text(
                      'Comment',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.userImage == null ||
        widget.userImage!.isEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor:
            theme.colorScheme.primaryContainer,
        child: Text(
          widget.userName.isNotEmpty
              ? widget.userName[0].toUpperCase()
              : '?',
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.userImage!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (
          context,
          url,
        ) {
          return const CircleAvatar(
            radius: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        },
        errorWidget: (
          context,
          url,
          error,
        ) {
          return CircleAvatar(
            radius: 22,
            backgroundColor:
                theme.colorScheme.primaryContainer,
            child: Text(
              widget.userName.isNotEmpty
                  ? widget.userName[0]
                      .toUpperCase()
                  : '?',
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentsHeader(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(${_comments.length})',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildComments(
    BuildContext context,
  ) {
    if (_isLoadingComments) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.comment_outlined,
              size: 48,
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load comments.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadComments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text(
            'No comments yet. Be the first to comment!',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Column(
        children: _comments.map(
          (comment) {
            return _buildComment(
              context,
              comment,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildComment(
    BuildContext context,
    Comment comment,
  ) {
    final theme = Theme.of(context);

    final currentUser =
        context.read<AuthProvider>().user;

    final isCurrentUser =
        currentUser != null &&
        comment.userId == currentUser.id;

    final displayName = isCurrentUser
        ? currentUser.fullName
        : (comment.userFullName.isEmpty
            ? comment.username
            : comment.userFullName);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor:
                theme.colorScheme.secondaryContainer,
            child: Text(
              displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: theme.colorScheme
                    .onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    comment.body,
                    style: const TextStyle(
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentComposer(
    BuildContext context,
  ) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, -2),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: _commentController,
                label: 'Comment',
                hintText: 'Write a comment...',
                prefixIcon:
                    Icons.mode_comment_outlined,
                keyboardType:
                    TextInputType.multiline,
                maxLines: 3,
                textInputAction:
                    TextInputAction.newline,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              height: 52,
              child: CustomButton(
                text: '',
                icon: Icons.send,
                isLoading: _isAddingComment,
                onPressed: _addComment,
                borderRadius: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}