//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebaseui/firebaseui.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  final FirebaseAuth auth = FirebaseAuth.instance;

  String _signedName = 'Unknown';
  bool _status = false;
  UiFirebaseUser _user;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    String platformVersion;
    setState(() {
      _status = false;
    });

    try {
      initUser();
    } on PlatformException {
      platformVersion = "Failed to get status";
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Plugin example app'),
      ),
      body: new Center(
        child: new ListView(
          children: <Widget>[
            new Text('Running on: $_signedName\n'),
            new RaisedButton(
              child: _status ? const Text("邮件地址登录") : const Text("登录"),
              onPressed: () {
//                _handleSignout();
              },
            ),
            new RaisedButton(
              child: const Text("手机号码登录"),
              onPressed: () {
                _handlePhoneSignin();
              },
            ),
            new RaisedButton(
              child: _status ? const Text("退出") : const Text("登录"),
              onPressed: () {
//                _handleSignout();
              },
            ),
          ],
        ),
      ),
    );
  }

//  _handleSignout() async {
//    if (!_status) {
//      String signedName;
//      try {
////        signedName = await Firebaseui.signin;
////        FirebaseUser user = await auth.signInAnonymously();
//        setState(() {
//          _status = true;
//          _signedName = signedName;
//        });
//      } on PlatformException {
//        signedName = "Failed to get signed name";
//        setState(() {
//          _status = false;
//        });
//      }
//      return;
//    }
//    await auth.signOut();
//    setState(() {
//      _status = false;
//      _user = null;
//      _signedName = 'UnKnown';
//    });
//  }

  initUser() async {
//    UiFirebaseUser user = await Firebaseui.currentUser;
    await Firebaseui.currentUser.then((user) {
      if (user != null) {
        print(user);
        setState(() {
          _user = user;
          _status = true;
          _signedName = user.displayName;
        });
      } else {
        print('没取到登录用户');
      }
    }, onError: () {});
  }

  _handlePhoneSignin() {
    print('开始登录...');
    Firebaseui.signinPhone.then((phone) {
      print('登录返回${phone}');
      setState(() {
        _signedName = phone;
      });
    });
  }
}
