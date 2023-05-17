import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/screens/HomeScreen/components/MenuPage.dart';
import 'package:myapp/screens/MenuDetailPage.dart';
import 'package:myapp/screens/splashScreen.dart';
import 'package:myapp/screens/splashScreen2.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/color.dart';

const String SETTINGS_BOX = "settings";
const String API_BOX = "api_data";
const String FAVORITES_BOX = "favorites";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase app
  //handleDeepLink();
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
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Gala Caterers',
            theme: ThemeData(
              fontFamily: 'Roboto',
              primarySwatch: MaterialColor(
                0xFF0D55A1,
                <int, Color>{
                  50: kblue.withOpacity(0.1),
                  100: kblue.withOpacity(0.2),
                  200: kblue.withOpacity(0.3),
                  300: kblue.withOpacity(0.4),
                  400: kblue.withOpacity(0.5),
                  500: kblue.withOpacity(0.6),
                  600: kblue.withOpacity(0.7),
                  700: kblue.withOpacity(0.8),
                  800: kblue.withOpacity(0.9),
                  900: kblue.withOpacity(1),
                },
              ),
            ),
            builder: (context, child) {
              // initialize the navigator state before building the widget tree
              return Navigator(
                key: navigatorKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => child!,
                  );
                },
              );
            },
            home: child,
          ),
        );
      },
      child: SplashScreen(),
    );
  }
}
