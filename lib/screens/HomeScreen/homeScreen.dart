import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/components/CategoryPage.dart';
import 'package:myapp/screens/HomeScreen/components/HomePage.dart';
import 'package:myapp/screens/HomeScreen/components/MenuPage.dart';
import 'package:myapp/screens/HomeScreen/components/ProfilePage.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';

import '../../constants/NoInternet.dart';
import '../../services/api_service.dart';
import '../MaintananceMode.dart';

class HomeScreen extends StatefulWidget {
  final userName;
  HomeScreen({Key? key, this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  /*Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('exit?'),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text('no'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }*/

  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[];

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(),
      CategoryPage(),
      MenuPage(),
      ProfilePage(),
    ];
    _checkMaintenanceMode();
    _checkVersion();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /*@override
  void initState() {
    super.initState();
    //_checkVersion();
  }*/


  void _checkVersion() async {
    final newVersion = NewVersion(
      androidId: "com.example.myapp",
    );
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: "UPDATE!!!",
        dismissButtonText: "Skip",
        dialogText: "Please update the app from " +
            "${status.localVersion}" +
            " to " +
            "${status.storeVersion}",
        dismissAction: () {
          SystemNavigator.pop();
        },
        updateButtonText: "Lets update",
      );

      print("DEVICE : " + (status.localVersion ?? ""));
      print("STORE : " + (status.storeVersion ?? ""));
    } else {
      print("Failed to get version status");
    }
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isMaintenanceMode
          ? MaintananceMode()
          :
      Provider.of<InternetConnectionStatus>(context) ==
          InternetConnectionStatus.disconnected
          ? NoInternet()
      : Scaffold(
          body: WillPopScope(child: _widgetOptions.elementAt(_selectedIndex),
              onWillPop: () async {
                final value = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('Are you sure you want to exit?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text('Yes, exit'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    }
                );

                return value == true;
              },),

          bottomNavigationBar: Container(
            height: 50,
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/images/Asset 3.png",),
                    ),
                    activeIcon: ImageIcon(
                      AssetImage("assets/images/Asset 10.png"),
                    ),
                    label: ""
                ),
                BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/images/Asset 5.png"),
                    ),
                    activeIcon: ImageIcon(
                      AssetImage("assets/images/Asset 8.png"),
                    ),
                    label: ""
                ),
                BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/images/Asset 6.png"),
                    ),
                    activeIcon: ImageIcon(
                      AssetImage("assets/images/Asset 9.png"),
                    ),
                    label: ""
                ),
                BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/images/Asset 4.png"),
                    ),
                    activeIcon: ImageIcon(
                      AssetImage("assets/images/Asset 7.png"),
                    ),
                    label: ""
                ),
              ],
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              backgroundColor: kblue,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              iconSize: 20,
              onTap: _onItemTapped,
              showSelectedLabels: false,
              showUnselectedLabels: false,
            ),
          )
      ),
    );
  }
}
