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
import 'package:myapp/screens/MenuDetailPage.dart';
import 'package:myapp/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

import '../constants/NoInternet.dart';
import 'HomeScreen/components/MenuList2.dart';
import 'MaintananceMode.dart';

class CatMenuList extends StatefulWidget {
  final String category;
  final String title;
  final String image;

  const CatMenuList({Key? key, required this.category, required this.title, required this.image}) : super(key: key);

  @override
  State<CatMenuList> createState() => _CatMenuListState();
}

class _CatMenuListState extends State<CatMenuList> with TickerProviderStateMixin {

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
        //backgroundColor: kblue,
        /*body: Column(
          children: [
            /*Container(
              height: 300,
              padding: EdgeInsets.only(
                  top: 60.h, left: 30.w, right: 30.w, bottom: 10.h),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.image),
                  fit: BoxFit.cover,
                )
              ),
              child: ClipRRect( // make sure we apply clip it properly
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          /*Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new_outlined,color: kwhite,),
                        SizedBox(width: 10.w,),
                        Text('Back', style: TextStyle(color: kwhite,fontSize: 20.sp),)
                      ],
                    ),*/
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(onPressed: (){
                                Navigator.of(context).pop();
                              }
                                  , icon: Icon(Icons.arrow_back_ios_new_outlined,color: kwhite, size: 30.r,)),
                              Icon(Icons.search,color: kwhite, size: 30.r,)
                            ],
                          ),
                          Text(widget.title, style: TextStyle(color: kwhite,fontSize: 30.sp),),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),*/
            Stack(
              children: <Widget>[
                Image.network(widget.image,
                  fit: BoxFit.cover,
                  width: 1.sw,
                  height: 200.h,
                  color: Colors.white.withOpacity(0.6),
                  colorBlendMode: BlendMode.modulate,
                ),
                /*ClipRRect( // Clip it cleanly.
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      //color: Colors.black.withOpacity(0.2),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 250.h),
                        child: Center(
                          child: Text(widget.title,
                            style: TextStyle(color: kwhite, fontSize: 40.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),*/
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurImage,
                      sigmaY: blurImage,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 100.h),
                        child: Center(
                          child: Text(widget.title,
                            style: TextStyle(color: kwhite, fontSize: 40.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10.w,
                  top: 70.h,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new_outlined, color: kwhite,),
                        SizedBox(width: 10.w,),
                        Text('Back',
                          style: TextStyle(color: kwhite, fontSize: 20.sp),)
                      ],
                    ),
                  ),
                ),
                Positioned(
                    right: 10.w,
                    top: 70.h,
                    child: Icon(Icons.search, color: kwhite, size: 30.r,)
                ),
                /*Padding(
                  padding: EdgeInsets.only(top: 250.h),
                  child: Center(
                    child: Text(widget.title,
                      style: TextStyle(color: kblack, fontSize: 40.sp),
                    ),
                  ),
                ),*/
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 10.w, right: 5.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: FutureBuilder<CatMenu>(
                  future: futureCatMenuModel,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return
                        GridView.builder(
                          //itemCount: image.length,
                          itemCount: snapshot.data!.data.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.w,
                              mainAxisSpacing: 10.h,
                            childAspectRatio: 1.02,
                          ),
                          itemBuilder: (BuildContext context, int index){
                            //final DocumentSnapshot documentSnapshot = snapshot.data!.data[index];
                            return GestureDetector(
                              onTap: (){
                                showModalBottomSheet(
                                  backgroundColor: Colors.white,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      height: 200.h,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(height: 5.h,),
                                          TextButton(
                                            onPressed: (){
                                              showDialog(
                                                  context: context,
                                                  builder: (
                                                      BuildContext context) {
                                                    return Center(
                                                      child: Material(
                                                        type: MaterialType.transparency,
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.white,
                                                            ),
                                                            //padding: EdgeInsets.all(15),
                                                            height: 300.h,
                                                            width: MediaQuery.of(context).size.width * 0.9.w,
                                                            /*child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return ClipRRect(
                                                      borderRadius: BorderRadius.circular(5.r),
                                                      child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                    );
                                                  },
                                                ),*/
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(5.r),
                                                              child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                            )
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.open_in_new, size: 30.r, color: kblack,),
                                                SizedBox(width: 10.w,),
                                                Text('Open', style: TextStyle(fontSize: 20.sp, color: kblack),),
                                              ],
                                            ),
                                          ),
                                          Divider(height: 5.h, color: Colors.black45,),
                                          TextButton(
                                            onPressed: (){
                                              showDialog(
                                                  context: context,
                                                  builder: (
                                                      BuildContext context) {
                                                    return Center(
                                                      child: Material(
                                                        type: MaterialType.transparency,
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.white,
                                                            ),
                                                            //padding: EdgeInsets.all(15),
                                                            height: 300.h,
                                                            width: MediaQuery.of(context).size.width * 0.9.w,
                                                            /*child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return ClipRRect(
                                                      borderRadius: BorderRadius.circular(5.r),
                                                      child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                    );
                                                  },
                                                ),*/
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(5.r),
                                                              child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                            )
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.share, size: 30.r, color: kblack,),
                                                SizedBox(width: 10.w,),
                                                Text('Share', style: TextStyle(fontSize: 20.sp, color: kblack),),
                                              ],
                                            ),
                                          ),
                                          Divider(height: 5.h, color: Colors.black45,),
                                          TextButton(
                                            onPressed: (){
                                              showDialog(
                                                  context: context,
                                                  builder: (
                                                      BuildContext context) {
                                                    return Center(
                                                      child: Material(
                                                        type: MaterialType.transparency,
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.white,
                                                            ),
                                                            //padding: EdgeInsets.all(15),
                                                            height: 300.h,
                                                            width: MediaQuery.of(context).size.width * 0.9.w,
                                                            /*child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return ClipRRect(
                                                      borderRadius: BorderRadius.circular(5.r),
                                                      child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                    );
                                                  },
                                                ),*/
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(5.r),
                                                              child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                            )
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.favorite_border, size: 30.r, color: kblack,),
                                                SizedBox(width: 10.w,),
                                                Text('Add To Menu', style: TextStyle(fontSize: 20.sp, color: kblack),),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    );
                                  },
                                );
                              },
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Container(
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.r),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10.r),
                                            /*child: Image.asset(image[index], fit: BoxFit.cover,),*/
                                            child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                          ),
                                        )),
                                    Container(
                                        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 2.w),
                                        /*child: Center(child: Text(snapshot.data!.data[index].employeeName, style: TextStyle(color: kblue, fontSize: 18.sp, fontWeight: FontWeight.w400),)),*/
                                        child: Align(child: Text(snapshot.data!.data[index].prodName,
                                          style: TextStyle(color: kblue, fontSize: 18.sp, fontWeight: FontWeight.w400),),
                                        alignment: Alignment.center,)
                                    )
                                  ]),
                            );
                              /*FocusedMenuHolder(
                              onPressed: (){},
                              menuWidth: MediaQuery.of(context).size.width*0.55,
                              blurSize: 5.0,
                              menuItemExtent: 45,
                              menuBoxDecoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.all(Radius.circular(15.0))),
                              duration: Duration(milliseconds: 100),
                              animateMenuItems: true,
                              blurBackgroundColor: Colors.black54,
                              bottomOffsetHeight: 100,
                              openWithTap: true,
                              menuItems: <FocusedMenuItem>[
                                FocusedMenuItem(title: Text("Open"),trailingIcon: Icon(Icons.open_in_new) ,onPressed: (){
                                  showDialog(
                                      context: context,
                                      builder: (
                                          BuildContext context) {
                                        return Center(
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: Colors.white,
                                                ),
                                                //padding: EdgeInsets.all(15),
                                                height: 300.h,
                                                width: MediaQuery.of(context).size.width * 0.9.w,
                                                /*child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return ClipRRect(
                                                      borderRadius: BorderRadius.circular(5.r),
                                                      child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                    );
                                                  },
                                                ),*/
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(5.r),
                                                  child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                )
                                            ),
                                          ),
                                        );
                                      });
                                }),
                                FocusedMenuItem(title: Text("Share"),trailingIcon: Icon(Icons.share) ,onPressed: (){}),
                                FocusedMenuItem(title: Text("Favorite"),trailingIcon: Icon(Icons.favorite_border) ,onPressed: (){}),
                                //FocusedMenuItem(title: Text("Delete",style: TextStyle(color: Colors.redAccent),),trailingIcon: Icon(Icons.delete,color: Colors.redAccent,) ,onPressed: (){}),
                              ],
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Container(
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.r),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10.r),
                                            /*child: Image.asset(image[index], fit: BoxFit.cover,),*/
                                            child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                          ),
                                        )),
                                    Container(
                                        padding: EdgeInsets.all(5.r),
                                        /*child: Center(child: Text(snapshot.data!.data[index].employeeName, style: TextStyle(color: kblue, fontSize: 18.sp, fontWeight: FontWeight.w400),)),*/
                                        child: Text(snapshot.data!.data[index].prodName, style: TextStyle(color: kblue, fontSize: 18.sp, fontWeight: FontWeight.w400),)
                                    )
                                  ]),
                            );*/

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
              ),
            ),
            /*Container(
              width: 1.sw,
              height: 300.h,
              child: FutureBuilder<AllCatList>(
                future: futureAllCatModel,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: 1.sw,
                          height: 300.h,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data!.data[index].thumb.toString()),
                                fit: BoxFit.cover,
                                //width: 1.sw,
                                //height: 300.h,
                                //color: Colors.white.withOpacity(0.4),
                                //colorBlendMode: BlendMode.modulate,
                              )
                          ),
                          /*child: Stack(
                            children: <Widget>[
                              Image.network(snapshot.data!.data[index].thumb.toString(),
                                fit: BoxFit.cover,
                                //width: 1.sw,
                                //height: 300.h,
                                color: Colors.white.withOpacity(0.4),
                                colorBlendMode: BlendMode.modulate,),
                              Positioned(
                                left: 10.w,
                                top: 70.h,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_back_ios_new_outlined,
                                        color: kwhite,),
                                      SizedBox(width: 10.w,),
                                      Text('Back',
                                        style: TextStyle(color: kwhite, fontSize: 20.sp),)
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: 10.w,
                                  top: 70.h,
                                  child: Icon(Icons.search, color: kwhite, size: 30.r,)
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 200.h),
                                child: Center(
                                  child: Text( //widget.category.title,
                                    snapshot.data!.data[index].ctgName,
                                    style: TextStyle(color: kwhite, fontSize: 40.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),*/
                        );
                        //return _getListItemTile(context, index);
                      },
                    );
                  }
                  else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return const Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),*/
          ],
        ),*/
        body: NestedScrollView(
          headerSliverBuilder:
              (BuildContext context, bool innnerBoxIsScrolled) {
            if (innnerBoxIsScrolled) {
              /* Animation */
              controller1 = AnimationController(
                vsync: this,
                duration: Duration(
                  milliseconds: 500,
                ),
              );
              animation1 = Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(controller1);
              /* Animation */
              controller1.forward();
            }
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: kblue,
                automaticallyImplyLeading: false,
                titleSpacing: 0.0,
                toolbarHeight:
                (innnerBoxIsScrolled != null && innnerBoxIsScrolled == true)
                    ? 60.0
                    : 200.0,
                centerTitle: true,
                elevation: 0.0,
                leadingWidth: 0.0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (innnerBoxIsScrolled != null &&
                        innnerBoxIsScrolled == true)
                      FadeTransition(
                        opacity: animation1,
                        child: Padding(
                          padding: EdgeInsets.only(right: 7.w, ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 7.w, right: 15.w, top: 15.h, bottom: 15.h),
                                      child: Row(
                                        children: [
                                          Icon(Icons.arrow_back_ios_new_outlined, color: kwhite, size: 18.r,),
                                      ],
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                        color: kwhite,
                                        fontSize: 20.sp,
                                    ),
                                  ),
                                  Spacer(),
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
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.image),
                          fit: BoxFit.cover,
                          //width: 1.sw,
                          //height: 300.h,
                          //color: Colors.white.withOpacity(0.4),
                          //colorBlendMode: BlendMode.modulate,
                        ),),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      color: Colors.black54.withOpacity(.3),
                      //filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                      child: Padding(
                        padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 10.h, bottom: 80.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
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
                            Center(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  color: kwhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Builder(
            builder: (BuildContext context) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
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
                                //itemCount: image.length,
                                itemCount: snapshot.data!.data.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of columns
                                  crossAxisSpacing: spacing, // Horizontal spacing
                                  mainAxisSpacing: spacing, // Vertical spacing
                                  childAspectRatio: childAspectRatio.toDouble(),
                                ),
                                itemBuilder: (BuildContext context, int index){
                                  //final DocumentSnapshot documentSnapshot = snapshot.data!.data[index];
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
                                          /*Container(
                                            child: Card(
                                              clipBehavior: Clip.antiAlias,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10.r),
                                                /*child: Image.asset(image[index], fit: BoxFit.cover,),*/
                                                child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                              ),
                                            ),
                                        ),*/
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
                                                                      SizedBox(width: 10.w,),
                                                                      Image.asset("assets/images/AddToMenu.png", height: 20.h, width: 20.w,),
                                                                      SizedBox(width: 15.w,),
                                                                      Text('Add to Menu', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Divider(height: 5.h, color: Colors.black45,),
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
                                              padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                                              child: Align(alignment: Alignment.center,child: Text(snapshot.data!.data[index].prodName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: kblue, fontSize: 15.sp, fontWeight: FontWeight.bold),),)
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
                ],
              );
            },
          ),
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

  /*Widget buildSheet(context, state)=> Material(
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
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                    ),
                  ),
                  child: Center(
                    child: MenuListPage(),
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
          GestureDetector(
            onTap: (){
              addNewMenuItem(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset("assets/images/AddToMenu.png", height: 20.h, width: 20.w,),
                SizedBox(width: 10.w,),
                Text('New Menu', style: TextStyle(color: kblue,fontSize: 20.sp),)
              ],
            ),
          ),
          SizedBox(height: 5.h,),
          Divider(color: kblack),
          RefreshIndicator(
              child: FutureBuilder<CreateMenu>(
                future: fetchCreateMenu(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index){
                          return Text(snapshot.data!.data[index].name);
                        });
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return const Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
              onRefresh: () {
                setState(() {});
                return fetchCreateMenu();
              },
          )
        ],
      ),
    ),
  );*/

  void addNewMenuItem(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("New Menu", style: TextStyle(fontSize: 20.sp),),
            content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, //the dialog takes only size it needs
                  children: [
                    TextFormField(
                      controller: _controller,
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
                        labelText: 'Enter New Menu',
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
                    /*TextFormField(
                                                              controller: _contactController, //will help get the field value on submit
                                                              decoration: const InputDecoration(
                                                                //border: OutlineInputBorder(),
                                                                labelText: 'User Name',
                                                              ),
                                                              //validator on submit, must return null when every thing ok
                                                              // The validator receives the text that the user has entered.
                                                              validator: (value){
                                                                if(value == null || value.isEmpty){
                                                                  return 'Value is required!';}
                                                                else if(value.trim().isEmpty){
                                                                  return "Value is required!";
                                                                }
                                                                return null;
                                                              },
                                                            ),*/
                  ],
                )
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: (){
                  //    showToast(context, "Canceled");  //toast a cancelled sms
                  Navigator.of(context).pop(); // dismiss dialog
                },
              ),

              TextButton(
                child: const Text("Create"),
                onPressed: (){
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      futureCreateData = fetchCreateData(_controller.text);
                      futureCreateMenu = fetchCreateMenu();
                    });
                    _controller.clear(); //clear text in field
                    //_countController.clear(); //clear the field
                    Navigator.of(context).pop(); // dismiss dialog


                  }
                },

              ),

            ],
          );
        });
  }

}
