import 'package:flutter/material.dart';
import 'package:petsaojoao/models/utils_firebase/firebase_facebook.dart';
import 'package:petsaojoao/screens/dashboard/dashboard.dart';
import '../../models/utils_firebase/firebase_auth.dart';
import '../dashboard/dashboard.dart';
import '../register_tutor/personal_info.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:petsaojoao/screens/notification/pet_found/pet_found_board.dart';

//Acompanhe desing do projeto aqui --> https://www.figma.com/file/GYFrt79mzIbOUXXmFyDgwL/Material-Baseline-Design-Kit?node-id=38%3A5814
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _homeScreenText = "Waiting for token...";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _navigateToItemDetail(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );

    //Needed by iOS only
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    //Getting the token from FCM
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: \n\n $token";
      });
      print(_homeScreenText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget> [
          ClipWavy(),
          LogoApp(),
          Padding(
            padding: EdgeInsets.only(top: 250, left: 30, right: 30,
            ),
            child: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 90,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text (
                              "Entre",
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.black45,
                              ),
                            ),

                            SizedBox(
                              height: 5,
                            ),
                            Text (
                              "E seja bem vindo!",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black45,
                              ),
                            ),
                          ]
                      ),

                      Spacer(flex: 6),
                      Container(
                        height: 100,
                        alignment: Alignment.centerRight,
                        child: Image.asset("assets/login/townhall.png"),
                      ),
                    ]
                  ),

                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 2,
                    endIndent: 100,
                  ),

                  SizedBox(
                    height: 50,
                  ),

                  SocialLogin(),
                ]
              ),
            ),
          ),

          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.maxFinite,
              height: 30,
              color: Colors.blueAccent[200],
              child:
              Image.asset("assets/login/logo-unifeob.png"),
            ),
          ),
        ]
      ),
    );
  }
  void _navigateToItemDetail(Map<String, dynamic> message) {
    final MessageBean item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }
}


class ClipHome extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height-30);

    path.quadraticBezierTo(size.width/90, size.height-110, size.width-160, size.height-100);
    path.quadraticBezierTo(size.width-(size.width/20), size.height-90, size.width, size.height-160);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ClipWavy extends StatelessWidget {
  final _imgPaws=Image.asset("assets/login/legs.png");
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipHome(),
      child: Container(
        child: Opacity(
          opacity: 0.35,
          child: _imgPaws,
        ),
       height: 350,
        color: Colors.blueAccent[200],
      ),

//      width: double.maxFinite, height: 303,
    );
  }
}

class LogoApp extends StatelessWidget {
  final _imgLogo=Image.asset("assets/login/logoDogWhite.png");
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 60
      ),
      height: 170,
      width: double.maxFinite,
      alignment: Alignment.center,
//        decoration: BoxDecoration(
//          gradient: RadialGradient(
//              colors: [Colors.white70, Colors.white]
//          ),
//        ),
      child: _imgLogo,
    );
  }
}

class SocialLogin extends StatelessWidget {
  final _imgFacebook = Image.asset("assets/login/facebook.png");
  final _imgGmail = Image.asset("assets/login/gmail.png");
  final _imgTwitter = Image.asset("assets/login/twitter.png");

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 60,
            width: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.blueAccent[200],
            ),
            child: FlatButton(
              child: SizedBox(
                child: _imgFacebook,
                height: 50,
                width: 50,
              ),

              onPressed: () async {
                signUpWithFacebook().whenComplete(() => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context){
                        return Dashboard();
                      } )
                  )
                });
              },
            ),
          ),
          Spacer(flex: 2),
          Container(
            height: 60,
            width: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.blueAccent[200],
            ),
            child: FlatButton(
              child: SizedBox(
                child: _imgGmail,
                height: 50,
                width: 50,
              ),
              onPressed: () async {
                signInWithGoogle().whenComplete(() => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context){
                        return Dashboard();
                      } )
                  )
                });

              },
            ),
          ),
          Spacer(flex: 2),
          Container(
            height: 60,
            width: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.blueAccent[200],
            ),
            child: FlatButton(
              child: SizedBox(
                child: _imgTwitter,
                height: 50,
                width: 50,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard()),
                );
              },
            ),
          ),
        ]
    );
  }
}

final Map<String, MessageBean> _items = <String, MessageBean>{};
MessageBean _itemForMessage(Map<String, dynamic> message) {
  //If the message['data'] is non-null, we will return its value, else return map message object
  final dynamic data = message['data'] ?? message;
  final String petId = data['id_fnd'].toString();
  final MessageBean item = _items.putIfAbsent(
      petId, () => MessageBean(petId: petId))
    ..status = data['status'];
  return item;
}

//Model class to represent the message return by FCM
class MessageBean {
  MessageBean({this.petId});
  final String petId;

  StreamController<MessageBean> _controller =
  StreamController<MessageBean>.broadcast();
  Stream<MessageBean> get onChanged => _controller.stream;

  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$petId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(petId),
      ),
    );
  }
}

//Detail UI screen that will display the content of the message return from FCM
class DetailPage extends StatefulWidget {
  DetailPage(this.petId);
  final String petId;
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  MessageBean _item;
  StreamSubscription<MessageBean> _subscription;

  @override
  void initState() {
    super.initState();
    _item = _items[widget.petId];
    _subscription = _item.onChanged.listen((MessageBean item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PetFoundBoard(req_id: _item.petId,);
  }
}
