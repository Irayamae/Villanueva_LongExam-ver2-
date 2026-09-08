// lib/screens/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../widgets/custom_info.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final PostService _postService = PostService();

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPosts();
    });
  }

  Future<void> _loadUserPosts() async {
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'No logged-in user was found.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await _postService.getPostsByUserId(
        user.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (
        context,
        authProvider,
        child,
      ) {
        final user = authProvider.user;

        if (user == null) {
          return const Center(
            child: Text(
              'No user session found.',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadUserPosts,
          child: ListView(
            padding: const EdgeInsets.only(
              bottom: 24,
            ),
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 12),
              _buildInformationCard(context, user),
              const SizedBox(height: 12),
              _buildPostsSection(context, user),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Cover photo placeholder
          Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.landscape_outlined,
              size: 50,
              color: theme
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -42),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: _buildAvatar(
                    context,
                    user.image,
                    user.firstName,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '@${user.username}',
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'User ID: ${user.id}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    String image,
    String firstName,
  ) {
    final theme = Theme.of(context);

    if (image.isEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundColor:
            theme.colorScheme.primaryContainer,
        child: Text(
          firstName.isNotEmpty
              ? firstName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: theme
                .colorScheme
                .onPrimaryContainer,
          ),
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: image,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        placeholder: (
          context,
          url,
        ) {
          return CircleAvatar(
            radius: 48,
            child: const CircularProgressIndicator(),
          );
        },
        errorWidget: (
          context,
          url,
          error,
        ) {
          return CircleAvatar(
            radius: 48,
            backgroundColor:
                theme.colorScheme.primaryContainer,
            child: Text(
              firstName.isNotEmpty
                  ? firstName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInformationCard(
    BuildContext context,
    dynamic user,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CustomInfo(
              icon: Icons.email_outlined,
              title: 'Email',
              value: user.email,
            ),
            CustomInfo(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: user.phone,
            ),
            CustomInfo(
              icon: Icons.person_outline,
              title: 'Username',
              value: user.username,
            ),
            CustomInfo(
              icon: Icons.cake_outlined,
              title: 'Age',
              value: user.age.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSection(
    BuildContext context,
    dynamic user,
  ) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load your posts.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadUserPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'You have no posts yet.',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              'Your Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._posts.map(
            (post) {
              return PostCard(
                key: ValueKey(
                  'profile-${post.id}',
                ),
                post: post,
                userName: user.fullName,
                userImage: user.image,
                onTap: () {
                  _openDetails(
                    post,
                    user,
                  );
                },
                onComment: () {
                  _openDetails(
                    post,
                    user,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _openDetails(
    Post post,
    dynamic user,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          post: post,
          userName: user.fullName,
          userImage: user.image,
        ),
      ),
    );
  }
}