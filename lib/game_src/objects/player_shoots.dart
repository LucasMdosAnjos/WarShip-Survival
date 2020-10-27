import 'dart:math';
import 'dart:ui';
import 'package:flame/flame_audio.dart';
import 'package:flame/sprite.dart';
import 'package:warship_survival/game_src/game.dart';

class Shoots {
  Rect position;
  double shootSpeed;
  Sprite bullet;
  double angleDirection;
  bool atingiuAlvo = false;
  final MyGame game;
  Shoots(this.game) {
    bullet = Sprite('laser.png');
    shootSpeed = -500;
    FlameAudio audio = FlameAudio();
    audio.play('shooting1.wav');
  }
  void render(Canvas canvas) {
    if (angleDirection != null) {
      canvas.save();
      canvas.translate(position.center.dx, position.center.dy);
      canvas.rotate(angleDirection == 0.0 ? 0.0 : angleDirection + (pi / 2));
      canvas.translate(-position.center.dx, -position.center.dy);
      bullet.renderRect(canvas, position);
      bullet.renderRect(canvas, position);
      canvas.restore();
    }
  }

  void update(double dt) {}
}
