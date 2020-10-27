import 'dart:math';
import 'dart:ui';
import 'package:flame/animation.dart' as FlameAnimation;
class BossShoots{
    Rect position;
    double distance = 0;
  FlameAnimation.Animation animation;
  int directionOption;
  double angleDirection;
  Random random;
  bool alreadyMultiplied = false;
  bool atingiuAlvo = false;
  BossShoots(){
    random = Random();
  }
  void render(Canvas canvas){
    if(animation.loaded()){
      animation.getSprite().renderRect(canvas, position);
    }
  }
  void update(double dt){
    animation.update(dt);
  }
}