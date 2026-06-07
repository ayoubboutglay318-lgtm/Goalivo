import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/league_models.dart';
import '../models/match_models.dart';
import '../models/standing_models.dart';
import '../models/team_models.dart';
import 'cache_service.dart';

class FootballApiService extends ChangeNotifier {
  FootballApiService({http.Client? client})
      : _client = client ?? http.Client();

  static const String baseUrl = 'https://api-koora-production.up.railway.app';

  final http.Client _client;
  final CacheService _cache = CacheService();

  bool _isOffline = false;
  DateTime? _offlineSince;

  bool get isOffline => _isOffline;
  DateTime? get offlineSince => _offlineSince;

  void _setOffline(bool offline) {
    if (_isOffline == offline) return;
    _isOffline = offline;
    _offlineSince = offline ? DateTime.now() : null;
    notifyListeners();
  }

  Future<List<FootballMatch>> getLiveMatches() async =>
      _cachedGet('live', '/api/football/live', FootballMatch.fromJson);

  Future<List<FootballMatch>> getTodayMatches() async =>
      _cachedGet('today', '/api/football/today', FootballMatch.fromJson);

  Future<List<FootballMatch>> getYesterdayMatches() async =>
      _cachedGet('yesterday', '/api/football/yesterday', FootballMatch.fromJson);

  Future<List<FootballMatch>> getTomorrowMatches() async =>
      _cachedGet('tomorrow', '/api/football/tomorrow', FootballMatch.fromJson);

  Future<List<FootballMatch>> getMatchesByDate(DateTime date) async {
    final d = date.toLocal();
    final now = DateTime.now().toLocal();
    final offset = DateTime(d.year, d.month, d.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (offset == 0) return getTodayMatches();
    if (offset == -1) return getYesterdayMatches();
    if (offset == 1) return getTomorrowMatches();
    final formatted = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    try {
      return await _cachedGet('date_$formatted', '/api/football/date/$formatted', FootballMatch.fromJson);
    } catch (_) {
      return [];
    }
  }

  Future<List<TeamItem>> getTeams() async =>
      _cachedGet('teams', '/api/football/teams', TeamItem.fromJson);

  Future<List<StandingGroup>> getStandings() async =>
      _cachedGet('standings', '/api/football/standings', StandingGroup.fromJson);

  Future<List<LeagueItem>> getLeagues() async =>
      _cachedGet('leagues', '/api/football/leagues', LeagueItem.fromJson);

  Future<List<MatchTeamStats>> getMatchStats(int fixtureId) async {
    try {
      final uri = Uri.parse(
          'https://$_rapidApiHost/v3/fixtures/statistics?fixture=$fixtureId');
      final response = await _client.get(uri, headers: {
        'x-rapidapi-key': _rapidApiKey,
        'x-rapidapi-host': _rapidApiHost,
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      final list = (decoded['response'] as List<dynamic>?) ?? [];
      return list.map((e) => MatchTeamStats.fromJson(_asMap(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static const _rapidApiKey = '1ace74ec80msh32795e21bd8a5c7p1880cbjsn29d97a4805e7';
  static const _rapidApiHost = 'api-football-v1.p.rapidapi.com';

  Future<List<MatchLineup>> getLineups(int fixtureId) async {
    try {
      final uri = Uri.parse(
          'https://$_rapidApiHost/v3/fixtures/lineups?fixture=$fixtureId');
      debugPrint('[LINEUP] Fetching lineups for fixture: $fixtureId from $uri');
      final response = await _client.get(uri, headers: {
        'x-rapidapi-key': _rapidApiKey,
        'x-rapidapi-host': _rapidApiHost,
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      debugPrint('[LINEUP] Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('[LINEUP] Error response: ${response.body.substring(0, 500)}');
        return [];
      }

      final decoded = jsonDecode(response.body);
      debugPrint('[LINEUP] Response keys: ${decoded.keys}');

      final list = (decoded['response'] as List<dynamic>?) ?? [];
      debugPrint('[LINEUP] Got ${list.length} lineups from API');

      final lineups = <MatchLineup>[];
      for (final item in list) {
        try {
          final lineup = MatchLineup.fromJson(_asMap(item));
          lineups.add(lineup);
          debugPrint('[LINEUP] Team: ${lineup.team.name}, Start XI: ${lineup.startXI.length}, Subs: ${lineup.substitutes.length}');
          for (final p in lineup.startXI.take(3)) {
            debugPrint('[LINEUP]   - ${p.name} (ID: ${p.id}, Photo: ${p.photoUrl})');
          }
        } catch (e) {
          debugPrint('[LINEUP] Error parsing lineup: $e');
        }
      }
      return lineups;
    } catch (e) {
      debugPrint('[LINEUP] Exception: $e');
      return [];
    }
  }

  Future<List<T>> _cachedGet<T>(
    String cacheKey,
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final result = await _getRaw(path, (data) => _parseList(data, fromJson));
      await _cache.save(cacheKey, jsonEncode(result.rawData));
      _setOffline(false);
      return result.data;
    } catch (_) {
      final cached = await _cache.load(cacheKey);
      if (cached != null) {
        _setOffline(true);
        final decoded = jsonDecode(cached.json) as List<dynamic>;
        return decoded.map((item) => fromJson(_asMap(item))).toList();
      }
      _setOffline(true);
      rethrow;
    }
  }

  Future<_RawResult<T>> _getRaw<T>(String path, T Function(dynamic data) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }

    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode}) for $path: ${response.body}');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Received malformed JSON from $path.');
    }

    if (decoded is! Map) throw Exception('Unexpected response format from $path.');

    final json = _asMap(decoded);
    try {
      final apiResponse = ApiResponse<T>.fromJson(json, parser);
      if (!apiResponse.success) {
        throw Exception(apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'API returned an unsuccessful response for $path.');
      }
      return _RawResult(apiResponse.data, json['data']);
    } on FormatException catch (error) {
      throw Exception('Invalid API envelope from $path: ${error.message}');
    } catch (error) {
      throw Exception('Failed to parse response from $path: $error');
    }
  }

  static List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is! List) throw const FormatException('Expected a list in the response data.');
    return data.map((dynamic item) => fromJson(_asMap(item))).toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    throw const FormatException('Expected a JSON object.');
  }
}

class _RawResult<T> {
  final T data;
  final dynamic rawData;
  _RawResult(this.data, this.rawData);
}
