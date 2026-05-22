const _base = 'https://media.api-sports.io/football/players';
String _p(int id) => '$_base/$id.png';

class TeamFormation {
  const TeamFormation({
    required this.formation,
    required this.description,
    required this.lineup,
    this.notes = const [],
  });
  final String formation;
  final String description;
  final List<TeamPlayer> lineup;
  final List<String> notes;
}

class TeamPlayer {
  const TeamPlayer({
    required this.position,
    required this.name,
    required this.role,
    this.photoUrl,
    this.number,
  });
  final String position;
  final String name;
  final String role;
  final String? photoUrl;
  final int? number;
}

class TeamPlanService {
  TeamPlanService._();

  static TeamFormation getPlanForTeam(String teamName) {
    final n = teamName.toLowerCase();

    // ── Premier League ────────────────────────────────────────────────────────

    if (n.contains('manchester united') || n.contains('man united')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'A compact midfield with quick attacking transitions.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'André Onana',         role: 'Shot-stopper',          photoUrl: _p(36907)),
          TeamPlayer(position: 'RB',  name: 'Diogo Dalot',         role: 'Attacking full-back',    photoUrl: _p(19220)),
          TeamPlayer(position: 'CB',  name: 'Raphaël Varane',      role: 'Ball-playing defender',  photoUrl: _p(154)),
          TeamPlayer(position: 'CB',  name: 'Victor Lindelöf',     role: 'Organizer',              photoUrl: _p(19199)),
          TeamPlayer(position: 'LB',  name: 'Luke Shaw',           role: 'Wing support',           photoUrl: _p(1473)),
          TeamPlayer(position: 'DM',  name: 'Casemiro',            role: 'Defensive shield',       photoUrl: _p(756)),
          TeamPlayer(position: 'CM',  name: 'Bruno Fernandes',     role: 'Playmaker',              photoUrl: _p(521)),
          TeamPlayer(position: 'CAM', name: 'Mason Mount',         role: 'Link-up creator',        photoUrl: _p(19233)),
          TeamPlayer(position: 'RW',  name: 'Antony',              role: 'Wide attacker',          photoUrl: _p(35845)),
          TeamPlayer(position: 'LW',  name: 'Marcus Rashford',     role: 'Wide forward',           photoUrl: _p(19197)),
          TeamPlayer(position: 'ST',  name: 'Rasmus Højlund',      role: 'Target striker',         photoUrl: _p(284435)),
        ],
      );
    }

    if (n.contains('liverpool')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'High-pressing attack with fluid front three.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Alisson Becker',           role: 'Sweeper keeper',       photoUrl: _p(2930)),
          TeamPlayer(position: 'RB',  name: 'Trent Alexander-Arnold',   role: 'Creative full-back',   photoUrl: _p(19252)),
          TeamPlayer(position: 'CB',  name: 'Virgil van Dijk',          role: 'Defensive leader',     photoUrl: _p(2935)),
          TeamPlayer(position: 'CB',  name: 'Ibrahima Konaté',          role: 'Power defender',       photoUrl: _p(284454)),
          TeamPlayer(position: 'LB',  name: 'Andy Robertson',           role: 'Overlap specialist',   photoUrl: _p(19202)),
          TeamPlayer(position: 'CM',  name: 'Dominik Szoboszlai',       role: 'Box-to-box boss',      photoUrl: _p(37138)),
          TeamPlayer(position: 'CM',  name: 'Alexis Mac Allister',      role: 'Midfield conductor',   photoUrl: _p(37090)),
          TeamPlayer(position: 'CM',  name: 'Ryan Gravenberch',         role: 'Ball retriever',       photoUrl: _p(284455)),
          TeamPlayer(position: 'RW',  name: 'Mohamed Salah',            role: 'Inside forward',       photoUrl: _p(306)),
          TeamPlayer(position: 'ST',  name: 'Darwin Núñez',             role: 'Direct striker',       photoUrl: _p(284444)),
          TeamPlayer(position: 'LW',  name: 'Luis Díaz',                role: 'Wide attacker',        photoUrl: _p(37106)),
        ],
      );
    }

    if (n.contains('arsenal')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'Control-oriented shape with creative attackers.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'David Raya',           role: 'Shot-stopper',             photoUrl: _p(37112)),
          TeamPlayer(position: 'RB',  name: 'Ben White',            role: 'Ball-carrying defender',   photoUrl: _p(19234)),
          TeamPlayer(position: 'CB',  name: 'William Saliba',       role: 'Ball-playing centre-back', photoUrl: _p(284451)),
          TeamPlayer(position: 'CB',  name: 'Gabriel Magalhães',    role: 'Dominant defender',        photoUrl: _p(284452)),
          TeamPlayer(position: 'LB',  name: 'Oleksandr Zinchenko',  role: 'Creative full-back',       photoUrl: _p(37114)),
          TeamPlayer(position: 'DM',  name: 'Declan Rice',          role: 'Deep-lying shield',        photoUrl: _p(24992)),
          TeamPlayer(position: 'CM',  name: 'Thomas Partey',        role: 'Box-to-box support',       photoUrl: _p(1485)),
          TeamPlayer(position: 'RW',  name: 'Bukayo Saka',          role: 'Wide creator',             photoUrl: _p(284453)),
          TeamPlayer(position: 'CAM', name: 'Martin Ødegaard',      role: 'Attacking conductor',      photoUrl: _p(19191)),
          TeamPlayer(position: 'LW',  name: 'Gabriel Martinelli',   role: 'High-energy winger',       photoUrl: _p(284450)),
          TeamPlayer(position: 'ST',  name: 'Kai Havertz',          role: 'False nine',               photoUrl: _p(284446)),
        ],
      );
    }

    if (n.contains('chelsea')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'Dynamic squad with youthful energy and flair.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Robert Sánchez',   role: 'Calm under pressure',      photoUrl: _p(284447)),
          TeamPlayer(position: 'RB',  name: 'Reece James',      role: 'Powerful wing-back',        photoUrl: _p(19238)),
          TeamPlayer(position: 'CB',  name: 'Thiago Silva',     role: 'Experienced anchor',        photoUrl: _p(779)),
          TeamPlayer(position: 'CB',  name: 'Wesley Fofana',    role: 'Athletic defender',         photoUrl: _p(284456)),
          TeamPlayer(position: 'LB',  name: 'Ben Chilwell',     role: 'Forward-driving winger',    photoUrl: _p(19246)),
          TeamPlayer(position: 'DM',  name: 'Enzo Fernández',   role: 'Box-to-box midfielder',     photoUrl: _p(284441)),
          TeamPlayer(position: 'DM',  name: 'Moisés Caicedo',   role: 'Midfield carrier',          photoUrl: _p(284442)),
          TeamPlayer(position: 'RW',  name: 'Pedro Neto',       role: 'Wide attacker',             photoUrl: _p(284449)),
          TeamPlayer(position: 'CAM', name: 'Cole Palmer',      role: 'Inside forward',            photoUrl: _p(284457)),
          TeamPlayer(position: 'LW',  name: 'Noni Madueke',     role: 'Pace merchant',             photoUrl: _p(284458)),
          TeamPlayer(position: 'ST',  name: 'Nicolas Jackson',  role: 'Creative striker',          photoUrl: _p(284459)),
        ],
      );
    }

    if (n.contains('tottenham') || n.contains('spurs')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Attacking football under new management.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Guglielmo Vicario',   role: 'Modern keeper',           photoUrl: _p(284480)),
          TeamPlayer(position: 'RB',  name: 'Pedro Porro',         role: 'Attacking full-back',     photoUrl: _p(284481)),
          TeamPlayer(position: 'CB',  name: 'Micky van de Ven',    role: 'Pace and composure',      photoUrl: _p(284482)),
          TeamPlayer(position: 'CB',  name: 'Cristian Romero',     role: 'Aggressive stopper',      photoUrl: _p(284483)),
          TeamPlayer(position: 'LB',  name: 'Destiny Udogie',      role: 'Dynamic full-back',       photoUrl: _p(284484)),
          TeamPlayer(position: 'CM',  name: 'Rodrigo Bentancur',   role: 'Box-to-box engine',       photoUrl: _p(284485)),
          TeamPlayer(position: 'CM',  name: 'Yves Bissouma',       role: 'Midfield anchor',         photoUrl: _p(284486)),
          TeamPlayer(position: 'CM',  name: 'James Maddison',      role: 'Creative playmaker',      photoUrl: _p(19245)),
          TeamPlayer(position: 'RW',  name: 'Brennan Johnson',     role: 'Pace on the wing',        photoUrl: _p(284487)),
          TeamPlayer(position: 'ST',  name: 'Son Heung-min',       role: 'Clinical attacker',       photoUrl: _p(1455)),
          TeamPlayer(position: 'LW',  name: 'Dejan Kulusevski',    role: 'Versatile attacker',      photoUrl: _p(284488)),
        ],
      );
    }

    if (n.contains('newcastle')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Strong defensive base with rapid counter attacks.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Nick Pope',          role: 'England No.1',             photoUrl: _p(19249)),
          TeamPlayer(position: 'RB',  name: 'Kieran Trippier',    role: 'Set-piece specialist',     photoUrl: _p(1469)),
          TeamPlayer(position: 'CB',  name: 'Sven Botman',        role: 'Dominant defender',        photoUrl: _p(284489)),
          TeamPlayer(position: 'CB',  name: 'Fabian Schär',       role: 'Composed organizer',       photoUrl: _p(2936)),
          TeamPlayer(position: 'LB',  name: 'Dan Burn',           role: 'Reliable defender',        photoUrl: _p(284490)),
          TeamPlayer(position: 'CM',  name: 'Bruno Guimarães',    role: 'Midfield engine',          photoUrl: _p(284491)),
          TeamPlayer(position: 'CM',  name: 'Sandro Tonali',      role: 'Box-to-box talent',        photoUrl: _p(284492)),
          TeamPlayer(position: 'CM',  name: 'Joe Willock',        role: 'Energy injector',          photoUrl: _p(19241)),
          TeamPlayer(position: 'RW',  name: 'Miguel Almirón',     role: 'Tenacious winger',         photoUrl: _p(3307)),
          TeamPlayer(position: 'ST',  name: 'Alexander Isak',     role: 'Clinical finisher',        photoUrl: _p(284493)),
          TeamPlayer(position: 'LW',  name: 'Anthony Gordon',     role: 'Energetic left wing',      photoUrl: _p(284494)),
        ],
      );
    }

    if (n.contains('aston villa') || n.contains('villa')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'European ambition with creative flair.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Emiliano Martínez',   role: 'World Cup winner',        photoUrl: _p(3476)),
          TeamPlayer(position: 'RB',  name: 'Matty Cash',          role: 'Hard-working full-back',  photoUrl: _p(284495)),
          TeamPlayer(position: 'CB',  name: 'Pau Torres',          role: 'Ball-playing defender',   photoUrl: _p(284496)),
          TeamPlayer(position: 'CB',  name: 'Ezri Konsa',          role: 'Reliable stopper',        photoUrl: _p(284497)),
          TeamPlayer(position: 'LB',  name: 'Lucas Digne',         role: 'Creative full-back',      photoUrl: _p(2980)),
          TeamPlayer(position: 'DM',  name: 'Youri Tielemans',     role: 'Deep playmaker',          photoUrl: _p(284498)),
          TeamPlayer(position: 'DM',  name: 'Douglas Luiz',        role: 'Brazilian engine',        photoUrl: _p(284499)),
          TeamPlayer(position: 'RW',  name: 'Leon Bailey',         role: 'Rapid winger',            photoUrl: _p(284500)),
          TeamPlayer(position: 'CAM', name: 'John McGinn',         role: 'Box-to-box captain',      photoUrl: _p(19244)),
          TeamPlayer(position: 'LW',  name: 'Moussa Diaby',        role: 'Electric dribbler',       photoUrl: _p(284501)),
          TeamPlayer(position: 'ST',  name: 'Ollie Watkins',       role: 'Clinical English striker', photoUrl: _p(19248)),
        ],
      );
    }

    // ── La Liga ───────────────────────────────────────────────────────────────

    if (n.contains('real madrid')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Counter-attacking royalty with world-class talent.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Thibaut Courtois',     role: 'World-class keeper',      photoUrl: _p(2935)),
          TeamPlayer(position: 'RB',  name: 'Dani Carvajal',        role: 'Veteran right back',      photoUrl: _p(1473)),
          TeamPlayer(position: 'CB',  name: 'Antonio Rüdiger',      role: 'Aggressive defender',     photoUrl: _p(774)),
          TeamPlayer(position: 'CB',  name: 'Éder Militão',         role: 'Athletic centre-back',    photoUrl: _p(284464)),
          TeamPlayer(position: 'LB',  name: 'Ferland Mendy',        role: 'Solid full-back',         photoUrl: _p(284465)),
          TeamPlayer(position: 'CM',  name: 'Aurélien Tchouaméni',  role: 'Defensive anchor',        photoUrl: _p(284466)),
          TeamPlayer(position: 'CM',  name: 'Eduardo Camavinga',    role: 'Box-to-box dynamo',       photoUrl: _p(284467)),
          TeamPlayer(position: 'CM',  name: 'Jude Bellingham',      role: 'Modern midfielder',       photoUrl: _p(939)),
          TeamPlayer(position: 'RW',  name: 'Rodrygo',              role: 'Creative winger',         photoUrl: _p(284468)),
          TeamPlayer(position: 'ST',  name: 'Kylian Mbappé',        role: 'World-class striker',     photoUrl: _p(278)),
          TeamPlayer(position: 'LW',  name: 'Vinícius Júnior',      role: 'Explosive dribbler',      photoUrl: _p(1082)),
        ],
      );
    }

    // FC Barcelona only — excludes "Barcelona SC" (Ecuador), "Sporting de Barcelona", etc.
    if ((n.contains('barcelona') || n.contains('barça')) &&
        !n.contains('barcelona sc') && !n.contains('sc barcelona') && !n.contains('sporting')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Possession-heavy tiki-taka football.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Marc-André ter Stegen', role: 'Sweeper keeper',          photoUrl: _p(2932)),
          TeamPlayer(position: 'RB',  name: 'Jules Koundé',          role: 'Technical defender'),
          TeamPlayer(position: 'CB',  name: 'Ronald Araújo',         role: 'Ball-playing centre-back',photoUrl: _p(284461)),
          TeamPlayer(position: 'CB',  name: 'Pau Cubarsí',           role: 'Young organizer',         photoUrl: _p(284462)),
          TeamPlayer(position: 'LB',  name: 'Alejandro Balde',       role: 'Attacking full-back'),
          TeamPlayer(position: 'CM',  name: 'Frenkie de Jong',       role: 'Midfield engine'),
          TeamPlayer(position: 'CM',  name: 'Pedri',                 role: 'Creative orchestrator'),
          TeamPlayer(position: 'CM',  name: 'Gavi',                  role: 'Energetic midfielder'),
          TeamPlayer(position: 'RW',  name: 'Lamine Yamal',          role: 'Young sensation',         photoUrl: _p(284434)),
          TeamPlayer(position: 'ST',  name: 'Robert Lewandowski',    role: 'Goal hunter',             photoUrl: _p(174)),
          TeamPlayer(position: 'LW',  name: 'Raphinha',              role: 'Inverted winger',         photoUrl: _p(284435)),
        ],
      );
    }

    if (n.contains('atletico') || n.contains('atlético')) {
      return TeamFormation(
        formation: '4-4-2',
        description: 'Defensive organization with lethal counter attacks.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Jan Oblak',           role: 'Shot-stopping legend',    photoUrl: _p(2931)),
          TeamPlayer(position: 'RB',  name: 'Nahuel Molina',       role: 'Attacking full-back',     photoUrl: _p(284502)),
          TeamPlayer(position: 'CB',  name: 'Stefan Savić',        role: 'Physical stopper',        photoUrl: _p(2937)),
          TeamPlayer(position: 'CB',  name: 'José Giménez',        role: 'Committed defender',      photoUrl: _p(2938)),
          TeamPlayer(position: 'LB',  name: 'Reinildo',            role: 'Solid left back',         photoUrl: _p(284503)),
          TeamPlayer(position: 'RM',  name: 'Samuel Lino',         role: 'Wide energy',             photoUrl: _p(284504)),
          TeamPlayer(position: 'CM',  name: 'Koke',                role: 'Captain and conductor',   photoUrl: _p(2939)),
          TeamPlayer(position: 'CM',  name: 'Rodrigo De Paul',     role: 'Argentine engine',        photoUrl: _p(284505)),
          TeamPlayer(position: 'LM',  name: 'Ángel Correa',        role: 'Versatile attacker',      photoUrl: _p(284506)),
          TeamPlayer(position: 'ST',  name: 'Antoine Griezmann',   role: 'World-class forward',     photoUrl: _p(2084)),
          TeamPlayer(position: 'ST',  name: 'Álvaro Morata',       role: 'Target striker',          photoUrl: _p(2082)),
        ],
      );
    }

    if (n.contains('sevilla')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'Europa League specialists with technical football.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Yassine Bounou',      role: 'Moroccan wall',           photoUrl: _p(284507)),
          TeamPlayer(position: 'RB',  name: 'Gonzalo Montiel',     role: 'World Cup winner',        photoUrl: _p(284508)),
          TeamPlayer(position: 'CB',  name: 'Marcão',              role: 'Physical defender',       photoUrl: _p(284509)),
          TeamPlayer(position: 'CB',  name: 'Loïc Badé',           role: 'French organizer',        photoUrl: _p(284510)),
          TeamPlayer(position: 'LB',  name: 'Marcos Acuña',        role: 'Argentine full-back',     photoUrl: _p(284511)),
          TeamPlayer(position: 'DM',  name: 'Fernando',            role: 'Brazilian anchor',        photoUrl: _p(284512)),
          TeamPlayer(position: 'DM',  name: 'Joan Jordán',         role: 'Technical midfielder',    photoUrl: _p(284513)),
          TeamPlayer(position: 'RW',  name: 'Suso',                role: 'Creative winger',         photoUrl: _p(2940)),
          TeamPlayer(position: 'CAM', name: 'Dodi Lukébakio',      role: 'Belgian flair',           photoUrl: _p(284514)),
          TeamPlayer(position: 'LW',  name: 'Óliver Torres',       role: 'Technical midfielder',    photoUrl: _p(284515)),
          TeamPlayer(position: 'ST',  name: 'Youssef En-Nesyri',   role: 'Moroccan striker',        photoUrl: _p(284516)),
        ],
      );
    }

    // ── Serie A ───────────────────────────────────────────────────────────────

    if (n.contains('juventus') || n.contains('juve')) {
      return TeamFormation(
        formation: '3-5-2',
        description: 'Italian defensive solidity with attacking quality.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Wojciech Szczęsny',   role: 'Polish wall',             photoUrl: _p(2941)),
          TeamPlayer(position: 'CB',  name: 'Federico Gatti',      role: 'Physical defender',       photoUrl: _p(284517)),
          TeamPlayer(position: 'CB',  name: 'Gleison Bremer',      role: 'Brazilian stopper',       photoUrl: _p(284518)),
          TeamPlayer(position: 'CB',  name: 'Danilo',              role: 'Versatile defender',      photoUrl: _p(284519)),
          TeamPlayer(position: 'RWB', name: 'Andrea Cambiaso',     role: 'Modern wing-back',        photoUrl: _p(284520)),
          TeamPlayer(position: 'CM',  name: 'Manuel Locatelli',    role: 'Deep playmaker',          photoUrl: _p(284521)),
          TeamPlayer(position: 'CM',  name: 'Nicolò Fagioli',      role: 'Technical midfielder',    photoUrl: _p(284522)),
          TeamPlayer(position: 'CM',  name: 'Adrien Rabiot',       role: 'Box-to-box powerhouse',   photoUrl: _p(1474)),
          TeamPlayer(position: 'LWB', name: 'Filip Kostić',        role: 'Serbian wing-back',       photoUrl: _p(284523)),
          TeamPlayer(position: 'ST',  name: 'Dušan Vlahović',      role: 'Serbian striker',         photoUrl: _p(284524)),
          TeamPlayer(position: 'ST',  name: 'Federico Chiesa',     role: 'Italian talent',          photoUrl: _p(284525)),
        ],
      );
    }

    if (n.contains('inter') && !n.contains('miami')) {
      return TeamFormation(
        formation: '3-5-2',
        description: 'Simone Inzaghi\'s counter-pressing masterpiece.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Yann Sommer',         role: 'Swiss keeper',            photoUrl: _p(2942)),
          TeamPlayer(position: 'CB',  name: 'Francesco Acerbi',    role: 'Experienced defender',    photoUrl: _p(284526)),
          TeamPlayer(position: 'CB',  name: 'Alessandro Bastoni',  role: 'Ball-playing centre-back',photoUrl: _p(284527)),
          TeamPlayer(position: 'CB',  name: 'Benjamin Pavard',     role: 'French defender',         photoUrl: _p(284528)),
          TeamPlayer(position: 'RWB', name: 'Matteo Darmian',      role: 'Reliable wing-back',      photoUrl: _p(284529)),
          TeamPlayer(position: 'CM',  name: 'Nicolo Barella',      role: 'Italian engine',          photoUrl: _p(284530)),
          TeamPlayer(position: 'CM',  name: 'Hakan Çalhanoğlu',    role: 'Turkish regista',         photoUrl: _p(284531)),
          TeamPlayer(position: 'CM',  name: 'Henrikh Mkhitaryan',  role: 'Box-to-box veteran',      photoUrl: _p(2943)),
          TeamPlayer(position: 'LWB', name: 'Federico Dimarco',    role: 'Dynamic wing-back',       photoUrl: _p(284532)),
          TeamPlayer(position: 'ST',  name: 'Lautaro Martínez',    role: 'Argentine captain',       photoUrl: _p(284533)),
          TeamPlayer(position: 'ST',  name: 'Marcus Thuram',       role: 'French powerhouse',       photoUrl: _p(284534)),
        ],
      );
    }

    if (n.contains('milan') && !n.contains('inter')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'Pioli\'s fluid system with technical excellence.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Mike Maignan',        role: 'French No.1',             photoUrl: _p(284535)),
          TeamPlayer(position: 'RB',  name: 'Davide Calabria',     role: 'Captain full-back',       photoUrl: _p(284536)),
          TeamPlayer(position: 'CB',  name: 'Simon Kjær',          role: 'Danish leader',           photoUrl: _p(2944)),
          TeamPlayer(position: 'CB',  name: 'Fikayo Tomori',       role: 'Pace and power',          photoUrl: _p(284537)),
          TeamPlayer(position: 'LB',  name: 'Theo Hernández',      role: 'Attacking left back',     photoUrl: _p(284538)),
          TeamPlayer(position: 'DM',  name: 'Tijjani Reijnders',   role: 'Dutch dynamo',            photoUrl: _p(284539)),
          TeamPlayer(position: 'DM',  name: 'Ismael Bennacer',     role: 'Algerian conductor',      photoUrl: _p(284540)),
          TeamPlayer(position: 'RW',  name: 'Samuel Chukwueze',    role: 'Nigerian winger',         photoUrl: _p(284541)),
          TeamPlayer(position: 'CAM', name: 'Ruben Loftus-Cheek',  role: 'Physical midfielder',     photoUrl: _p(19236)),
          TeamPlayer(position: 'LW',  name: 'Rafael Leão',         role: 'Portuguese star',         photoUrl: _p(284542)),
          TeamPlayer(position: 'ST',  name: 'Olivier Giroud',      role: 'Veteran target man',      photoUrl: _p(1470)),
        ],
      );
    }

    if (n.contains('napoli')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Technical Italian football at its finest.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Alex Meret',          role: 'Italian keeper',          photoUrl: _p(284543)),
          TeamPlayer(position: 'RB',  name: 'Giovanni Di Lorenzo', role: 'Italy captain',           photoUrl: _p(284544)),
          TeamPlayer(position: 'CB',  name: 'Amir Rrahmani',       role: 'Kosovo defender',         photoUrl: _p(284545)),
          TeamPlayer(position: 'CB',  name: 'Min-jae Kim',         role: 'Monster defender',        photoUrl: _p(284477)),
          TeamPlayer(position: 'LB',  name: 'Mathías Olivera',     role: 'Uruguayan full-back',     photoUrl: _p(284546)),
          TeamPlayer(position: 'CM',  name: 'Stanislav Lobotka',   role: 'Slovak metronome',        photoUrl: _p(284547)),
          TeamPlayer(position: 'CM',  name: 'Piotr Zieliński',     role: 'Polish playmaker',        photoUrl: _p(284548)),
          TeamPlayer(position: 'CM',  name: 'André-Frank Anguissa', role: 'Cameroon powerhouse',   photoUrl: _p(284549)),
          TeamPlayer(position: 'RW',  name: 'Matteo Politano',     role: 'Italian winger',          photoUrl: _p(284550)),
          TeamPlayer(position: 'ST',  name: 'Victor Osimhen',      role: 'Nigerian superstar',      photoUrl: _p(284551)),
          TeamPlayer(position: 'LW',  name: 'Khvicha Kvaratskhelia', role: 'Georgian wizard',       photoUrl: _p(284552)),
        ],
      );
    }

    if (n.contains('roma') || n.contains('as roma')) {
      return TeamFormation(
        formation: '3-4-2-1',
        description: 'Mourinho\'s organized defensive structure.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Rui Patrício',        role: 'Portuguese keeper',       photoUrl: _p(2945)),
          TeamPlayer(position: 'CB',  name: 'Gianluca Mancini',    role: 'Committed defender',      photoUrl: _p(284553)),
          TeamPlayer(position: 'CB',  name: 'Chris Smalling',      role: 'English stopper',         photoUrl: _p(2946)),
          TeamPlayer(position: 'CB',  name: 'Roger Ibáñez',        role: 'Brazilian defender',      photoUrl: _p(284554)),
          TeamPlayer(position: 'RWB', name: 'Rick Karsdorp',       role: 'Dutch wing-back',         photoUrl: _p(284555)),
          TeamPlayer(position: 'CM',  name: 'Bryan Cristante',     role: 'Box-to-box Italian',      photoUrl: _p(284556)),
          TeamPlayer(position: 'CM',  name: 'Lorenzo Pellegrini',  role: 'Roma captain',            photoUrl: _p(284557)),
          TeamPlayer(position: 'LWB', name: 'Leonardo Spinazzola', role: 'Attacking wing-back',     photoUrl: _p(284558)),
          TeamPlayer(position: 'SS',  name: 'Paulo Dybala',        role: 'Argentine magician',      photoUrl: _p(284559)),
          TeamPlayer(position: 'SS',  name: 'Nicolò Zaniolo',      role: 'Italian talent',          photoUrl: _p(284560)),
          TeamPlayer(position: 'ST',  name: 'Romelu Lukaku',       role: 'Belgian powerhouse',      photoUrl: _p(2947)),
        ],
      );
    }

    if (n.contains('lazio')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Fast transitions with technical midfield.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Ivan Provedel',       role: 'Italian keeper',          photoUrl: _p(284561)),
          TeamPlayer(position: 'RB',  name: 'Elseid Hysaj',        role: 'Albanian full-back',      photoUrl: _p(284562)),
          TeamPlayer(position: 'CB',  name: 'Alessio Romagnoli',   role: 'Italian defender',        photoUrl: _p(284563)),
          TeamPlayer(position: 'CB',  name: 'Patric',              role: 'Spanish stopper',         photoUrl: _p(284564)),
          TeamPlayer(position: 'LB',  name: 'Luca Pellegrini',     role: 'Attacking full-back',     photoUrl: _p(284565)),
          TeamPlayer(position: 'CM',  name: 'Sergej Milinković-Savić', role: 'Serbian titan',       photoUrl: _p(284566)),
          TeamPlayer(position: 'CM',  name: 'Matías Vecino',       role: 'Uruguayan engine',        photoUrl: _p(284567)),
          TeamPlayer(position: 'CM',  name: 'Luis Alberto',        role: 'Spanish playmaker',       photoUrl: _p(284568)),
          TeamPlayer(position: 'RW',  name: 'Felipe Anderson',     role: 'Brazilian winger',        photoUrl: _p(284569)),
          TeamPlayer(position: 'ST',  name: 'Ciro Immobile',       role: 'Italian goal machine',    photoUrl: _p(2948)),
          TeamPlayer(position: 'LW',  name: 'Mattia Zaccagni',     role: 'Creative attacker',       photoUrl: _p(284570)),
        ],
      );
    }

    // ── Bundesliga ────────────────────────────────────────────────────────────

    if (n.contains('manchester city') || n.contains('man city')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Pep\'s positional masterpiece.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Ederson',             role: 'Sweeper keeper',          photoUrl: _p(641)),
          TeamPlayer(position: 'RB',  name: 'Kyle Walker',         role: 'Versatile full-back',     photoUrl: _p(1534)),
          TeamPlayer(position: 'CB',  name: 'Rúben Dias',          role: 'Commanding defender',     photoUrl: _p(284469)),
          TeamPlayer(position: 'CB',  name: 'Manuel Akanji',       role: 'Ball-playing stopper',    photoUrl: _p(284470)),
          TeamPlayer(position: 'LB',  name: 'Joško Gvardiol',      role: 'Dynamic full-back',       photoUrl: _p(284471)),
          TeamPlayer(position: 'CM',  name: 'Rodri',               role: 'World-class conductor',   photoUrl: _p(895)),
          TeamPlayer(position: 'CM',  name: 'Kevin De Bruyne',     role: 'Creative genius',         photoUrl: _p(627)),
          TeamPlayer(position: 'CM',  name: 'Bernardo Silva',      role: 'Pressing maestro',        photoUrl: _p(284472)),
          TeamPlayer(position: 'RW',  name: 'Phil Foden',          role: 'Inside forward',          photoUrl: _p(284473)),
          TeamPlayer(position: 'ST',  name: 'Erling Haaland',      role: 'Goal machine',            photoUrl: _p(1100)),
          TeamPlayer(position: 'LW',  name: 'Jeremy Doku',         role: 'Pace and dribbles',       photoUrl: _p(284474)),
        ],
      );
    }

    if (n.contains('bayern') || n.contains('münchen') || n.contains('munich')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'German efficiency with relentless intensity.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Manuel Neuer',        role: 'Legendary keeper',        photoUrl: _p(2931)),
          TeamPlayer(position: 'RB',  name: 'Noussair Mazraoui',   role: 'Attacking full-back',     photoUrl: _p(284475)),
          TeamPlayer(position: 'CB',  name: 'Dayot Upamecano',     role: 'Physical defender',       photoUrl: _p(284476)),
          TeamPlayer(position: 'CB',  name: 'Kim Min-jae',         role: 'Dominant stopper',        photoUrl: _p(284477)),
          TeamPlayer(position: 'LB',  name: 'Alphonso Davies',     role: 'Lightning pace',          photoUrl: _p(284478)),
          TeamPlayer(position: 'DM',  name: 'Joshua Kimmich',      role: 'Modern libero',           photoUrl: _p(19190)),
          TeamPlayer(position: 'DM',  name: 'Leon Goretzka',       role: 'Box-to-box powerhouse',   photoUrl: _p(19204)),
          TeamPlayer(position: 'CAM', name: 'Jamal Musiala',       role: 'Creative genius',         photoUrl: _p(284479)),
          TeamPlayer(position: 'RW',  name: 'Leroy Sané',          role: 'Electric winger',         photoUrl: _p(19217)),
          TeamPlayer(position: 'ST',  name: 'Harry Kane',          role: 'World-class striker',     photoUrl: _p(184)),
          TeamPlayer(position: 'LW',  name: 'Serge Gnabry',        role: 'Versatile attacker',      photoUrl: _p(19216)),
        ],
      );
    }

    if (n.contains('dortmund') || n.contains('bvb')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'Gegenpressing machine with electric pace.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Gregor Kobel',        role: 'Swiss keeper',            photoUrl: _p(284571)),
          TeamPlayer(position: 'RB',  name: 'Julian Ryerson',      role: 'Norwegian full-back',     photoUrl: _p(284572)),
          TeamPlayer(position: 'CB',  name: 'Nico Schlotterbeck',  role: 'German defender',         photoUrl: _p(284573)),
          TeamPlayer(position: 'CB',  name: 'Mats Hummels',        role: 'Experienced sweeper',     photoUrl: _p(2949)),
          TeamPlayer(position: 'LB',  name: 'Ian Maatsen',         role: 'Dutch wing-back',         photoUrl: _p(284574)),
          TeamPlayer(position: 'DM',  name: 'Marcel Sabitzer',     role: 'Austrian engine',         photoUrl: _p(284575)),
          TeamPlayer(position: 'DM',  name: 'Salih Özcan',         role: 'Turkish anchor',          photoUrl: _p(284576)),
          TeamPlayer(position: 'RW',  name: 'Karim Adeyemi',       role: 'German pace merchant',    photoUrl: _p(284577)),
          TeamPlayer(position: 'CAM', name: 'Julian Brandt',       role: 'Creative playmaker',      photoUrl: _p(284578)),
          TeamPlayer(position: 'LW',  name: 'Jamie Bynoe-Gittens', role: 'Young English winger',    photoUrl: _p(284579)),
          TeamPlayer(position: 'ST',  name: 'Sébastien Haller',    role: 'Ivorian target man',      photoUrl: _p(284580)),
        ],
      );
    }

    if (n.contains('leverkusen') || n.contains('bayer')) {
      return TeamFormation(
        formation: '3-4-2-1',
        description: 'Alonso\'s unbeaten champions with fluid pressing.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Lukáš Hrádecký',      role: 'Finnish keeper',          photoUrl: _p(284581)),
          TeamPlayer(position: 'CB',  name: 'Jonathan Tah',        role: 'German powerhouse',       photoUrl: _p(284582)),
          TeamPlayer(position: 'CB',  name: 'Odilon Kossounou',    role: 'Ivorian defender',        photoUrl: _p(284583)),
          TeamPlayer(position: 'CB',  name: 'Edmond Tapsoba',      role: 'Burkinabé defender',      photoUrl: _p(284584)),
          TeamPlayer(position: 'RWB', name: 'Jeremie Frimpong',    role: 'Dutch wing-back',         photoUrl: _p(284585)),
          TeamPlayer(position: 'CM',  name: 'Granit Xhaka',        role: 'Swiss captain',           photoUrl: _p(2950)),
          TeamPlayer(position: 'CM',  name: 'Exequiel Palacios',   role: 'Argentine engine',        photoUrl: _p(284586)),
          TeamPlayer(position: 'LWB', name: 'Alejandro Grimaldo',  role: 'Spanish wing-back',       photoUrl: _p(284587)),
          TeamPlayer(position: 'SS',  name: 'Florian Wirtz',       role: 'German wonderkid',        photoUrl: _p(284588)),
          TeamPlayer(position: 'SS',  name: 'Jonas Hofmann',       role: 'German technician',       photoUrl: _p(284589)),
          TeamPlayer(position: 'ST',  name: 'Patrik Schick',       role: 'Czech striker',           photoUrl: _p(284590)),
        ],
      );
    }

    // ── Ligue 1 ───────────────────────────────────────────────────────────────

    if (n.contains('paris') || n.contains('psg')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Attacking football powered by world-class stars.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Gianluigi Donnarumma', role: 'Italian wall',           photoUrl: _p(3025)),
          TeamPlayer(position: 'RB',  name: 'Achraf Hakimi',        role: 'Explosive right back',   photoUrl: _p(284436)),
          TeamPlayer(position: 'CB',  name: 'Marquinhos',           role: 'Captain and leader',     photoUrl: _p(284437)),
          TeamPlayer(position: 'CB',  name: 'Lucas Hernández',      role: 'Strong defender',        photoUrl: _p(284438)),
          TeamPlayer(position: 'LB',  name: 'Nuno Mendes',          role: 'Attacking left back',    photoUrl: _p(284439)),
          TeamPlayer(position: 'CM',  name: 'Vitinha',              role: 'Midfield engine',        photoUrl: _p(284440)),
          TeamPlayer(position: 'CM',  name: 'João Neves',           role: 'Young playmaker',        photoUrl: _p(284591)),
          TeamPlayer(position: 'CM',  name: 'Fabian Ruiz',          role: 'Spanish technician',     photoUrl: _p(284592)),
          TeamPlayer(position: 'RW',  name: 'Ousmane Dembélé',      role: 'Rapid winger',           photoUrl: _p(284443)),
          TeamPlayer(position: 'ST',  name: 'Gonçalo Ramos',        role: 'Clinical striker',       photoUrl: _p(284593)),
          TeamPlayer(position: 'LW',  name: 'Bradley Barcola',      role: 'Young talent',           photoUrl: _p(284594)),
        ],
      );
    }

    if (n.contains('marseille') || n.contains('olympique de marseille')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'Mediterranean flair with passionate football.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Pau López',           role: 'Spanish keeper',          photoUrl: _p(284595)),
          TeamPlayer(position: 'RB',  name: 'Jonathan Clauss',     role: 'French wing-back',        photoUrl: _p(284596)),
          TeamPlayer(position: 'CB',  name: 'Samuel Gigot',        role: 'French defender',         photoUrl: _p(284597)),
          TeamPlayer(position: 'CB',  name: 'Chancel Mbemba',      role: 'Congolese stopper',       photoUrl: _p(284598)),
          TeamPlayer(position: 'LB',  name: 'Nuno Tavares',        role: 'Portuguese full-back',    photoUrl: _p(284599)),
          TeamPlayer(position: 'DM',  name: 'Valentin Rongier',    role: 'French anchor',           photoUrl: _p(284600)),
          TeamPlayer(position: 'DM',  name: 'Geoffroy Kondogbia',  role: 'Central African engine',  photoUrl: _p(284601)),
          TeamPlayer(position: 'RW',  name: 'Jonathan Rowe',       role: 'English winger',          photoUrl: _p(284602)),
          TeamPlayer(position: 'CAM', name: 'Pierre-Emerick Aubameyang', role: 'Gabon striker',     photoUrl: _p(1462)),
          TeamPlayer(position: 'LW',  name: 'Vitinha',             role: 'Portuguese winger',       photoUrl: _p(284603)),
          TeamPlayer(position: 'ST',  name: 'Mason Greenwood',     role: 'English forward',         photoUrl: _p(284604)),
        ],
      );
    }

    if (n.contains('monaco')) {
      return TeamFormation(
        formation: '4-2-3-1',
        description: 'Young talent with explosive attacking play.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Radosław Majecki',    role: 'Polish keeper',           photoUrl: _p(284605)),
          TeamPlayer(position: 'RB',  name: 'Vanderson',           role: 'Brazilian full-back',     photoUrl: _p(284606)),
          TeamPlayer(position: 'CB',  name: 'Axel Disasi',         role: 'French defender',         photoUrl: _p(284607)),
          TeamPlayer(position: 'CB',  name: 'Chrislain Matsima',   role: 'Young stopper',           photoUrl: _p(284608)),
          TeamPlayer(position: 'LB',  name: 'Caio Henrique',       role: 'Brazilian left back',     photoUrl: _p(284609)),
          TeamPlayer(position: 'DM',  name: 'Mohamed Camara',      role: 'Mali engine',             photoUrl: _p(284610)),
          TeamPlayer(position: 'DM',  name: 'Youssouf Fofana',     role: 'French powerhouse',       photoUrl: _p(284611)),
          TeamPlayer(position: 'RW',  name: 'Takumi Minamino',     role: 'Japanese forward',        photoUrl: _p(284612)),
          TeamPlayer(position: 'CAM', name: 'Aleksandr Golovin',   role: 'Russian playmaker',       photoUrl: _p(284613)),
          TeamPlayer(position: 'LW',  name: 'Maghnes Akliouche',   role: 'Algerian talent',         photoUrl: _p(284614)),
          TeamPlayer(position: 'ST',  name: 'Wissam Ben Yedder',   role: 'French-Tunisian striker', photoUrl: _p(284615)),
        ],
      );
    }

    // ── Saudi Pro League ──────────────────────────────────────────────────────

    if (n.contains('al nassr') || n.contains('nassr')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Al Nassr powered by the greatest of all time.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'David Ospina',        role: 'Colombian keeper',        photoUrl: _p(2951)),
          TeamPlayer(position: 'RB',  name: 'Sultan Al-Ghannam',   role: 'Saudi full-back',         photoUrl: _p(284616)),
          TeamPlayer(position: 'CB',  name: 'Ali Al-Bulayhi',      role: 'Saudi defender',          photoUrl: _p(284617)),
          TeamPlayer(position: 'CB',  name: 'Aymeric Laporte',     role: 'Spanish-French defender', photoUrl: _p(284618)),
          TeamPlayer(position: 'LB',  name: 'Seko Fofana',         role: 'Ivorian full-back',       photoUrl: _p(284619)),
          TeamPlayer(position: 'CM',  name: 'Seko Fofana',         role: 'Ivorian engine',          photoUrl: _p(284620)),
          TeamPlayer(position: 'CM',  name: 'Marcelo Brozović',    role: 'Croatian conductor',      photoUrl: _p(284621)),
          TeamPlayer(position: 'CM',  name: 'Abdulrahman Ghareeb', role: 'Saudi midfielder',        photoUrl: _p(284622)),
          TeamPlayer(position: 'RW',  name: 'Sadio Mané',          role: 'Senegalese star',         photoUrl: _p(306)),
          TeamPlayer(position: 'ST',  name: 'Cristiano Ronaldo',   role: 'The GOAT',                photoUrl: _p(874)),
          TeamPlayer(position: 'LW',  name: 'Anderson Talisca',    role: 'Brazilian powerhouse',    photoUrl: _p(284623)),
        ],
      );
    }

    if (n.contains('al hilal') || n.contains('hilal')) {
      return TeamFormation(
        formation: '4-3-3',
        description: 'Saudi giants with world stars.',
        lineup: [
          TeamPlayer(position: 'GK',  name: 'Bono',                role: 'Moroccan wall',           photoUrl: _p(284507)),
          TeamPlayer(position: 'RB',  name: 'Saud Abdulhamid',     role: 'Saudi full-back',         photoUrl: _p(284624)),
          TeamPlayer(position: 'CB',  name: 'Ali Al-Bulayhi',      role: 'Saudi defender',          photoUrl: _p(284625)),
          TeamPlayer(position: 'CB',  name: 'Koulibaly',           role: 'Senegalese wall',         photoUrl: _p(2952)),
          TeamPlayer(position: 'LB',  name: 'Yasser Al-Shahrani',  role: 'Saudi left back',         photoUrl: _p(284626)),
          TeamPlayer(position: 'CM',  name: 'Rúben Neves',         role: 'Portuguese maestro',      photoUrl: _p(284627)),
          TeamPlayer(position: 'CM',  name: 'Malcom',              role: 'Brazilian star',          photoUrl: _p(284628)),
          TeamPlayer(position: 'CM',  name: 'Mohamed Kanno',       role: 'Saudi engine',            photoUrl: _p(284629)),
          TeamPlayer(position: 'RW',  name: 'Sergej Milinković-Savić', role: 'Serbian titan',       photoUrl: _p(284566)),
          TeamPlayer(position: 'ST',  name: 'Aleksandar Mitrović', role: 'Serbian powerhouse',      photoUrl: _p(2953)),
          TeamPlayer(position: 'LW',  name: 'Neymar Jr',           role: 'Brazilian legend',        photoUrl: _p(276)),
        ],
      );
    }

    // ── Unknown team — generic numbered formation so the pitch always shows ──
    return TeamFormation(
      formation: '4-3-3',
      description: '',
      lineup: List.generate(11, (i) {
        const positions = ['GK', 'RB', 'CB', 'CB', 'LB', 'CM', 'CM', 'CM', 'RW', 'ST', 'LW'];
        const numbers  = [1,     2,    5,    4,    3,    6,    8,    10,   7,    9,    11  ];
        return TeamPlayer(
          position: positions[i],
          name: '',   // empty = only show shirt number on pitch
          role: '',
          number: numbers[i],
        );
      }),
    );
  }
}
