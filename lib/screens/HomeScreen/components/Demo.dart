import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/components/widgets/image_widget.dart';

class Demo extends StatefulWidget {
  const Demo({Key? key}) : super(key: key);

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: CustomSliverAppBarDelegate(expandedHeight: 300.h),
            pinned: true,
          ),
          //buildImages(),
          SliverPadding(
            padding: EdgeInsets.only(top: 20.r, left: 20.r, right: 20.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  height: 100.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 35.r,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage('assets/images/FoodMenu1.png'),
                            ),
                            Text("Bittings", style: TextStyle(color: kblue, fontSize: 15.sp),)
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
                              backgroundImage: AssetImage('assets/images/FoodMenu2.png'),
                            ),
                            Text("Juices", style: TextStyle(color: kblue, fontSize: 15.sp),)
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
                    ],
                  ),
                ),
                SizedBox(height: 40.h,),
                Container(
                  height: 300.h,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Additions..',
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: kblue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.r),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/category-fastfood.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 100.h,
                                width: 150.w,
                              ),
                              SizedBox(width: 10.w,),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/category-desserts.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 100.h,
                                width: 150.w,
                              ),
                              SizedBox(width: 10.w,),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/category-indian.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 100.h,
                                width: 150.w,
                              ),
                              SizedBox(width: 10.w,),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/category-sweets.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 100.h,
                                width: 150.w,
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/category-juice.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 100.h,
                                width: 150.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImages() => SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    delegate: SliverChildBuilderDelegate(
          (context, index) => ImageWidget(index: index),
      childCount: 2,
    ),
  );
}

class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  const CustomSliverAppBarDelegate({
    required this.expandedHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final size = 155;
    final top = expandedHeight - shrinkOffset - size / 2;

    return Stack(
      clipBehavior: Clip.none, fit: StackFit.loose,
      children: [
        buildBackground(shrinkOffset),
        buildAppBar(shrinkOffset),
        Positioned(
          top: top,
          left: 20.w,
          right: 20.w,
          child: buildFloating(shrinkOffset),
        ),
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget buildAppBar(double shrinkOffset) => Opacity(
    opacity: appear(shrinkOffset),
    child: AppBar(
      title: Text(""),
      centerTitle: true,
    ),
  );

  Widget buildBackground(double shrinkOffset) => Opacity(
    opacity: disappear(shrinkOffset),
    child: Stack(
      children: [
        Image.asset(
          'assets/images/HomeBg.png',
          fit: BoxFit.cover,
        ),
        Positioned(
            left: 50.w,
            right: 50.w,
            bottom: 40.h,
            top: 120.h,
            child: Image.asset('assets/images/Asset 48.png',height: 5.h, width: 5.h,)
        ),
      ],
    ),
  );

  Widget buildFloating(double shrinkOffset) => Opacity(
    opacity: disappear(shrinkOffset),
    child: Card(
        child: Container(
          height: 50.h,
          child: TextField(
            decoration: InputDecoration(
                hintText: "Search food, beverages & more..",hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                fillColor: Colors.white,
                filled: true,
                suffixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(color: kblue),

                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h)
            ),
          ),
        )
    ),
  );

  Widget buildButton({
    required String text,
    required IconData icon,
  }) =>
      TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            SizedBox(width: 12.w),
            Text(text, style: TextStyle(fontSize: 20.sp)),
          ],
        ),
        onPressed: () {},
      );


  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

}