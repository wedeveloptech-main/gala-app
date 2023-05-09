import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/LoginData.dart';
import 'package:myapp/Models/ShowLogin.dart';
import 'package:myapp/constants/NoInternet.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/login/OtpScreen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../MaintananceMode.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //form key for validating the form fields
  final _formKey = GlobalKey<FormState>();
  // Create a text controller and use it to retrieve the current value of the TextField.
  late Future<LoginData> futureLoginData;
  late Future<ShowLogin> futureShowLogin;
  final TextEditingController _userNameController = TextEditingController();
  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';


  @override
  void initState() {
    super.initState();
    futureLoginData = fetchLoginData(_userNameController.text);
    //futureCreateData = fetchCreateData(_controller.text);

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

  void _verifyPhoneNumber() async {
    final response = await http.get(
      Uri.parse('http://appdata.galacaterers.in/requserlogin-ax.php?phno=${_userNameController.text}'),
    );
    final data = json.decode(response.body);
    //print(response.body);

    if (data['code'] == 1) {
      if (_formKey.currentState!.validate()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OTPScreen(
                  phoneNumber: _userNameController.text,
                  salt: data['data']['salt'],
                  password: data['data']['password'],
                  profilestatus: data['data']['profilestatus'],
                ),
          ),
        );
      }
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString('cid', data.cid);
      //print(prefs);
      await SessionManager().set("cid", data['data']['cid']);
      await SessionManager().set("name", data['data']['name']);
      await SessionManager().set("phoneno", data['data']['phoneno']);
      await SessionManager().set("profilestatus", data['data']['profilestatus']);
      await SessionManager().set("isLogin", true);
      //dynamic temp_id = await SessionManager().get("cid");
      //print(temp_id);
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
          : WillPopScope(
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
                        //Navigator.of(context).pop(true);
                        SystemNavigator.pop();
                      },
                    ),
                  ],
                );
              }
          );

          return value == true;
        },
            child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w,),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back,
                              size: 32,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),*/
                    Container(
                      width: 300.w,
                      height: 300.h,
                      child: Image.asset(
                        'assets/images/OTPVector.png',
                      ),
                    ),
                    Text(
                      'Registration',
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        color: kblue,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      "Please register using your phone number. An OTP would be sent for verification.",
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.all(28.r),
                      child: FutureBuilder<LoginData>(
                        builder: (context, snapshot) {
                          return Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  maxLength: 10,
                                  keyboardType: TextInputType.phone,
                                  //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  controller: _userNameController, //will help get the field value on submit
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10.r)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10.r)),
                                    prefixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            '(+91)',
                                          ),
                                        )
                                      ],),
                                    suffixIcon: Icon(
                                      Icons.phone_android,
                                      color: kblue,
                                      size: 30.r,
                                    ),
                                    hintText: 'Phone Number',
                                    hintStyle: TextStyle(color: kgrey),
                                  ),
                                  //validator on submit, must return null when every thing ok
                                  // The validator receives the text that the user has entered.
                                  validator: (value) {
                                    final pattern = RegExp(r'^[0-9]{10}$');
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Your Phone Number';
                                    } else if (value.trim().isEmpty) {
                                      return "Please Enter Your Phone Number";
                                    } else if (!pattern.hasMatch(value)) {
                                      return 'Invalid Phone Number';
                                    }
                                    return null;
                                  },
                                ),
                                /*TextFormField(
                                controller: _userNameController,
                                keyboardType: TextInputType.number,
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
                                  prefix: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                    child: Text(
                                      '(+91)',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Icon(
                                    Icons.call,
                                    color: kblue,
                                    size: 30.r,
                                  ),
                                  //hintText: 'Phone Number',
                                  //hintStyle: TextStyle(color: kgrey),
                                ),
                              ),*/
                                SizedBox(
                                  height: 25.h,
                                ),
                                Container(
                                  height: 70.h,
                                  width: 1.sw,
                                  child: TextButton(
                                    onPressed: () async {
                                      try {
                                        final configResponse = await http
                                            .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

                                        if (configResponse.statusCode == 200) {
                                          final configJson = jsonDecode(configResponse.body);
                                          final base_url = configJson['data']['apidomain'];

                                          final response = await http.get(Uri.parse('$base_url/requserlogin-ax.php?phno=${_userNameController.text}'));
                                          final data = json.decode(response.body);

                                          if (_formKey.currentState!.validate()) {
                                            if (data['code'] == 1) {
                                              showToastMessage("OTP sent to ${_userNameController.text}!");
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OTPScreen(
                                                        phoneNumber: _userNameController.text.toString(),
                                                        salt: data['data']['salt'].toString(),
                                                        password: data['data']['password'].toString(),
                                                        profilestatus: data['data']['profilestatus'].toString(),
                                                      ),
                                                ),
                                              );
                                            }
                                            await SessionManager().set("cid", data['data']['cid']);
                                            await SessionManager().set("name", data['data']['name']);
                                            await SessionManager().set("phoneno", data['data']['phoneno'].toString());
                                            await SessionManager().set("password", data['data']['password']);
                                            await SessionManager().set("isLogin", true);
                                          }
                                        } else {
                                          throw Exception('Failed to load config');
                                        } }
                                      catch (error) {
                                        print('Error occurred: $error');
                                      }
                                    },
                                    //onPressed: _verifyPhoneNumber,
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        backgroundColor: kblue),
                                    child:
                                    Text(
                                      'Send',
                                      style: TextStyle(fontFamily: 'Roboto', fontSize: 20.sp),),
                                  ),
                                )
                              ],
                            ),
                          );

                          return const Center(
                            child: SizedBox(
                              height: 50.0,
                              width: 50.0,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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

}
