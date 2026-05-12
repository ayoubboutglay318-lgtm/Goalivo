class TeamItem {
  const TeamItem({this.team, this.venue, this.country, this.founded, this.national});
  final TeamInfo? team;
  final TeamVenue? venue;
  final String? country;
  final int? founded;
  final bool? national;

  factory TeamItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> teamMap = json['team'] is Map ? _asMap(json['team']) : json;
    final Map<String, dynamic> venueMap =
        json['venue'] is Map ? _asMap(json['venue']) : <String, dynamic>{};
    return TeamItem(
      team: TeamInfo.fromJson(teamMap),
      venue: venueMap.isEmpty ? null : TeamVenue.fromJson(venueMap),
      country: json['country']?.toString() ?? teamMap['country']?.toString(),
      founded: _toInt(json['founded'] ?? teamMap['founded']),
      national: _toBool(json['national'] ?? teamMap['national']),
    );
  }
}

class TeamInfo {
  const TeamInfo({
    this.id, this.name, this.code, this.country,
    this.founded, this.national, this.logo, this.winner,
  });
  final int? id;
  final String? name;
  final String? code;
  final String? country;
  final int? founded;
  final bool? national;
  final String? logo;
  final bool? winner;

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      country: json['country']?.toString(),
      founded: _toInt(json['founded']),
      national: _toBool(json['national']),
      logo: json['logo']?.toString(),
      winner: _toBool(json['winner']),
    );
  }
}

class TeamVenue {
  const TeamVenue({
    this.id, this.name, this.address, this.city,
    this.capacity, this.surface, this.image,
  });
  final int? id;
  final String? name;
  final String? address;
  final String? city;
  final int? capacity;
  final String? surface;
  final String? image;

  factory TeamVenue.fromJson(Map<String, dynamic> json) {
    return TeamVenue(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      capacity: _toInt(json['capacity']),
      surface: json['surface']?.toString(),
      image: json['image']?.toString(),
    );
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

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return null;
}
