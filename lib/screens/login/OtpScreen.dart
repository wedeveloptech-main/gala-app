import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/LoginData.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/homeScreen.dart';
import 'package:myapp/screens/login/LoginName.dart';
import 'package:myapp/services/api_service.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/NoInternet.dart';
import '../MaintananceMode.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String salt;
  final String profilestatus;
  final String password;
  const OTPScreen({Key? key, required this.phoneNumber, required this.salt, required this.password, required this.profilestatus}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  int start = 09;
  bool wait = false;
  int secondsRemaining = 09;
  bool enableResend = false;
  late String _newOTP;
  late Timer timer;
  String verificationIdFinal = "";
  String smsCode = "";
  late Future<LoginData> futureLoginData;TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';
  late String _password;
  late String _profilestatus;
  late String _salt;

  bool obscureText = false;
  String obscuringCharacter = '*';
  int otpprefilled = 0;

  void _submitOtp() async {
    final response = await http.get(
      Uri.parse('http://appdata.galacaterers.in/requserlogin-ax.php?phno=${widget.phoneNumber}&otp=${otpController.text}'),
    );
    final data = json.decode(response.body);

    if (data['code'] == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
    else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginNameScreen(),
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    //showToastMessage("OTP Resend Successfully!");
    setState(() {
      //showToastMessage("OTP Resend Successfully!");
      secondsRemaining = 09;
      enableResend = false;
    });

    otpController.clear();

    try {
      final configResponse = await http.get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

      if (configResponse.statusCode == 200) {
        final configJson = jsonDecode(configResponse.body);
        final base_url = configJson['data']['apidomain'];

        final response = await http.get(Uri.parse('$base_url/requserlogin-ax.php?phno=${widget.phoneNumber}'));
        final data = json.decode(response.body);

        if (data['code'] == 1) {
          setState(() {
            _salt = data['data']['salt'];
            //_password = data['data']['password'];
            _password = widget.password;
            _profilestatus = data['data']['profilestatus'];
          });

        }

        try {
          final configData = await fetchMaintenanceModeData();
          setState(() {
            otpprefilled = configData['data']['otpprefilled'];
            if (otpprefilled == 1) {
              otpController.text = _password.toString();
            } else {
              otpController.text = '';
            }
          });
        } catch (e) {
          print(e.toString());
        }

        showToastMessage("OTP sent to ${widget.phoneNumber}!");
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP sent successfully')));
      } else {
        throw Exception('Failed to load config');
      }
    } catch (error) {
      showToastMessage("Error occurred: $error");
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error occurred: $error')));
    }

    setState(() async {
      await SessionManager().set("password", _password);
      await SessionManager().set("salt", _salt);
    });
  }


  @override
  initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
    _checkMaintenanceMode();
    fetchConfigData();
    _password = widget.password;
    _profilestatus = widget.profilestatus;
    _salt = widget.salt;
  }

  Future<void> fetchConfigData() async {
    try {
      final configData = await fetchMaintenanceModeData();
      setState(() {
        otpprefilled = configData['data']['otpprefilled'];
        if (otpprefilled == 1) {
          otpController.text = widget.password.toString();
        } else {
          otpController.text = '';
        }
      });
    } catch (e) {
      print(e.toString());
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
        resizeToAvoidBottomInset: true,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Container(
                    width: 300.w,
                    height: 300.h,
                    child: Image.asset(
                      'assets/images/OTPVector.png',
                    ),
                  ),
                  Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: kblue,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Please enter the OTP sent to your registered phone number.",
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    padding: EdgeInsets.all(28.r),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: kblue,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 5,

                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5.r),
                            borderWidth: 1,
                            fieldHeight: 45.h,
                            fieldWidth: 35.w,
                            inactiveColor: kgrey,
                            activeColor: kblue,
                            inactiveFillColor: kwhite,
                            activeFillColor: Colors.white70,
                            selectedColor: kblue,
                            selectedFillColor: kwhite,
                          ),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.normal, // Set font weight to normal
                          ),
                          cursorColor: Colors.black,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          //errorAnimationController: errorController,
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          /*boxShadows: const [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: Colors.black12,
                                  blurRadius: 10,
                                )
                              ],*/
                          onCompleted: (v) {
                            debugPrint("Completed");
                          },
                          // onTap: () {
                          //   print("Pressed");
                          // },
                          onChanged: (value) {
                            debugPrint(value);
                            /*setState(() {
                                  currentText = value;
                                });*/
                          },
                          beforeTextPaste: (text) {
                            debugPrint("Allowing to paste $text");
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                      ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Container(
                          height: 70.h,
                          width: 1.sw,
                          child: TextButton(
                            onPressed: () async {
                              String correctOTP = widget.password.toString();
                              //int? enteredOTP = int.tryParse(otpController.text);
                              String enteredOTP = otpController.text; // Parse the entered OTP as an integer
                              if (enteredOTP == correctOTP) {
                                // Check if entered OTP is not null and matches the expected OTP (e.g., 18791)
                                /*Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => LoginNameScreen()),
                                );*/
                                dynamic profilestatus = await SessionManager().get("profilestatus");
                                if (widget.profilestatus == '0') {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => LoginNameScreen()),
                                        (route) => false,
                                  );
                                  await SessionManager().set("isLogin", true);
                                  showToastMessage("OTP Verified Successfully!");
                                } else {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                        (route) => false,
                                  );
                                  await SessionManager().set("isLogin", true);
                                  showToastMessage("OTP Verified Successfully!");
                                }

                              } else if  (enteredOTP == null || enteredOTP.isEmpty){
                                showToastMessage("Please Enter OTP!");
                              }
                              else {
                                showToastMessage("Invalid OTP!"); // Show a message indicating invalid OTP
                              }
                              //isLoading ? null : _onSubmitOtp;
                            },

                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                backgroundColor: kblue),
                            child:  Text(
                              'Verify',
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 20.sp),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    "Didn't you receive any code?",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text('Resend OTP again in ',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: enableResend ? kblue : Colors.black12,
                          ),),
                        onPressed:
                        enableResend ? _resendCode : null,
                      ),
                      Text(
                        '00:$secondsRemaining',
                        style: TextStyle(fontSize: 16, color: korange),
                      ),
                      Text(
                        ' sec',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: kblue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  /*void _resendCode() {
    showToastMessage("OTP Resend Successfully!");
    //other code here
    setState((){
      showToastMessage("");
      secondsRemaining = 09;
      enableResend = false;
    });
  }*/

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

  @override
  dispose(){
    timer.cancel();
    super.dispose();
  }

  // Function to send OTP
  Future<void> sendOTP(String phoneNumber) async {
    /*final url = 'http://appdata.galacaterers.in/requserlogin-ax.php?phno=$phoneNumber'; // Replace with your actual API endpoint
  final response = await http.post(url, body: {'phoneNumber': phoneNumber});*/
    final response = await http
        .get(Uri.parse('http://appdata.galacaterers.in/requserlogin-ax.php?phno=$phoneNumber'));

    // Handle response
    if (response.statusCode == 200) {
      // OTP sent successfully
      print('OTP sent to $phoneNumber');
    } else {
      // Handle error
      print('Failed to send OTP');
    }
  }

}

