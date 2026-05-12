class LeagueItem {
  const LeagueItem({this.league, this.country, this.seasons = const []});
  final LeagueInfo? league;
  final LeagueCountry? country;
  final List<LeagueSeason> seasons;

  factory LeagueItem.fromJson(Map<String, dynamic> json) {
    return LeagueItem(
      league: json['league'] is Map
          ? LeagueInfo.fromJson(_asMap(json['league']))
          : LeagueInfo.fromJson(json),
      country: json['country'] is Map
          ? LeagueCountry.fromJson(_asMap(json['country']))
          : null,
      seasons: _asList(json['seasons'])
          .map((s) => LeagueSeason.fromJson(_asMap(s)))
          .toList(),
    );
  }
}

class LeagueInfo {
  const LeagueInfo({this.id, this.name, this.type, this.logo});
  final int? id;
  final String? name;
  final String? type;
  final String? logo;

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    return LeagueInfo(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      logo: json['logo']?.toString(),
    );
  }
}

class LeagueCountry {
  const LeagueCountry({this.name, this.code, this.flag});
  final String? name;
  final String? code;
  final String? flag;

  factory LeagueCountry.fromJson(Map<String, dynamic> json) {
    return LeagueCountry(
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      flag: json['flag']?.toString(),
    );
  }
}

class LeagueSeason {
  const LeagueSeason({this.year, this.start, this.end, this.current, this.coverage});
  final int? year;
  final String? start;
  final String? end;
  final bool? current;
  final LeagueCoverage? coverage;

  factory LeagueSeason.fromJson(Map<String, dynamic> json) {
    return LeagueSeason(
      year: _toInt(json['year']),
      start: json['start']?.toString(),
      end: json['end']?.toString(),
      current: _toBool(json['current']),
      coverage: json['coverage'] is Map
          ? LeagueCoverage.fromJson(_asMap(json['coverage']))
          : null,
    );
  }
}

class LeagueCoverage {
  const LeagueCoverage({
    this.fixtures, this.standings, this.players,
    this.topScorers, this.topAssists, this.topCards,
    this.injuries, this.predictions, this.odds,
  });
  final LeagueCoverageFixtures? fixtures;
  final bool? standings;
  final bool? players;
  final bool? topScorers;
  final bool? topAssists;
  final bool? topCards;
  final bool? injuries;
  final bool? predictions;
  final bool? odds;

  factory LeagueCoverage.fromJson(Map<String, dynamic> json) {
    return LeagueCoverage(
      fixtures: json['fixtures'] is Map
          ? LeagueCoverageFixtures.fromJson(_asMap(json['fixtures']))
          : null,
      standings: _toBool(json['standings']),
      players: _toBool(json['players']),
      topScorers: _toBool(json['top_scorers'] ?? json['topScorers']),
      topAssists: _toBool(json['top_assists'] ?? json['topAssists']),
      topCards: _toBool(json['top_cards'] ?? json['topCards']),
      injuries: _toBool(json['injuries']),
      predictions: _toBool(json['predictions']),
      odds: _toBool(json['odds']),
    );
  }
}

class LeagueCoverageFixtures {
  const LeagueCoverageFixtures({
    this.events, this.lineups, this.statisticsFixtures, this.statisticsPlayers,
  });
  final bool? events;
  final bool? lineups;
  final bool? statisticsFixtures;
  final bool? statisticsPlayers;

  factory LeagueCoverageFixtures.fromJson(Map<String, dynamic> json) {
    return LeagueCoverageFixtures(
      events: _toBool(json['events']),
      lineups: _toBool(json['lineups']),
      statisticsFixtures: _toBool(json['statistics_fixtures'] ?? json['statisticsFixtures']),
      statisticsPlayers: _toBool(json['statistics_players'] ?? json['statisticsPlayers']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, dynamic val) => MapEntry(key.toString(), val));
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
