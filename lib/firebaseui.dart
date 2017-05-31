import 'dart:async';

import 'package:flutter/services.dart';

class Firebaseui {
  static const MethodChannel _channel =
      const MethodChannel('firebaseui');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');

  static Future<bool> get signinstatus =>
      _channel.invokeMethod('getSignStatus');

  static Future<String> get signin =>
      _channel.invokeMethod('signIn');

  static Future<bool> get signout =>
      _channel.invokeMethod('signOut');

}
