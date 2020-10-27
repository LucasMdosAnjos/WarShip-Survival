import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:warship_survival/game_src/game.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class WidgetsDelay extends StatelessWidget {
  final MyGame game;

  const WidgetsDelay({Key key, this.game}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Opacity(
          opacity: 0.85,
          child: Container(
            width: 250,
            child: Row(
              children: <Widget>[
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 5.0,
                  percent: game.delayUseLifeAgain == 0
                      ? 1.0
                      : (game.delayUseLifeAgain / game.lifeDelay),
                  center: game.delayUseLifeAgain == 0
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/images/more.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            '${(game.lifeDelay - game.delayUseLifeAgain).floor()}',
                            style: TextStyle(
                                fontFamily: 'Karma',
                                color: Colors.white,
                                fontSize: 25.0),
                          ),
                      ),
                  progressColor: Colors.green,
                ),
                SizedBox(
                  width: 5,
                ),
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 5.0,
                  percent: game.delayUseMissileAgain == 0
                      ? 1.0
                      : (game.delayUseMissileAgain / game.carryGunMissileDelay),
                  center: (game.bCanMissile) ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/atomic-bomb.png',
                      fit: BoxFit.contain,
                    ),
                  ) : Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            '${(game.carryGunMissileDelay - game.delayUseMissileAgain).floor()}',
                            style: TextStyle(
                                fontFamily: 'Karma',
                                color: Colors.white,
                                fontSize: 25.0),
                          ),
                      ),
                  progressColor: Colors.green,
                ),
                SizedBox(
                  width: 5,
                ),
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 5.0,
                  percent: (game.bCanFire)
                      ? (game.shootsGiven / game.totalShoots)
                      : game.delayUseShootAgain == 0
                          ? 1.0
                          : (game.delayUseShootAgain / game.carryGunShootDelay),
                  center: (game.bCanFire)
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FlareActor(
                            'assets/AmmoButton.flr',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: 'colorChange',
                          ))
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '${(game.carryGunShootDelay - game.delayUseShootAgain).floor()}',
                            style: TextStyle(
                                fontFamily: 'Karma',
                                color: Colors.white,
                                fontSize: 25.0),
                          ),
                        ),
                  progressColor: Colors.brown[400],
                ),
              ],
            ),
          ),
        ));
  }
}
