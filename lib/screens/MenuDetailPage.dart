import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/AddMenuData.dart';
import 'package:myapp/Models/CatMenu.dart';
import 'package:myapp/Models/CreateData.dart';
import 'package:myapp/Models/CreateMenu.dart';
import 'package:myapp/Models/NewAddListModel.dart';
import 'package:myapp/Models/menuList.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/CatMenuList.dart';
import 'package:myapp/screens/CatMenuList2.dart';
import 'package:myapp/screens/HomeScreen/components/CategoryPage.dart';
import 'package:myapp/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../constants/NoInternet.dart';
import 'HomeScreen/components/CategoryPage2.dart';
import 'MaintananceMode.dart';

class MenuDetailPage extends StatefulWidget {
  final String name;
  final String product;

  const MenuDetailPage({Key? key, required this.name, required this.product,}) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  late Future<MenuListData> futureOpenMenuList;
  late Future<MenuListData> futureDeleteMenu;
  late Future<AddMenuData> futureRemoveMenuData;

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  Future<String> createDynamicLink() async {

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galacaterers.page.link',
      link: Uri.parse('https://galacaterers.page.link/menudetails?name=TMenu&product=48'),
      androidParameters: AndroidParameters(
        packageName: "com.galacaterers.app_data",
        minimumVersion: 0,
        fallbackUrl: Uri.parse('https://galacaterers.page.link/menudetails?name=TMenu&product=48'),
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Gala Caterers',
        description: 'Your App Description',
        //imageUrl: Uri.parse('https://your-app-url.com/your-image.jpg'),
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    final Uri shortUrl = shortLink.shortUrl;

    print(shortUrl);

    return shortUrl.toString();
  }

  /*final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://galacaterer.page.link',
    link: Uri.parse('https://galacaterer.page.link/menudetails?name=sangeet&product=60'),
    androidParameters: AndroidParameters(
      packageName: 'com.galacaterers.app_data',
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: 'Your App Title',
      description: 'Your App Description',
      //imageUrl: Uri.parse('https://your-app-url.com/your-image.jpg'),
    ),
  );*/
  /*Future<void> generateDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galacaterer.page.link',
      link: Uri.parse('https://galacaterer.page.link/menudetails?name=${Uri.encodeComponent(widget.name)}&product=${Uri.encodeComponent(widget.product)}'),
      androidParameters: AndroidParameters(
        packageName: 'com.galacaterers.app_data',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Your App Title',
        description: 'Your App Description',
        //imageUrl: Uri.parse('https://your-app-url.com/your-image.jpg'),
      ),
    );
    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    final Uri shortUrl = shortLink.shortUrl;
    print(shortUrl);// The shortened dynamic link URL

    //final Uri dynamicUrl = await parameters.buildUrl();
    // Use the dynamicUrl as needed
  }*/

  @override
  void initState() {
    super.initState();
    futureOpenMenuList = fetchOpenMenuList(widget.product);
    //futureDeleteMenu = fetchDeleteMenu(widget.product);
    futureRemoveMenuData = fetchRemoveMenuData(widget.product, String);

    /*FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      if (dynamicLinkData != null) {
        // Extract the deep link URL from the PendingDynamicLinkData
        Uri deepLink = dynamicLinkData.link;

        print(deepLink);
        // Extract the query parameters from the deep link URL
        //String? name = deepLink.queryParameters['name'];
        String? name = 'TMenu';
        //String? cid = deepLink.queryParameters['category'];
        //String? product = deepLink.queryParameters['product'];
        String? product = '48';

        // Provide default values for the query parameters if they are null
        name ??= 'Default Name';
        product ??= 'Default Product';

        // Navigate to the MenuDetailPage with the extracted parameters
        Navigator.push(context, MaterialPageRoute(builder: (context) => MenuDetailPage(name: 'TMenu', product: '48')));

      }
    }).onError((error) {
      if (kDebugMode) {
        print('error.message');
      }
    });*/
    //initDynamicLinks(context);
    //this.initDynamicLinks(context);

    //FirebaseDynamicLinks.instance.onLink;

    // Listen for dynamic links after the app has been launched
    // Listen for dynamic links
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      if (dynamicLinkData != null) {
        // Extract the deep link URL from the DynamicLinkData
        Uri deepLink = dynamicLinkData.link;
        print(deepLink);

        // Extract the query parameters from the deep link URL
        String? name = deepLink.queryParameters['name'];
        String? product = deepLink.queryParameters['product'];

        // Provide default values for the query parameters if they are null
        name ??= 'Default Name';
        product ??= 'Default Product';

        // Navigate to the MenuDetailPage with the extracted parameters
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailPage(
              name: name!,
              product: product!,
            ),
          ),
        );
      }
    }, onError: (error) {
      // Handle any errors
    });

    // Get the initial dynamic link (if any)
    FirebaseDynamicLinks.instance.getInitialLink().then((dynamicLinkData) {
      if (dynamicLinkData != null) {
        // Extract the deep link URL from the DynamicLinkData
        Uri deepLink = dynamicLinkData.link;
        print(deepLink);

        // Extract the query parameters from the deep link URL
        String? name = deepLink.queryParameters['name'];
        String? product = deepLink.queryParameters['product'];

        // Provide default values for the query parameters if they are null
        name ??= 'Default Name';
        product ??= 'Default Product';

        // Navigate to the MenuDetailPage with the extracted parameters
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailPage(
              name: name!,
              product: product!,
            ),
          ),
        );
      }
    }, onError: (error) {
      // Handle any errors
    });
    _checkMaintenanceMode();
  }

  /*void initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            Navigator.pushNamed(context, deepLink.path);
          }
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }*/

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
          children: <Widget>[
            /*Container(
              padding: EdgeInsets.only(
                  top: 10.h, left: 10.w, right: 10.w, bottom: 10.h),
              child: SizedBox(
                height: 80.h,
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
                        Text('Menu: ' + widget.name, style: TextStyle(color: kwhite,fontSize: 20.sp),),
                        /*IconButton(
                            onPressed: () async {
                              final DynamicLinkParameters parameters = DynamicLinkParameters(
                                uriPrefix: 'https://galacaterers.page.link',
                                link: Uri.parse('https://galacaterers.page.link/menudetails?name=TMenu&product=48'),
                                androidParameters: AndroidParameters(
                                  packageName: "com.galacaterers.app_data",
                                  minimumVersion: 0,
                                  fallbackUrl: Uri.parse('https://galacaterers.page.link/menudetails?name=TMenu&product=48'),
                                ),
                                socialMetaTagParameters: SocialMetaTagParameters(
                                  title: 'Gala Caterers',
                                  description: 'Your App Description',
                                  //imageUrl: Uri.parse('https://your-app-url.com/your-image.jpg'),
                                ),
                              );

                              // Construct the Firebase deep link URL
                              String firebaseUrl = 'https://galacaterer.page.link/menudetails';
                              String sharedUrl = firebaseUrl +
                                  '?name=' +
                                  'TMenu' +
                                  '&product=' +
                                  '48';
                              //String sharedUrl = firebaseUrl + '?cid='

                              // Call the share method to share the deep link

                              final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
                              final Uri shortUrl = shortLink.shortUrl; // The shortened dynamic link URL
                              //String shortLink = '$firebaseUrl?name=${Uri.encodeComponent(widget.name)}&product=${Uri.encodeComponent(widget.product)}';
                              Share.share(sharedUrl);
                              print(sharedUrl);
                            },
                            icon: Icon(Icons.share, color: kwhite, size: 30.r,),
                            /*onPressed: () async {
                              //final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
                              //final Uri shortUrl = shortLink.shortUrl; // The shortened dynamic link URL
                              //String sharedUrl = shortUrl.toString(); // Convert the shortened dynamic link URL to a string
                              //Share.share(sharedUrl);
                            },*/
                          ),*/

                      ],
                    ),
                  ],
                ),
              ),
            ),*/
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
                      Text('Menu: ' + widget.name, style: TextStyle(color: kwhite,fontSize: 20.sp),),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child:  RefreshIndicator(
                  onRefresh: () {
                    setState(() {});
                    return fetchOpenMenuList(widget.product);
                  },
                  child: FutureBuilder<MenuListData>(
                    future: futureOpenMenuList,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          itemCount: snapshot.data!.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (snapshot.data!.data[index].ctgId.isEmpty &&
                                snapshot.data!.data[index].name.isEmpty) {
                              return SizedBox.shrink();
                            }

                            else {
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w),
                                    child: InkWell(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text(
                                            snapshot.data!.data[index].name,
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              color: kblue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(
                                            snapshot.data!.data[index].ctgId
                                                .isNotEmpty &&
                                                snapshot.data!.data[index].name
                                                    .isNotEmpty
                                                ? Icons.arrow_forward_ios
                                                : null,
                                            color: kblue,
                                            size: 20.r,
                                          ),
                                        ],
                                      ),
                                      onTap: () =>
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CatMenuList2(
                                                      //category: AllCatList.fromJson(data!.data[index].ctgId),
                                                      category: snapshot.data!
                                                          .data[index].ctgId
                                                          .toString(),
                                                      title: snapshot.data!
                                                          .data[index].name,
                                                      //image: snapshot.data!.data[index].thumb.toString(),
                                                    ),
                                              )),
                                    ),
                                  ),
                                  for(final item in snapshot.data!.data[index]
                                      .items)
                                    InkWell(
                                      onTap: (){},
                                      child: ListTile(
                                        leading: InkWell(
                                          onTap: (){
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
                                                          width: MediaQuery.of(context).size.width,

                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(5.r),
                                                            child: Image.network(item.thumb.toString(), fit: BoxFit.cover,),
                                                          )
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Image.network(
                                              item.thumb.toString()
                                          ),
                                        ),
                                        title: Text(item.prodName),
                                        subtitle: Text(
                                            snapshot.data!.data[index].name),
                                        trailing: GestureDetector(
                                          onTap: () {
                                            /*showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return SizedBox(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      mainAxisSize: MainAxisSize
                                                          .min,
                                                      children: <Widget>[
                                                        /*TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              fetchDeleteMenu(widget.product);
                                                            });
                                                            String ProdId = item.prodId;
                                                            /*futureOpenMenuList.delete(item.prodId);
                                                            futureRemoveMenuData = fetchRemoveMenuData(widget.product, item.prodId);
                                                            setState(() {
                                                              futureRemoveMenuData = fetchRemoveMenuData(widget.product, item.prodId);
                                                              futureOpenMenuList = fetchOpenMenuList(widget.product);
                                                            });*/
                                                            int index = snapshot.data!.data.indexWhere((menu) => menu.items.any((item) => item.prodId == ProdId));
                                                            if (index != -1) {
                                                              int itemIndex = snapshot.data!.data[index].items.indexWhere((item) => item.prodId == ProdId);
                                                              if (itemIndex != -1) {
                                                                snapshot.data!.data[index].items.removeAt(itemIndex);
                                                                if (snapshot.data!.data[index].items.isEmpty) {
                                                                  // If no remaining items, delete cat_id and name
                                                                  snapshot.data!.data[index].ctgId.isEmpty;
                                                                  snapshot.data!.data[index].name.isEmpty;
                                                                }// remove the item from the list at the correct index
                                                                fetchRemoveMenuData(widget.product, ProdId);
                                                                fetchDeleteMenu(widget.product);
                                                                futureOpenMenuList;// update API data with updated item list
                                                                setState(() {
                                                                  fetchDeleteMenu(widget.product);
                                                                  futureOpenMenuList;
                                                                });
                                                              }
                                                            }
                                                            Navigator.of(context).pop();
                                                            fetchDeleteMenu(widget.product);
                                                            futureOpenMenuList;
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.remove_circle_outline, size: 30.r, color: kblue,),
                                                              SizedBox(width: 10.w,),
                                                              Text('Remove from the Menu', style: TextStyle(fontSize: 20.sp, color: kblack),),
                                                            ],
                                                          ),
                                                        ),*/
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.of(context)
                                                                .pop();
                                                            setState(() {
                                                              fetchDeleteMenu(
                                                                  widget.product);
                                                              Fluttertoast.showToast(
                                                                msg: "Item Removed from Menu Successfully!", // your toast message
                                                                toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                gravity: ToastGravity.BOTTOM, // toast gravity
                                                                backgroundColor: Colors.black54, // background color of the toast
                                                                textColor: Colors.white, // text color of the toast
                                                              );
                                                            });
                                                            String ProdId = item
                                                                .prodId;
                                                            int index = snapshot
                                                                .data!.data
                                                                .indexWhere((
                                                                menu) =>
                                                                menu.items.any((
                                                                    item) =>
                                                                item.prodId ==
                                                                    ProdId));
                                                            if (index != -1) {
                                                              int itemIndex = snapshot
                                                                  .data!
                                                                  .data[index]
                                                                  .items
                                                                  .indexWhere((
                                                                  item) =>
                                                              item.prodId ==
                                                                  ProdId);
                                                              if (itemIndex !=
                                                                  -1) {
                                                                snapshot.data!
                                                                    .data[index]
                                                                    .items
                                                                    .removeAt(
                                                                    itemIndex);
                                                                if (snapshot.data!
                                                                    .data[index]
                                                                    .items
                                                                    .isEmpty) {
                                                                  // If no remaining items, delete cat_id and name
                                                                  snapshot.data!
                                                                      .data[index]
                                                                      .ctgId =
                                                                  ''; // set cat_id to empty
                                                                  snapshot.data!
                                                                      .data[index]
                                                                      .name =
                                                                  ''; // set name to empty
                                                                }
                                                                await fetchRemoveMenuData(
                                                                    widget
                                                                        .product,
                                                                    ProdId);
                                                                await fetchDeleteMenu(
                                                                    widget
                                                                        .product);
                                                                await futureOpenMenuList; // update API data with updated item list
                                                                setState(() {
                                                                  fetchDeleteMenu(
                                                                      widget
                                                                          .product);
                                                                  futureOpenMenuList;
                                                                  Fluttertoast.showToast(
                                                                    msg: "Menu Deleted Successfully!", // your toast message
                                                                    toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                    gravity: ToastGravity.BOTTOM, // toast gravity
                                                                    backgroundColor: Colors.black54, // background color of the toast
                                                                    textColor: Colors.white, // text color of the toast
                                                                  );
                                                                });
                                                              }
                                                            }
                                                            Navigator.of(context)
                                                                .pop();
                                                            fetchDeleteMenu(
                                                                widget.product);
                                                            futureOpenMenuList;
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons
                                                                  .remove_circle_outline,
                                                                size: 30.r,
                                                                color: kblue,),
                                                              SizedBox(
                                                                width: 10.w,),
                                                              Text(
                                                                'Remove from the Menu',
                                                                style: TextStyle(
                                                                    fontSize: 20
                                                                        .sp,
                                                                    color: kblack),),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });*/
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
                                                          TextButton(
                                                            onPressed: () async{
                                                              final urlImage = item.thumb.toString();
                                                              final url = Uri.parse(urlImage);
                                                              final response = await http.get(url);
                                                              final bytes = response.bodyBytes;

                                                              final temp = await getTemporaryDirectory();
                                                              final path = '${temp.path}/image.jpg';
                                                              File(path).writeAsBytesSync(bytes);

                                                              await Share.shareFiles([path], text: item.prodName);
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
                                                          Divider(height: 5.h, color: Colors.black45,),
                                                          TextButton(
                                                            onPressed: () async {
                                                              Navigator.of(context)
                                                                  .pop();
                                                              setState(() {
                                                                //fetchDeleteMenu(widget.product);
                                                                Fluttertoast.showToast(
                                                                  msg: "Item Removed from Menu Successfully!", // your toast message
                                                                  toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                  gravity: ToastGravity.BOTTOM, // toast gravity
                                                                  backgroundColor: Colors.black54, // background color of the toast
                                                                  textColor: Colors.white, // text color of the toast
                                                                );
                                                              });
                                                              String ProdId = item.prodId;
                                                              int index = snapshot.data!.data.indexWhere((menu) =>
                                                                  menu.items.any((item) => item.prodId == ProdId));
                                                              if (index != -1) {
                                                                int itemIndex = snapshot.data!.data[index].items.indexWhere((item) =>
                                                                item.prodId ==
                                                                    ProdId);
                                                                if (itemIndex !=
                                                                    -1) {
                                                                  snapshot.data!
                                                                      .data[index]
                                                                      .items
                                                                      .removeAt(
                                                                      itemIndex);
                                                                  if (snapshot.data!
                                                                      .data[index]
                                                                      .items
                                                                      .isEmpty) {
                                                                    // If no remaining items, delete cat_id and name
                                                                    snapshot.data!
                                                                        .data[index]
                                                                        .ctgId =
                                                                    ''; // set cat_id to empty
                                                                    snapshot.data!
                                                                        .data[index]
                                                                        .name =
                                                                    ''; // set name to empty
                                                                  }
                                                                  await fetchRemoveMenuData(
                                                                      widget
                                                                          .product,
                                                                      ProdId);
                                                                  //await fetchDeleteMenu(widget.product);
                                                                  await futureOpenMenuList; // update API data with updated item list
                                                                  setState(() {
                                                                    //fetchDeleteMenu(widget.product);
                                                                    futureOpenMenuList;
                                                                    Fluttertoast.showToast(
                                                                      msg: "Menu Deleted Successfully!", // your toast message
                                                                      toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                      gravity: ToastGravity.BOTTOM, // toast gravity
                                                                      backgroundColor: Colors.black54, // background color of the toast
                                                                      textColor: Colors.white, // text color of the toast
                                                                    );
                                                                  });
                                                                }
                                                              }
                                                              Navigator.of(context)
                                                                  .pop();
                                                              //fetchDeleteMenu(widget.product);
                                                              futureOpenMenuList;
                                                            },
                                                            child: Row(
                                                              children: [
                                                                SizedBox(width: 10.w,),
                                                                Image.asset("assets/images/Delete-Icon.png", height: 20.h, width: 20.w,),
                                                                SizedBox(width: 15.w,),
                                                                Text('Remove from the Menu', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                                padding: EdgeInsets.all(5.r),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius: BorderRadius
                                                      .circular(10.r),
                                                ),
                                                child: Image.asset(
                                                    "assets/images/MenuIcon.png",
                                                    height: 20.h, width: 20.w)
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Divider(),
                                ],
                              );
                            }
                          }
                        );

                      }
                      else if (snapshot.hasError) {
                        return Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w,),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/NoRecordsFound.png',
                                    height: 150.h,
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Center(
                                    child: Text(
                                      'Your Menu is Empty!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25.sp,
                                        fontWeight: FontWeight.bold,
                                        color: kblue,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Center(
                                    child: Text(
                                      'Looks like you haven\'t added \nanything to your menu yet!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25.h,
                                  ),
                                  Container(
                                    height: 70.h,
                                    width: 1.sw/2.w,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) =>
                                            CategoryPage2(),
                                        ));
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
                                        'Browse Food Items',
                                        style: TextStyle(fontFamily: 'Roboto', fontSize: 20.sp),),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
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
                ),


              ),
            ),
          ],
        ),
      ),
    );
  }
}