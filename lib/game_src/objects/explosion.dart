import 'dart:ui';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/flame_audio.dart';

class Explosion{
  Rect position;
  FlameAnimation.Animation animation;

  Explosion(){
    FlameAudio audio = FlameAudio();
    audio.play('explosion.wav',volume: .25);
  }

  void render(Canvas canvas) {
    if (animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
  }

  void update(double dt) {
    animation.update(dt);
  }
}