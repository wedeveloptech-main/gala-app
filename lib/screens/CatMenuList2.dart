import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/AllCatList.dart';
import 'package:myapp/Models/CatMenu.dart';
import 'package:myapp/Models/CreateData.dart';
import 'package:myapp/Models/CreateMenu.dart';
import 'package:myapp/Models/NewAddListModel.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/SearchPage.dart';
import 'package:myapp/screens/HomeScreen/components/MenuList.dart';
import 'package:myapp/screens/HomeScreen/components/MenuList2.dart';
import 'package:myapp/screens/MenuDetailPage.dart';
import 'package:myapp/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

import '../constants/NoInternet.dart';
import 'MaintananceMode.dart';

class CatMenuList2 extends StatefulWidget {
  final String category;
  final String title;

  const CatMenuList2({Key? key, required this.category, required this.title}) : super(key: key);

  @override
  State<CatMenuList2> createState() => _CatMenuList2State();
}

class _CatMenuList2State extends State<CatMenuList2> with TickerProviderStateMixin {

  late Future<CatMenu> futureCatMenuModel;
  final TextEditingController _controller = TextEditingController();
  late Future<CreateMenu> futureCreateMenu;
  Future<CreateData>? futureCreateData;
  int _currentIndex = 0;
  late PageController _pageController;

  final formKey = GlobalKey<FormState>();

  double blurImage = 0;
  double blurBox = 0.8;

  final TextEditingController stateController = TextEditingController();
  final FocusNode stateFocus = FocusNode();

  var animation1;
  var controller1;

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  @override
  void initState() {
    super.initState();
    futureCatMenuModel = fetchCatMenuModel(widget.category);
    futureCreateMenu = fetchCreateMenu();
    futureCreateData = fetchCreateData(_controller.text);
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
                  top: 10.h, right: 10.w, bottom: 10.h),
              child: SizedBox(
                height: 40.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios_new_outlined,
                                  color: kwhite, size: 15.r,),
                                SizedBox(width: 10.w,),
                                Text('Back',
                                  style: TextStyle(color: kwhite, fontSize: 15.sp),),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: kwhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(25.0),
                                      topRight: const Radius.circular(25.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: SearchPage(),
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(Icons.search, color: kwhite, size: 30.r,),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () {
                  setState(() {});
                  return fetchCatMenuModel(widget.category);
                },
                child: FutureBuilder<CatMenu>(
                  future: futureCatMenuModel,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final screenHeight = MediaQuery.of(context).size.height;

                      // Calculate the spacing based on the screen width
                      final spacing = screenWidth * 0.02;
                      final childAspectRatio = screenHeight > 800 ? 1.06 : 1.18;
                      return
                        GridView.builder(
                          itemCount: snapshot.data!.data.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: spacing, // Horizontal spacing
                            mainAxisSpacing: spacing, // Vertical spacing
                            childAspectRatio: childAspectRatio.toDouble(),
                          ),
                          itemBuilder: (BuildContext context, int index){
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _currentIndex = index; // Update the current index to the tapped index
                                });
                                showDialog(
                                    context: context,
                                    builder: (
                                        BuildContext context) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop(); // Dismiss the dialog when tapping outside
                                        },
                                        child: PageView.builder(
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
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                  child: Column(
                                                    children: [
                                                      Container(
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
                                                      SizedBox(height: 10.h),
                                                      Container(
                                                        color: Colors.transparent,
                                                        child: Text(
                                                          snapshot.data!.data[index].prodName,
                                                          style: TextStyle(
                                                            color: kwhite,
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
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
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: (){
                                            showModalBottomSheet(
                                                backgroundColor: Colors.transparent,
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (BuildContext context)  => Container(
                                                  height: 200.h,
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
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: <Widget>[
                                                            SizedBox(height: 5.h,),
                                                            TextButton(
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
                                                                        child: MenuList2(
                                                                          prod: snapshot.data!.data[index].prodId.toString(),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Image.asset("assets/images/AddToMenu.png", height: 20.h, width: 20.w,),
                                                                  SizedBox(width: 15.w,),
                                                                  Text('Add to Menu', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(height: 5.h, color: kwhite2,),
                                                            TextButton(
                                                              onPressed: () async{
                                                                final urlImage = snapshot.data!.data[index].thumb.toString();
                                                                final url = Uri.parse(urlImage);
                                                                final response = await http.get(url);
                                                                final bytes = response.bodyBytes;

                                                                final temp = await getTemporaryDirectory();
                                                                final path = '${temp.path}/image.jpg';
                                                                File(path).writeAsBytesSync(bytes);

                                                                await Share.shareFiles([path], text: snapshot.data!.data[index].prodName);
                                                                //await Share.share([path], subject: snapshot.data!.data[index].prodName);
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Image.asset("assets/images/Share.png", height: 20.h, width: 20.w,),
                                                                  SizedBox(width: 15.w,),
                                                                  Text('Share', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
                                                                ],
                                                              ),
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
                                          child: Container(
                                              height: 34.h,
                                              width: 28.w,
                                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Image.asset("assets/images/MenuIcon1.png", height: 18.h, width: 18.w)
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(5.r),
                                        /*child: Center(child: Text(snapshot.data!.data[index].employeeName, style: TextStyle(color: kblue, fontSize: 18.sp, fontWeight: FontWeight.w400),)),*/
                                        child: Center(child: Text(snapshot.data!.data[index].prodName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: kblue, fontSize: 15.sp, fontWeight: FontWeight.bold),))
                                    )
                                  ]),
                            );

                          },
                        );
                    } else if (snapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //cartHeadWidget("0"),
                          Container(
                            //padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            child: Center(
                              child: Text(
                                "No Data Found!",
                                style: TextStyle(color: Colors.black54, fontSize: 20.sp, fontWeight: FontWeight.bold,
                                ),),
                            ),
                          ),
                        ],
                      );
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
              ),
            ),
            )
          ],
        ),
      ),
    );
  }

  Future showSheet() => showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context)  => Container(
        height: MediaQuery.of(context).size.height * 0.2,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 5.h,),
                TextButton(
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
                          child: const Center(
                            //child: MenuListPage(),
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
          ],
        ),
      )
  );
}