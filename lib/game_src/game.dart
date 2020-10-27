import 'dart:math';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flame/flame_audio.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/time.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:warship_survival/game_src/components/boss_health_bar.dart';
import 'package:warship_survival/game_src/objects/boss_enemy.dart';
import 'package:warship_survival/game_src/objects/controller.dart';
import 'package:warship_survival/game_src/objects/player_ship.dart';
import 'package:warship_survival/game_src/objects/player_shoots.dart';
import 'package:warship_survival/game_src/objects/simple_enemy.dart';
import 'package:warship_survival/game_src/objects/explosion.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:warship_survival/screens/chooseShip.dart';
import 'package:warship_survival/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/health_bar.dart';
import 'components/widgets_delay.dart';
import 'objects/planet.dart';
import 'objects/player_missile.dart';
import 'objects/stars.dart';
import 'package:flutter/foundation.dart';

class MyGame extends BaseGame with HasWidgetsOverlay, TapDetector {
  BuildContext context;
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;
  //Variável Jogo pausado
  bool isPaused = false;
  bool showBoss = false;
  BossEnemy boss;
  int fase;

  //Variáveis de proporção
  Size screenSize;
  double tileSize;

  //Nave do jogador e controlador da nave
  PlayerShip playerShip;
  Controller controller;
  String shipModel;
  int vida;

  //Variáveis tiro do jogador
  Timer timerCarryGunShootDelay;
  Timer shootCreator;
  Timer checkSavedVariables;
  bool bCanFire = true;
  double totalShoots = 40;
  double shootsGiven = 0;
  double carryGunShootDelay = 2;
  double delayUseShootAgain = 0;

  //Variável misseis do jogador
  Timer timerCarryGunMissileDelay;
  bool bCanMissile = true;
  double totalMissiles = 2;
  double missilesGiven = 0;
  double carryGunMissileDelay = 25;
  double delayUseMissileAgain = 0;

  //Variáveis vida do jogador
  Timer enemyCreator;
  bool bCanUseLifeAgain = true;
  double lifeDelay = 10;
  double delayUseLifeAgain = 0;
  Timer timerLifeDelay;

  //Entidades do jogo
  List<Shoots> shoots = [];
  List<Missile> missiles = [];
  List<Enemy> enemies = [];
  List<Explosion> explosions = [];
  List<Stars> stars = [];
  List<Planet> planets = [];

  //variavel aleatoria
  Random random;
  MyGame(this.screenSize,
      {@required this.shipModel,
      @required this.fase,
      @required this.context,
      @required this.vida}) {
    //Carregar anuncio para exibir depois
    interstitialAd = AdmobInterstitial(
      adUnitId: (kReleaseMode)
          ? 'ca-app-pub-9480221320403320/5003772529'
          : 'ca-app-pub-3940256099942544/8691691433',
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    )..load();

    rewardAd = AdmobReward(
        adUnitId: (kReleaseMode)
            ? 'ca-app-pub-9480221320403320/9461483169'
            : 'ca-app-pub-3940256099942544/5224354917',
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          if (event == AdmobAdEvent.rewarded ||
              event == AdmobAdEvent.completed) {
            showCupertinoDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: Text(
                      'Thanks for watching this Rewarded Ad!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                            'Reward Type: ${args == null ? 'Health Increase' : args['type']}'),
                        Text(
                            'Amount: ${args == null ? '30' : args['amount']} of Health.'),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          updateLife();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  );
                });
          }
          if (event == AdmobAdEvent.closed) rewardAd.load();
        })
      ..load();

    //Fim anuncio

    random = Random();
    tileSize = screenSize.height / 9;
    playerShip = PlayerShip(this, shipModel: shipModel, vidaInicial: vida);
    controller = Controller(this);
    enemyCreator = Timer(1.0, repeat: true, callback: () {
      enemies.add(Enemy('PurpleEnemy', this)
        ..position = Rect.fromLTWH(screenSize.width,
            (screenSize.height - 50) * random.nextDouble(), 25, 25));
    });
    enemyCreator.start();
    checkSavedVariables = Timer(2, repeat: true, callback: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      fase = prefs.getInt('fase');
      shipModel = prefs.getString('shipModel');

      if (!prefs.getBool('rated') && fase > 2) {
        isPaused = true;
        showCupertinoDialog(
            context: context,
            builder: (_) {
              return CupertinoAlertDialog(
                title: Text(
                  'Rating this App',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                ),
                content: Column(
                  children: <Widget>[
                    Text(
                      'Can you Rate my Game now?',
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    RatingBar(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 1.5),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      await prefs.setBool('rated', true);
                      Navigator.pop(context);
                      await Future.delayed(Duration(milliseconds: 750));
                      isPaused = false;
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Rate now!',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () async {
                      await prefs.setBool('rated', true);
                      const url = 'https://play.google.com/store/apps/details?id=com.lucas.warship_survival';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        //Do Something
                      }
                      Navigator.pop(context);
                      isPaused = false;
                    },
                  ),
                ],
              );
            });
      }
    });
    checkSavedVariables.start();
    shootCreator = Timer(0.2, repeat: true, callback: () {
      shootsGiven++;
      if (shootsGiven <= totalShoots) {
        // final animation = FlameAnimation.Animation.sequenced("bullet.png", 4,
        //     textureWidth: 8, textureHeight: 16, stepTime: 0.05);
        //animation.loop = true;
        shoots.add(
          Shoots(this)
            //..animation = animation
            ..position = Rect.fromCenter(
                center: playerShip.rect.center, width: 24, height: 24),
        );
      } else {
        shootCreator.stop();
        timerCarryGunShootDelay.start();
        bCanFire = false;
      }
    });
    for (int i = 0; i < 20; i++) {
      stars.add(Stars(this)
        ..position = Rect.fromLTWH(
            (screenSize.width - 25) * random.nextDouble(),
            (screenSize.height - 25) * random.nextDouble(),
            24,
            24));
    }
    planets.add(Planet('Jupyter.flr')
      ..position = Rect.fromLTWH((screenSize.width / 1.25 - 50),
          (screenSize.height / 1.5 - 50), 100, 100));
    planets.add(Planet('Saturn.flr')
      ..position = Rect.fromLTWH((screenSize.width - 75), (0), 100, 100));
    planets.add(Planet('Planet.flr')
      ..position = Rect.fromLTWH((screenSize.width / 2), (-35), 100, 100));

    timerLifeDelay = Timer(1, repeat: true, callback: () {
      delayUseLifeAgain += 1;
      if (delayUseLifeAgain == lifeDelay) {
        timerLifeDelay.stop();
        delayUseLifeAgain = 0;
        bCanUseLifeAgain = true;
      }
    });
    timerCarryGunShootDelay = Timer(1, repeat: true, callback: () {
      delayUseShootAgain += 1;
      if (delayUseShootAgain == carryGunShootDelay) {
        timerCarryGunShootDelay.stop();
        delayUseShootAgain = 0;
        shootsGiven = 0;
        bCanFire = true;
      }
    });
    timerCarryGunMissileDelay = Timer(1, repeat: true, callback: () {
      delayUseMissileAgain += 1;
      if (delayUseMissileAgain == carryGunMissileDelay) {
        timerCarryGunMissileDelay.stop();
        delayUseMissileAgain = 0;
        missilesGiven = 0;
        bCanMissile = true;
      }
    });
  }

  void addWidgetsDelay() {
    addWidgetOverlay(
        'WidgetsDelay',
        WidgetsDelay(
          game: this,
        ));
  }

  void updateHealthBar() {
    addWidgetOverlay(
      'HealthBar',
      HealthBar(
        game: this,
      ),
    );
  }

  void pauseMenu() {
    addWidgetOverlay(
        'PauseMenu',
        Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/vortex.png'),
                fit: BoxFit.cover),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blue[400].withOpacity(0.65),
                      borderRadius: BorderRadius.circular(15.0)),
                  alignment: Alignment.center,
                  width: screenSize.width * 0.4,
                  height: screenSize.height * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Paused',
                          style: TextStyle(
                              fontFamily: 'ZeroVelo',
                              color: Colors.black,
                              fontSize: 35.0),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              removeWidgetOverlay('PauseMenu');
                              isPaused = false;
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(28.0)),
                              child: Image.asset(
                                'assets/images/TxtPlay.png',
                                width: 70,
                                height: 70,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              SystemNavigator.pop();
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(28.0)),
                              child: Image.asset(
                                'assets/images/TxtQuit.png',
                                width: 70,
                                height: 70,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.red[300],
                            ),
                            iconSize: 70,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ChooseShip(
                                            edit: true,
                                            size: size,
                                          )));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                GestureDetector(
                  onTap: () {
                    rewardAd.show();
                  },
                  child: Container(
                    width: screenSize.width * 0.45,
                    padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: Colors.blue,
                          size: 30,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: AutoSizeText(
                            'Increase Health watching Rewarded Ads!',
                            style: TextStyle(
                                fontFamily: 'Karmatic',
                                color: Colors.green,
                                letterSpacing: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                AdmobBanner(
                  adUnitId: (kReleaseMode)
                      ? 'ca-app-pub-9480221320403320/1379495937'
                      : 'ca-app-pub-3940256099942544/6300978111',
                  adSize: AdmobBannerSize.BANNER,
                  listener: (AdmobAdEvent event, Map<String, dynamic> args) {},
                  onBannerCreated: (AdmobBannerController controller) {},
                ),
              ],
            ),
          ),
        ));
  }

  void updateBossHealthBar() {
    addWidgetOverlay('BossHealthBar', BossHealthBar(game: this));
  }

  void gameOver() {
    addWidgetOverlay(
        'GameOver',
        Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/vortex.png'),
                fit: BoxFit.cover),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.red[700].withOpacity(0.65),
                      borderRadius: BorderRadius.circular(15.0)),
                  alignment: Alignment.center,
                  width: screenSize.width * 0.4,
                  height: screenSize.height * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'GAME OVER',
                        style: TextStyle(
                            fontFamily: 'Karmatic',
                            color: Colors.black,
                            fontSize: 25),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              removeWidgetOverlay('GameOver');
                              enemyCreator.stop();
                              enemies.clear();
                              isPaused = false;

                              playerShip = PlayerShip(this,
                                  shipModel: shipModel, vidaInicial: vida);
                              enemyCreator.start();
                              showBoss = false;
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(28.0)),
                              child: Image.asset(
                                'assets/images/TxtPlay.png',
                                width: 70,
                                height: 70,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              SystemNavigator.pop();
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(28.0)),
                              child: Image.asset(
                                'assets/images/TxtQuit.png',
                                width: 70,
                                height: 70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                GestureDetector(
                  onTap: () {
                    rewardAd.show();
                  },
                  child: Container(
                    width: screenSize.width * 0.45,
                    padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: Colors.blue,
                          size: 30,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: AutoSizeText(
                            'Increase Health watching Rewarded Ads!',
                            style: TextStyle(
                                fontFamily: 'Karmatic',
                                color: Colors.green,
                                letterSpacing: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void pause() {
    isPaused = true;
  }

  void shootMissile() {
    if (bCanMissile) {
      missilesGiven++;
      final animation = FlameAnimation.Animation.sequenced("bullet.png", 4,
          textureWidth: 8, textureHeight: 16, stepTime: 0.05);
      animation.loop = true;
      missiles.add(
        Missile(this)
          ..position = Rect.fromCenter(
              center: playerShip.rect.center, width: 24, height: 24),
      );
      if (missilesGiven == totalMissiles) {
        bCanMissile = false;
        timerCarryGunMissileDelay.start();
      }
    }
  }

  void beginFire(LongPressStartDetails details) {
    if (bCanFire) {
      shootCreator.start();
      addWidgetOverlay(
        'AmmoWidget',
        Align(
            alignment: Alignment.topRight,
            child: Opacity(
              opacity: 0.85,
              child: Container(
                width: 50,
                height: 50,
                child: FlareActor(
                  'assets/ammo.flr',
                  animation: 'Shooting',
                ),
              ),
            )),
      );
    }
  }

  void stopFire() {
    shootCreator.stop();
    removeWidgetOverlay('AmmoWidget');
  }

  void increaseLife() {
    if (bCanUseLifeAgain) {
      FlameAudio audio = FlameAudio();
      audio.play('life_pickup.flac', volume: 1.0);
      bCanUseLifeAgain = false;
      playerShip.vida += (playerShip.vidaInicial * 0.15).floor();
      timerLifeDelay.start();
    }
  }

  void onPanStart(DragStartDetails details) {
    controller.onPanStart(details);
  }

  void onPanUpdate(DragUpdateDetails details) {
    controller.onPanUpdate(details);
  }

  void onPanEnd(DragEndDetails details) {
    controller.onPanEnd(details);
  }

  Future<void> updatePhase({@required int value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fase', value);
  }

  Future updateLife() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool exec = await prefs.setInt('vida', playerShip.vidaInicial += 30);
    while (!exec) {
      exec = await prefs.setInt('vida', playerShip.vidaInicial += 30);
    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => HomeScreen(
                size: size,
                shipModel: prefs.getString('shipModel'),
                fase: prefs.getInt('fase'),
                vida: prefs.getInt('vida'))));
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      if (playerShip.vida <= 0) {
        pause();
        gameOver();
      }
      timerCarryGunShootDelay.update(dt);
      timerCarryGunMissileDelay.update(dt);
      timerLifeDelay.update(dt);
      addWidgetsDelay();
      updateBossHealthBar();
      updateHealthBar();
      stars.forEach((star) => star.update(dt));
      planets.forEach((planet) => planet.update(dt));
      playerShip.update(dt);
      controller.update(dt);
      shootCreator.update(dt);
      checkSavedVariables.update(dt);
      enemyCreator.update(dt);

      enemies.forEach((enemy) {
        enemy.update(dt);
      });
      explosions.forEach((explosion) {
        explosion.update(dt);
      });
      explosions.removeWhere((explosion) => explosion.animation.isLastFrame);
      enemies.removeWhere((enemy) => enemy.position.right <= 0);
      enemies.removeWhere((enemy) {
        if (enemy.position.overlaps(playerShip.rect)) {
          playerShip.vida -= 15;
          return true;
        } else {
          return false;
        }
      });
      shoots.removeWhere((shoot) =>
          shoot.atingiuAlvo ||
          shoot.position.bottom <= 0 ||
          shoot.position.top >= screenSize.height ||
          shoot.position.left <= 0 ||
          shoot.position.right >= screenSize.width);
      missiles.removeWhere((missile) =>
          missile.atingiuAlvo ||
          missile.position.bottom <= 0 ||
          missile.position.top >= screenSize.height ||
          missile.position.left <= 0 ||
          missile.position.right >= screenSize.width);
      if (showBoss) {
        if (boss.vida <= 0) {
          updatePhase(value: fase + 1).then((value) {
            interstitialAd.show();
            enemyCreator.start();
            playerShip.inimigosDestruidos = 0;
            fase++;
            showBoss = false;
          });
        }
        boss.update(dt);
        boss.enemyShoots.removeWhere((shoot) =>
            shoot.alreadyMultiplied ||
            shoot.position.bottom <= 0 ||
            shoot.position.top >= screenSize.height ||
            shoot.position.left <= 0 ||
            shoot.position.right >= screenSize.width);

        boss.dividedShoots.removeWhere((shoot) {
          if (shoot.position.overlaps(playerShip.rect)) {
            playerShip.vida -= 30 + (fase / 2);
          }
          return (shoot.atingiuAlvo ||
              shoot.position.bottom <= 0 ||
              shoot.position.top >= screenSize.height ||
              shoot.position.left <= 0 ||
              shoot.position.right >= screenSize.width);
        });
      }
      missiles.forEach((missile) => missile.update(dt));
    } else {
      //Pausado
    }
  }

  void createExplosionAt(double x, double y, {bool isMissile = false}) {
    final animation = FlameAnimation.Animation.sequenced("explosion.png", 6,
        textureWidth: 32, textureHeight: 32, stepTime: 0.05);
    animation.loop = false;
    explosions.add(Explosion()
      ..animation = animation
      ..position = Rect.fromLTWH(
          x - 25, y - 25, !isMissile ? 50 : 125, !isMissile ? 50 : 125));
  }

  @override
  void render(Canvas canvas) {
    if (!isPaused) {
      stars.forEach((star) => star.render(canvas));
      planets.forEach((planet) => planet.render(canvas));
      playerShip.render(canvas);
      controller.render(canvas);
      shoots.forEach((element) {
        element.render(canvas);
      });
      missiles.forEach((missile) => missile.render(canvas));
      enemies.forEach((enemy) {
        enemy.render(canvas);
      });
      if (showBoss) {
        boss.render(canvas);
      }
      explosions.forEach((explosion) {
        explosion.render(canvas);
      });
    } else {
      //Pausado
    }
  }
}
