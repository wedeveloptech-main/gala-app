import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/screens/HomeScreen/components/MenuPage.dart';
import 'package:myapp/screens/MenuDetailPage.dart';
import 'package:myapp/screens/splashScreen.dart';
import 'package:myapp/screens/splashScreen2.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String SETTINGS_BOX = "settings";
const String API_BOX = "api_data";
const String FAVORITES_BOX = "favorites";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase app
  //handleDeepLink();
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isFirstTime = prefs.getBool('first_time');
  if (isFirstTime == null) {
    await prefs.setBool('first_time', true);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 915),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return StreamProvider<InternetConnectionStatus>(
          initialData: InternetConnectionStatus.connected,
          create: (_) {
            return InternetConnectionChecker().onStatusChange;
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              fontFamily: 'Roboto',
              primarySwatch: Colors.blue,
            ),
            routes: {
              // When navigating to the "/" route, build the FirstScreen widget.
              //'/': (context) => const FirstScreen(),
              // When navigating to the "/second" route, build the SecondScreen widget.
              '/menudetail': (context) => MenuPage(),
            },
            home: child,
          ),
        );
      },
      child: SplashScreen(),
    );
  }
}
