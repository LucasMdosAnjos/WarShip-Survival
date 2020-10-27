import 'dart:ui';
import 'package:flame/animation.dart' as FlameAnimation;
class EnemyShoot{
  Rect position;
  FlameAnimation.Animation animation;
  double angleDirection;
  void render(Canvas canvas){
    if(animation.loaded()){
      animation.getSprite().renderRect(canvas, position);
    }
  }
  void update(double dt){
    animation.update(dt);
  }
}