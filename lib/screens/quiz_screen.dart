import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/xp_service.dart';

class _Question {
  const _Question({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.fact,
  });
  final String question;
  final List<String> options;
  final int answerIndex;
  final String fact;
}

const _questions = [
  _Question(
    question: 'Who won the 2022 FIFA World Cup?',
    options: ['France', 'Brazil', 'Argentina', 'Germany'],
    answerIndex: 2,
    fact: 'Argentina beat France 4-2 on penalties in one of the greatest World Cup finals ever.',
  ),
  _Question(
    question: 'How many players are on a football team on the pitch?',
    options: ['9', '10', '11', '12'],
    answerIndex: 2,
    fact: 'Each team fields exactly 11 players, including the goalkeeper.',
  ),
  _Question(
    question: 'Which club has won the most UEFA Champions League titles?',
    options: ['AC Milan', 'Barcelona', 'Bayern Munich', 'Real Madrid'],
    answerIndex: 3,
    fact: 'Real Madrid has won 15 Champions League titles — more than any other club.',
  ),
  _Question(
    question: 'Who is the all-time top scorer in FIFA World Cup history?',
    options: ['Ronaldo', 'Pelé', 'Messi', 'Miroslav Klose'],
    answerIndex: 3,
    fact: 'Miroslav Klose scored 16 World Cup goals across four tournaments for Germany.',
  ),
  _Question(
    question: 'In which year was FIFA founded?',
    options: ['1900', '1904', '1920', '1930'],
    answerIndex: 1,
    fact: 'FIFA was founded on May 21, 1904, in Paris, France.',
  ),
  _Question(
    question: 'Which country has won the most FIFA World Cups?',
    options: ['Germany', 'Italy', 'Argentina', 'Brazil'],
    answerIndex: 3,
    fact: "Brazil has won the World Cup 5 times — 1958, 1962, 1970, 1994, and 2002.",
  ),
  _Question(
    question: 'Who scored the famous "Hand of God" goal?',
    options: ['Pelé', 'Ronaldo', 'Zidane', 'Maradona'],
    answerIndex: 3,
    fact: 'Diego Maradona scored it with his hand against England in the 1986 World Cup quarter-final.',
  ),
  _Question(
    question: 'Who has won the most Ballon d\'Or awards?',
    options: ['Cristiano Ronaldo', 'Ronaldinho', 'Zinedine Zidane', 'Lionel Messi'],
    answerIndex: 3,
    fact: 'Lionel Messi has won a record 8 Ballon d\'Or awards.',
  ),
  _Question(
    question: 'What is the standard duration of a football match?',
    options: ['80 min', '85 min', '90 min', '100 min'],
    answerIndex: 2,
    fact: 'A standard match is 90 minutes: two 45-minute halves. Injury time and extra time are added separately.',
  ),
  _Question(
    question: 'Which team plays their home games at Anfield?',
    options: ['Everton', 'Arsenal', 'Manchester City', 'Liverpool'],
    answerIndex: 3,
    fact: "Anfield has been Liverpool FC's home ground since 1884.",
  ),
  _Question(
    question: 'What does "VAR" stand for in football?',
    options: ['Video Action Review', 'Visual Aid Referee', 'Video Assistant Referee', 'Virtual Action Rule'],
    answerIndex: 2,
    fact: 'VAR (Video Assistant Referee) was introduced to review clear and obvious errors in key match decisions.',
  ),
  _Question(
    question: 'How many teams are in the English Premier League?',
    options: ['16', '18', '20', '22'],
    answerIndex: 2,
    fact: 'The Premier League has 20 teams. The bottom 3 are relegated to the Championship each season.',
  ),
  _Question(
    question: 'Which player is nicknamed "El Pibe de Oro" (The Golden Boy)?',
    options: ['Messi', 'Ronaldo', 'Maradona', 'Pelé'],
    answerIndex: 2,
    fact: 'Diego Maradona earned this nickname due to his golden football talent from a very young age.',
  ),
  _Question(
    question: 'How far is the penalty spot from the goal line?',
    options: ['8 metres', '9 metres', '11 metres', '13 metres'],
    answerIndex: 2,
    fact: 'The penalty spot is 11 metres (12 yards) from the goal line as per FIFA rules.',
  ),
  _Question(
    question: 'Which country hosted the 2014 FIFA World Cup?',
    options: ['Russia', 'South Africa', 'Germany', 'Brazil'],
    answerIndex: 3,
    fact: 'Brazil hosted the 2014 World Cup. Germany beat Argentina 1-0 in the final.',
  ),
  _Question(
    question: 'A hat-trick means scoring how many goals in one match?',
    options: ['2', '3', '4', '5'],
    answerIndex: 1,
    fact: 'Scoring 3 goals in a single game is called a hat-trick.',
  ),
  _Question(
    question: 'Which club won the very first UEFA Champions League (1956)?',
    options: ['Juventus', 'AC Milan', 'Real Madrid', 'Ajax'],
    answerIndex: 2,
    fact: "Real Madrid won the first five European Cups in a row from 1956 to 1960.",
  ),
  _Question(
    question: 'Mohamed Salah plays for which national team?',
    options: ['Morocco', 'Tunisia', 'Algeria', 'Egypt'],
    answerIndex: 3,
    fact: "Mohamed Salah is Egypt's all-time top scorer and captain.",
  ),
  _Question(
    question: 'Which of these is NOT an offside rule exception?',
    options: ['Goalkeeper throw', 'Goal kick', 'Corner kick', 'Playing the ball backwards'],
    answerIndex: 0,
    fact: 'Players cannot be offside from goal kicks, corner kicks, or throw-ins.',
  ),
  _Question(
    question: 'How many substitutions are allowed per team in a standard match?',
    options: ['3', '4', '5', '6'],
    answerIndex: 2,
    fact: 'FIFA changed the rule in 2020 to allow 5 substitutions per team per match.',
  ),
  _Question(
    question: 'Which club is known as "The Old Lady" of Italian football?',
    options: ['AC Milan', 'Inter Milan', 'AS Roma', 'Juventus'],
    answerIndex: 3,
    fact: 'Juventus, founded in 1897, is nicknamed "La Vecchia Signora" (The Old Lady).',
  ),
  _Question(
    question: 'In which city is FC Barcelona based?',
    options: ['Madrid', 'Seville', 'Barcelona', 'Valencia'],
    answerIndex: 2,
    fact: 'FC Barcelona is based in Barcelona, Catalonia, Spain. Their stadium is the Spotify Camp Nou.',
  ),
  _Question(
    question: 'Which World Cup had the first ever goal?',
    options: ['1930', '1934', '1938', '1950'],
    answerIndex: 0,
    fact: 'The first FIFA World Cup was held in Uruguay in 1930. Lucien Laurent of France scored the first ever World Cup goal.',
  ),
  _Question(
    question: 'What colour is the away kit traditionally associated with Real Madrid?',
    options: ['Blue', 'Black', 'Red', 'White'],
    answerIndex: 0,
    fact: 'Real Madrid traditionally wear white at home and blue or dark colours away.',
  ),
  _Question(
    question: 'Which player scored for 5 different clubs in the Champions League?',
    options: ['Ronaldo', 'Zlatan Ibrahimović', 'Raul', 'Thierry Henry'],
    answerIndex: 1,
    fact: "Zlatan Ibrahimović scored Champions League goals for Ajax, Juventus, Inter, Barcelona, AC Milan and PSG — 6 clubs!",
  ),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, this.xpService});
  final XpService? xpService;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<_Question> _deck;
  int _index = 0;
  int? _selected;
  bool _revealed = false;
  int _score = 0;
  int _xpEarned = 0;
  bool _done = false;
  int _dailyCount = 0;

  static const _dailyLimit = 5;
  static const _xpCorrect = 15;
  static const _xpWrong = 3;

  @override
  void initState() {
    super.initState();
    _setupDeck();
    _loadDailyCount();
  }

  Future<void> _loadDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    setState(() {
      _dailyCount = prefs.getInt('quiz_$today') ?? 0;
    });
  }

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }

  void _setupDeck() {
    final rng = Random();
    final shuffled = List<_Question>.from(_questions)..shuffle(rng);
    _deck = shuffled.take(10).toList();
  }

  Future<void> _select(int index) async {
    if (_revealed) return;
    final question = _deck[_index];
    final correct = index == question.answerIndex;
    final xp = correct ? _xpCorrect : _xpWrong;

    setState(() {
      _selected = index;
      _revealed = true;
      if (correct) _score++;
      _xpEarned += xp;
    });

    // Increment daily count
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final count = (prefs.getInt('quiz_$today') ?? 0) + 1;
    await prefs.setInt('quiz_$today', count);
    setState(() => _dailyCount = count);

    // Award XP
    if (widget.xpService != null) {
      await widget.xpService!.trackEvent(
        correct ? XpEvent.viewMatchDetail : XpEvent.viewMatchDetail,
      );
      // Direct XP add via trackEvent isn't perfect here; we simulate it
    }
  }

  void _next() {
    if (_index < _deck.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _revealed = false;
      });
    } else {
      setState(() => _done = true);
    }
  }

  void _restart() {
    setState(() {
      _setupDeck();
      _index = 0;
      _selected = null;
      _revealed = false;
      _score = 0;
      _xpEarned = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _ResultView(score: _score, total: _deck.length, xpEarned: _xpEarned, onRestart: _restart);

    final question = _deck[_index];
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            const Text('🧠', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Football Quiz',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Question ${_index + 1} of ${_deck.length}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_score correct',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_dailyCount/$_dailyLimit today',
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _deck.length,
            minHeight: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        // Question card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              question.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Options
        ...question.options.asMap().entries.map((entry) {
          final i = entry.key;
          final opt = entry.value;
          return _OptionTile(
            label: opt,
            index: i,
            selected: _selected == i,
            revealed: _revealed,
            correct: i == question.answerIndex,
            onTap: () => _select(i),
          );
        }),
        if (_revealed) ...[
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.fact,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _next,
              child: Text(_index < _deck.length - 1 ? 'Next Question →' : 'See Results'),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.index,
    required this.selected,
    required this.revealed,
    required this.correct,
    required this.onTap,
  });
  final String label;
  final int index;
  final bool selected;
  final bool revealed;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? bg;
    Color? border;
    Widget? trailing;

    if (revealed) {
      if (correct) {
        bg = Colors.green.withValues(alpha: 0.15);
        border = Colors.green;
        trailing = const Icon(Icons.check_circle, color: Colors.green, size: 20);
      } else if (selected) {
        bg = Colors.red.withValues(alpha: 0.15);
        border = Colors.red;
        trailing = const Icon(Icons.cancel, color: Colors.red, size: 20);
      }
    } else if (selected) {
      bg = theme.colorScheme.primary.withValues(alpha: 0.15);
      border = theme.colorScheme.primary;
    }

    final labels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: revealed ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: border ?? theme.colorScheme.outline.withValues(alpha: 0.3),
            width: border != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: border?.withValues(alpha: 0.2) ??
                    theme.colorScheme.outline.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                labels[index],
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: border ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: revealed && !correct && !selected
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : null,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.score,
    required this.total,
    required this.xpEarned,
    required this.onRestart,
  });
  final int score;
  final int total;
  final int xpEarned;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = score / total;
    final emoji = pct >= 0.8 ? '🏆' : pct >= 0.6 ? '⚽' : pct >= 0.4 ? '🎽' : '📚';
    final label = pct >= 0.8 ? 'Football Expert!' : pct >= 0.6 ? 'Solid Knowledge!' : pct >= 0.4 ? 'Keep Practicing' : 'Study Up!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              label,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '$score / $total correct',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpEarned XP earned',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRestart,
                child: const Text('Play Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
