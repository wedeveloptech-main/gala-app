import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/Models/NewAddListModel.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/services/api_service.dart';

class ScrollPage extends StatefulWidget {
  const ScrollPage({Key? key,}) : super(key: key);

  @override
  State<ScrollPage> createState() => _ScrollPageState();
}

class _ScrollPageState extends State<ScrollPage> {
  late Future<NewAddList> futureNewAddListModel;
  bool isPageViewVisible = false;
  PageView pageView = PageView();
  PageController _pageController = PageController();
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    futureNewAddListModel = fetchNewAddListModel();
    //controller = PageController(initialPage: widget.prod);
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildGridView(),
          //_buildPageView(),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return
      RefreshIndicator(
        onRefresh: () {
          setState(() {});
          return fetchNewAddListModel();
        },
        child: FutureBuilder<NewAddList>(
          future: futureNewAddListModel,
          builder: (context, snapshot) {

            if (snapshot.hasData) {
              return
                GridView.builder(
                  //itemCount: image.length,
                  itemCount: snapshot.data!.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3.w,
                    childAspectRatio: 1.09,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (
                                BuildContext context) {
                              //_currentIndex = snapshot.data!.data[index].prodId as int;
                              return PageView.builder(
                                itemCount: snapshot.data!.data.length,
                                scrollDirection: Axis.horizontal,
                                reverse: false,
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
                                        child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                      ),
                                    ),
                                  );
                                },
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .stretch,
                            children: <Widget>[
                              Container(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: (){},
                                    child: Container(
                                        padding: EdgeInsets.all(5.r),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Image.asset("assets/images/MenuIcon1.png", height: 20.h, width: 20.w)
                                    ),
                                  ),
                                ),
                                height: 135.h,
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
                                  padding: EdgeInsets.all(5.r),
                                  /*child: Center(child: Text(snapshot.data!.data[index].employeeName, style: TextStyle(color: kblue, fontSize: 18.sp, fontWeight: FontWeight.w400),)),*/
                                  child: Center(
                                    child: Text(
                                      snapshot.data!.data[index].prodName,
                                      style: TextStyle(color: kblue,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w400),),
                                  )
                              )
                            ]),
                      ),
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
      );
  }

  Widget _buildPageView() {
    RefreshIndicator pageView =
    RefreshIndicator(
      onRefresh: () {
        setState(() {});
        return fetchNewAddListModel();
      },
      child: FutureBuilder<NewAddList>(
        future: futureNewAddListModel,
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            return
              PageView.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Image.network(snapshot.data!.data[index].thumb),
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
    );

    return Opacity(
      opacity: isPageViewVisible ? 1 : 0,   // <--- make PageView transparent
      child: IgnorePointer(
        ignoring: !isPageViewVisible,       // <--- make PageView ignore the cliks
        child: pageView,
      ),
    );
  }

  void _showPageView(int index) {
    _pageController.jumpToPage(index);  //<--- set PageView's page
    _setPageViewVisible(true);
  }

  void _setPageViewVisible(bool visible) {
    setState(() => isPageViewVisible = visible);
  }
}


