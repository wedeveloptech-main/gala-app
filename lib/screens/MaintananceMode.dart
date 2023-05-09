import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../constants/color.dart';
import '../services/api_service.dart';

class MaintananceMode extends StatefulWidget {
  const MaintananceMode({Key? key}) : super(key: key);

  @override
  State<MaintananceMode> createState() => _MaintananceModeState();
}

class _MaintananceModeState extends State<MaintananceMode> {

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Provider.of<InternetConnectionStatus>(context) ==
          InternetConnectionStatus.disconnected
          ? Scaffold(
        body: Container(
          color: kwhite,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 1.sh / 4.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/NoInternet.png',
                  height: 150.h,
                ),
                Center(
                  child: Text(
                    'Oops!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: kblue,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'No Internet Connection Found!\nCheck Your Connection or Try Again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          : Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 300.w,
                  height: 300.h,
                  child: Image.asset(
                    'assets/images/maintenance-mode.png',
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                Center(
                  child: Text(
                    'Maintenance Mode',
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: kblue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                Text(
                  _maintenanceMsg,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
