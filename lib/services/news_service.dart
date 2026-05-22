import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cache_service.dart';

class SportsNewsArticle {
  const SportsNewsArticle({
    required this.title,
    required this.description,
    required this.source,
    required this.publishedAt,
  });

  final String title;
  final String description;
  final String source;
  final DateTime publishedAt;

  factory SportsNewsArticle.fromJson(Map<String, dynamic> json) {
    return SportsNewsArticle(
      title: json['title']?.toString() ?? 'Untitled news',
      description:
          json['description']?.toString() ?? 'No description available.',
      source: json['source'] is Map
          ? (json['source'] as Map)['name']?.toString() ?? 'Sports News'
          : 'Sports News',
      publishedAt:
          DateTime.tryParse(json['publishedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  static const _newsUrl =
      'https://saurav.tech/NewsAPI/top-headlines/category/sports/in.json';
  static const _cacheKey = 'sports_news_headlines';

  final http.Client _client;
  final CacheService _cache = CacheService();

  Future<List<SportsNewsArticle>> getTeamNews(String teamName) async {
    final allNews = await _fetchHeadlines();
    final query = teamName.trim();
    if (query.isEmpty) {
      return allNews.take(6).toList();
    }

    final candidates = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .toList();

    final filtered = allNews.where((article) {
      final content = '${article.title} ${article.description}'.toLowerCase();
      return candidates.any((keyword) => content.contains(keyword));
    }).toList();

    if (filtered.isEmpty) {
      return allNews.take(6).toList();
    }
    return filtered.take(6).toList();
  }

  Future<List<SportsNewsArticle>> _fetchHeadlines() async {
    final cache = await _cache.load(_cacheKey);
    try {
      final response = await _client
          .get(
            Uri.parse(_newsUrl),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('News API returned ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['articles'] is! List) {
        throw Exception('Unexpected news response structure.');
      }

      final articles = (decoded['articles'] as List)
          .map(
            (item) =>
                SportsNewsArticle.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      await _cache.save(_cacheKey, jsonEncode(decoded));
      return articles;
    } catch (error) {
      if (cache != null) {
        final decoded = jsonDecode(cache.json);
        if (decoded is Map && decoded['articles'] is List) {
          return (decoded['articles'] as List)
              .map(
                (item) =>
                    SportsNewsArticle.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }
      rethrow;
    }
  }
}
