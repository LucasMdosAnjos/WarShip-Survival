import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flame/flame.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:warship_survival/screens/chooseShip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Splash extends StatefulWidget {
  final Size size;

  const Splash({Key key, this.size}) : super(key: key);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  bool showLoading = false;
  AnimationController controllerAnimation;
  Animation<double> opacity;
  @override
  void initState() {
    super.initState();
       Admob.initialize('ca-app-pub-9480221320403320~7042886155');
    Flame.bgm.play('background_music.wav', volume: .10);
    controllerAnimation = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1250));
    controllerAnimation.forward();
    _getInternalData();
  }

  @override
  Widget build(BuildContext context) {
    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controllerAnimation, curve: Curves.easeIn));
    return AnimatedBuilder(
        animation: controllerAnimation,
        builder: (context, _) {
          return Opacity(
              opacity: opacity.value,
              child: Scaffold(
                  body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/vortex.png'),
                        fit: BoxFit.cover)),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Container(
                            width: 150,
                            height: 150,
                            child: FlareActor(
                              'assets/Gears.flr',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              animation: 'GearsRotation',
                            )),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        'Loading Data...',
                        style: TextStyle(
                            fontFamily: 'ZeroVelo',
                            color: Colors.blue,
                            fontSize: 35,
                            letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              )));
        });
  }

  Future<void> _getInternalData() async {
    setState(() {
      showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String shipModel = prefs.getString('shipModel');
    Future.delayed(Duration(seconds: 3), () {
      if (shipModel == null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChooseShip(
                  size: widget.size,
                )));
      } else {
        int fase = prefs.getInt('fase');
        int vida = prefs.getInt('vida');
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeScreen(
                  size: widget.size,
                  shipModel: shipModel,
                  fase: fase,
                  vida: vida,
                )));
      }
    });
  }
}
