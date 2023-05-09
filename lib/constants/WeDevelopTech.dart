import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../screens/MaintananceMode.dart';
import '../services/api_service.dart';
import 'NoInternet.dart';

class WeDevelopTech extends StatefulWidget {
  const WeDevelopTech({Key? key}) : super(key: key);

  @override
  State<WeDevelopTech> createState() => _WeDevelopTechState();
}

class _WeDevelopTechState extends State<WeDevelopTech> {

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';
  late WebViewController _webView;

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
      child: _isMaintenanceMode
          ? MaintananceMode()
          :
      Provider.of<InternetConnectionStatus>(context) ==
          InternetConnectionStatus.disconnected
          ? NoInternet()
          :
      Scaffold(
        body: Container(
          width: double.infinity,
          //padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: WebView(
            initialUrl: 'https://www.wedeveloptech.com/',
            javascriptMode: JavascriptMode.unrestricted,
            onWebResourceError: (WebResourceError error) {
              print('WebView error: ${error.description}');
            },
            onWebViewCreated: (WebViewController controller) {
              _webView = controller;
            },
          ),
        ),
      ),
    );
  }
}
