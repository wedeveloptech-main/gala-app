import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../screens/MaintananceMode.dart';
import '../services/api_service.dart';
import 'NoInternet.dart';
import 'color.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final String url;
  const PrivacyPolicyScreen({required this.url});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {

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
          : Scaffold(
        backgroundColor: kblue,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: 10.h, left: 10.w, right: 10.w, bottom: 10.h),
              child: SizedBox(
                height: 40.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios_new_outlined,
                              color: kwhite, size: 15.r,),
                            SizedBox(width: 10.w,),
                            Text('Back',
                              style: TextStyle(color: kwhite, fontSize: 15.sp),)
                          ],
                        ),
                      ),
                    ),
                    /*SizedBox(
                      height: 40.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Privacy Policy', style: TextStyle(color: kwhite,fontSize: 20.sp),),
                        ],
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
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
                    //initialUrl: 'http://www.galacaterers.in/',
                  initialUrl: widget.url,
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
          ],
        ),
      ),
    );
  }
}
