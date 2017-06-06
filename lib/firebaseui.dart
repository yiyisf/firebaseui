import 'dart:async';

import 'package:flutter/services.dart';

class Firebaseui {
  static const MethodChannel _channel =
      const MethodChannel('firebaseui');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');

  static Future<FirebaseUser> get currentUser =>
      _channel.invokeMethod('getCurrentUser');

  static Future<String> get signin =>
      _channel.invokeMethod('signIn');

  static Future<bool> get signout =>
      _channel.invokeMethod('signOut');

}

/// Represents user data returned from an identity provider.
class UserInfo {
  final Map<String, dynamic> _data;
  UserInfo._(this._data);

  /// The provider identifier.
  String get providerId => _data['providerId'];

  /// The provider’s user ID for the user.
  String get uid => _data['uid'];

  /// The name of the user.
  String get displayName => _data['displayName'];

  /// The URL of the user’s profile photo.
  String get photoUrl => _data['photoUrl'];

  /// The user’s email address.
  String get email => _data['email'];

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}

/// Represents a user.
class FirebaseUser extends UserInfo {
  final Map<String, dynamic> _data;
  final List<UserInfo> providerData;
  FirebaseUser._(this._data)
      : providerData = (_data['providerData'] as List<Map<String, dynamic>>)
      .map((Map<String, dynamic> info) => new UserInfo._(info)).toList(),
        super._(_data);

  // Returns true if the user is anonymous; that is, the user account was
  // created with signInAnonymously() and has not been linked to another
  // account.
  bool get isAnonymous => _data['isAnonymous'];

  /// Returns true if the user's email is verified.
  bool get isEmailVerified => _data['isEmailVerified'];

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}
