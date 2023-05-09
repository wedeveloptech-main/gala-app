import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/LoginData.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/homeScreen.dart';
import 'package:myapp/screens/login/OtpScreen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../constants/NoInternet.dart';
import '../MaintananceMode.dart';

class LoginNameScreen extends StatefulWidget {
  const LoginNameScreen({Key? key}) : super(key: key);

  @override
  State<LoginNameScreen> createState() => _LoginNameScreenState();
}

class _LoginNameScreenState extends State<LoginNameScreen> {

  //form key for validating the form fields
  final _formKey = GlobalKey<FormState>();
  // Create a text controller and use it to retrieve the current value of the TextField.
  Future<LoginData>? futureLoginData;
  final _userNameController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  @override
  void initState() {
    super.initState();
    //futureCreateData = fetchCreateData(_controller.text);
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

  void _verifyUserName() async {

    dynamic cid = await SessionManager().get("cid");

    final configResponse = await http
        .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

    if (configResponse.statusCode == 200) {
      final configJson = jsonDecode(configResponse.body);
      final base_url = configJson['data']['apidomain'];

    final response = await http.get(
      Uri.parse('$base_url/requpdateclientdtls-ax.php?clid=$cid&name=${_contactController.text}'),
    );
    final data = json.decode(response.body);
    //print(response.body);

    if (data['code'] == 1) {
      if (_formKey.currentState!.validate()) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
              (route) => false,
        );
        SessionManager().set("name", _contactController.text);
      }
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString('cid', data.cid);
      //print(prefs);
      await SessionManager().set("cid", data['data']['cid']);
      await SessionManager().set("name", data['data']['name']);
      await SessionManager().set("phoneno", data['data']['phoneno'].toString());
      await SessionManager().set("profilestatus", data['data']['profilestatus']);
      await SessionManager().set("password", data['data']['password']);
      await SessionManager().set("isLogin", true);
      //print(temp_id);

    }
    } else {
      throw Exception('Failed to load config');
    }
  }

  /*void _verifyUserName() async {
    dynamic cid = await SessionManager().get("cid");

    final configResponse = await http
        .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

    if (configResponse.statusCode == 200) {
      final configJson = jsonDecode(configResponse.body);
      final base_url = configJson['data']['apidomain'];

      final response = await http.get(Uri.parse(
          'http://appdata.galacaterers.in/requpdateclientdtls-ax.php?clid=$cid&name=${_contactController.text}'));

      final data = json.decode(response.body);

      if (data['code'] == 1) {

        await SessionManager().set("name", data['data']['name']);
        await SessionManager().set("profilestatus", data['data']['profilestatus']);

        if (_formKey.currentState!.validate()) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
          );
        }
        await SessionManager().set("cid", data['data']['cid']);
        await SessionManager().set("name", data['data']['name']);
        await SessionManager().set("phoneno", data['data']['phoneno']);
        await SessionManager().set("isLogin", true);

      }
    } else {
      throw Exception('Failed to load config');
    }
  }*/


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
        resizeToAvoidBottomInset: true,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Container(
                    width:300.w,
                    height: 300.h,
                    child: Image.asset(
                      'assets/images/OTPVector.png',
                    ),
                  ),
                  Text(
                    'User Name',
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: kblue,
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Text(
                    "Please share your name for better interaction.",
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    padding: EdgeInsets.all(28.r),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _contactController, //will help get the field value on submit
                            // initialValue: "1",
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10.r)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10.r)),
                              suffixIcon: Icon(
                                Icons.person,
                                color: kblue,
                                size: 32.r,
                              ),
                              hintText: 'Username',
                              hintStyle: TextStyle(color: kgrey),
                            ),
                            //validator on submit, must return null when every thing ok
                            // The validator receives the text that the user has entered.
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return 'Username is required';}
                              else if(value.trim().isEmpty){
                                return "Username is required";
                              }
                              return null;
                            },
                          ),
                          /*TextFormField(
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10.r)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10.r)),
                              suffixIcon: Icon(
                                Icons.person,
                                color: kblue,
                                size: 32.r,
                              ),
                              hintText: 'Username',
                              hintStyle: TextStyle(color: kgrey),
                            ),
                          ),*/
                          SizedBox(
                            height: 25.h,
                          ),
                          Container(
                            height: 70.h,
                            width: 1.sw,
                            child: TextButton(
                              onPressed: _verifyUserName,
                              /*onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    //futureCreateData = fetchCreateData(_controller.text);
                                    //futureCreateMenu = fetchCreateMenu();
                                  });
                                  _submitForm();//clear text in field
                                  _contactController.clear();
                                  //showToastMessage("OTP send successfully.");
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(
                                          userName: _contactController.text),
                                    ),
                                  );
                                };
                              },*/

                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  backgroundColor: kblue),
                              child: Text(
                                'Send',
                                style: TextStyle(fontFamily: 'Roboto', fontSize: 20.sp),),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showToastMessage(String message){
    Fluttertoast.showToast(
        msg: message, //message to show toast
        toastLength: Toast.LENGTH_LONG, //duration for message to show
        gravity: ToastGravity.BOTTOM, //where you want to show, top, bottom
        timeInSecForIosWeb: 1, //for iOS only
        //backgroundColor: Colors.red, //background Color for message
        textColor: Colors.white, //message text color
        fontSize: 16.0 //message font size
    );
  }

  void _submitForm() async {
    String name = _contactController.text;

    // Make the API request
    var response = await http.post(Uri.parse('http://appdata.galacaterers.in/requserlogin-ax.php?phno=9821881347'),
        body: {'name': name});

    // Handle the response
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      // do something with the data
    } else {
      // handle error
    }
  }

}
