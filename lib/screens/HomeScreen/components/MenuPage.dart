import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:myapp/Demo1.dart';
import 'package:myapp/Demo2.dart';
import 'package:myapp/Models/AllCatList.dart';
import 'package:myapp/Models/CreateData.dart';
import 'package:myapp/Models/CreateMenu.dart';
import 'package:myapp/Models/LoginData.dart';
import 'package:myapp/Models/ShowLogin.dart';
import 'package:myapp/Models/menuList.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/components/ProfilePage.dart';
import 'package:myapp/screens/MenuDetailPage.dart';
import 'package:myapp/screens/createMenuList.dart';
import 'package:myapp/services/api_service.dart';
import 'package:provider/provider.dart';

import '../../../Models/SelectedCreateMenu.dart';
import '../../../constants/NoInternet.dart';
import '../../MaintananceMode.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key,}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  final _shoppingBox = "shopping_box";

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  //form key for validating the form fields
  final formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  late Future<CreateMenu> futureCreateMenu;
  late Future<SelectedCreateMenu> futureSelectedCreateMenu;
  Future<CreateData>? futureCreateData;
  late Future<CreateData> futureUpdateData;
  late Future<CreateData> futureDeleteData;
  late Future<MenuListData> menuList;
  late Future<MenuListData> futureOpenMenuList;
  late Future<AllCatList> futureAllCatModel;
  Future<LoginData>? futureLoginData;
  late Future<ShowLogin> futureShowLogin;
  final TextEditingController _userNameController = TextEditingController();

  bool _isMaintenanceMode = false;
  String _maintenanceMsg = '';

  @override
  void initState() {
    super.initState();
    futureCreateMenu = fetchCreateMenu();
    futureUpdateData = fetchUpdateData(String, _controller.text);
    futureCreateData = fetchCreateData(_controller.text);
    futureSelectedCreateMenu = fetchSelectedCreateMenu(_controller.text);
    futureDeleteData = fetchDeleteData(String);
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
        body:Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: 10.h, left: 10.w, right: 10.w, bottom: 10.h),
              child: SizedBox(
                height: 40.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Planned Menus', style: TextStyle(color: kwhite,fontSize: 20.sp),),
                        InkWell(
                          onTap: () {
                            addNewMenuItem(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.w, left: 30.w, top: 10.h, bottom: 10.h),
                            child: Image.asset("assets/images/AddMenu.png", height: 20.h, width: 20.w,),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(//screen decoration
                //alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  //use a listenable builder, it will make sure it builds whenever needed
                  child: (fetchCreateMenu == null)
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

                      child: FutureBuilder<CreateMenu>(
                        future: fetchCreateMenu(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.data.isNotEmpty) {
                            return ListView.builder(
                                padding: EdgeInsets.only(top: 3.h),
                                itemCount: snapshot.data!.data.length,
                                itemBuilder: (context, index){
                                  int itemNumber = index + 1;
                                  return InkWell(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => MenuDetailPage(
                                          name: snapshot.data!.data[index].name,
                                          product: snapshot.data!.data[index].id,
                                        ),
                                      ),),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 15.w),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children:[
                                                    Container(
                                                      alignment: Alignment.center,
                                                      height: 40.h,
                                                      width: 40.w,
                                                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                      //margin: const EdgeInsets.symmetric(vertical: 10),
                                                      child: Image.asset("assets/images/MenuList.png", height: 25.h, width: 25.w,),
                                                    ),
                                                    SizedBox(
                                                      width: 15.w,
                                                    ),

                                                    //the item title and count
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          snapshot.data!.data[index].name,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 18.sp, color: kblue, fontWeight: FontWeight.w500)
                                                        ),

                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              //leading icon the cart item

                                              //end btns
                                              Flexible(
                                                child: InkWell(
                                                  onTap:(){ //edit btn clicked
                                                    //editShoppingItem(context, name, count);
                                                    showModalBottomSheet(
                                                        backgroundColor: Colors.transparent,
                                                        isScrollControlled: true,
                                                        context: context,
                                                        builder: (BuildContext context)  => Container(
                                                          height: 280.h,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:  BorderRadius.only(
                                                              topLeft: Radius.circular(25.r),
                                                              topRight: Radius.circular(25.r),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                                                                    /*TextButton(
                                                                      //onPressed: () => Share.share(snapshot.data!.data[index].thumb.toString(),
                                                                      //subject: snapshot.data!.data[index].prodName),
                                                                      onPressed: () async{},
                                                                      child: Row(
                                                                        children: [
                                                                          SizedBox(width: 10.w,),
                                                                          Image.asset("assets/images/Share.png", height: 20.h, width: 20.w,),
                                                                          SizedBox(width: 15.w,),
                                                                          Text('Share', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Divider(height: 5.h, color: kwhite2,),*/
                                                                    TextButton(
                                                                      onPressed: (){
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (BuildContext context){
                                                                              return AlertDialog(
                                                                                title: Text("Update Menu Name",
                                                                                  style: TextStyle(fontSize: 20.sp),),
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
                                                                                            labelText: 'Menu Name',
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
                                                                                //actions
                                                                                actions: [
                                                                                  //dismiss dialog
                                                                                  TextButton(onPressed: (){
                                                                                    Navigator.of(context).pop(); // dismiss dialog
                                                                                  }, child: const Text("Cancel")),

                                                                                  //save btn
                                                                                  TextButton(
                                                                                    child: const Text("Edit"),
                                                                                    onPressed: (){
                                                                                      Navigator.of(context).pop();
                                                                                      if (formKey.currentState!.validate()) {
                                                                                        setState(() {
                                                                                          futureUpdateData = fetchUpdateData(snapshot.data!.data[index].id, _controller.text);
                                                                                          futureCreateMenu = fetchCreateMenu();
                                                                                        });
                                                                                        _controller.clear(); //clear text in field
                                                                                        //_countController.clear(); //clear the field
                                                                                        Navigator.of(context).pop(); // dismiss dialog
                                                                                        Fluttertoast.showToast(
                                                                                          msg: "Menu Updated Successfully!", // your toast message
                                                                                          toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                                          gravity: ToastGravity.BOTTOM, // toast gravity
                                                                                          backgroundColor: Colors.black54, // background color of the toast
                                                                                          textColor: Colors.white, // text color of the toast
                                                                                        );
                                                                                        futureCreateMenu = fetchCreateMenu();
                                                                                      }
                                                                                    },

                                                                                  ),

                                                                                ],
                                                                              );
                                                                            });
                                                                      },
                                                                      child: Row(
                                                                        children: [
                                                                          Image.asset("assets/images/Edit-Icon.png", height: 20.h, width: 20.w,),
                                                                          SizedBox(width: 15.w,),
                                                                          Text('Edit Menu Name', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Divider(height: 5.h, color: kwhite2,),
                                                                    TextButton(
                                                                      //onPressed: () => Share.share(snapshot.data!.data[index].thumb.toString(),
                                                                      //subject: snapshot.data!.data[index].prodName),
                                                                      onPressed: () async{
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (context) {
                                                                              return AlertDialog(
                                                                                title: Text('Delete Menu',
                                                                                  style: TextStyle(fontSize: 20.sp),),
                                                                                content: Text('Do you really want to delete this menu?',
                                                                                  style: TextStyle(fontSize: 18.sp),),
                                                                                actions: <Widget>[
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context); //close Dialog
                                                                                    },
                                                                                    child: Text('Cancel'),
                                                                                  ),
                                                                                  TextButton(
                                                                                      onPressed: () {
                                                                                        //action code for "Yes" button
                                                                                        Navigator.of(context).pop();
                                                                                        setState(() {
                                                                                          futureDeleteData = fetchDeleteData(snapshot.data!.data[index].id);
                                                                                          futureCreateMenu = fetchCreateMenu();
                                                                                          Fluttertoast.showToast(
                                                                                            msg: "Menu Deleted Successfully!", // your toast message
                                                                                            toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                                            gravity: ToastGravity.BOTTOM, // toast gravity
                                                                                            backgroundColor: Colors.black54, // background color of the toast
                                                                                            textColor: Colors.white, // text color of the toast
                                                                                          );
                                                                                          futureCreateMenu = fetchCreateMenu();
                                                                                        });
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: Text('Yes')),
                                                                                ],
                                                                              );
                                                                            });
                                                                      },
                                                                      child: Row(
                                                                        children: [
                                                                          Image.asset("assets/images/Delete-Icon.png", height: 20.h, width: 20.w,),
                                                                          SizedBox(width: 15.w,),
                                                                          Text('Delete Menu', style: TextStyle(fontSize: 18.sp, color: kblue, fontWeight: FontWeight.bold),),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 20.h,),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.r),
                                                    child: Image.asset("assets/images/MenuIcon1.png", height: 20.h, width: 20.w),
                                                  )
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10.h,),
                                          Divider(height: 5.h, color: kwhite2,),
                                          SizedBox(height: 10.h,),
                                        ],
                                      ),
                                    ),
                                  );
                                });
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
                                          'No Menu Found!',
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
                                          'Looks like you haven\'t created any menu yet!',
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
                                      addNewMenuItem(context);
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
                                            'Create New Menu',
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

                      onRefresh: () {
                        setState(() {});
                        return fetchCreateMenu();
                      })
              ),


            ),
          ],
        ),
      ),
    );
  }

  //single shopping item
  /*Widget menuRowItem(String name, String count){
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MenuDetailPage(),
        ),),
      //Navigator.pushNamed(context, '/menulist'),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
        //height: 90.h,
        //margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration:BoxDecoration(
          //borderRadius: BorderRadius.circular(15.r), //50 or 20
          //color: Colors.white70,
          //border: Border.all(width: 1.h, color: Colors.black54),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children:[
                      Container(
                        alignment: Alignment.center,
                        height: 40.h,
                        width: 40.w,
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        //margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Image.asset("assets/images/MenuList.png", height: 30.h, width: 30.w,),
                        /*decoration:BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        color: const Color(0XFFe5cec6),
                        shape: BoxShape.rectangle,
                      ),*/
                      ),
                      SizedBox(
                        width: 15.w,
                      ),

                      //the item title and count
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: kblue, fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Food Items',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: kblue, fontSize: 15.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //leading icon the cart item

                //end btns
                Flexible(
                  child: InkWell(
                    onTap:(){ //edit btn clicked
                      //editShoppingItem(context, name, count);
                    },
                    child:  Icon(
                      Icons.arrow_forward_ios,
                      color: kblue,
                      //size: 25.r,
                    ),
                  ),
                  /*child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //Edit btn
                        InkWell(
                          onTap:(){ //edit btn clicked
                            editShoppingItem(context, name, count);
                          },
                          child:  Icon(
                            Icons.edit,
                            size: 25.r,
                          ),
                        ),
                        SizedBox(width: 10.w,),
                        //delete btn
                        InkWell(
                          onTap: (){ //delete btn clicked
                            deleteShoppingItem(context, name);
                          },
                          child:   Icon(
                            Icons.delete,
                            size: 25.r,
                          ),
                        ),

                      ],
                    )*/
                ),
              ],
            ),
            SizedBox(height: 10.h,),
            Divider()
          ],
        ),
      ),
    );
  }*/

  //delete a shopping item from the shopping box
  /*void deleteShoppingItem(BuildContext context, String menu){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text("Are You Sure ??"),
            content: Text("Confirm to remove \"$menu\" from the menu list"),
            actions: [
              TextButton(onPressed: (){
                Navigator.of(context).pop(); // dismiss dialog
              }, child: const Text("Cancel")),

              TextButton(
                child: const Text("Remove"),
                onPressed: (){
                  Hive.box(_shoppingBox).delete(menu); //key is item name.
                  Navigator.of(context).pop(); // dismiss dialog
                },

              ),

            ],
          );
        });
  }*/

  //add new menu name to the box dialog
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
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: "Menu Created Successfully!", // your toast message
                      toastLength: Toast.LENGTH_SHORT, // duration of the toast
                      gravity: ToastGravity.BOTTOM, // toast gravity
                      backgroundColor: Colors.black54, // background color of the toast
                      textColor: Colors.white, // text color of the toast
                    );// dismiss dialog
                    futureCreateMenu = fetchCreateMenu();
                  }
                },
              ),
            ],
          );
        });
  }

  //edit menu name
  void editMenuItem(BuildContext context, String item){
    showDialog(
        context: context,
        builder: (BuildContext context){
          //set initial values before it
          _controller.text = item;
          //_countController.text = count;
          return AlertDialog(
            title: Text("Edit & Save Item",
              style: TextStyle(fontSize: 20.sp),),
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
                        labelText: 'Menu Name',
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
            //actions
            actions: [
              //dismiss dialog
              TextButton(onPressed: (){
                Navigator.of(context).pop(); // dismiss dialog
              }, child: const Text("Cancel")),

              //save btn
              TextButton(
                child: const Text("Create"),
                onPressed: (){
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      futureUpdateData = fetchUpdateData(String, _controller.text);
                      futureCreateMenu = fetchCreateMenu();
                    });
                    _controller.clear(); //clear text in field
                    //_countController.clear(); //clear the field
                    Navigator.of(context).pop(); // dismiss dialog
                    Fluttertoast.showToast(
                      msg: "Menu Updated Successfully!", // your toast message
                      toastLength: Toast.LENGTH_SHORT, // duration of the toast
                      gravity: ToastGravity.BOTTOM, // toast gravity
                      backgroundColor: Colors.black54, // background color of the toast
                      textColor: Colors.white, // text color of the toast
                    );
                  }
                },

              ),

            ],
          );
        });
  }

  //define a toast method
  void showToast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text, textAlign: TextAlign.center,
        style: TextStyle(color: Colors.deepOrange, fontSize: 14.sp),),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
    ));
  }

  /*Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //cartHeadWidget("0"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: const Text(
            "Create New Menu",
            style: TextStyle(color: Colors.black54, fontSize: 30, fontWeight: FontWeight.bold,
            ),),
        ),
      ],
    );
  }

  FutureBuilder<CreateMenu> buildFutureBuilder() {
    return FutureBuilder<CreateMenu>(
      future: futureCreateMenu,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.data.length,
              itemBuilder: (context, index){
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => MenuDetailPage(
                        name: snapshot.data!.data[index].name,
                        product: snapshot.data!.data[index].id.toString(),
                      ),
                    ),),
                  //Navigator.pushNamed(context, '/menulist'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
                    //height: 90.h,
                    //margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    decoration:BoxDecoration(
                      //borderRadius: BorderRadius.circular(15.r), //50 or 20
                      //color: Colors.white70,
                      //border: Border.all(width: 1.h, color: Colors.black54),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children:[
                                  Container(
                                    alignment: Alignment.center,
                                    height: 40.h,
                                    width: 40.w,
                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                    //margin: const EdgeInsets.symmetric(vertical: 10),
                                    child: Image.asset("assets/images/MenuList.png", height: 45.h, width: 45.w,),
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),

                                  //the item title and count
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        snapshot.data!.data[index].name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kblue, fontSize: 20.sp, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Food Items',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kblue, fontSize: 17.sp),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //leading icon the cart item

                            //end btns
                            Flexible(
                              child: InkWell(
                                onTap:(){ //edit btn clicked
                                  //editShoppingItem(context, name, count);
                                },
                                child:  Icon(
                                  Icons.arrow_forward_ios,
                                  color: kblue,
                                  size: 25.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Divider()
                      ],
                    ),
                  ),
                );
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
    );
  }

  Future<void> _getData() async {
    setState(() {
      fetchCreateMenu();
    });
  }*/

}

