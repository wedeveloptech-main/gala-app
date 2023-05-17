import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/SearchData.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/components/searchTile.dart';
import 'package:myapp/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../Models/AddMenuData.dart';
import '../../Models/CreateData.dart';
import '../../Models/CreateMenu.dart';
import '../../Models/SelectedCreateMenu.dart';
import '../../constants/ListTile1.dart';
import '../MaintananceMode.dart';
import 'package:http/http.dart' as http;

import 'components/MenuList2.dart';

class SearchDataList extends StatefulWidget {

  final nameHolder ;

  const SearchDataList({Key? key, this.nameHolder,}) : super(key: key);

  @override
  State<SearchDataList> createState() => _SearchDataListState();
}

class _SearchDataListState extends State<SearchDataList> {

  late Future<SearchData> futureSearchData;
  late Future<CreateMenu> futureCreateMenu;
  Future<CreateData>? futureCreateData;
  Future<AddMenuData>? futureAddMenuData;
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  final TextEditingController _controller = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    futureSearchData = fetchSearchData(widget.nameHolder);
    futureCreateMenu = fetchCreateMenu();
    futureAddMenuData = fetchAddMenuData(_controller.text, String);
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
          ? Scaffold(
        body: Container(
          color: kwhite,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 1.sh / 4.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/NoInternet.png',
                  height: 150.h,
                ),
                Center(
                  child: Text(
                    'Oops!',
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
        ),
      )
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
                      Text('Search for ' + widget.nameHolder, style: TextStyle(color: kwhite,fontSize: 20.sp),),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 7.w, right: 7.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 20.h),
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
                          return fetchSearchData(widget.nameHolder);
                        },
                        child: FutureBuilder<SearchData>(
                          future: futureSearchData,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
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
                                    mainAxisSpacing: spacing, // Vertical spacing
                                    childAspectRatio: childAspectRatio.toDouble(),
                                  ),
                                  itemBuilder: (BuildContext context, int index){
                                    final prod = snapshot.data!.data[index].prodId;
                                    //final DocumentSnapshot documentSnapshot = snapshot.data!.data[index];
                                    return GestureDetector(
                                      onTap: (){
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
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
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
                            }
                            else if (snapshot.hasError) {
                              return Center(
                                child: SingleChildScrollView(
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
                                            'We couldn\'t find what you searched for.\nTry searching again',
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
                                ),
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
                    ),
                  ],
                )
              ),
            ),
          ],
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
