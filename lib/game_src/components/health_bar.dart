import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:warship_survival/game_src/game.dart';

class HealthBar extends StatelessWidget {
  final MyGame game;

  const HealthBar({Key key, this.game}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double percentageLife = game.playerShip.vida / game.playerShip.vidaInicial;
    return       Positioned.fromRect(
          rect: Rect.fromLTWH(game.playerShip.rect.left - game.playerShip.size / 3,
              game.playerShip.rect.top - game.playerShip.size / 2, 120, 15),
          child: Opacity(
            opacity: 0.85,
            child: FAProgressBar(
              progressColor: percentageLife <= 1.0 && percentageLife >= 0.7
                  ? Colors.green[400]
                  : percentageLife < 0.7 && percentageLife >= 0.35
                      ? Colors.yellow[400]
                      : percentageLife < 0.35 && percentageLife >= 0.0
                          ? Colors.red[400]
                          : Colors.red[400],
              borderRadius: 15.0,
              maxValue: game.playerShip.vidaInicial,
              currentValue: game.playerShip.vida.round(),
              displayText: '/${game.playerShip.vidaInicial}',
            ),
          ));
  }
}