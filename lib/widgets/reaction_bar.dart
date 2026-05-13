import 'package:flutter/material.dart';

import '../services/reactions_service.dart';

class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.fixtureId,
    required this.reactionsService,
  });
  final int fixtureId;
  final ReactionsService reactionsService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: reactionsService,
      builder: (context, _) {
        final chosen = reactionsService.reactionFor(fixtureId);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: kReactionEmojis.map((emoji) {
            final selected = chosen == emoji;
            return GestureDetector(
              onTap: () => reactionsService.react(fixtureId, emoji),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: selected ? 20 : 17,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
