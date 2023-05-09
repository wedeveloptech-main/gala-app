import 'dart:developer';
import 'dart:io';
// 
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:list_positioned_scroll_button/list_positioned_scroll_button.dart';
import 'package:myapp/Models/AllMenuList.dart';
import 'package:myapp/Models/NewAddListModel.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/SearchPage.dart';
import 'package:myapp/screens/HomeScreen/components/MenuList.dart';
import 'package:myapp/screens/ScrollPage.dart';
import 'package:myapp/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;


class Demo1 extends StatefulWidget {
  const Demo1({Key? key,}) : super(key: key);

  @override
  State<Demo1> createState() => _Demo1State();
}

class _Demo1State extends State<Demo1> {
  late Future<NewAddList> futureNewAddListModel;
  List<String> imagesList = [];
  //late int _currentIndex;
  late final String imagePath;
  bool isPageViewVisible = false;

  late List<double> itemHeights;
  late List<Color> itemColors;
  bool reversed = false;
  late PageController _pageController;
  int _activeImageIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    futureNewAddListModel = fetchNewAddListModel();
    _pageController =
        PageController(initialPage: 0, keepPage: true, viewportFraction: 1);
    _pageController.addListener(() {
      setState(() {
        _activeImageIndex = _pageController.page!.toInt();
      });
    });
    //_currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Provider.of<InternetConnectionStatus>(context) ==
          InternetConnectionStatus.disconnected
          ? Container(
        color: kwhite,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 1.sh / 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/NoRecordsFound.png',
                height: 150.h,
              ),
              Center(
                child: Text(
                  'No Results Found!',
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
      )
          : Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Stack(
                  children: [
                    FutureBuilder<NewAddList>(
                      future: futureNewAddListModel,
                      builder: (context, snapshot) {

                        if (snapshot.hasData) {
                          snapshot.data!.data.forEach((e) {
                            imagesList.add(e.thumb);
                            print(imagesList.length);
                          });
                          return
                            GridView.builder(
                              itemCount: snapshot.data!.data.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 3.w,
                                childAspectRatio: 1.09,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentIndex = index; // Update the current index to the tapped index
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (
                                            BuildContext context) {
                                          return PageView.builder(
                                            // Set the controller to a new PageController with initialPage set to the current index
                                            controller: PageController(initialPage: _currentIndex),
                                            itemCount: snapshot.data!.data.length,
                                            scrollDirection: Axis.horizontal,
                                            reverse: false,
                                            // Set onPageChanged to update the current index
                                            onPageChanged: (page) {
                                              setState(() {
                                                _currentIndex = page;
                                              });
                                            },
                                            itemBuilder: (BuildContext context, int index) {
                                              return Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: Colors.white,
                                                    ),
                                                    height: 300.h,
                                                    width: 1.sw,
                                                    child: Image.network(
                                                      snapshot.data!.data[index].thumb,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );


                                        });
                                  },
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Container(
                                          height: 150.h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.r),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    snapshot.data!.data[index].thumb.toString()
                                                ),
                                                fit: BoxFit.cover
                                            ),
                                          ),
                                        ),
                                        Container(
                                            padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                                            child: Align(alignment: Alignment.center,child: Text(snapshot.data!.data[index].prodName,
                                              style: TextStyle(color: kblue, fontSize: 15.sp, fontWeight: FontWeight.w400),),)
                                        )
                                      ]),
                                );
                              },
                            );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        // By default, show a loading spinner.
                        return const Center(
                          child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _setPageViewVisible(bool visible) {
    setState(() => isPageViewVisible = visible);
  }

  Future showSheet() => showSlidingBottomSheet(
      context,
      builder: (context) => SlidingSheetDialog(
        cornerRadius: 16.r,
        snapSpec: SnapSpec(
          initialSnap: 0.2,
          snappings: [0.4, 0.7],
        ),
        headerBuilder: buildHeader,
        builder: buildSheet,
      )
  );

  Widget buildSheet(context, state)=> Material(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 5.h,),
        TextButton(
          /*onPressed: (){
            showSlidingBottomSheet(
                context,
                builder: (context) => SlidingSheetDialog(
                  cornerRadius: 16.r,
                  snapSpec: SnapSpec(
                    initialSnap: 0.1,
                    snappings: [0.4, 0.7],
                  ),
                  headerBuilder: buildHeader,
                  builder: buildSheet1,
                )
            );
          },*/
          onPressed: (){
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:  BorderRadius.only(
                      topLeft: Radius.circular(25.r),
                      topRight: Radius.circular(25.r),
                    ),
                  ),
                  child: Center(
                    /*child: MenuListPage(
                      prod: snapshot.data!.data[index].prodId.toString(),
                    ),*/
                  ),
                );
              },
            );
          },
          child: Row(
            children: [
              SizedBox(width: 10.w,),
              Image.asset("assets/images/AddToMenu.png", height: 20.h, width: 20.w,),
              SizedBox(width: 15.w,),
              Text('Add to Menu', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Divider(height: 5.h, color: Colors.black45,),
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              SizedBox(width: 10.w,),
              Image.asset("assets/images/Share.png", height: 20.h, width: 20.w,),
              SizedBox(width: 15.w,),
              Text('Share', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        SizedBox(height: 20.h,),
      ],
    ),
  );

  Widget buildHeader(context, state)=> Material(
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
      ],
    ),
  );

  Widget buildSheet1(context, state)=> Material(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 5.h,),
          InkWell(
            onTap: (){},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset("assets/images/AddToMenu.png", height: 20.h, width: 20.w,),
                SizedBox(width: 10.w,),
                Text('New Menu', style: TextStyle(color: kblue,fontSize: 18.sp),)
              ],
            ),
          ),
          SizedBox(height: 5.h,),
          Divider(color: kblack),
        ],
      ),
    ),
  );
}

