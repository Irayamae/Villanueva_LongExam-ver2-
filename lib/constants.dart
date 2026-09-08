// lib/constants.dart

const String host = 'https://dummyjson.com';

const String appName = 'Facebook Replication';

const String authLoginEndpoint = '$host/auth/login';

const String authMeEndpoint = '$host/auth/me';

const String postsEndpoint = '$host/posts';

const String commentsEndpoint = '$host/comments';

const String defaultProfileImage =
    'https://dummyjson.com/image/150x150';

const String defaultPostImage =
    'https://dummyjson.com/image/600x300';

const Duration apiTimeout = Duration(seconds: 15);