import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/Models/SearchData.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/SearchData.dart';
import 'package:myapp/screens/HomeScreen/SearchPage.dart';
import 'package:myapp/services/api_service.dart';


class HeaderWithSearchBox extends StatefulWidget {
  final loginName;
  HeaderWithSearchBox({
    Key? key,
    this.loginName
  }) : super(key: key);

  @override
  State<HeaderWithSearchBox> createState() => _HeaderWithSearchBoxState();
}

class _HeaderWithSearchBoxState extends State<HeaderWithSearchBox> {

  late Future<SearchData> futureSearchData;

  final search_name = TextEditingController();
  final phoneNumber = TextEditingController();
  final studentClass = TextEditingController();

  final _searchKey1 = GlobalKey<FormState>();
  bool _showClearButton = false;
  String name = "User";

  @override
  void initState() {
    super.initState();
    futureSearchData = fetchSearchData(String);
    search_name.addListener(() {
      setState(() {
        _showClearButton = search_name.text.isNotEmpty;
      });
    });
    _loadName();
  }

  Future<void> _loadName() async {
    String nameFromSession = await SessionManager().get("name");
    if (nameFromSession != null) {
      setState(() {
        name = nameFromSession;
      });
    }
    else if (nameFromSession == null) {
      setState(() {
        name = 'User';
      });
    }
  }

  @override
  void dispose() {
    search_name.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      search_name.clear();
      _showClearButton = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      // It will cover 20% of our total height
      height: 200.h,
      child: Stack(
        children: <Widget>[
          Stack(
            children: [
              Image.asset(
                'assets/images/HomeBg.png',
                height: 170.h,
                width: 1.sw,
                fit: BoxFit.cover,
              ),
              Positioned(
                  left: 50.w,
                  right: 50.w,
                  bottom: 50.h,
                  child: Image.asset('assets/images/Asset 48.png',height: 50.h, width: 50.w,)
              ),
              Positioned(
                  left: 20.w,
                  //right: 50.w,
                  bottom: 100.h,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Text('Hello, $name',
                          style: TextStyle(color: kwhite, fontSize: 20.sp, fontWeight: FontWeight.w500),),
                    ),
                  ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              height: 60.h,
              /*decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: kblue
                ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 50.r,
                    color: kblue.withOpacity(0.23),
                  ),
                ],
              ),*/
              child: Row(
                children: <Widget>[
                  FutureBuilder<SearchData>(
                      future: futureSearchData,
                      builder: (context, snapshot) {
                        return  Expanded(
                          child: Form(
                            key: _searchKey1,
                            child: /*TextFormField(
                              controller: name,
                              textCapitalization: TextCapitalization.words,
                              autocorrect: true,
                              onChanged: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Value is required';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                if (_searchKey1.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SearchDataList(
                                            nameHolder: name.text,
                                          ),
                                    ),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Search food, beverages & more..",
                                hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    if (_searchKey1.currentState!.validate()) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchDataList(
                                                    nameHolder: name.text,))
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.search, size: 25.r),
                                ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                //contentPadding: EdgeInsets.symmetric(vertical: 21.h, horizontal: 8.w),
                              ),
                            ),*/

                            TextFormField(
                              controller: search_name,
                              textCapitalization: TextCapitalization.words,
                              autocorrect: true,
                              onChanged: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Value is required';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                if (_searchKey1.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SearchDataList(
                                            nameHolder: search_name.text,
                                          ),
                                    ),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 13.w),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kblue),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kblue),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                hintText: "Search food, beverages & more..",
                                hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                                suffixIcon:
                                /*IconButton(
                                  onPressed: () {
                                    if (_searchKey1.currentState!.validate()) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchDataList(
                                                    nameHolder: name.text,))
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.search, size: 25.r),
                                ),*/

                                _showClearButton
                                    ? IconButton(
                                  onPressed: _clearSearch,
                                  icon: Icon(Icons.clear, size: 25.r, color: kblue,),
                                )
                                    : IconButton(
                                  onPressed: () {
                                    if (_searchKey1.currentState!.validate()) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchDataList(
                                                    nameHolder: search_name.text,))
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.search, size: 25.r, color: kblue,),
                                ),
                                filled: true,
                              ),
                              //onSubmitted :
                            ),

                          ),
                        );
                      }
                  ),
                  //SvgPicture.asset("assets/icons/search.svg"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}