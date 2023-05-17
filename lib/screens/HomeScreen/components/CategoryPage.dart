import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Models/AllCatList.dart';
import 'package:myapp/Models/CatMenu.dart';
import 'package:myapp/Models/SearchData.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/CatMenuList.dart';
import 'package:myapp/screens/HomeScreen/SearchPage.dart';
import 'package:myapp/services/api_service.dart';
import 'package:provider/provider.dart';

import '../../../constants/NoInternet.dart';
import '../../MaintananceMode.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  //late Future<CatModel> futureCatModel;
  late Future<AllCatList> futureAllCatModel;
  late Future<CatMenu> futureCatMenuModel;
  late Future<SearchData> futureSearchDataModel;
  //late Future<Albums> futureAlbums;

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';


  @override
  void initState() {
    super.initState();
    futureAllCatModel = fetchAllCatModel();
    futureCatMenuModel = fetchCatMenuModel(String);

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
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: 10.h, left: 10.w, right: 10.w, bottom: 10.h),
              child: SizedBox(
                height: 40.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        Text('Food Categories', style: TextStyle(color: kwhite,fontSize: 20.sp),),
                        /*IconButton(icon: Icon(Icons.search,color: kwhite, size: 30.r,),
                          onPressed: () {
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
                                    child: SearchPage(),
                                  ),
                                );
                              },
                            );
                          },
                        ),*/
                        InkWell(
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
                            child: Padding(
                              padding: EdgeInsets.only(left: 30.w, top: 5.h, bottom: 5.h),
                              child: Icon(Icons.search, color: kwhite, size: 30.r,),
                            ),
                        )
                      ],
                    ),
                    /*FutureBuilder<CatMenu>(
                      future: futureCatMenuModel,
                      builder: (context, snapshot) {
                        if (snapshot.hasData){
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.data.length,
                              itemBuilder: (context,index){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Food Categories', style: TextStyle(color: kwhite,fontSize: 20.sp),),
                                    IconButton(icon: Icon(Icons.search,color: kwhite, size: 30.r,),
                                      onPressed: (){
                                        /*Navigator.of(context).push(MaterialPageRoute(
                                          builder: (ctx)=> SearchPage(
                                            product: snapshot.data!.data[index].prodId.toString(),
                                          ),
                                        ));*/
                                      },
                                    )
                                  ],
                                );
                              }
                          );
                        }
                        else if (snapshot.hasError) {
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
                    )*/
                  ],
                ),
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
                  child: RefreshIndicator(
                    onRefresh: () {
                      setState(() {});
                      return fetchAllCatModel();
                    },
                    child: FutureBuilder<AllCatList>(
                      future: futureAllCatModel,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final aspectRatio = 0.62; // desired aspect ratio
                          final itemWidth = (screenWidth - (2 * 3.w)) / 2; // subtract the cross axis spacing from the screen width
                          final itemHeight = itemWidth / aspectRatio;
                          final childAspectRatio = itemWidth / itemHeight;
                          return
                            GridView.builder(
                              //itemCount: image.length,
                              itemCount: snapshot.data!.data.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 3.w,
                                childAspectRatio: 2.0 * childAspectRatio,
                              ),
                              itemBuilder: (BuildContext context, int index){
                                //final DocumentSnapshot documentSnapshot = snapshot.data!.data[index];
                                return InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CatMenuList(
                                          //category: AllCatList.fromJson(data!.data[index].ctgId),
                                          category: snapshot.data!.data[index].ctgId.toString(),
                                            title: snapshot.data!.data[index].ctgName,
                                            image: snapshot.data!.data[index].thumb.toString(),
                                        ),
                                      )),
                                  //onTap: (){},
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
                                            child: Center(child: Text(snapshot.data!.data[index].ctgName,
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
            ),
            ),
          ],
        ),
      ),
    );
  }
}

