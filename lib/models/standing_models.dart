class StandingGroup {
  const StandingGroup({this.league, this.standings = const []});
  final StandingLeague? league;
  final List<StandingRow> standings;

  factory StandingGroup.fromJson(Map<String, dynamic> json) {
    final dynamic rawStandings = json['standings'];
    final List<dynamic> flattened = [];
    if (rawStandings is List) {
      for (final dynamic item in rawStandings) {
        if (item is List) {
          flattened.addAll(item);
        } else {
          flattened.add(item);
        }
      }
    }
    return StandingGroup(
      league: json['league'] is Map
          ? StandingLeague.fromJson(_asMap(json['league']))
          : null,
      standings: flattened.map((row) => StandingRow.fromJson(_asMap(row))).toList(),
    );
  }
}

class StandingLeague {
  const StandingLeague({this.id, this.name, this.country, this.logo, this.flag, this.season});
  final int? id;
  final String? name;
  final String? country;
  final String? logo;
  final String? flag;
  final int? season;

  factory StandingLeague.fromJson(Map<String, dynamic> json) {
    return StandingLeague(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      country: json['country']?.toString(),
      logo: json['logo']?.toString(),
      flag: json['flag']?.toString(),
      season: _toInt(json['season']),
    );
  }
}

class StandingRow {
  const StandingRow({
    this.rank, this.team, this.points, this.goalsDiff,
    this.group, this.form, this.status, this.description,
    this.all, this.home, this.away, this.update,
  });
  final int? rank;
  final StandingTeam? team;
  final int? points;
  final int? goalsDiff;
  final String? group;
  final String? form;
  final String? status;
  final String? description;
  final StandingStats? all;
  final StandingStats? home;
  final StandingStats? away;
  final String? update;

  factory StandingRow.fromJson(Map<String, dynamic> json) {
    return StandingRow(
      rank: _toInt(json['rank']),
      team: json['team'] is Map ? StandingTeam.fromJson(_asMap(json['team'])) : null,
      points: _toInt(json['points']),
      goalsDiff: _toInt(json['goalsDiff']),
      group: json['group']?.toString(),
      form: json['form']?.toString(),
      status: json['status']?.toString(),
      description: json['description']?.toString(),
      all: json['all'] is Map ? StandingStats.fromJson(_asMap(json['all'])) : null,
      home: json['home'] is Map ? StandingStats.fromJson(_asMap(json['home'])) : null,
      away: json['away'] is Map ? StandingStats.fromJson(_asMap(json['away'])) : null,
      update: json['update']?.toString(),
    );
  }
}

class StandingTeam {
  const StandingTeam({this.id, this.name, this.logo});
  final int? id;
  final String? name;
  final String? logo;

  factory StandingTeam.fromJson(Map<String, dynamic> json) {
    return StandingTeam(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
    );
  }
}

class StandingStats {
  const StandingStats({this.played, this.win, this.draw, this.lose, this.goals});
  final int? played;
  final int? win;
  final int? draw;
  final int? lose;
  final StandingGoals? goals;

  factory StandingStats.fromJson(Map<String, dynamic> json) {
    return StandingStats(
      played: _toInt(json['played']),
      win: _toInt(json['win']),
      draw: _toInt(json['draw']),
      lose: _toInt(json['lose']),
      goals: json['goals'] is Map ? StandingGoals.fromJson(_asMap(json['goals'])) : null,
    );
  }
}

class StandingGoals {
  const StandingGoals({this.forGoals, this.against});
  final int? forGoals;
  final int? against;

  factory StandingGoals.fromJson(Map<String, dynamic> json) {
    return StandingGoals(forGoals: _toInt(json['for']), against: _toInt(json['against']));
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, dynamic val) => MapEntry(key.toString(), val));
  return <String, dynamic>{};
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
