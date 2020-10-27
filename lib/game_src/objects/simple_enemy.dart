import 'dart:math';
import 'dart:ui';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/time.dart';

import '../game.dart';
import 'enemy_shoot.dart';

class Enemy {
  Rect position;
  FlameAnimation.Animation animation;
  final String enemyType;
  final MyGame game;
  double enemySpeed = -200;
  double vida = 0;
  List<EnemyShoot> enemyShoots = [];
  Timer shootCreator;
  int rotationValue = 0;
  Random random;
  Enemy(this.enemyType, this.game) {
    if(enemyType == "PurpleEnemy"){
      vida = 50;
    }
    random = Random();
    rotationValue = random.nextInt(3);
    _start();

  }
  void _start() async {
    //Inicio configuração layout inimigo
      animation = FlameAnimation.Animation.sequenced('enemy.png', 4,
          textureWidth: 16, textureHeight: 16);
      animation.loop = true;
    //Fim Configuração layout inimigo

    //Criação de tiro do inimigo
    shootCreator = Timer(0.8, repeat: true, callback: () {
      final animation = FlameAnimation.Animation.sequenced("bullet.png", 4,
          textureWidth: 8, textureHeight: 16, stepTime: 0.05);
      animation.loop = true;
      enemyShoots.add(
        EnemyShoot()
          ..animation = animation
          ..position =
              Rect.fromCenter(center: position.center, width: 16, height: 16),
      );
    });
    shootCreator.start();
    //Fim Criação de tiro do inimigo
  }

  void render(Canvas canvas) { 
      if (animation.loaded()) {
        canvas.save();
    }
    canvas.restore();
        canvas.save();
        canvas.translate(position.center.dx, position.center.dy);
        canvas.rotate(pi/(<double>[1.5,2,3][rotationValue]));
        canvas.translate(-position.center.dx, -position.center.dy);
        animation.getSprite().renderRect(canvas, position);
        canvas.restore();
    enemyShoots.forEach((shoot) {
      shoot.render(canvas);
    });
  }

  void update(double dt) {
    double angleDirection =
            pi / <double>[1.715, 2, 2.4][rotationValue];
        position = position.translate(
            (enemySpeed * dt * sin(angleDirection)),
            enemySpeed * dt * -cos(angleDirection));


    enemyShoots.forEach((shoot) {
       shoot.angleDirection = pi/<double>[1.715,2,2.4][rotationValue];
        shoot.position = shoot.position.translate(
            (-400 * dt * sin(shoot.angleDirection)),
            -400 * dt * -cos(shoot.angleDirection));
      shoot.update(dt);
    });
    shootCreator.update(dt);
      animation.update(dt);
     enemyShoots.forEach((shoot) {
      shoot.update(dt);
    });
          for(int i = 0; i< enemyShoots.length; i++){
        EnemyShoot shoot = enemyShoots[i];
        if(shoot.position.overlaps(game.playerShip.rect))
        {
          game.playerShip.vida -=75;
          game.createExplosionAt(shoot.position.left, shoot.position.top);
          enemyShoots.removeAt(i);
        }
      }
  }
}
