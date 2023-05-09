import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/Models/AddMenuData.dart';
import 'package:myapp/Models/CreateData.dart';
import 'package:myapp/Models/CreateMenu.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuListPage extends StatefulWidget {
  final prod;
  const MenuListPage({Key? key, required this.prod}) : super(key: key);

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {

  final formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  late Future<CreateMenu> futureCreateMenu;
  Future<CreateData>? futureCreateData;
  Future<AddMenuData>? futureAddMenuData;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    futureCreateMenu = fetchCreateMenu();
    futureCreateData = fetchCreateData(_controller.text);
    futureAddMenuData = fetchAddMenuData(String, widget.prod);
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

                        child: FutureBuilder<CreateMenu>(
                          future: fetchCreateMenu(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: snapshot.data!.data.length,
                                  itemBuilder: (context, index){
                                    return Container(
                                      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if(snapshot.data!.data[index].id.contains(widget.prod)){
                                                    futureAddMenuData = fetchAddMenuData(snapshot.data!.data[index].id, widget.prod);
                                                    futureCreateMenu = fetchCreateMenu();
                                                    _selected_box.add(index);
                                                    Fluttertoast.showToast(
                                                      msg: "Item Added to Menu!", // your toast message
                                                      toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                      gravity: ToastGravity.BOTTOM, // toast gravity
                                                      backgroundColor: Colors.black54, // background color of the toast
                                                      textColor: Colors.white, // text color of the toast
                                                    );}
                                                    else{
                                                      //fetchDeleteMenu(widget.prod);
                                                      futureCreateMenu = fetchCreateMenu();
                                                      _selected_box.add(index);
                                                      Fluttertoast.showToast(
                                                        msg: "Item Added to Menu!", // your toast message
                                                        toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                        gravity: ToastGravity.BOTTOM, // toast gravity
                                                        backgroundColor: Colors.black54, // background color of the toast
                                                        textColor: Colors.white, // text color of the toast
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    children:[
                                                      Container(
                                                        alignment: Alignment.center,
                                                        height: 40.h,
                                                        width: 40.w,
                                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                        //margin: const EdgeInsets.symmetric(vertical: 10),
                                                        //child: Image.asset("assets/images/MenuList.png", height: 30.h, width: 30.w,),
                                                        child:  Checkbox(
                                                          activeColor: kblue,
                                                          value: _selected_box.contains(index), // Check if index is already selected
                                                          onChanged: (value) {
                                                            setState(() {
                                                              // Check if index is already selected
                                                              if (_selected_box.contains(index)) {
                                                                _selected_box.remove(index);
                                                                futureAddMenuData = fetchAddMenuData(snapshot.data!.data[index].id, widget.prod);
                                                                futureCreateMenu = fetchCreateMenu();
                                                                Fluttertoast.showToast(
                                                                  msg: "Item Removed from Menu!", // your toast message
                                                                  toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                  gravity: ToastGravity.BOTTOM, // toast gravity
                                                                  backgroundColor: Colors.black54, // background color of the toast
                                                                  textColor: Colors.white, // text color of the toast
                                                                );
                                                              } else {
                                                                //fetchDeleteMenu(]widget.prod);
                                                                futureCreateMenu = fetchCreateMenu();
                                                                _selected_box.add(index);
                                                                Fluttertoast.showToast(
                                                                  msg: "Item Added to Menu!", // your toast message
                                                                  toastLength: Toast.LENGTH_SHORT, // duration of the toast
                                                                  gravity: ToastGravity.BOTTOM, // toast gravity
                                                                  backgroundColor: Colors.black54, // background color of the toast
                                                                  textColor: Colors.white, // text color of the toast
                                                                );
                                                              }

                                                              // Update the futureAddMenuData based on the new selection
                                                              if (value == true) {
                                                                futureAddMenuData = fetchAddMenuData(snapshot.data!.data[index].id, widget.prod);
                                                              }
                                                              else{

                                                              }
                                                            });
                                                          },
                                                        ),
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
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider()
                                        ],
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
      ),
    );
  }

  void addNewMenuItem(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text("New Menu"),
            content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, //the dialog takes only size it needs
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                      child: TextFormField(
                        controller: _controller, //will help get the field value on submit
                        decoration: const InputDecoration(
                          //border: OutlineInputBorder(),
                          labelText: 'Enter New Menu',
                        ),
                        //validator on submit, must return null when every thing ok
                        // The validator receives the text that the user has entered.
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'This field is required.';}
                          else if(value.trim().isEmpty){
                            return "This field is required.";
                          }
                          return null;
                        },
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

class CheckProvider extends ChangeNotifier {
  bool _checkbox = false;
  void checkValue() {
    _checkbox = !_checkbox;
  }
}
