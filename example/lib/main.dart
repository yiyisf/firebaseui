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
  String _signedName = 'Unknown';
  bool _status = false;
  FirebaseUser _user;
  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    String platformVersion;

    try {
      initUser();
    } on PlatformException {
      platformVersion = "Failed to get status";
    }

    if (!mounted) return;

    setState(() {
      _status = true;
    });
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
              child: _status ? const Text("退出") : const Text("登录"),
              onPressed: () {
                _handleSignout();
              },
            )
          ],
        ),
      ),
    );
  }

  _handleSignout() async {
    if (!_status) {
      String signedName;
      try {
        signedName = await Firebaseui.signin;
        setState(() {
          _status = true;
          _signedName = signedName;
        });
      } on PlatformException {
        signedName = "Failed to get signed name";
        setState(() {
          _status = false;
        });
      }
      return;
    }
    bool status = await Firebaseui.signout;
    if (status) {
      setState(() {
        _status = false;
      });
    }
  }

  initUser() {
    setState(()async {_user = await Firebaseui.currentUser;});
  }
}
