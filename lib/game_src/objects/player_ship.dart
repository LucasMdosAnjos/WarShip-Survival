import 'dart:math';
import 'dart:ui';
import 'package:flame/flare_animation.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:warship_survival/game_src/game.dart';
import 'package:warship_survival/game_src/objects/boss_enemy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'simple_enemy.dart';

class PlayerShip {
  final MyGame game;
  String shipModel;
  int vidaInicial;
  Sprite player;
  bool loaded = false;
  double aspectRatio = 1.4;
  double size;
  double vida;
  Rect rect;
  double inimigosDestruidos = 0;
  double speed = 140.0;
  bool move = false;
  double lastMoveRadAngle = 0.0;
  int numberShip;
  String playerType;
  Random random;
  PlayerShip(this.game,{this.shipModel,this.vidaInicial}) {
    _start();
  }
 void _start() async {
    random = Random();
    vida = vidaInicial.toDouble();
    numberShip = random.nextInt(3);
    while (numberShip == 0) {
      numberShip = random.nextInt(3);
    }
    numberShip = 4;
    playerType = '$shipModel';
      player = Sprite(playerType);
    size = 65;
    rect = Rect.fromLTWH(game.screenSize.width / 2 - (size / 2),
        game.screenSize.height / 2 - (size / 2), size, size);
  }

  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(lastMoveRadAngle == 0.0 ? 0.0 : lastMoveRadAngle + (pi / 2));
    canvas.translate(-rect.center.dx, -rect.center.dy);
      player.renderRect(canvas, rect);
    canvas.restore();
  }

  void update(double dt) {
    shipMove(dt);

    game.shoots.forEach((shoot) {
      if (shoot.angleDirection == null) {
        shoot.angleDirection = lastMoveRadAngle;
        shoot.position = shoot.position.translate(
            (shoot.shootSpeed * dt * sin(shoot.angleDirection - (pi / 2))),
            shoot.shootSpeed * dt * cos(shoot.angleDirection + (pi / 2)));
      } else {
        shoot.position = shoot.position.translate(
            (shoot.shootSpeed * dt * sin(shoot.angleDirection - (pi / 2))),
            shoot.shootSpeed * dt * cos(shoot.angleDirection + (pi / 2)));
      }
      shoot.update(dt);
    });
     game.missiles.forEach((missile) {
      if (missile.angleDirection == null) {
        missile.angleDirection = lastMoveRadAngle;
        missile.position = missile.position.translate(
            (missile.shootSpeed * dt * sin(missile.angleDirection - (pi / 2))),
            missile.shootSpeed * dt * cos(missile.angleDirection + (pi / 2)));
      } else {
        missile.position = missile.position.translate(
            (missile.shootSpeed * dt * sin(missile.angleDirection - (pi / 2))),
            missile.shootSpeed * dt * cos(missile.angleDirection + (pi / 2)));
      }
      missile.update(dt);
    });

    if (game.showBoss) {
      game.shoots.removeWhere((shoot) {
        if (shoot.position.overlaps(game.boss.position)) {
          for (int i = 0; i < 5; i++) {
            shoot.position = shoot.position.translate(
                (shoot.shootSpeed * dt * sin(shoot.angleDirection - (pi / 2))),
                shoot.shootSpeed * dt * cos(shoot.angleDirection + (pi / 2)));
          }
          game.createExplosionAt(shoot.position.left, shoot.position.top);
          game.boss.vida -= 35;
          return true;
        } else {
          return false;
        }
      });
      game.missiles.removeWhere((missile) {
        if (missile.position.overlaps(game.boss.position)) {
          for (int i = 0; i < 5; i++) {
            missile.position = missile.position.translate(
                (missile.shootSpeed * dt * sin(missile.angleDirection - (pi / 2))),
                missile.shootSpeed * dt * cos(missile.angleDirection + (pi / 2)));
          }
          game.createExplosionAt(missile.position.left, missile.position.top,isMissile: true);
          game.boss.vida -= (35*4);
          return true;
        } else {
          return false;
        }
      });
    } else {
      game.shoots.forEach((shoot) {
        for (int i = 0; i < game.enemies.length; i++) {
          Enemy enemy = game.enemies[i];
          if (shoot.position.overlaps(enemy.position)) {
            game.createExplosionAt(shoot.position.left, shoot.position.top);
            enemy.shootCreator.stop();
            enemy.enemyShoots.clear();
            game.enemies.removeAt(i);
            inimigosDestruidos++;
            shoot.atingiuAlvo = true;
            if (inimigosDestruidos == (7 + game.fase)) {
              game.enemies.clear();
              game.enemyCreator.stop();
              game.boss = BossEnemy(game);
              game.showBoss = true;
            }
          }
        }
      });
       game.missiles.forEach((missile) {
        for (int i = 0; i < game.enemies.length; i++) {
          Enemy enemy = game.enemies[i];
          if (missile.position.overlaps(enemy.position)) {
            game.createExplosionAt(missile.position.left, missile.position.top,isMissile: true);
            enemy.shootCreator.stop();
            enemy.enemyShoots.clear();
            game.enemies.removeAt(i);
            missile.atingiuAlvo = true;
            inimigosDestruidos++;
            if (inimigosDestruidos == (7 + game.fase)) {
              game.enemies.clear();
              game.enemyCreator.stop();
              game.boss = BossEnemy(game);
              game.showBoss = true;
            }
          }
        }
      });
    }
  }

  //FUNCTIONS

  void shipMove(double dt) {
    if (move) {
      if(!game.showBoss){
      if (rect.top <= 0) {
        rect = rect.translate(0, 0.05);
        vida -= (1);
        return;
      }
      if ((rect.top + size) >= game.screenSize.height) {
        rect = rect.translate(0, -0.05);
        vida -= (1);
        return;
      }
      if (rect.left <= 0) {
        rect = rect.translate(0.05, 0);
        vida -= (1);
        return;
      }
      if ((rect.left + size) >= game.screenSize.width) {
        rect = rect.translate(-0.05, 0);
        vida -= (1);

        return;
      }
      double nextX = (speed * dt) * cos(lastMoveRadAngle);
      double nextY = (speed * dt) * sin(lastMoveRadAngle);
      Offset nextPoint = Offset(nextX, nextY);
      Offset diffBase =
          Offset(rect.center.dx + nextPoint.dx, rect.center.dy + nextPoint.dy) -
              rect.center;
      rect = rect.shift(diffBase);
      }else{
        if(rect.right <=  game.boss.position.left){
                if (rect.top <= 0) {
        rect = rect.translate(0, 0.05);
        vida -= (1);
        return;
      }
      if ((rect.top + size) >= game.screenSize.height) {
        rect = rect.translate(0, -0.05);
        vida -= (1);
        return;
      }
      if (rect.left <= 0) {
        rect = rect.translate(0.05, 0);
        vida -= (1);
        return;
      }
      if ((rect.left + size) >= game.screenSize.width) {
        rect = rect.translate(-0.05, 0);
        vida -= (1);

        return;
      }
      double nextX = (speed * dt) * cos(lastMoveRadAngle);
      double nextY = (speed * dt) * sin(lastMoveRadAngle);
      Offset nextPoint = Offset(nextX, nextY);
      Offset diffBase =
          Offset(rect.center.dx + nextPoint.dx, rect.center.dy + nextPoint.dy) -
              rect.center;
      rect = rect.shift(diffBase);
        }else{
          rect = rect.translate(-2, 0);
        }
      }
    }
  }
}
