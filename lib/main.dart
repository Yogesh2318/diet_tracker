import 'package:flutter/material.dart';
import 'package:my_project/auth/signup.dart';
import 'package:my_project/pages/home.dart';

import 'auth/login.dart';

void main ()=> runApp(MaterialApp(
debugShowCheckedModeBanner: false,
initialRoute: 'login',
routes: {
  'login': (context) => Login(),
  'signup':(context) => Signup(),
  // 'home':(context) => Home(username: '',),
}
));



