import 'package:admob_flutter/admob_flutter.dart';
import 'package:flame/flame.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:warship_survival/game_src/game.dart';

class HomeScreen extends StatefulWidget {
  final Size size;
  final String shipModel;
  final int fase;
  final int vida;

  const HomeScreen({Key key,@required this.size, @required this.shipModel,@required this.fase, @required this.vida})
      : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  MyGame game;
  @override
  void initState() {
    super.initState();
    Admob.initialize('ca-app-pub-9480221320403320~7042886155');
    WidgetsBinding.instance.addObserver(this);
    Flame.bgm.stop();
    Flame.bgm.clearAll();
    Flame.bgm.play('background_music1.wav', volume: .25);
  }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }


    @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Flame.bgm.resume();
        if(game.playerShip.vida > 0){
        game.pauseMenu();
        }
        break;
      case AppLifecycleState.inactive:
        Flame.bgm.pause();
        game.pause();
        break;
      case AppLifecycleState.paused:
        Flame.bgm.pause();
        game.pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
        game = MyGame(widget.size, shipModel: widget.shipModel,fase: widget.fase,context: context,vida: widget.vida);
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          game.pause();
          game.pauseMenu();
          await Future.delayed(Duration(seconds: 2));
          return false;
        },
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: game.onPanStart,
                onPanUpdate: game.onPanUpdate,
                onPanEnd: game.onPanEnd,
                onForcePressStart: (details) {
                },
                child: game.widget),
            Transform.translate(
              offset: Offset(-35, -67.5),
              child: GestureDetector(
                onTap: game.increaseLife,
                child: Container(
                  width: 45,
                  height: 45,
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.only(right: 7.5, bottom: 25.0),
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/more.png',
                      fit: BoxFit.contain),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Transform.translate(
                  offset: Offset(0, -20),
                  child: GestureDetector(
                    onTap: game.shootMissile,
                    child: Container(
                      width: 45,
                      height: 45,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(right: 7.5, bottom: 25.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/images/atomic-bomb.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                GestureDetector(
                  onLongPressStart: game.beginFire,
                  onLongPressUp: game.stopFire,
                  child: Container(
                      width: 60,
                      height: 60,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(right: 25.0, bottom: 25.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: FlareActor(
                        'assets/AmmoButton.flr',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: 'colorChange',
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
