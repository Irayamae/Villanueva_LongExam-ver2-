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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (
        context,
        authProvider,
        child,
      ) {
        final user = authProvider.user;

        if (user == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 54,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No user session found.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadUserPosts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 32,
            ),
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 18),
              _buildInformationCard(context, user),
              const SizedBox(height: 22),
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

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // =====================================================
            // COVER PHOTO
            // =====================================================
            Container(
              height: 175,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: Stack(
                  children: [
                    // Background glow
                    Positioned(
                      top: -55,
                      left: -45,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: 0.10,
                          ),
                        ),
                      ),
                    ),

                    // Background glow
                    Positioned(
                      top: -50,
                      right: -35,
                      child: Container(
                        width: 145,
                        height: 145,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                    ),

                    // Sun
                    Positioned(
                      top: 22,
                      right: 42,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: 0.22,
                          ),
                        ),
                      ),
                    ),

                    // Back mountain
                    Positioned(
                      left: -35,
                      bottom: 5,
                      child: Transform.rotate(
                        angle: -0.04,
                        child: Container(
                          width: 245,
                          height: 105,
                          decoration: BoxDecoration(
                            color: theme.colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.42),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(140),
                              topRight: Radius.circular(160),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Middle mountain
                    Positioned(
                      left: 105,
                      bottom: -25,
                      child: Transform.rotate(
                        angle: 0.03,
                        child: Container(
                          width: 235,
                          height: 125,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.55),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(160),
                              topRight: Radius.circular(130),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Front mountain
                    Positioned(
                      right: -65,
                      bottom: -40,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: Container(
                          width: 270,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.72),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(170),
                              topRight: Radius.circular(120),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Small decorative dots
                    Positioned(
                      top: 34,
                      left: 52,
                      child: _buildCoverDot(
                        theme,
                        5,
                      ),
                    ),

                    Positioned(
                      top: 72,
                      left: 92,
                      child: _buildCoverDot(
                        theme,
                        3,
                      ),
                    ),

                    Positioned(
                      top: 48,
                      right: 115,
                      child: _buildCoverDot(
                        theme,
                        4,
                      ),
                    ),

                    // Decorative birds
                    Positioned(
                      top: 62,
                      right: 82,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.white.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 72,
                      right: 65,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 15,
                        color: Colors.white.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =====================================================
            // PROFILE CIRCLE
            // =====================================================
            Positioned(
              bottom: -58,
              child: Container(
                width: 124,
                height: 124,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 22,
                      spreadRadius: 2,
                      offset: const Offset(0, 9),
                      color: Colors.black.withValues(
                        alpha: 0.32,
                      ),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: _buildAvatar(
                    context,
                    user.image,
                    user.firstName,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 72),

        // =======================================================
        // NAME
        // =======================================================
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        // =======================================================
        // USERNAME
        // =======================================================
        Text(
          '@${user.username}',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 9),

        // =======================================================
        // USER ID
        // =======================================================
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline,
                size: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'User ID: ${user.id}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverDot(
    ThemeData theme,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }

  Widget _buildAvatar(
  BuildContext context,
  String image,
  String firstName,
) {
  final theme = Theme.of(context);

  return Stack(
    clipBehavior: Clip.none,
    children: [
      // Profile avatar
      Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF18202B),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.person_rounded,
            size: 68,
            color: Colors.white,
          ),
        ),
      ),

      // Blue outer accent
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),

      // Online indicator
      Positioned(
        right: -2,
        bottom: 2,
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CD964),
            border: Border.all(
              color: theme.colorScheme.surface,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildInformationCard(
    BuildContext context,
    dynamic user,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant
                .withValues(alpha: 0.45),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            17,
            17,
            17,
            10,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 19,
                      color:
                          theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Divider(height: 1),

              const SizedBox(height: 5),

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
      ),
    );
  }

  Widget _buildPostsSection(
    BuildContext context,
    dynamic user,
  ) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 42,
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading your posts...',
              style: TextStyle(
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.error
                  .withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_outlined,
                  size: 30,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Unable to load your posts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loadUserPosts,
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                ),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 42,
          horizontal: 24,
        ),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: theme.colorScheme
                    .surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article_outlined,
                size: 30,
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'You have no posts yet.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 2,
              right: 2,
              bottom: 11,
            ),
            child: Row(
              children: [
                const Text(
                  'Your Posts',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary
                        .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${_posts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
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