import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:list_positioned_scroll_button/list_positioned_scroll_button.dart';
import 'package:myapp/Models/AllMenuList.dart';
import 'package:myapp/Models/NewAddListModel.dart';
import 'package:myapp/Models/newAddModel.dart';
import 'package:myapp/constants/NoInternet.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/SearchPage.dart';
import 'package:myapp/screens/ScrollPage.dart';
import 'package:myapp/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../Models/AddMenuData.dart';
import '../Models/CreateData.dart';
import '../Models/CreateMenu.dart';
import '../Models/SelectedCreateMenu.dart';
import '../constants/ListTile1.dart';
import 'HomeScreen/components/MenuList2.dart';


class AllRecommend extends StatefulWidget {
  const AllRecommend({Key? key,}) : super(key: key);

  @override
  State<AllRecommend> createState() => _AllRecommendState();
}

class _AllRecommendState extends State<AllRecommend> {
  late Future<NewAddList> futureNewAddListModel;
  late Future<NewAdd> futureRecom;
  List<String> imagesList = [];
  //late int _currentIndex;
  late final String imagePath;
  bool isPageViewVisible = false;

  /// Controller to scroll or jump to a particular item.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();
  late List<double> itemHeights;
  late List<Color> itemColors;
  bool reversed = false;
  late PageController _pageController;
  int _activeImageIndex = 0;
  int _currentIndex = 0;
  late Future<CreateMenu> futureCreateMenu;
  Future<CreateData>? futureCreateData;
  Future<AddMenuData>? futureAddMenuData;

  final TextEditingController _controller = TextEditingController();

  final formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    futureRecom = fetchRecom();
    futureCreateMenu = fetchCreateMenu();
    futureAddMenuData = fetchAddMenuData(_controller.text, String);
    futureCreateData = fetchCreateData(_controller.text);
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
          ? NoInternet()
          : Scaffold(
        backgroundColor: kblue,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: 10.h, left: 10.w, right: 10.w, bottom: 10.h),
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
                  SizedBox(height: 8.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recommended Menu', style: TextStyle(color: kwhite,fontSize: 20.sp),),
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
                                      topLeft: Radius.circular(25.r),
                                      topRight: Radius.circular(25.r)
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
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () {
                        setState(() {});
                        return fetchRecom();
                      },
                      child: FutureBuilder<NewAdd>(
                        future: futureRecom,
                        builder: (context, snapshot) {

                          if (snapshot.hasData) {
                            snapshot.data!.data.forEach((e) {
                              imagesList.add(e.thumb);
                              print(imagesList.length);
                            });
                            final screenWidth = MediaQuery.of(context).size.width;
                            final screenHeight = MediaQuery.of(context).size.height;

                            // Calculate the spacing based on the screen width
                            final spacing = screenWidth * 0.02;
                            final childAspectRatio = screenWidth / 390.h;
                            return
                              GridView.builder(
                                //itemCount: image.length,
                                itemCount: snapshot.data!.data.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of columns
                                  crossAxisSpacing: spacing, // Horizontal spacing
                                  //mainAxisSpacing: spacing, // Vertical spacing
                                  childAspectRatio: childAspectRatio.toDouble(),
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  final prod = snapshot.data!.data[index].prodId;
                                  return GestureDetector(
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
                                                                  fontSize: 18.0,
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
                                    /*onTap: (){
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

                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(5.r),
                                                        child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                                      )
                                                  ),
                                                ),
                                              );
                                            });
                                      },*/
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
                                                                  onPressed: () async {
                                                                    final menuId = await fetchCreateMenu();
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
                                                                          child:
                                                                          Padding(
                                                                            padding: EdgeInsets.all(10.r),
                                                                            child: Container(
                                                                              width: double.infinity,
                                                                              //padding: const EdgeInsets.only(bottom: 44),
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(20.r),
                                                                                  topRight: Radius.circular(20.r),
                                                                                ),
                                                                              ),
                                                                              child: Column(
                                                                                children: [
                                                                                  Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: <Widget>[
                                                                                      SizedBox(height: 6.h,),
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
                                                                                  Expanded(
                                                                                    child: Container(//screen decoration
                                                                                      //alignment: Alignment.center,
                                                                                      width: double.infinity,
                                                                                      //padding: const EdgeInsets.only(bottom: 44),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.only(
                                                                                          topLeft: Radius.circular(20.r),
                                                                                          topRight: Radius.circular(20.r),
                                                                                        ),
                                                                                      ),
                                                                                      //use a listenable builder, it will make sure it builds whenever needed
                                                                                      child: (futureCreateMenu == null)
                                                                                          ? Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          //cartHeadWidget("0"),
                                                                                          Container(
                                                                                            //padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                                                                            child: Center(
                                                                                              child: Text(
                                                                                                "Create New Menu",
                                                                                                style: TextStyle(color: Colors.black54, fontSize: 30.sp, fontWeight: FontWeight.bold,
                                                                                                ),),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                          : RefreshIndicator(
                                                                                        onRefresh: () {
                                                                                          setState(() {});
                                                                                          return fetchCreateMenu();
                                                                                        },
                                                                                        child: FutureBuilder<SelectedCreateMenu>(
                                                                                          future: fetchSelectedCreateMenu(prod),
                                                                                          builder: (context, snapshot) {
                                                                                            if (snapshot.hasData && snapshot.data!.data.isNotEmpty) {
                                                                                              return ListView.builder(
                                                                                                itemCount: snapshot.data!.data.length,
                                                                                                itemBuilder: (context, index) {
                                                                                                  return ListTile1(model: snapshot.data!.data[index], prod:prod);
                                                                                                  /*return CheckboxListTile(
                                                                                                      title: Text(
                                                                                                        snapshot.data!.data[index].name,
                                                                                                        maxLines: 1,
                                                                                                        overflow: TextOverflow.ellipsis,
                                                                                                        style: TextStyle(
                                                                                                          color: kblue,
                                                                                                          fontSize: 20.sp,
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                        ),
                                                                                                      ),
                                                                                                      activeColor: kblue,
                                                                                                      value: snapshot.data!.data[index].isselected == "1",
                                                                                                      onChanged: (bool? value) async {
                                                                                                        //print('Checked');
                                                                                                        if (value != null) {
                                                                                                          setState(() {
                                                                                                            snapshot.data!.data[index].isselected = value ? "1" : "0";
                                                                                                            if (value) {
                                                                                                              print('true');
                                                                                                              futureAddMenuData = fetchAddMenuData(
                                                                                                                  snapshot.data!.data[index].id, prod);
                                                                                                              _selected_box.add(index);
                                                                                                              Fluttertoast.showToast(
                                                                                                                msg: "Item Added to Menu!",
                                                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                                                gravity: ToastGravity.BOTTOM,
                                                                                                                backgroundColor: Colors.black54,
                                                                                                                textColor: Colors.white,
                                                                                                              );
                                                                                                            } else {
                                                                                                              print('false');
                                                                                                              futureAddMenuData = fetchAddMenuData(
                                                                                                                  snapshot.data!.data[index].id, prod);
                                                                                                              _selected_box.remove(index);
                                                                                                              print(index);
                                                                                                              Fluttertoast.showToast(
                                                                                                                msg: "Item Removed from Menu!",
                                                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                                                gravity: ToastGravity.BOTTOM,
                                                                                                                backgroundColor: Colors.black54,
                                                                                                                textColor: Colors.white,
                                                                                                              );
                                                                                                            }
                                                                                                          });
                                                                                                        }
                                                                                                      },
                                                                                                      contentPadding: EdgeInsets.zero,
                                                                                                      controlAffinity: ListTileControlAffinity.leading,
                                                                                                    );*/
                                                                                                },
                                                                                              );
                                                                                            }
                                                                                            else if (snapshot.hasError) {
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

                                                                                            else if (snapshot.hasData && snapshot.data!.data.isEmpty) {
                                                                                              return Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                children: [
                                                                                                  //cartHeadWidget("0"),
                                                                                                  Container(
                                                                                                    //padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                                                                                    child: Center(
                                                                                                      child: Text(
                                                                                                        "Create New Menu",
                                                                                                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold,
                                                                                                        ),),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              );
                                                                                            }

                                                                                            return const Center(
                                                                                              child: SizedBox(
                                                                                                height: 24.0,
                                                                                                width: 24.0,
                                                                                                child: CircularProgressIndicator(),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),


                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          /*child: Center(
                                                                            child: MenuList2(
                                                                              prod: snapshot.data!.data[index].prodId.toString(),
                                                                            ),
                                                                          ),*/
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
                              height: 24.0,
                              width: 24.0,
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
                      //futureSelectedCreateMenu = fetchSelectedCreateMenu(widget.prod);
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

