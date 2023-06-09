import 'dart:async';
import 'dart:convert';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/screens/MaintananceMode.dart';
import 'package:myapp/screens/MenuDetailPage.dart';
import 'package:myapp/screens/onBoard/onboarding.dart';
import 'package:myapp/screens/splashScreen2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver{

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

  late String _linkMessage;
  bool _isCreatingLink = false;

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final String _testString =
      'To test: long press link and then copy and click from a non-browser '
      "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
      'is properly setup. Look at firebase_dynamic_links/README.md for more '
      'details.';

  final String DynamicLink = 'https://gala.page.link/menudetail?name=<name>&product=<product>';
  final String Link = 'https://gala.page.link/category';

  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      final Map<String, String> queryParameters = deepLink.queryParameters;
      final String? name = queryParameters['name'];
      final String? product = queryParameters['product'];
      if (name != null && product != null) {
        Get.off(() => MenuDetailPage(name: name, product: product, openedByDeepLink: true,))?.then((value) => {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Save Menu?"),
              content: Text("Do you want to save this menu?"),
              actions: [
                TextButton(
                  child: Text("No"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Yes"),
                  onPressed: () async {
                    final configResponse = await http
                        .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

                    if (configResponse.statusCode == 200) {
                      final configJson = jsonDecode(configResponse.body);
                      final base_url = configJson['data']['apidomain'];

                      final cid = await SessionManager().get("cid");
                      final userMenuListUrl = '$base_url/getusermenulist-ax.php?clid=$cid';
                      final userMenuListResponse = await http.get(Uri.parse(userMenuListUrl));
                      if (userMenuListResponse.statusCode == 200) {
                        final userMenuListJson = jsonDecode(userMenuListResponse.body);
                        final userMenuList = userMenuListJson['data'];
                        final menuExists = userMenuList.any((menu) => menu['id'] == product);
                        if (!menuExists) {
                          // Add the menu to the user's list
                          final createMenuUrl = '$base_url/reqmenuaccess-ax.php?mid=$product&clid=$cid';
                          final createMenuResponse = await http.post(Uri.parse(createMenuUrl));
                          if (createMenuResponse.statusCode == 200) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Menu saved successfully!"),
                            ));
                          } else {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Failed to save menu!"),
                            ));
                          }
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Menu already exists!"),
                          ));
                        }
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Failed to get user menu list!"),
                        ));
                      }
                    }
                  },
                ),
              ],
            ),
          )

        });
      }
    }

    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;
      if (deepLink != null) {
        final Map<String, String> queryParameters = deepLink.queryParameters;
        final String? name = queryParameters['name'];
        final String? product = queryParameters['product'];
        if (name != null && product != null) {
          Get.to(() => MenuDetailPage(name: name, product: product, openedByDeepLink: true,))?.then((value) => {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Save Menu?"),
                content: Text("Do you want to save this menu?"),
                actions: [
                  TextButton(
                    child: Text("No"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text("Yes"),
                    onPressed: () async {
                      final configResponse = await http
                          .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

                      if (configResponse.statusCode == 200) {
                        final configJson = jsonDecode(configResponse.body);
                        final base_url = configJson['data']['apidomain'];

                        final cid = await SessionManager().get("cid");
                        final userMenuListUrl = '$base_url/getusermenulist-ax.php?clid=$cid';
                        final userMenuListResponse = await http.get(Uri.parse(userMenuListUrl));
                        if (userMenuListResponse.statusCode == 200) {
                          final userMenuListJson = jsonDecode(userMenuListResponse.body);
                          final userMenuList = userMenuListJson['data'];
                          final menuExists = userMenuList.any((menu) => menu['id'] == product);
                          if (!menuExists) {
                            // Add the menu to the user's list
                            final createMenuUrl = '$base_url/reqmenuaccess-ax.php?mid=$product&clid=$cid';
                            final createMenuResponse = await http.post(Uri.parse(createMenuUrl));
                            if (createMenuResponse.statusCode == 200) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Menu saved successfully!"),
                              ));
                            } else {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Failed to save menu!"),
                              ));
                            }
                          } else {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Menu already exists!"),
                            ));
                          }
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Failed to get user menu list!"),
                          ));
                        }
                      }
                    },
                  ),
                ],
              ),
            )
          });
        }
        else{
          print('Link Not Found!');
        }
      }
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }


  Future<void> _createDynamicLink(bool short, String name, String product) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://gala.page.link/',
      link: Uri.parse('https://gala.page.link/menudetail?name=$name&product=$product'),
      androidParameters: const AndroidParameters(
        packageName: 'in.galacaterers.app_data',
        minimumVersion: 0,
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
      await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
      print(url.toString());
    } else {
      url = await dynamicLinks.buildLink(parameters);
      print(url.toString());
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }


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

    _checkMaintenanceMode();
    WidgetsBinding.instance!.addObserver(this);
    initDynamicLinks();
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData?.link;

      if (deepLink != null) {
        // Navigate to the appropriate page based on the deep link parameters
        String name = deepLink.queryParameters['name'] ?? '';
        String product = deepLink.queryParameters['product'] ?? '';
        Get.to(() => MenuDetailPage(name: name, product: product, openedByDeepLink: true,))?.then((value) => {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Save Menu?"),
              content: Text("Do you want to save this menu?"),
              actions: [
                TextButton(
                  child: Text("No"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Yes"),
                  onPressed: () async {
                    final configResponse = await http
                        .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

                    if (configResponse.statusCode == 200) {
                      final configJson = jsonDecode(configResponse.body);
                      final base_url = configJson['data']['apidomain'];

                      final cid = await SessionManager().get("cid");
                      final userMenuListUrl = '$base_url/getusermenulist-ax.php?clid=$cid';
                      final userMenuListResponse = await http.get(Uri.parse(userMenuListUrl));
                      if (userMenuListResponse.statusCode == 200) {
                        final userMenuListJson = jsonDecode(userMenuListResponse.body);
                        final userMenuList = userMenuListJson['data'];
                        final menuExists = userMenuList.any((menu) => menu['id'] == product);
                        if (!menuExists) {
                          // Add the menu to the user's list
                          final createMenuUrl = '$base_url/reqmenuaccess-ax.php?mid=$product&clid=$cid';
                          final createMenuResponse = await http.post(Uri.parse(createMenuUrl));
                          if (createMenuResponse.statusCode == 200) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Menu saved successfully!"),
                            ));
                          } else {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Failed to save menu!"),
                            ));
                          }
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Menu already exists!"),
                          ));
                        }
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Failed to get user menu list!"),
                        ));
                      }
                    }
                  },
                ),
              ],
            ),
          )
        });
      }
    }).onError((error) {
      if (kDebugMode) {
        print('error.message');
      }
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      String? name = deepLink.queryParameters['name'];
      String? product = deepLink.queryParameters['product'];

      Get.offNamed('/menudetail', arguments: {
        'name': name,
        'product': product,
      })?.then((value) => {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Save Menu?"),
            content: Text("Do you want to save this menu?"),
            actions: [
              TextButton(
                child: Text("No"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  final configResponse = await http
                      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

                  if (configResponse.statusCode == 200) {
                    final configJson = jsonDecode(configResponse.body);
                    final base_url = configJson['data']['apidomain'];

                    final cid = await SessionManager().get("cid");
                    final userMenuListUrl = '$base_url/getusermenulist-ax.php?clid=$cid';
                    final userMenuListResponse = await http.get(Uri.parse(userMenuListUrl));
                    if (userMenuListResponse.statusCode == 200) {
                      final userMenuListJson = jsonDecode(userMenuListResponse.body);
                      final userMenuList = userMenuListJson['data'];
                      final menuExists = userMenuList.any((menu) => menu['id'] == product);
                      if (!menuExists) {
                        // Add the menu to the user's list
                        final createMenuUrl = '$base_url/reqmenuaccess-ax.php?mid=$product&clid=$cid';
                        final createMenuResponse = await http.post(Uri.parse(createMenuUrl));
                        if (createMenuResponse.statusCode == 200) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Menu saved successfully!"),
                          ));
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Failed to save menu!"),
                          ));
                        }
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Menu already exists!"),
                        ));
                      }
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to get user menu list!"),
                      ));
                    }
                  }
                },
              ),
            ],
          ),
        )
      });
    }
  });
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
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initDynamicLinks();
    }
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
