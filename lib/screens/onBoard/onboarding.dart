import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/constants/NoInternet.dart';
import 'dart:async';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/homeScreen.dart';
import 'package:myapp/screens/login/Login.dart';
import 'package:myapp/screens/onBoard/content_model.dart';
import 'package:provider/provider.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Provider.of<InternetConnectionStatus>(context) ==
          InternetConnectionStatus.disconnected
          ? NoInternet()
          : Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w,),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: contents.length,
                      onPageChanged: (int index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: EdgeInsets.only(top: 50.h, left: 30.w, right: 30.w),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 50.h, left: 20.w, right: 20.w),
                                child: Image.asset(
                                  contents[i].image,
                                  height: 320.h,
                                ),
                              ),
                              Center(
                                child: Text(
                                  contents[i].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.bold,
                                    color: kblue,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Center(
                                child: Text(
                                  contents[i].description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 60.h),
                              Container(
                                height: 70.h,
                                width: 1.sw,
                                child: TextButton(
                                  onPressed: () {
                                    if (currentIndex == contents.length - 1) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LoginScreen(),
                                        ),
                                      );
                                    }
                                    _controller.nextPage(
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.bounceOut,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    backgroundColor: kblue),
                                  child: Text(
                                      currentIndex == contents.length - 1 ? "Lets Begin!" : "Next",
                                    style: TextStyle(fontFamily: 'Roboto', fontSize: 20.sp),),

                                ),
                              ),
                              SizedBox(height: 30.h),
                              Container(
                                margin: EdgeInsets.only(bottom: 30.r),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    for (int i = 0; i < contents.length; i++)
                                      if (i == currentIndex) ...[circleBar(true)] else
                                        circleBar(false),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.h,
      width: currentIndex == index ? 25.w : 10.w,
      margin: EdgeInsets.only(right: 5.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: kblue,
      ),
    );
  }

  Widget circleBar(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.r),
      height: isActive ? 15.h : 12.h,
      width: isActive ? 15.w : 12.w,
      decoration: BoxDecoration(
          color: isActive ? korange : kblue,
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }
}