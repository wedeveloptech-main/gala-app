import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/screens/HomeScreen/homeScreen.dart';
import 'package:myapp/screens/onBoard/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/Login.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({Key? key}) : super(key: key);

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {


  /*Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('first_time');

    if (isFirstTime != null && !isFirstTime) {
      return false;
    } else {
      await prefs.setBool('first_time', false);
      return true;
    }
  }*/

  Future<Widget> determineScreen() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isFirstTime = prefs.getBool('first_time');
      bool isLoggedIn = await SessionManager().get("isLogin") ?? false;

      if (isFirstTime != null && !isFirstTime) {
        if (isLoggedIn) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      } else {
        await prefs.setBool('first_time', false);
        return Onboarding();
      }
    } catch (e) {
      print("Error determining screen: $e");
      return LoginScreen();
    }
  }


  @override
  void initState() {
    super.initState();
    /*Future.delayed(Duration(seconds: 3), () {
      isFirstTime().then((result) {
        if (result) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Onboarding(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      });

      SessionManager().set("isLogin", true);
    });*/
    Future.delayed(Duration(seconds: 3), () async {
      var screen = await determineScreen();
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen 
        //?? LoginScreen()
        ),
      );
      setState(() {}); // to prevent calling setState after disposing the state
    });
  }




  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () async {
      var screen = await determineScreen();
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen
            //?? LoginScreen()
            ),
      );
      setState(() {}); // to prevent calling setState after disposing the state
    });
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/SplashScreen2.png'),
              fit: BoxFit.cover
            )
          ),
        ),
      ),
    );
  }
}

class OnboardScreen extends StatefulWidget {
  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  bool _seenOnboard = false;

  @override
  void initState() {
    super.initState();
    _checkIfSeenOnboard();
  }

  Future<void> _checkIfSeenOnboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('seenOnboard') ?? false;
    setState(() {
      _seenOnboard = seen;
    });
  }

  Future<void> _setSeenOnboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboard', true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_seenOnboard) {
      return Onboarding();
    } else {
      return HomeScreen();
    }
  }
}