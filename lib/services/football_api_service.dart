import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/league_models.dart';
import '../models/match_models.dart';
import '../models/standing_models.dart';
import '../models/team_models.dart';

class FootballApiService {
  FootballApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://api-koora-production.up.railway.app';

  final http.Client _client;

  Future<List<FootballMatch>> getLiveMatches() async {
    final response = await _get('/api/football/live',
        (data) => _parseList(data, FootballMatch.fromJson));
    return response.data;
  }

  Future<List<FootballMatch>> getTodayMatches() async {
    final response = await _get('/api/football/today',
        (data) => _parseList(data, FootballMatch.fromJson));
    return response.data;
  }

  Future<List<FootballMatch>> getYesterdayMatches() async {
    final response = await _get('/api/football/yesterday',
        (data) => _parseList(data, FootballMatch.fromJson));
    return response.data;
  }

  Future<List<FootballMatch>> getTomorrowMatches() async {
    final response = await _get('/api/football/tomorrow',
        (data) => _parseList(data, FootballMatch.fromJson));
    return response.data;
  }

  Future<List<TeamItem>> getTeams() async {
    final response = await _get(
        '/api/football/teams', (data) => _parseList(data, TeamItem.fromJson));
    return response.data;
  }

  Future<List<StandingGroup>> getStandings() async {
    final response = await _get('/api/football/standings',
        (data) => _parseList(data, StandingGroup.fromJson));
    return response.data;
  }

  Future<List<LeagueItem>> getLeagues() async {
    final response = await _get('/api/football/leagues',
        (data) => _parseList(data, LeagueItem.fromJson));
    return response.data;
  }

  Future<ApiResponse<T>> _get<T>(String path, T Function(dynamic data) parser) async {
    final uri = Uri.parse('$baseUrl$path');
    late final http.Response response;
    try {
      response = await _client.get(uri, headers: const {'Accept': 'application/json'});
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
      return apiResponse;
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
