import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class ChatMessage {
  const ChatMessage({required this.role, required this.content});
  final String role;
  final String content;
}

class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _token = kGptToken;
  static const String _baseUrl = 'https://models.inference.ai.azure.com';
  static const String _model = 'gpt-4o-mini';

  final http.Client _client;

  Future<String> chat(List<ChatMessage> history) async {
    final body = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a football expert assistant built into the FootbalLive app. '
              'Help users with match analysis, player stats, tactics, predictions, '
              'league standings, and any football-related questions. Be concise and engaging.',
        },
        ...history.map((m) => {'role': m.role, 'content': m.content}),
      ],
      'max_tokens': 1024,
    });

    late final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    } catch (e) {
      throw Exception('Failed to connect to AI: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('AI error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    return (choices[0] as Map<String, dynamic>)['message']['content'] as String;
  }

  Future<String> analyzeMatch({
    required String homeTeam,
    required String awayTeam,
    required String score,
    required String status,
    required String league,
    required List<String> events,
  }) async {
    final eventsText = events.isEmpty ? 'No events recorded yet.' : events.join('\n');
    final prompt = '''
Analyze this football match for me:

League: $league
Match: $homeTeam vs $awayTeam
Score: $score
Status: $status

Match Events:
$eventsText

Give me a short, punchy analysis — key moments, team performance, and a prediction if the match is still live.
''';
    return chat([ChatMessage(role: 'user', content: prompt)]);
  }
}
