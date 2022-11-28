import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

logout(BuildContext context) {
  SharedPreferences.getInstance().then((sharedPreferences) {
    // prefs.clear();
    sharedPreferences.remove('accessToken');
    sharedPreferences.remove('id');
    sharedPreferences.remove('email');
    Navigator.pushReplacementNamed(context, "login");
  });
}
