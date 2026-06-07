import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cache_service.dart';

class CommunityApiService {
  CommunityApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://api-koora-production.up.railway.app';
  static const String _postsPath = '/api/community/posts';
  static const String _cacheKey = 'community_remote_posts';

  final http.Client _client;
  final CacheService _cache = CacheService();

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final uri = Uri.parse('$baseUrl$_postsPath');
    try {
      final decoded = await _getJson(uri);
      final posts = _normalizeList(decoded);
      await _cache.save(_cacheKey, jsonEncode(posts));
      return posts;
    } catch (error) {
      final cache = await _cache.load(_cacheKey);
      if (cache != null) {
        final decoded = jsonDecode(cache.json);
        return _normalizeList(decoded);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPost({
    required String user,
    required String message,
    required DateTime timestamp,
  }) async {
    final uri = Uri.parse('$baseUrl$_postsPath');
    final decoded = await _postJson(uri, {
      'user': user,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    });

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    throw Exception('Unexpected response format when creating community post.');
  }

  Future<dynamic> _getJson(Uri uri) async {
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Community posts request failed: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    return _unwrapResponse(decoded);
  }

  Future<dynamic> _postJson(Uri uri, Map<String, dynamic> body) async {
    final response = await _client
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create community post: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    return _unwrapResponse(decoded);
  }

  dynamic _unwrapResponse(dynamic decoded) {
    if (decoded is Map) {
      if (decoded.containsKey('success') && decoded['success'] == false) {
        throw Exception(decoded['message']?.toString() ?? 'Community API returned an error.');
      }
      if (decoded.containsKey('data')) {
        return decoded['data'];
      }
      if (decoded.containsKey('posts')) {
        return decoded['posts'];
      }
    }
    return decoded;
  }

  static List<Map<String, dynamic>> _normalizeList(dynamic data) {
    if (data is List) {
      return data
          .map((item) => item is Map<String, dynamic>
              ? item
              : item is Map
                  ? item.map((key, value) => MapEntry(key.toString(), value))
                  : <String, dynamic>{})
          .where((item) => item.isNotEmpty)
          .toList();
    }
    throw Exception('Expected a list of community posts.');
  }
}
