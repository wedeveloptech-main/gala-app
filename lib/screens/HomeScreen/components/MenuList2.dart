import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/AddMenuData.dart';
import '../../../Models/CreateData.dart';
import '../../../Models/CreateMenu.dart';
import '../../../Models/SelectedCreateMenu.dart';
import '../../../Models/menuList.dart';
import '../../../constants/color.dart';
import '../../../services/api_service.dart';

class MenuList2 extends StatefulWidget {
  final prod;
  const MenuList2({Key? key, required this.prod}) : super(key: key);

  @override
  State<MenuList2> createState() => _MenuList2State();
}

class _MenuList2State extends State<MenuList2> {

  final formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  late Future<CreateMenu> futureCreateMenu;
  late Future<SelectedCreateMenu> futureSelectedCreateMenu;
  Future<CreateData>? futureCreateData;
  Future<AddMenuData>? futureAddMenuData;
  late Future<MenuListData> futureDeleteMenu;
  late Future<AddMenuData> futureRemoveMenuData;
  late SharedPreferences _prefs;
  //final Debouncer debouncer = Debouncer(milliseconds: 0);
  late final ValueChanged<bool?>? onChanged;
  bool _valueCheck = false;

  @override
  void initState() {
    super.initState();
    futureCreateMenu = fetchCreateMenu();
    futureSelectedCreateMenu = fetchSelectedCreateMenu(_controller.text);
    futureCreateData = fetchCreateData(_controller.text);
    futureAddMenuData = fetchAddMenuData(String, widget.prod);
    //futureDeleteMenu = fetchDeleteMenu(widget.prod);
    futureRemoveMenuData = fetchRemoveMenuData(String, widget.prod);
    _initPrefs();
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load saved checkboxes from shared preferences
      _selected_box = _prefs.getStringList('selectedBox')?.map(int.parse).toList() ?? [];
    });
  }

  void _saveSelectedBox() {
    // Save selected checkboxes to shared preferences
    _prefs.setStringList('selectedBox', _selected_box.map((index) => index.toString()).toList());
  }


  List<int> _selected_box = [];
  //List<int> selectedProductIds = [];

  // Define a Map to store the selected product ids and their corresponding boolean values
  Map<String, bool> selectedProducts = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:  BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      child: Padding(
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
                    Text('New Menu', style: TextStyle(color: kblue,fontSize: 20.sp),),
                    SizedBox(width: 10.w,),
                  ],
                ),
              ),
              SizedBox(height: 5.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Divider(color: kwhite2),
              ),
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
                      future: fetchSelectedCreateMenu(widget.prod),
                      builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.data.isNotEmpty) {
                            return ListView.builder(
                              itemCount: snapshot.data!.data.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    //debouncer.run(() {
                                    //await Future.delayed(Duration(milliseconds: 50));
                                      setState(() {
                                        snapshot.data!.data[index].isselected =
                                        snapshot.data!.data[index].isselected == "1" ? "0" : "1";
                                      });
                                    //});
                                  },
                                  child: CheckboxListTile(
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
                                    //value: _valueCheck,
                                    onChanged: (bool? value) {
                                      // Update the selectedProductIds list and the UI state based on the checkbox value
                                      setState(() {
                                        if (value != null) {
                                          snapshot.data!.data[index].isselected = value ? "1" : "0";
                                          if (value == true) {
                                            print('true');
                                            _selected_box.add(index);
                                            //selectedProductIds.add(int.parse(snapshot.data!.data[index].id));
                                            futureAddMenuData = fetchAddMenuData(snapshot.data!.data[index].id, widget.prod);
                                            //futureSelectedCreateMenu = fetchSelectedCreateMenu(widget.prod);
                                            /*ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Item Added to Menu!")),
                                            );*/
                                            /*Fluttertoast.showToast(
                                            msg: "Item Added to Menu!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.black54,
                                            textColor: Colors.white,
                                          );*/
                                          } else {
                                            print('false');
                                            // msnapshot.data!.data[index].isselected == "0" ? "1" : "0";
                                            _selected_box.remove(index);
                                            //selectedProductIds.remove(int.parse(snapshot.data!.data[index].id));
                                            futureAddMenuData = fetchAddMenuData(snapshot.data!.data[index].id, widget.prod);
                                            //futureDeleteMenu = fetchDeleteMenu(widget.prod);
                                            //futureSelectedCreateMenu = fetchSelectedCreateMenu(widget.prod);
                                            /*ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Item Removed from Menu!")),
                                            );*/
                                            /*Fluttertoast.showToast(
                                            msg: "Item Removed from Menu!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.black54,
                                            textColor: Colors.white,
                                          );*/
                                          }
                                        }
                                        //value = value;

                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                                  ),
                                );
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


class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}