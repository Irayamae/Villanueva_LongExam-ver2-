// lib/widgets/post_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import 'custom_inkwell_button.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String userName;
  final String? userImage;
  final VoidCallback? onComment;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.userName,
    this.userImage,
    this.onComment,
    this.onTap,
    this.onLike,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _likeCount;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.likes != widget.post.likes) {
      _likeCount = widget.post.likes;
    }
  }

  void _handleLike() {
    setState(() {
      if (_isLiked) {
        _likeCount--;
        _isLiked = false;
      } else {
        _likeCount++;
        _isLiked = true;
      }
    });

    widget.onLike?.call();
  }

  String get _initial {
    if (widget.userName.trim().isEmpty) {
      return '?';
    }

    return widget.userName.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // User header
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    _buildAvatar(theme),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Post #${widget.post.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_horiz,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // Post text
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Text(
                  widget.post.body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // Placeholder media area
              // --------------------------------------------------
              _buildMediaPlaceholder(theme),

              // --------------------------------------------------
              // Reactions
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thumb_up,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_likeCount',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // --------------------------------------------------
              // Action buttons
              // --------------------------------------------------
              Row(
                children: [
                  CustomInkWellButton(
                    icon: _isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    label: 'Like',
                    isActive: _isLiked,
                    onTap: _handleLike,
                  ),
                  CustomInkWellButton(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comment',
                    onTap: widget.onComment,
                  ),
                  const CustomInkWellButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final image = widget.userImage;

    if (image == null || image.trim().isEmpty) {
      return CircleAvatar(
        radius: 21,
        backgroundColor:
            theme.colorScheme.primary.withValues(alpha: 0.12),
        child: Text(
          _initial,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: image,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return CircleAvatar(
            radius: 21,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorWidget: (context, url, error) {
          return CircleAvatar(
            radius: 21,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              _initial,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 150,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 42,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 6),
          Text(
            'Post Media',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}