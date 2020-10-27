import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:warship_survival/game_src/game.dart';

class BossHealthBar extends StatelessWidget {
  final MyGame game;

  const BossHealthBar({Key key, this.game}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double percentageLife = game.showBoss ? game.boss.vida / game.boss.vidaInicial : 0;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: game.size.width * 0.4,
        child: Column(
          children: <Widget>[
            Text(
              game.showBoss ? 'B O S S' : 'P H A S E - ${game.fase}',
              style: TextStyle(
                  fontFamily: 'Karma', color: Colors.white, fontSize: 35.0),
            ),
            game.showBoss ?SizedBox(
              height: 3.0,
            ) : Container(),
            game.showBoss ? Opacity(
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
                maxValue: game.boss.vidaInicial,
                currentValue: game.boss.vida,
                displayText: '/${game.boss.vidaInicial}',
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
