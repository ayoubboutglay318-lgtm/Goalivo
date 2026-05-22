import 'package:flutter/material.dart';

import '../models/match_models.dart';
import '../services/prediction_service.dart';
import '../services/xp_service.dart';
import '../screens/profile_screen.dart';

class PredictionWidget extends StatefulWidget {
  const PredictionWidget({
    super.key,
    required this.match,
    required this.predictionService,
    this.xpService,
  });
  final FootballMatch match;
  final PredictionService predictionService;
  final XpService? xpService;

  @override
  State<PredictionWidget> createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget> {
  int _home = 1;
  int _away = 1;
  bool _submitting = false;

  int get _fixtureId => widget.match.fixture.id ?? 0;
  String get _status => widget.match.fixture.status?.short ?? 'NS';
  bool get _isFinished => {'FT', 'AET', 'PEN'}.contains(_status);
  bool get _isLive => {'1H', '2H', 'HT', 'ET', 'P'}.contains(_status);
  bool get _canPredict => !_isFinished && !_isLive;

  @override
  void initState() {
    super.initState();
    _checkResult();
  }

  Future<void> _checkResult() async {
    if (!_isFinished) return;
    final actualHome = widget.match.goals.home;
    final actualAway = widget.match.goals.away;
    if (actualHome == null || actualAway == null) return;

    final xpEarned = await widget.predictionService.checkResult(
      fixtureId: _fixtureId,
      actualHome: actualHome,
      actualAway: actualAway,
    );
    if (xpEarned > 0 && widget.xpService != null && mounted) {
      // Award bonus XP via a silent trackEvent proxy
      XpToast.show(context, xpGained: xpEarned, newBadges: const []);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.predictionService.savePrediction(_fixtureId, _home, _away);
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.predictionService,
      builder: (context, _) {
        final pred = widget.predictionService.predictionFor(_fixtureId);
        final theme = Theme.of(context);

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Predict the Score',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (pred != null && pred.checkedResult)
                      _ResultBadge(pred: pred),
                  ],
                ),
                const SizedBox(height: 14),
                if (pred != null) ...[
                  // Show existing prediction
                  _PredictionDisplay(
                    pred: pred,
                    homeName: widget.match.teams.home.name ?? 'Home',
                    awayName: widget.match.teams.away.name ?? 'Away',
                    isFinished: _isFinished,
                    actualHome: widget.match.goals.home,
                    actualAway: widget.match.goals.away,
                  ),
                ] else if (_canPredict) ...[
                  // Input
                  _PredictInput(
                    homeName: widget.match.teams.home.name ?? 'Home',
                    awayName: widget.match.teams.away.name ?? 'Away',
                    home: _home,
                    away: _away,
                    onHomeChanged: (v) => setState(() => _home = v),
                    onAwayChanged: (v) => setState(() => _away = v),
                    onSubmit: _submitting ? null : _submit,
                  ),
                ] else ...[
                  Text(
                    _isLive ? 'Match is live — too late to predict!' : 'No prediction made.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.pred});
  final Prediction pred;

  @override
  Widget build(BuildContext context) {
    if (pred.wasCorrectScore) {
      return _badge('⚽ Exact score!', Colors.green);
    }
    if (pred.wasCorrectResult) {
      return _badge('✅ Correct result', Colors.teal);
    }
    return _badge('❌ Wrong', Colors.red);
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _PredictionDisplay extends StatelessWidget {
  const _PredictionDisplay({
    required this.pred,
    required this.homeName,
    required this.awayName,
    required this.isFinished,
    this.actualHome,
    this.actualAway,
  });
  final Prediction pred;
  final String homeName;
  final String awayName;
  final bool isFinished;
  final int? actualHome;
  final int? actualAway;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(homeName, textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${pred.homeGoals} - ${pred.awayGoals}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: Text(awayName, textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        if (isFinished && actualHome != null && actualAway != null) ...[
          const SizedBox(height: 8),
          Text(
            'Actual: $actualHome - $actualAway',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _PredictInput extends StatelessWidget {
  const _PredictInput({
    required this.homeName,
    required this.awayName,
    required this.home,
    required this.away,
    required this.onHomeChanged,
    required this.onAwayChanged,
    required this.onSubmit,
  });
  final String homeName;
  final String awayName;
  final int home;
  final int away;
  final ValueChanged<int> onHomeChanged;
  final ValueChanged<int> onAwayChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(homeName, textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  _ScoreStepper(value: home, onChanged: onHomeChanged),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('-',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w200,
                )),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(awayName, textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  _ScoreStepper(value: away, onChanged: onAwayChanged),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Lock In Prediction'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreStepper extends StatelessWidget {
  const _ScoreStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 20,
        ),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          onPressed: value < 20 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 20,
        ),
      ],
    );
  }
}
