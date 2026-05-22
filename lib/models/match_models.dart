class FootballMatch {
  const FootballMatch({
    required this.fixture,
    required this.league,
    required this.teams,
    required this.goals,
    this.score,
    this.events = const [],
    this.streamUrl,
  });

  final MatchFixture fixture;
  final MatchLeague league;
  final MatchTeams teams;
  final MatchGoals goals;
  final MatchScore? score;
  final List<MatchEvent> events;
  final String? streamUrl;

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    return FootballMatch(
      fixture: MatchFixture.fromJson(_asMap(json['fixture'])),
      league: MatchLeague.fromJson(_asMap(json['league'])),
      teams: MatchTeams.fromJson(_asMap(json['teams'])),
      goals: MatchGoals.fromJson(_asMap(json['goals'])),
      score: json['score'] is Map<String, dynamic>
          ? MatchScore.fromJson(_asMap(json['score']))
          : null,
      events: _asList(
        json['events'],
      ).map((event) => MatchEvent.fromJson(_asMap(event))).toList(),
      streamUrl: json['stream'] != null
          ? (json['stream'] is Map
                ? json['stream']['url']?.toString()
                : json['stream']?.toString())
          : null,
    );
  }
}

class MatchFixture {
  const MatchFixture({
    required this.id,
    this.referee,
    this.timezone,
    this.date,
    this.timestamp,
    this.periods,
    this.venue,
    this.status,
  });

  final int? id;
  final String? referee;
  final String? timezone;
  final DateTime? date;
  final int? timestamp;
  final MatchPeriods? periods;
  final MatchVenue? venue;
  final MatchStatus? status;

  factory MatchFixture.fromJson(Map<String, dynamic> json) {
    return MatchFixture(
      id: _toInt(json['id']),
      referee: json['referee']?.toString(),
      timezone: json['timezone']?.toString(),
      date: _toDateTime(json['date']),
      timestamp: _toInt(json['timestamp']),
      periods: json['periods'] is Map<String, dynamic>
          ? MatchPeriods.fromJson(_asMap(json['periods']))
          : null,
      venue: json['venue'] is Map<String, dynamic>
          ? MatchVenue.fromJson(_asMap(json['venue']))
          : null,
      status: json['status'] is Map<String, dynamic>
          ? MatchStatus.fromJson(_asMap(json['status']))
          : null,
    );
  }
}

class MatchPeriods {
  const MatchPeriods({this.first, this.second});
  final int? first;
  final int? second;

  factory MatchPeriods.fromJson(Map<String, dynamic> json) {
    return MatchPeriods(
      first: _toInt(json['first']),
      second: _toInt(json['second']),
    );
  }
}

class MatchVenue {
  const MatchVenue({this.id, this.name, this.city});
  final int? id;
  final String? name;
  final String? city;

  factory MatchVenue.fromJson(Map<String, dynamic> json) {
    return MatchVenue(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      city: json['city']?.toString(),
    );
  }
}

class MatchStatus {
  const MatchStatus({this.long, this.short, this.elapsed, this.extra});
  final String? long;
  final String? short;
  final int? elapsed;
  final int? extra;

  factory MatchStatus.fromJson(Map<String, dynamic> json) {
    return MatchStatus(
      long: json['long']?.toString(),
      short: json['short']?.toString(),
      elapsed: _toInt(json['elapsed']),
      extra: _toInt(json['extra']),
    );
  }
}

class MatchLeague {
  const MatchLeague({
    this.id,
    this.name,
    this.country,
    this.logo,
    this.flag,
    this.season,
    this.round,
  });
  final int? id;
  final String? name;
  final String? country;
  final String? logo;
  final String? flag;
  final int? season;
  final String? round;

  factory MatchLeague.fromJson(Map<String, dynamic> json) {
    return MatchLeague(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      country: json['country']?.toString(),
      logo: json['logo']?.toString(),
      flag: json['flag']?.toString(),
      season: _toInt(json['season']),
      round: json['round']?.toString(),
    );
  }
}

class MatchTeams {
  const MatchTeams({required this.home, required this.away});
  final MatchTeam home;
  final MatchTeam away;

  factory MatchTeams.fromJson(Map<String, dynamic> json) {
    return MatchTeams(
      home: MatchTeam.fromJson(_asMap(json['home'])),
      away: MatchTeam.fromJson(_asMap(json['away'])),
    );
  }
}

class MatchTeam {
  const MatchTeam({this.id, this.name, this.logo, this.winner});
  final int? id;
  final String? name;
  final String? logo;
  final bool? winner;

  factory MatchTeam.fromJson(Map<String, dynamic> json) {
    return MatchTeam(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
      winner: _toBool(json['winner']),
    );
  }
}

class MatchGoals {
  const MatchGoals({this.home, this.away});
  final int? home;
  final int? away;

  factory MatchGoals.fromJson(Map<String, dynamic> json) {
    return MatchGoals(home: _toInt(json['home']), away: _toInt(json['away']));
  }
}

class MatchScore {
  const MatchScore({
    this.halftime,
    this.fulltime,
    this.extratime,
    this.penalty,
  });
  final MatchGoals? halftime;
  final MatchGoals? fulltime;
  final MatchGoals? extratime;
  final MatchGoals? penalty;

  factory MatchScore.fromJson(Map<String, dynamic> json) {
    return MatchScore(
      halftime: json['halftime'] is Map
          ? MatchGoals.fromJson(_asMap(json['halftime']))
          : null,
      fulltime: json['fulltime'] is Map
          ? MatchGoals.fromJson(_asMap(json['fulltime']))
          : null,
      extratime: json['extratime'] is Map
          ? MatchGoals.fromJson(_asMap(json['extratime']))
          : null,
      penalty: json['penalty'] is Map
          ? MatchGoals.fromJson(_asMap(json['penalty']))
          : null,
    );
  }
}

class MatchEvent {
  const MatchEvent({
    this.time,
    this.team,
    this.player,
    this.assist,
    this.type,
    this.detail,
    this.comments,
  });
  final MatchEventTime? time;
  final MatchEventTeam? team;
  final MatchEventPerson? player;
  final MatchEventPerson? assist;
  final String? type;
  final String? detail;
  final String? comments;

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    return MatchEvent(
      time: json['time'] is Map
          ? MatchEventTime.fromJson(_asMap(json['time']))
          : null,
      team: json['team'] is Map
          ? MatchEventTeam.fromJson(_asMap(json['team']))
          : null,
      player: json['player'] is Map
          ? MatchEventPerson.fromJson(_asMap(json['player']))
          : null,
      assist: json['assist'] is Map
          ? MatchEventPerson.fromJson(_asMap(json['assist']))
          : null,
      type: json['type']?.toString(),
      detail: json['detail']?.toString(),
      comments: json['comments']?.toString(),
    );
  }
}

class MatchEventTime {
  const MatchEventTime({this.elapsed, this.extra});
  final int? elapsed;
  final int? extra;

  factory MatchEventTime.fromJson(Map<String, dynamic> json) {
    return MatchEventTime(
      elapsed: _toInt(json['elapsed']),
      extra: _toInt(json['extra']),
    );
  }
}

class MatchEventTeam {
  const MatchEventTeam({this.id, this.name, this.logo});
  final int? id;
  final String? name;
  final String? logo;

  factory MatchEventTeam.fromJson(Map<String, dynamic> json) {
    return MatchEventTeam(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
    );
  }
}

class MatchEventPerson {
  const MatchEventPerson({this.id, this.name});
  final int? id;
  final String? name;

  factory MatchEventPerson.fromJson(Map<String, dynamic> json) {
    return MatchEventPerson(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

class MatchTeamStats {
  const MatchTeamStats({required this.team, this.stats = const []});
  final MatchTeam team;
  final List<MatchStatItem> stats;

  factory MatchTeamStats.fromJson(Map<String, dynamic> json) {
    return MatchTeamStats(
      team: json['team'] is Map ? MatchTeam.fromJson(_asMap(json['team'])) : const MatchTeam(),
      stats: _asList(json['statistics']).map((s) => MatchStatItem.fromJson(_asMap(s))).toList(),
    );
  }

  String? get(String type) {
    for (final s in stats) {
      if (s.type?.toLowerCase() == type.toLowerCase()) return s.value?.toString();
    }
    return null;
  }
}

class MatchStatItem {
  const MatchStatItem({this.type, this.value});
  final String? type;
  final dynamic value;

  factory MatchStatItem.fromJson(Map<String, dynamic> json) =>
      MatchStatItem(type: json['type']?.toString(), value: json['value']);
}

class MatchLineup {
  const MatchLineup({
    required this.team,
    this.formation,
    this.startXI = const [],
    this.substitutes = const [],
  });
  final MatchTeam team;
  final String? formation;
  final List<LineupPlayer> startXI;
  final List<LineupPlayer> substitutes;

  factory MatchLineup.fromJson(Map<String, dynamic> json) {
    return MatchLineup(
      team: json['team'] is Map ? MatchTeam.fromJson(_asMap(json['team'])) : const MatchTeam(),
      formation: json['formation']?.toString(),
      startXI: _asList(json['startXI']).map((p) => LineupPlayer.fromJson(_asMap(p))).toList(),
      substitutes: _asList(json['substitutes']).map((p) => LineupPlayer.fromJson(_asMap(p))).toList(),
    );
  }
}

class LineupPlayer {
  const LineupPlayer({this.id, this.name, this.number, this.pos, this.grid, this.captain = false});
  final int? id;
  final String? name;
  final int? number;
  final String? pos;
  final String? grid;
  final bool captain;

  factory LineupPlayer.fromJson(Map<String, dynamic> json) {
    final p = json['player'] is Map ? _asMap(json['player']) : json;
    return LineupPlayer(
      id: _toInt(p['id']),
      name: p['name']?.toString(),
      number: _toInt(p['number']),
      pos: p['pos']?.toString(),
      grid: p['grid']?.toString(),
      captain: p['captain'] == true || p['captain']?.toString().toLowerCase() == 'true',
    );
  }

  String get photoUrl =>
      id != null && id! > 0 ? 'https://media.api-sports.io/football/players/$id.png' : '';
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, dynamic val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return null;
}

DateTime? _toDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
