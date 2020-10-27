import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flame/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/animation.dart' as FlameAnimation;

import '../game.dart';
import 'boss_shoots.dart';

class BossEnemy {
  Rect position;
  Sprite boss;
  final MyGame game;
  int vidaInicial = 2500;
  int vida = 2500;
  bool loaded = false;
  double speed = -4.0;
  bool bGoToSecondStage = false;
  Timer shootCreator;
  List<BossShoots> enemyShoots = [];
  List<BossShoots> dividedShoots = [];
  double size;
  Random random;
  int numberShip;
  String bossType;
  BossEnemy(this.game) {
    _start();
  }
  void _start() async {
    vidaInicial +=(game.fase*25);
    vida += (game.fase*25);
    random = Random();
    numberShip = random.nextInt(10);
    while (numberShip == 0) {
      numberShip = random.nextInt(10);
    }
    bossType = 'model$numberShip.png';
    size = 180;
    boss = Sprite(bossType);
    position = Rect.fromLTWH(game.screenSize.width - size,
        game.screenSize.height / 2 - (size / 2), size, size);

    //Criação de tiro do inimigo
    shootCreatorFunction(stage: 0);
    shootCreator.start();
    //Fim Criação de tiro do inimigo
  }

  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.center.dx, position.center.dy);
    canvas.rotate(-pi / 2);
    canvas.translate(-position.center.dx, -position.center.dy);
    boss.renderRect(canvas, position);
    canvas.restore();
    enemyShoots.forEach((shoot) {
      shoot.render(canvas);
    });
    dividedShoots.forEach((shoot) {
      shoot.render(canvas);
    });
  }

  void update(double dt) {
    if (shootCreator != null) {
      shootCreator.update(dt);
    }
    if (vida / vidaInicial <= 0.7) {
      if (!bGoToSecondStage) {
        bGoToSecondStage = true;
        shootCreatorFunction(stage: 1);
        shootCreator.start();
      }
    }
    enemyShoots.forEach((shoot) {
      if (shoot.directionOption == null) {
        Random random = Random();
        shoot.directionOption = random.nextInt(3);
        shoot.angleDirection =
            pi / <double>[1.715, 2, 2.4][shoot.directionOption];
        shoot.position = shoot.position.translate(
            (-400 * dt * sin(shoot.angleDirection)),
            -400 * dt * -cos(shoot.angleDirection));
        shoot.distance += -400 * dt * sin(shoot.angleDirection);
      } else {
        shoot.position = shoot.position.translate(
            (-400 * dt * sin(shoot.angleDirection)),
            -400 * dt * -cos(shoot.angleDirection));
        shoot.distance += -400 * dt * sin(shoot.angleDirection);
        if (shoot.distance.abs() >
                [
                  game.screenSize.width * 0.15,
                  game.screenSize.width * 0.3,
                  game.screenSize.width*0.45,
                  game.screenSize.width*0.6
                ][random.nextInt(4)] &&
            !shoot.alreadyMultiplied) {
          final animation = FlameAnimation.Animation.sequenced("bullet.png", 4,
              textureWidth: 8, textureHeight: 16, stepTime: 0.05);
          animation.loop = true;
          for (int i = 0; i < 2; i++) {
            switch (i) {
              case 0:
                dividedShoots.add(
                  BossShoots()
                    ..animation = animation
                    ..angleDirection = shoot.angleDirection + 0.1
                    ..position = Rect.fromCenter(
                        center: shoot.position.center, width: 16, height: 16),
                );
                break;
              case 1:
                dividedShoots.add(
                  BossShoots()
                    ..animation = animation
                    ..angleDirection = shoot.angleDirection - 0.1
                    ..position = Rect.fromCenter(
                        center: shoot.position.center, width: 16, height: 16),
                );
                break;
                break;
            }
          }
          shoot.alreadyMultiplied = true;
        }
      }
      shoot.update(dt);
    });
    dividedShoots.forEach((shoot) {
      shoot.position = shoot.position.translate(
          (-400 * dt * sin(shoot.angleDirection)),
          -400 * dt * -cos(shoot.angleDirection));
      shoot.update(dt);
    });
    dividedShoots.forEach((shoot) {
      if(shoot.position.overlaps(game.playerShip.rect)){
        shoot.atingiuAlvo = true;
        game.createExplosionAt(shoot.position.left, shoot.position.top);
      }
    });
    position = position.translate(speed * dt, 0);
    if(position.left <=0){
      
    }
    
  }

  void shootCreatorFunction({int stage}) {
    switch (stage) {
      case 0:
        shootCreator = Timer(1.8, repeat: true, callback: () {
          final animation = FlameAnimation.Animation.sequenced("bullet.png", 4,
              textureWidth: 8, textureHeight: 16, stepTime: 0.05);
          animation.loop = true;
          enemyShoots.add(
            BossShoots()
              ..animation = animation
              ..position = Rect.fromCenter(
                  center: position.center, width: 16, height: 16),
          );
        });
        break;
      case 1:
        shootCreator.stop();
        shootCreator = Timer(1.8 - (game.fase/15), repeat: true, callback: () {
          final animation = FlameAnimation.Animation.sequenced("bullet.png", 4,
              textureWidth: 8, textureHeight: 16, stepTime: 0.05);
          animation.loop = true;
          enemyShoots.add(
            BossShoots()
              ..animation = animation
              ..position = Rect.fromCenter(
                  center: position.center, width: 16, height: 16),
          );
        });
        break;
    }
  }
}
