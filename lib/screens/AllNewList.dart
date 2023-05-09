import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:myapp/Models/NewAddListModel.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/ScrollPage.dart';
import 'package:myapp/services/api_service.dart';

class AllNewList extends StatefulWidget {
  const AllNewList({Key? key}) : super(key: key);

  @override
  State<AllNewList> createState() => _AllNewListState();
}

class _AllNewListState extends State<AllNewList> {
  late Future<NewAddList> futureNewAddListModel;

  @override
  void initState() {
    super.initState();
    futureNewAddListModel = fetchNewAddListModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kblue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },),
        title: Text('Newly Added'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Icon(Icons.search,color: kwhite, size: 30.r,),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        color: kblue,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
          child: Expanded(
            child: Container(
              width: double.infinity,
              //padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: ScrollPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageDialog extends StatefulWidget {
  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  late Future<NewAddList> futureNewAddListModel;

  @override
  void initState() {
    super.initState();
    futureNewAddListModel = fetchNewAddListModel();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder<NewAddList>(
        future: futureNewAddListModel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(snapshot.data!.data[index].thumb.toString(),),
                          fit: BoxFit.cover
                      )
                  ),
                );
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
    );
  }
}




