// lib/screens/newsfeed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() =>
      _NewsfeedScreenState();
}

class _NewsfeedScreenState
    extends State<NewsfeedScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PostProvider>();

      if (provider.posts.isEmpty &&
          !provider.isLoading) {
        provider.loadPosts();
      }
    });
  }

  Future<void> _refresh() async {
    await context.read<PostProvider>().loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (
        context,
        postProvider,
        child,
      ) {
        if (postProvider.isLoading &&
            postProvider.posts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (postProvider.error != null &&
            postProvider.posts.isEmpty) {
          return _buildError(
            context,
            postProvider.error!,
          );
        }

        if (postProvider.posts.isEmpty) {
          return _buildEmpty(context);
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              24,
            ),
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];

              return PostCard(
                key: ValueKey(post.id),
                post: post,
                userName: 'User ${post.userId}',
                userImage:
                    'https://dummyjson.com/icon/'
                    '${post.userId}/128',
                onLike: () {
                  _handleLike(post);
                },
                onComment: () {
                  _openDetails(post);
                },
                onTap: () {
                  _openDetails(post);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _handleLike(Post post) {
    context.read<PostProvider>().likePost(post);
  }

  void _openDetails(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          post: post,
          userName: 'User ${post.userId}',
          userImage:
              'https://dummyjson.com/icon/'
              '${post.userId}/128',
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String error,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 60,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load the feed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                context
                    .read<PostProvider>()
                    .loadPosts();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 60,
          ),
          SizedBox(height: 12),
          Text(
            'No posts available.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}