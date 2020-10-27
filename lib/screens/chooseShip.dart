import 'package:admob_flutter/admob_flutter.dart';
import 'package:flame/flame.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:warship_survival/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ChooseShip extends StatefulWidget {
  final Size size;
  final bool edit;

  const ChooseShip({Key key, this.size, this.edit = false}) : super(key: key);
  @override
  _ChooseShipState createState() => _ChooseShipState();
}

class _ChooseShipState extends State<ChooseShip> with WidgetsBindingObserver {
  bool loading = false;
  AdmobBannerSize bannerSize;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Flame.bgm.resume();
        break;
      case AppLifecycleState.inactive:
        Flame.bgm.pause();
        break;
      case AppLifecycleState.paused:
        Flame.bgm.pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Admob.initialize('ca-app-pub-9480221320403320~7042886155');
    bannerSize = AdmobBannerSize.BANNER;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/splash_bg.jpg'),
                fit: BoxFit.cover)),
        child: SafeArea(
          child: (!loading)
              ? Container(
                  width: widget.size.width,
                  height: widget.size.height,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Choose a Ship to Play...',
                        style: TextStyle(
                            fontFamily: 'Karmatic',
                            color: Colors.green,
                            fontSize: 25,
                            letterSpacing: 1.5),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Expanded(
                        child: Scrollbar(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(10, (index) {
                              return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    if (!widget.edit) {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'shipModel', 'model${index + 1}.png');
                                      await prefs.setInt('fase', 1);
                                      await prefs.setInt('vida', 1000);
                                      await prefs.setBool('rated', false);
                                      String shipModel =
                                          prefs.getString('shipModel');
                                      int fase = prefs.getInt('fase');
                                      int vida = prefs.getInt('vida');

                                      Future.delayed(Duration(seconds: 3))
                                          .then((value) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(
                                                      shipModel: shipModel,
                                                      size: widget.size,
                                                      fase: fase, vida: vida,
                                                    )),
                                            (Route<dynamic> route) => false);
                                      });
                                    } else {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'shipModel', 'model${index + 1}.png');
                                      String shipModel =
                                          prefs.getString('shipModel');
                                      int fase = prefs.getInt('fase');
                                      int vida = prefs.getInt('vida');
                                      Future.delayed(Duration(seconds: 3))
                                          .then((value) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(
                                                      shipModel: shipModel,
                                                      size: widget.size,
                                                      fase: fase,
                                                      vida: vida,
                                                    )),
                                            (Route<dynamic> route) => false);
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: ClipPath(
                                      clipper: MyClipper(),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          color: Colors.white12,
                                        ),
                                        child: Image.asset(
                                          'assets/images/model${index + 1}.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ));
                            }),
                          ),
                        ),
                      ),
                      AdmobBanner(
                        adUnitId: (kReleaseMode)
                            ? 'ca-app-pub-9480221320403320/1379495937'
                            : 'ca-app-pub-3940256099942544/6300978111',
                        adSize: bannerSize,
                        listener:
                            (AdmobAdEvent event, Map<String, dynamic> args) {
                        },
                        onBannerCreated: (AdmobBannerController controller) {},
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Container(
                      width: 150,
                      height: 150,
                      child: FlareActor(
                        'assets/Gears.flr',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: 'GearsRotation2',
                      )),
                ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // path.lineTo(0, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 50);
    //path.lineTo(size.width, size.height);

    var controllPoint = Offset(size.width, size.height);
    var endPoint = Offset(0, size.height);
    path.quadraticBezierTo(
        controllPoint.dx, controllPoint.dy, endPoint.dx, endPoint.dy);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
