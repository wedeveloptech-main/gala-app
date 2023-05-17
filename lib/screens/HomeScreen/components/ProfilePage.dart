import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/constants/WeDevelopTech.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/components/MenuPage.dart';
import 'package:myapp/screens/HomeScreen/components/widgets/RatingDialog.dart';
import 'package:myapp/screens/login/Login.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/NoInternet.dart';
import '../../../constants/PrivacyPolicy.dart';
import '../../../constants/Tems&Conditions.dart';
import '../../../services/api_service.dart';
import '../../MaintananceMode.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';
  final _formKey2 = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  var version;

  @override
  void initState() {
    super.initState();
    _checkMaintenanceMode();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final data = await fetchMaintenanceModeData();
    if (data['code'] == 1) {
      final appVersion = data['data']['appversion'];
      await SessionManager().set("appversion", appVersion);
      setState(() {
        version = appVersion;
      });
    }
    else{
      setState(() {
        version = 1;
      });
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

  void _updateUserName() async {
    String? cid = await SessionManager().get("cid");
    String? newName = _contactController.text;

    final response = await http.get(
      Uri.parse('http://appdata.galacaterers.in/requpdateclientdtls-ax.php?clid=$cid&name=$newName'),
    );
    final data = json.decode(response.body);

    if (data['code'] == 1) {
      // update the name in the SessionManager
      await SessionManager().set("name", newName);

      setState(() {
        // update the name in the UI
        _contactController.text = newName;
      });
    }
  }

  /*void _showRatingAppDialog() {
    final _ratingDialog = RatingDialog(
      initialRating: 1.0,
      title: Text(
        'Rate the App',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      message: Text(
        'Tap a star to set your rating.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
        submitButtonText: 'Submit',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, '
          //'comment: ${response.comment}'
        );

        if (response.rating < 3.0) {
          print('response.rating: ${response.rating}');
        } else {
          Container();
        }
      }
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ratingDialog,
    );
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Manage Profile',
                          style: TextStyle(color: kwhite, fontSize: 20.sp),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //padding: EdgeInsets.symmetric(horizontal: 10.w),
                    children: [
                      Column(
                        children: [
                          TextButton(
                            onPressed: () async {
                              dynamic username = await SessionManager().get("name");
                              dynamic phno = await SessionManager().get("phoneno");
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context)  => Container(
                                    height: 280.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:  BorderRadius.only(
                                        topLeft: Radius.circular(25.r),
                                        topRight: Radius.circular(25.r),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(height: 16.h,),
                                        Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20.r),
                                                color: kblue
                                            ),
                                            width: 100.w,
                                            height: 5.h,
                                          ),
                                        ),
                                        SizedBox(height: 16.h,),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context){
                                                        return AlertDialog(
                                                          title: Text("Update Name",
                                                            style: TextStyle(fontSize: 20.sp),),
                                                          content: Form(
                                                              key: _formKey2,
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min, //the dialog takes only size it needs
                                                                children: [
                                                                  TextFormField(
                                                                    controller: _contactController,
                                                                    textCapitalization: TextCapitalization.words,
                                                                    autocorrect: true,
                                                                    onChanged: (value) {},
                                                                    validator: (value) {
                                                                      if (value == null || value.isEmpty) {
                                                                        return 'Value is required';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    decoration: InputDecoration(
                                                                      labelText: 'User Name',
                                                                      hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                                                                      fillColor: Colors.white,
                                                                      filled: true,
                                                                      //enabledBorder: InputBorder.none,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: kgrey,),
                                                                        //borderRadius: BorderRadius.circular(50.0),
                                                                      ),
                                                                      //focusedBorder: InputBorder.none
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: kgrey,
                                                                        ),
                                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                                      ),
                                                                      contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                          ),
                                                          //actions
                                                          actions: [
                                                            //dismiss dialog
                                                            TextButton(onPressed: (){
                                                              Navigator.of(context).pop(); // dismiss dialog
                                                            }, child: const Text("Cancel")),

                                                            //save btn
                                                            TextButton(
                                                              child: const Text("Edit"),
                                                              onPressed: () async {
                                                                if (_formKey2.currentState!.validate()) {
                                                                  String name = _contactController.text.trim();
                                                                  dynamic cid = await SessionManager().get("cid");

                                                                  final response = await http.get(
                                                                    Uri.parse('http://appdata.galacaterers.in/requpdateclientdtls-ax.php?clid=$cid&name=$name'),
                                                                  );
                                                                  final data = json.decode(response.body);

                                                                  if (data['code'] == 1) {
                                                                    await SessionManager().set("name", name);
                                                                    /*ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text("Name updated successfully")),
                                                              );*/
                                                                    Navigator.of(context).pop();
                                                                    Fluttertoast.showToast(
                                                                      msg: "Name Updated Successfully!", // your toast message
                                                                      toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                      gravity: ToastGravity.BOTTOM, // toast gravity
                                                                      backgroundColor: Colors.black54, // background color of the toast
                                                                      textColor: Colors.white, // text color of the toast
                                                                    );
                                                                  } else {
                                                                    Navigator.of(context).pop();
                                                                    /*ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text("Error updating name")),
                                                              );*/
                                                                    Fluttertoast.showToast(
                                                                      msg: "Error While Updating Name!", // your toast message
                                                                      toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                      gravity: ToastGravity.BOTTOM, // toast gravity
                                                                      backgroundColor: Colors.red, // background color of the toast
                                                                      textColor: Colors.white, // text color of the toast
                                                                    );
                                                                  }
                                                                  Navigator.of(context).pop();
                                                                  _contactController.clear();
                                                                }

                                                              },

                                                            ),

                                                          ],
                                                        );
                                                      });
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Text("User Name", style: TextStyle(color: kblue, fontSize: 20.sp),),
                                                        SizedBox(height: 5.h,),
                                                        Text(username, style: TextStyle(color: kblack1, fontSize: 18.sp),),
                                                      ],
                                                    ),
                                                    Image.asset("assets/images/Edit-Icon.png", height: 25.h, width: 25.w,),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10.h,),
                                              Divider(height: 5.h, color: Colors.black45,),
                                              SizedBox(height: 10.h,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Text("Contact No.", style: TextStyle(color: kblue, fontSize: 20.sp),),
                                                  SizedBox(height: 5.h,),
                                                  Text('+91 $phno', style: TextStyle(color: kblack1, fontSize: 18.sp),)
                                                ],
                                              ),
                                              SizedBox(height: 20.h,),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              );
                            },
                            child: Row(
                              children: [
                                Image.asset("assets/images/Profile-P.png", height: 20.h, width: 20.w,),
                                SizedBox(width: 10.w,),
                                Text('Profile', style: TextStyle(
                                    fontSize: 18.sp, color: kblue),),
                              ],
                            ),),
                          SizedBox(height: 2.h,),
                          Divider(height: 5.h, color: Colors.black45,),
                          SizedBox(height: 2.h,),
                          /*TextButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Image.asset("assets/images/Saved-P.png", height: 20.h, width: 20.w,),
                            SizedBox(width: 10.w,),
                            Text('Saved Menu', style: TextStyle(
                                fontSize: 18.sp, color: kblue),),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h,),
                      Divider(height: 5.h, color: Colors.black45,),
                      SizedBox(height: 2.h,),*/
                          TextButton(
                            onPressed: () async {
                              final data = await fetchMaintenanceModeData();
                              if (data['code'] == 1) {
                                if (data['data']['termsandcondition'] != null) {
                                  //await launch(data['data']['termsandcondition']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TermsConditions(url: data['data']['privacypolicy']),
                                    ),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Page Not Found!", // your toast message
                                    toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                    gravity: ToastGravity.BOTTOM, // toast gravity
                                    backgroundColor: Colors.black54, // background color of the toast
                                    textColor: Colors.white, // text color of the toast
                                  );
                                }
                                print(launch);
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Page Not Found!", // your toast message
                                  toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                  gravity: ToastGravity.BOTTOM, // toast gravity
                                  backgroundColor: Colors.black54, // background color of the toast
                                  textColor: Colors.white, // text color of the toast
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Image.asset("assets/images/Terms-P.png", height: 20.h, width: 20.w,),
                                SizedBox(width: 10.w,),
                                Text('Terms & Conditions', style: TextStyle(
                                    fontSize: 18.sp, color: kblue),),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h,),
                          Divider(height: 5.h, color: Colors.black45,),
                          SizedBox(height: 2.h,),
                          TextButton(
                            onPressed: () async {
                              final data = await fetchMaintenanceModeData();
                              if (data['code'] == 1) {
                                if (data['data']['privacypolicy'] != null) {
                                  //await launchUrl(data['data']['privacypolicy']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrivacyPolicyScreen(url: data['data']['privacypolicy']),
                                    ),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Page Not Found!", // your toast message
                                    toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                    gravity: ToastGravity.BOTTOM, // toast gravity
                                    backgroundColor: Colors.black54, // background color of the toast
                                    textColor: Colors.white, // text color of the toast
                                  );
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Page Not Found!", // your toast message
                                  toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                  gravity: ToastGravity.BOTTOM, // toast gravity
                                  backgroundColor: Colors.black54, // background color of the toast
                                  textColor: Colors.white, // text color of the toast
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Image.asset("assets/images/Privacy-P.png", height: 20.h, width: 20.w,),
                                SizedBox(width: 10.w,),
                                Text('Privacy Policy', style: TextStyle(
                                    fontSize: 18.sp, color: kblue),),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h,),
                          Divider(height: 5.h, color: Colors.black45,),
                          SizedBox(height: 2.h,),
                          TextButton(
                            onPressed: () async {
                              _showRatingDialog(context);
                              /*int stars = await showDialog(
                                context: context,
                                builder: (_) => RatingDialogBox()
                            );

                            if(stars == null) return;

                            print('Selected rate stars: $stars');*/
                            },
                            child: Row(
                              children: [
                                Image.asset("assets/images/Rate-P.png", height: 20.h, width: 20.w,),
                                SizedBox(width: 10.w,),
                                Text('Rate App', style: TextStyle(
                                    fontSize: 18.sp, color: kblue),),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h,),
                          Divider(height: 5.h, color: Colors.black45,),
                          SizedBox(height: 2.h,),
                          TextButton(
                            onPressed: () async{
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      //title: Text('Delete Menu'),
                                      content: Text('Do you really want to log out?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); //close Dialog
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                            onPressed: () async {
                                              await SessionManager().destroy();
                                              await SessionManager().set("isLogin", false);
                                              Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder: (context) => LoginScreen(),),
                                                    (route) => false,
                                              );
                                            },
                                            child: Text('Yes')),
                                      ],
                                    );
                                  });
                            },
                            child: Row(
                              children: [
                                Image.asset("assets/images/LogOut-P.png", height: 20.h, width: 20.w,),
                                SizedBox(width: 10.w,),
                                Text('Logout', style: TextStyle(
                                    fontSize: 18.sp, color: kblue),),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h,),
                          Divider(height: 5.h, color: Colors.black45,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset("assets/images/LogoSplash.png",  height: 60.h,),
                          SizedBox(height: 15.h,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('App Version $version'),
                              //Text('1.1'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Developed By'),
                              SizedBox(width: 5.w,),
                              Padding(
                                padding: EdgeInsets.zero,
                                child: TextButton(
                                  onPressed: () async {
                                    final data = await fetchMaintenanceModeData();
                                    if (data['code'] == 1) {
                                      if (data['data']['privacypolicy'] != null) {
                                        //await launchUrl(data['data']['privacypolicy']);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WeDevelopTech(url: data['data']['devloperurl']),
                                          ),
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Page Not Found!", // your toast message
                                          toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                          gravity: ToastGravity.BOTTOM, // toast gravity
                                          backgroundColor: Colors.black54, // background color of the toast
                                          textColor: Colors.white, // text color of the toast
                                        );
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Page Not Found!", // your toast message
                                        toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                        gravity: ToastGravity.BOTTOM, // toast gravity
                                        backgroundColor: Colors.black54, // background color of the toast
                                        textColor: Colors.white, // text color of the toast
                                      );
                                    }
                                  },
                                  child: Text('WeDevelopTech', style: TextStyle(
                                      color: kblack),),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h,),
                        ],
                      )
                      //SizedBox(height: 20.h,),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch website link
  Future<void> _launchWebsiteLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  _launchPrivacy() async {
    const url = 'https://www.galacaterers.in';
    final uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString(), forceSafariVC: true, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchTerms() async {
    const url = 'https://www.galacaterers.in';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchApp() async {
    // Replace 'com.example.your_app_package' with your app's package name
    String appPackage = 'in.galacaterers.app_data';

    // Open the Google Play Store with the app's URL
    //String url = 'https://play.google.com/store/apps/details?id=$appPackage';
    String url = 'https://play.google.com/apps/internaltest/4701600633340132070';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error, e.g. show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to open Google Play Store.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void show() {
    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return RatingDialog(
            //initialRating: 1.0,
            image: Icon(
              Icons.star,
              size: 80,
              color: kblue,
            ), // set your own image/icon widget
            title: Text(
              'Rate the App',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            message: Text(
              'Tap a star to set your rating.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            submitButtonText: "SUBMIT",
            //commentHint: 'Set your custom comment hint',
            onCancelled: () => print('cancelled'),
            onSubmitted: (response) {
              print('rating: ${response.rating}, comment: ${response.comment}');

              // TODO: add your own logic
              if (response.rating < 3.0) {
                // send their comments to your email or anywhere you wish
                // ask the user to contact you instead of leaving a bad review
              } else {
                _rateAndReviewApp();
              }
            },
          );
        });
    /*showDialog(
      context: context,
      barrierDismissible: true, // set to false if you want to force a rating
      builder: (context) => _dialog,
    );*/
  }

  void _rateAndReviewApp() async {
    // refer to: https://pub.dev/packages/in_app_review
    final _inAppReview = InAppReview.instance;

    if (await _inAppReview.isAvailable()) {
      print('request actual review from store');
      _inAppReview.requestReview();
    } else {
      print('open actual store listing');
      // TODO: use your own store ids
      _inAppReview.openStoreListing(
        appStoreId: '<your app store id>',
        microsoftStoreId: '<your microsoft store id>',
      );
    }
  }
}

void _showRatingDialog(BuildContext context){
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: Text("Rate This App", style: TextStyle(fontSize: 20.sp),)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Text("Please rate us and share your feedback.", style: TextStyle(fontSize: 18.sp),)),
          SizedBox(height: 16),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 38,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print(rating);
              // Here you can save the user's rating in a variable
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Submit"),
          onPressed: () async {
            Navigator.pop(context);
            if (await canLaunch("https://play.google.com/store/apps/details?id=in.galacaterers.app_data&pli=1")) {
              await launch("https://play.google.com/store/apps/details?id=in.galacaterers.app_data&pli=1");
            } else {
              throw "Could not launch store";
            }
          },
        ),
      ],
    ),
  );
}

