import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:warship_survival/game_src/game.dart';

class Stars{

  Rect position;
  Sprite stars;
  final MyGame game;

  Stars(this.game){
    stars = Sprite('stars.png');
  }
  void render(Canvas canvas){
    stars.renderRect(canvas, position);
  }

  void update(double dt){

  }
}