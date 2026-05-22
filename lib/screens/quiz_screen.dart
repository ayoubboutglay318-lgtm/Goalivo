import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    question: "Who has won the most Ballon d'Or awards?",
    options: ['Cristiano Ronaldo', 'Ronaldinho', 'Zinedine Zidane', 'Lionel Messi'],
    answerIndex: 3,
    fact: "Lionel Messi has won a record 8 Ballon d'Or awards.",
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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late List<_Question> _deck;
  int _index = 0;
  int? _selected;
  bool _revealed = false;
  int _score = 0;
  int _streak = 0;
  int _xpEarned = 0;
  bool _done = false;
  double _progressTarget = 0;

  // Animations
  late AnimationController _questionCtrl;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;

  late AnimationController _xpPopupCtrl;
  late Animation<double> _xpPopupFade;
  late Animation<Offset> _xpPopupSlide;

  int _lastXpGained = 0;

  static const _xpCorrect = 15;
  static const _xpWrong = 3;

  @override
  void initState() {
    super.initState();
    _setupDeck();
    _progressTarget = 1 / 10;

    _questionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _questionFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _questionCtrl, curve: Curves.easeOut),
    );
    _questionSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _questionCtrl, curve: Curves.easeOut),
    );
    _questionCtrl.forward();

    _xpPopupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _xpPopupFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _xpPopupCtrl,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );
    _xpPopupSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: const Offset(0, -0.5)).animate(
      CurvedAnimation(parent: _xpPopupCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _xpPopupCtrl.dispose();
    super.dispose();
  }

  void _setupDeck() {
    final shuffled = List<_Question>.from(_questions)..shuffle(Random());
    _deck = shuffled.take(10).toList();
  }

  Future<void> _select(int index) async {
    if (_revealed) return;
    final question = _deck[_index];
    final correct = index == question.answerIndex;
    final xp = correct ? _xpCorrect : _xpWrong;

    HapticFeedback.selectionClick();

    setState(() {
      _selected = index;
      _revealed = true;
      if (correct) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
      _xpEarned += xp;
      _lastXpGained = xp;
    });

    if (correct) {
      HapticFeedback.lightImpact();
      _xpPopupCtrl.forward(from: 0);
    } else {
      HapticFeedback.heavyImpact();
    }

    if (widget.xpService != null) {
      await widget.xpService!.trackEvent(XpEvent.viewMatchDetail);
    }
  }

  void _next() {
    if (_index < _deck.length - 1) {
      final nextProgress = (_index + 2) / _deck.length;
      _questionCtrl.reverse().then((_) {
        if (mounted) {
          setState(() {
            _index++;
            _selected = null;
            _revealed = false;
            _progressTarget = nextProgress;
          });
          _questionCtrl.forward();
        }
      });
    } else {
      setState(() => _done = true);
    }
    HapticFeedback.selectionClick();
  }

  void _restart() {
    setState(() {
      _setupDeck();
      _index = 0;
      _selected = null;
      _revealed = false;
      _score = 0;
      _streak = 0;
      _xpEarned = 0;
      _done = false;
      _progressTarget = 1 / 10;
    });
    _questionCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return _ResultView(
        score: _score,
        total: _deck.length,
        xpEarned: _xpEarned,
        onRestart: _restart,
      );
    }

    final question = _deck[_index];
    final theme = Theme.of(context);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('🧠', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Football Quiz',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Question ${_index + 1} of ${_deck.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score + streak
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_score correct',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (_streak >= 2) ...[
                      const SizedBox(height: 4),
                      _StreakBadge(streak: _streak),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animated progress bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: _progressTarget - 1 / _deck.length, end: _progressTarget),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (_, value, child) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Animated question + options
            FadeTransition(
              opacity: _questionFade,
              child: SlideTransition(
                position: _questionSlide,
                child: Column(
                  children: [
                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        question.question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Options
                    ...question.options.asMap().entries.map((entry) {
                      final i = entry.key;
                      return _OptionTile(
                        label: entry.value,
                        index: i,
                        selected: _selected == i,
                        revealed: _revealed,
                        correct: i == question.answerIndex,
                        onTap: () => _select(i),
                      );
                    }),

                    // Fact card
                    if (_revealed) ...[
                      const SizedBox(height: 12),
                      _FactCard(fact: question.fact),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _index < _deck.length - 1 ? 'Next Question →' : 'See Results',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // XP popup overlay
        if (_revealed)
          Positioned(
            top: 120,
            right: 24,
            child: FadeTransition(
              opacity: _xpPopupFade,
              child: SlideTransition(
                position: _xpPopupSlide,
                child: _XpPopup(xp: _lastXpGained, correct: _selected == _deck[_index].answerIndex),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Streak badge ───────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            '$streak streak',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── XP popup ──────────────────────────────────────────────────────────────────

class _XpPopup extends StatelessWidget {
  const _XpPopup({required this.xp, required this.correct});
  final int xp;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFF00C853) : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(correct ? '⭐' : '📚', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            '+$xp XP',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option tile ────────────────────────────────────────────────────────────────

class _OptionTile extends StatefulWidget {
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
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_OptionTile old) {
    super.didUpdateWidget(old);
    if (widget.revealed && !old.revealed && widget.selected && !widget.correct) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color borderColor;
    Widget? trailing;

    if (widget.revealed) {
      if (widget.correct) {
        bgColor = const Color(0xFF00C853).withValues(alpha: 0.15);
        borderColor = const Color(0xFF00C853);
        trailing = const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 22);
      } else if (widget.selected) {
        bgColor = Colors.red.withValues(alpha: 0.12);
        borderColor = Colors.red;
        trailing = const Icon(Icons.cancel_rounded, color: Colors.red, size: 22);
      } else {
        bgColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
        borderColor = theme.colorScheme.outline.withValues(alpha: 0.1);
      }
    } else {
      bgColor = _pressed
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : theme.colorScheme.surfaceContainerHighest;
      borderColor = _pressed
          ? theme.colorScheme.primary.withValues(alpha: 0.4)
          : theme.colorScheme.outline.withValues(alpha: 0.2);
    }

    final labels = ['A', 'B', 'C', 'D'];
    final labelColor = widget.revealed && widget.correct
        ? const Color(0xFF00C853)
        : widget.revealed && widget.selected
            ? Colors.red
            : widget.revealed
                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                : theme.colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shake.value, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.revealed) setState(() => _pressed = true);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (!widget.revealed) widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[widget.index],
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: labelColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.revealed && !widget.correct && !widget.selected
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fact card ─────────────────────────────────────────────────────────────────

class _FactCard extends StatefulWidget {
  const _FactCard({required this.fact});
  final String fact;

  @override
  State<_FactCard> createState() => _FactCardState();
}

class _FactCardState extends State<_FactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.fact,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Result view ───────────────────────────────────────────────────────────────

class _ResultView extends StatefulWidget {
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
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.easeOut));
    _ctrl.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = widget.score / widget.total;
    final emoji = pct >= 0.8 ? '🏆' : pct >= 0.6 ? '⚽' : pct >= 0.4 ? '🎽' : '📚';
    final label = pct >= 0.8
        ? 'Football Expert!'
        : pct >= 0.6
            ? 'Solid Knowledge!'
            : pct >= 0.4
                ? 'Keep Practicing'
                : 'Study Up!';
    final labelColor = pct >= 0.8
        ? const Color(0xFF00C853)
        : pct >= 0.6
            ? Colors.amber
            : pct >= 0.4
                ? Colors.orange
                : Colors.redAccent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Text(emoji, style: const TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: labelColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.score} / ${widget.total} correct',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              // XP earned
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.2),
                      const Color(0xFF7C3AED).withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+${widget.xpEarned} XP earned',
                          style: const TextStyle(
                            color: Color(0xFFA78BFA),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Added to your profile',
                          style: TextStyle(
                            color: const Color(0xFFA78BFA).withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: widget.onRestart,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
