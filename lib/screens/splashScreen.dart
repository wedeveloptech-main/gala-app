import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/screens/MaintananceMode.dart';
import 'package:myapp/screens/MenuDetailPage.dart';
import 'package:myapp/screens/onBoard/onboarding.dart';
import 'package:myapp/screens/splashScreen2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool animate =false;


  /*@override
  void initState() {
    //startAnimtion();
    super.initState();
    new Timer(new Duration(seconds: 4), () {
      checkFirstSeen();
    });
  }*/

  bool hasInternet = false;
  late StreamSubscription internetSubscription;

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  @override
  void initState() {
    super.initState();
    debugPrint(hasInternet.toString());
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
          final hasInternet = status == InternetConnectionStatus.connected;
          setState(() => this.hasInternet = hasInternet);
        });
    startAnimtion();
    OneSignal.shared.setLogLevel(OSLogLevel.debug, OSLogLevel.none);
    OneSignal.shared.setAppId("a74267fa-360e-4df0-b104-7d5b0b73d67b");

    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      var data =  openedResult.notification.additionalData!["Page"].toString();

      /*if(data == "Home"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }*/

    });

    // Listen for dynamic links
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      if (dynamicLinkData != null) {
        // Extract the deep link URL from the DynamicLinkData
        Uri deepLink = dynamicLinkData.link;
        print(deepLink);

        // Extract the query parameters from the deep link URL
        String? name = deepLink.queryParameters['name'];
        String? product = deepLink.queryParameters['product'];

        // Provide default values for the query parameters if they are null
        name ??= 'Default Name';
        product ??= 'Default Product';

        // Navigate to the MenuDetailPage with the extracted parameters
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailPage(
              name: name!,
              product: product!,
            ),
          ),
        );
      }
    }, onError: (error) {
      // Handle any errors
    });

    // Get the initial dynamic link (if any)
    FirebaseDynamicLinks.instance.getInitialLink().then((dynamicLinkData) {
      if (dynamicLinkData != null) {
        // Extract the deep link URL from the DynamicLinkData
        Uri deepLink = dynamicLinkData.link;
        print(deepLink);

        // Extract the query parameters from the deep link URL
        String? name = deepLink.queryParameters['name'];
        String? product = deepLink.queryParameters['product'];

        // Provide default values for the query parameters if they are null
        name ??= 'Default Name';
        product ??= 'Default Product';

        // Navigate to the MenuDetailPage with the extracted parameters
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailPage(
              name: name!,
              product: product!,
            ),
          ),
        );
      }
    }, onError: (error) {
      // Handle any errors
    });

    _checkMaintenanceMode();

  }

  Future<void> _checkMaintenanceMode() async {
    try {
      final maintenanceData = await fetchMaintenanceModeData();
      setState(() {
        _isMaintenanceMode = maintenanceData['data']['maintenancemode'] == 1;
        _maintenanceMsg = maintenanceData['data']['maintenancemsg'];
      });
    } catch (e) {
      // Handle error while fetching maintenance mode data
      print(e.toString());
    }
  }


  @override
  void dispose() {
    super.dispose();
    internetSubscription.cancel();
  }

  /*@override
  void initState() {
    startAnimtion();
  }*/


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: AnimatedSplashScreen(
              splash: Image.asset(
                "assets/images/LogoSplash.png",
                //height: 127,
                height: 127.h,
                //width: 500,
                width: 500.w,
              ),
              nextScreen: _isMaintenanceMode
                  ? MaintananceMode()
                  : SplashScreen2(),
              splashTransition: SplashTransition.scaleTransition,
            ),
          ),
        ),
      ),
    );
  }

  Future startAnimtion() async{
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      animate = true;
    });
    await Future.delayed(Duration(milliseconds: 2000));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      /*Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => hasInternet ? const HomeScreen() : Text('No Internet'),));*/
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreen2()));
    } else {
      prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreen2()));
    }
  }
}
