import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/CatMenu.dart';
import 'package:myapp/Models/QuickMenu.dart';
import 'package:myapp/Models/catModel.dart';
import 'package:myapp/Models/newAddModel.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/AllNewList.dart';
import 'package:myapp/screens/AllNewMenu.dart';
import 'package:myapp/screens/AllRecommend.dart';
import 'package:myapp/screens/CatMenuList.dart';
import 'package:myapp/screens/CatMenuList2.dart';
import 'package:myapp/screens/HomeScreen/components/widgets/header_with_search_box.dart';
import 'package:myapp/screens/HomeScreen/components/widgets/image_widget.dart';
import 'package:myapp/screens/onBoard/onboarding.dart';
import 'package:myapp/services/api_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../../../Models/AddMenuData.dart';
import '../../../Models/CreateData.dart';
import '../../../Models/CreateMenu.dart';
import '../../../Models/HomeMenu.dart';
import '../../../Models/SelectedCreateMenu.dart';
import '../../../constants/NoInternet.dart';
import '../../MaintananceMode.dart';
import 'package:http/http.dart' as http;

import 'MenuList2.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<QuickMenu> futureQuickMenu;
  late Future<NewAdd> futureNewAddModel;
  late Future<NewAdd> futureRecom;
  late Future<CatMenu> futureCatMenuModel;
  late Future<HomeMenu> futureHomeMenu;
  late HomeMenu homeMenu;
  List<String> imagesList = [];
  //late int _currentIndex;
  late final String imagePath;
  bool isPageViewVisible = false;
  late Future<CreateMenu> futureCreateMenu;
  Future<CreateData>? futureCreateData;
  Future<AddMenuData>? futureAddMenuData;

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

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  final TextEditingController _controller = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> _getData() async {
    final configResponse = await http
        .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

    if (configResponse.statusCode == 200) {
      final configJson = jsonDecode(configResponse.body);
      final base_url = configJson['data']['apidomain'];
    var response = await http.get(Uri.parse('$base_url/gethomeblocks-ax.php'));
    var decodedResponse = json.decode(response.body);
    homeMenu = HomeMenu.fromJson(decodedResponse);
    setState(() {});
    } else {
      throw Exception('Failed to load config');
    }
  }

  @override
  void initState() {
    super.initState();
    futureQuickMenu = fetchQuickMenuModel();
    futureNewAddModel = fetchNewAddModel();
    futureRecom = fetchRecom();
    futureHomeMenu = fetchHomeMenu();
    futureCatMenuModel = fetchCatMenuModel(String);
    futureCreateMenu = fetchCreateMenu();
    futureAddMenuData = fetchAddMenuData(_controller.text, String);
    futureCreateData = fetchCreateData(_controller.text);
    _checkMaintenanceMode();
    _getData();
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
    return  SafeArea(
        child: _isMaintenanceMode
            ? MaintananceMode()
            :
        Provider.of<InternetConnectionStatus>(context) ==
        InternetConnectionStatus.disconnected
        ? NoInternet()
        : Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.wait([
            fetchQuickMenuModel(),
            fetchNewAddModel(),
            fetchRecom(),
            fetchHomeMenu(),
          ]);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HeaderWithSearchBox(),
              Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 100.h,
                        child: RefreshIndicator(
                          child: FutureBuilder<QuickMenu>(
                            future: futureQuickMenu,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return
                                  ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data!.data.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        child: InkWell(
                                          onTap: () =>
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CatMenuList2(
                                                      //category: AllCatList.fromJson(data!.data[index].ctgId),
                                                      category: snapshot.data!.data[index].ctgId.toString(),
                                                      title: snapshot.data!.data[index].label,
                                                      //image: snapshot.data!.data[index].iconurl.toString(),
                                                    ),
                                                  )),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: 10.w),
                                                child: CircleAvatar(
                                                  radius: 40.r,
                                                  backgroundColor: Colors.transparent,
                                                  backgroundImage: NetworkImage(snapshot.data!.data[index].iconurl.toString(),),
                                                ),
                                              ),
                                              Text(snapshot.data!.data[index].label, style: TextStyle(color: kblue, fontSize: 15.sp, fontWeight: FontWeight.w400),)
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    /*children: [
                                          Container(
                                            child: InkWell(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CategoryList(
                                                      category: CategoryModel.cat[2],
                                                    ),
                                                  )),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 35.r,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: AssetImage('assets/images/FoodMenu1.png'),
                                                  ),
                                                  Text("Bitings", style: TextStyle(color: kblue, fontSize: 15.sp),)
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15.w,
                                          ),
                                          Container(
                                            child: InkWell(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CategoryList(
                                                      category: CategoryModel.cat[3],
                                                    ),
                                                  )),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 35.r,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: AssetImage('assets/images/FoodMenu2.png'),
                                                  ),
                                                  Text("Juices", style: TextStyle(color: kblue, fontSize: 15.sp),)
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15.w,
                                          ),
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CircleAvatar(
                                                  radius: 35.r,
                                                  backgroundColor: Colors.transparent,
                                                  backgroundImage: AssetImage('assets/images/FoodMenu3.png'),
                                                ),
                                                Text("Fast Food", style: TextStyle(color: kblue, fontSize: 15.sp),)
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15.w,
                                          ),
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CircleAvatar(
                                                  radius: 35.r,
                                                  backgroundColor: Colors.transparent,
                                                  backgroundImage: AssetImage('assets/images/FoodMenu4.png'),
                                                ),
                                                Text("Desserts", style: TextStyle(color: kblue, fontSize: 15.sp),)
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15.w,
                                          ),
                                          Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CircleAvatar(
                                                  radius: 35.r,
                                                  backgroundColor: Colors.transparent,
                                                  backgroundImage: AssetImage('assets/images/FoodMenu5.png'),
                                                ),
                                                Text("Mexican", style: TextStyle(color: kblue, fontSize: 15.sp),)
                                              ],
                                            ),
                                          ),
                                        ],*/
                                  );
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Data Not Found'));
                              }

                              // By default, show a loading spinner.
                              return Center(
                                child: SizedBox(
                                  height: 24.0,
                                  width: 24.0,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                            onRefresh: () {
                              setState(() {});
                              return fetchQuickMenuModel();
                            }
                        ),
                      ),
                      SizedBox(height: 30.h,),
                      Container(
                        height: 210.h,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'New Additions..',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: kblue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, color: kblue, size: 20.r,),
                                  ],
                                ),
                              ),
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllNewMenu(),
                                    )
                                );
                              },
                            ),
                            Container(
                              width: double.infinity,
                              height: 166.h,
                              child: RefreshIndicator(
                                onRefresh: () {
                                  setState(() {});
                                  return fetchNewAddModel();
                                },
                                child: FutureBuilder<NewAdd>(
                                  future: futureNewAddModel,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return
                                        ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            //itemCount: snapshot.data!.data.length,
                                            itemCount: 10,
                                            itemBuilder: (context, index) {
                                              final prod = snapshot.data!.data[index].prodId;
                                              return Container(
                                                margin: EdgeInsets.only(right: 16.r, top: 8.r, bottom: 8.r),
                                                child: InkWell(
                                                  /*onTap: () => {
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
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  },*/
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
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10.r),
                                                          image: DecorationImage(
                                                            image: NetworkImage(snapshot.data!.data[index].thumb.toString(),),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        height: 150.h,
                                                        width: 200.w,
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
                                                                                      /*child: Center(
                                                                                        child: MenuList2(
                                                                                          prod: snapshot.data!.data[index].prodId.toString(),
                                                                                        ),
                                                                                      ),*/
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
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Data Not Found'));
                                    }

                                    // By default, show a loading spinner.
                                    return Center(
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
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h,),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            InkWell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Our Recommendations',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: kblue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, color: kblue, size: 20.r,),
                                  ],
                                ),
                              ),
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllRecommend(),
                                    )
                                );
                              },
                            ),
                            SizedBox(height: 7.h,),
                            RefreshIndicator(
                              onRefresh: () {
                                setState(() {});
                                return fetchRecom();
                              },
                              child: FutureBuilder<NewAdd>(
                                future: futureRecom,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    // Get the screen width and height
                                    final screenWidth = MediaQuery.of(context).size.width;
                                    final screenHeight = MediaQuery.of(context).size.height;
                                    final spacing = screenWidth * 0.02;
                                    final spacing1 = screenHeight * 0.01;
                                    final childAspectRatio = screenWidth / 390.h;
                                    return
                                      GridView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        //itemCount: image.length,
                                        itemCount: 6,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2, // Number of columns
                                          crossAxisSpacing: spacing, // Horizontal spacing
                                          mainAxisSpacing: spacing1, // Vertical spacing
                                          childAspectRatio: childAspectRatio.toDouble(),
                                        ),
                                        itemBuilder: (BuildContext context, int index){
                                          final prod = snapshot.data!.data[index].prodId;
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
                                                        itemCount: 6,
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
                                                                            onPressed: () async {
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
                                    return Center(child: Text('Data Not Found'));
                                  }

                                  // By default, show a loading spinner.
                                  return Center(
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
                      SizedBox(height: 20.h,),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            RefreshIndicator(
                              onRefresh: () {
                                setState(() {});
                                return fetchHomeMenu();
                              },
                              child: FutureBuilder<HomeMenu>(
                                future: futureHomeMenu,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: SizedBox(
                                        height: 24.0,
                                        width: 24.0,
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Data Not Found'));
                                  }

                                  HomeMenu homeMenu = snapshot.requireData;

                                  return Container(
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        for (var entry in homeMenu.data.toJson().entries)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              InkWell(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        entry.key,
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          color: kblue,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Icon(Icons.arrow_forward_ios, color: kblue, size: 20.r,),
                                                    ],
                                                  ),
                                                ),
                                                onTap: (){
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CatMenuList2(
                                                                  title: entry.key,
                                                                  category: entry.value[0]['ctg_id'].toString()
                                                              )));
                                                },
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 180.h,
                                                child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    //itemCount: snapshot.data!.data.length,
                                                    itemCount: entry.value.length,
                                                    itemBuilder: (context, index) {
                                                      final prod = entry.value[index]['prodId'];
                                                      var item = entry.value[index];
                                                      return Container(
                                                        margin: EdgeInsets.only(right: 16.w, top: 4.h, bottom: 8.w),
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              _currentIndex = index;
                                                            });
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: PageView.builder(
                                                                    controller: PageController(initialPage: _currentIndex),
                                                                    itemCount: entry.value.length,
                                                                    scrollDirection: Axis.horizontal,
                                                                    reverse: false,
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
                                                                                    entry.value[index]['thumb'].toString(),
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 10.h),
                                                                                Container(
                                                                                  color: Colors.transparent,
                                                                                  child: Text(
                                                                                    entry.value[index]['prod_name'],
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
                                                              },
                                                            );
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.r),
                                                                  image: DecorationImage(
                                                                    image: NetworkImage(item['thumb'].toString()),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                                height: 150.h,
                                                                width: 200.w,
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
                                                                                                  prod: item['prod_id'].toString(),
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
                                                                                        final urlImage = item['thumb'].toString();
                                                                                        final url = Uri.parse(urlImage);
                                                                                        final response = await http.get(url);
                                                                                        final bytes = response.bodyBytes;

                                                                                        final temp = await getTemporaryDirectory();
                                                                                        final path = '${temp.path}/image.jpg';
                                                                                        File(path).writeAsBytesSync(bytes);

                                                                                        await Share.shareFiles([path], text: item['prod_name']);
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
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

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