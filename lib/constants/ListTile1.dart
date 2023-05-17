import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Models/AddMenuData.dart';
import '../Models/SelectedCreateMenu.dart';
import '../services/api_service.dart';
import 'color.dart';

class ListTile1 extends StatefulWidget {
  final Datum1 model;
  final prod;
  const ListTile1({super.key, required this.model, required this.prod});

  @override
  State<ListTile1> createState() => _ListTile1State();
}

class _ListTile1State extends State<ListTile1> {
  late Datum1 model;
  Future<AddMenuData>? futureAddMenuData;

  @override
  void initState() {
    model = widget.model;
    futureAddMenuData = fetchAddMenuData(String, String);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        model.name ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: kblue, // kBlue
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      activeColor: kblue,
      value: model.isselected == "1",
      onChanged: (bool? value) async {
        //print('Checked');
        if (value != null) {
          setState(() {
            model.isselected = value ? "1" : "0";
            if (value) {
              print('true');
              futureAddMenuData = fetchAddMenuData(model.id, widget.prod);
              // _selected_box.add(index);
              /*Fluttertoast.showToast(
                msg: "Item Added to Menu!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
              );*/
            } else {
              print('false');
              futureAddMenuData = fetchAddMenuData(model.id, widget.prod);
              // _selected_box.remove(index);
              // print(index);
              /*Fluttertoast.showToast(
                msg: "Item Removed from Menu!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
              );*/
            }
          });
        }
      },
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

}
