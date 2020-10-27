import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:warship_survival/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  await Flame.util.setLandscapeLeftOnly();
  await Flame.audio.load('explosion.wav');
  await Flame.audio.load('life_pickup.flac');
  await Flame.audio.load('shooting.wav');
  await Flame.audio.load('shooting1.wav');
  await Flame.audio.load('background_music.wav');
  await Flame.audio.load('background_music1.wav');
  Size size = await Flame.util.initialDimensions();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(size: size,)
    ),
  );
}