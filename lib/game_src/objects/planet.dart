import 'dart:ui';

import 'package:flame/flare_animation.dart';

class Planet{
  Rect position;
  FlareAnimation flareAnimation;
  final String planetType;
  bool loaded = false;
  Planet(this.planetType){
    _start(this.planetType);
  }
  void _start(String type)async{
       flareAnimation = await FlareAnimation.load("assets/$type");
    flareAnimation.updateAnimation("anim");

    flareAnimation.width = 100;
    flareAnimation.height = 100;

    loaded = true;

  }
  void render(Canvas canvas){
    if(loaded){
      flareAnimation.render(canvas,x: position.left,y: position.top);
    }
  }
  void update(double dt){
    if(loaded){
      flareAnimation.update(dt);
    }
  }
}