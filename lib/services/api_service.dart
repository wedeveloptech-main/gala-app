import 'dart:async';
import 'dart:convert';

import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/Models/AddMenuData.dart';
import 'package:myapp/Models/AllCatList.dart';
import 'package:myapp/Models/CatMenu.dart';
import 'package:myapp/Models/CreateData.dart';
import 'package:myapp/Models/CreateMenu.dart';
import 'package:myapp/Models/LoginData.dart';
import 'package:myapp/Models/NewAddListModel.dart';
import 'package:myapp/Models/QuickMenu.dart';
import 'package:myapp/Models/SearchData.dart';
import 'package:myapp/Models/ShowLogin.dart';
import 'package:myapp/Models/catModel.dart';
import 'package:myapp/Models/menuList.dart';
import 'package:myapp/Models/newAddModel.dart';
import 'package:myapp/constants/constants_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/HomeMenu.dart';
import '../Models/SelectedCreateMenu.dart';


class ApiService {
  /*Future<CatModel> getCategory() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        CatModel _model = catModelFromJson(response.body);
        return _model;
      }
    } catch (e) {
      log(e.toString());
    }
  }*/

}

Future<CatModel> fetchCatModel() async {
  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

    final response = await http.get(Uri.parse('$base_url/getnewitems-ax.php'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return CatModel.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<NewAdd> fetchNewAddModel() async {

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .get(Uri.parse('$base_url/getnewitems-ax.php'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return NewAdd.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<NewAdd> fetchRecom() async {

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

    final response = await http
      .get(Uri.parse('$base_url/getrecomlist-ax.php'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return NewAdd.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<NewAddList> fetchNewAddListModel() async {

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .get(Uri.parse('$base_url/getitemlist-ax.php?ctgid=62'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return NewAddList.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<AllCatList> fetchAllCatModel() async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .get(Uri.parse('$base_url/getctglist-ax.php'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return AllCatList.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<CatMenu> fetchCatMenuModel(catId) async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      //.get(Uri.parse(ApiConstants.base_Url + '/getitemlist-ax.php?ctgid=${prefs.getString("catId")}'));
      .get(Uri.parse('$base_url/getitemlist-ax.php?ctgid=$catId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return CatMenu.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<SearchData> fetchSearchData(name) async{
  //SharedPreferences prefs = await SharedPreferences.getInstance();


  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .get(Uri.parse('$base_url/getsearchlist-ax.php?search=$name'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return SearchData.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}


Future<QuickMenu> fetchQuickMenuModel() async {

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .get(Uri.parse('$base_url/getqctglist-ax.php'));
      //.get(Uri.parse(ApiConstants.base_Url1 + ApiConstants.quick_menu));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return QuickMenu.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<CreateMenu> fetchCreateMenu() async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  dynamic cid = await SessionManager().get("cid");

  final response = await http
      .get(Uri.parse('$base_url/getusermenulist-ax.php?clid=$cid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

      return CreateMenu.fromJson(jsonDecode(response.body));

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<SelectedCreateMenu> fetchSelectedCreateMenu(ProdId) async{
  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  dynamic cid = await SessionManager().get("cid");

  final response = await http
      .get(Uri.parse('$base_url/getusermenulist-ax.php?clid=$cid&pid=$ProdId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return SelectedCreateMenu.fromJson(jsonDecode(response.body));

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}


/*Future<MenuListData> fetchDeleteMenu(menuId) async {

  final response = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getmenuitems-ax.php?mid=$menuId'));

  if (response.statusCode == 200) {
    return MenuListData.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a "200 OK response",
    // then throw an exception.
    throw Exception('Failed to load data.');
  }
}*/

Future<CreateData> fetchCreateData(MenuName) async{
  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

    dynamic cid = await SessionManager().get("cid");

    final response = await http.get(Uri.parse('$base_url/requsermenu-ax.php?clid=$cid&name=$MenuName'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return CreateData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  } else {
    throw Exception('Failed to load config');
  }

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];


    dynamic cid = await SessionManager().get("cid");

  final response = await http
  //.get(Uri.parse(ApiConstants.base_Url + '/getitemlist-ax.php?ctgid=${prefs.getString("catId")}'));
      .get(Uri.parse('$base_url/requsermenu-ax.php?clid=$cid&name=$MenuName'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var jsonData = jsonDecode(response.body);
    if (jsonData['code'] == 1) {
      return CreateData.fromJson(jsonData);
    } else {
      throw Exception('Failed to load data');
    }

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<CreateData> fetchUpdateData(MenuId, MenuName) async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .put(Uri.parse('$base_url/requpdatemenu-ax.php?mid=$MenuId&name=$MenuName'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var jsonData = jsonDecode(response.body);
    if(jsonData.code==1)
      return CreateData.fromJson(jsonData);
    else{
      throw Exception('Failed to load data');
    }

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<CreateData> fetchDeleteData(MenuId) async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  dynamic cid = await SessionManager().get("cid");

  final response = await http
      .get(Uri.parse('$base_url/reqmenudelete-ax.php?clid=$cid&mid=$MenuId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var jsonData = jsonDecode(response.body);
    if(jsonData.code==1)
      return CreateData.fromJson(jsonData);
    else{
      throw Exception('Failed to load data');
    }

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<AddMenuData> fetchRemoveMenuData(MenuId, ProdId) async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

    dynamic cid = await SessionManager().get("cid");

    final response = await http.get(Uri.parse('$base_url/reqitemdelete-ax.php?mid=$MenuId&pid=$ProdId'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return AddMenuData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  } else {
    throw Exception('Failed to load config');
  }

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .get(Uri.parse('$base_url/reqitemdelete-ax.php?mid=$MenuId&pid=$ProdId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var jsonData = jsonDecode(response.body);
    if (jsonData['code'] == 1) {
      if (jsonData['data'] != '') {
        return AddMenuData.fromJson(jsonData);
      } else {
        // Handle the case where data is empty
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data1');
    }

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data2');
  }
  } else {
    throw Exception('Failed to load config');
  }
}


Future<AddMenuData> fetchAddMenuData(MenuId, ProdId) async {
  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

    dynamic cid = await SessionManager().get("cid");

    final response = await http.get(Uri.parse('$base_url/reqitemtomenu-ax.php?mid=$MenuId&pid=$ProdId'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return AddMenuData.fromJson(jsonDecode(response.body));
    } else if (MenuId == 0){
      throw Exception('Failed to load data');
    }

    else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  } else {
    throw Exception('Failed to load config');
  }

  /*if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

    final response = await http
        .get(Uri.parse('$base_url/reqitemtomenu-ax.php?mid=$MenuId&pid=$ProdId'));



    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      if (jsonData['code'] == 1) {
        if (jsonData['data'] != '') {
          return AddMenuData.fromJson(jsonData);
        } else {
          // Handle the case where data is empty
          throw Exception('Failed to load data');
        }
      } else {
        throw Exception('Failed to load data1');
      }
    } else {
      throw Exception('Failed to load data2');
    }
  } else {
    throw Exception('Failed to load config');
  }*/
}

Future<HomeMenu> fetchHomeMenu() async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

    final response = await http
        .get(Uri.parse('$base_url/gethomeblocks-ax.php'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      return HomeMenu.fromJson(jsonDecode(response.body));

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  } else {
    throw Exception('Failed to load config');
  }
}

Future<MenuListData> fetchOpenMenuList(menuId) async{

  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];

  final response = await http
      .get(Uri.parse('$base_url/getmenuitems-ax.php?mid=$menuId'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return MenuListData.fromJson(jsonDecode(response.body));

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

// Function to send OTP
Future<LoginData> fetchLoginData(String phoneNumber) async {
  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];
  final response = await http.get(Uri.parse('$base_url/requserlogin-ax.php?phno=$phoneNumber'));
  if (response.statusCode == 200) {
    return LoginData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load login data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}


Future<Map<String, dynamic>> fetchOTP(String phoneNumber) async {
  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];
  final response = await http.get(Uri.parse('$base_url/requserlogin-ax.php?phno=$phoneNumber'));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return jsonData;
  } else {
    throw Exception('Failed to load login data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}

/*Future<Map<String, dynamic>> fetchMaintenanceModeData() async {
  final configResponse = await http
      .get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

  if (configResponse.statusCode == 200) {
    final configJson = jsonDecode(configResponse.body);
    final base_url = configJson['data']['apidomain'];
  final response =
  await http.get(Uri.parse('$base_url/getconfig-ax.php'));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return jsonData;
  } else {
    throw Exception('Failed to fetch maintenance mode data');
  }
  } else {
    throw Exception('Failed to load config');
  }
}*/

Future<Map<String, dynamic>> fetchMaintenanceModeData() async {
    final response =
    await http.get(Uri.parse('http://appdata.galacaterers.in/getconfig-ax.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to fetch maintenance mode data');
    }
}


Future<void> saveLoginData(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('cid', data['cid']);
  await prefs.setString('phoneno', data['phoneno']);
  await prefs.setString('salt', data['salt']);
  await prefs.setString('password', data['password'].toString());
  await prefs.setString('name', data['name']);
  await prefs.setString('profilestatus', data['profilestatus']);
}

Future<Map<String, dynamic>> getLoginData() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'cid': prefs.getString('cid') ?? '',
    'phoneno': prefs.getString('phoneno') ?? '',
    'salt': prefs.getString('salt') ?? '',
    'password': int.tryParse(prefs.getString('password') ?? '') ?? 0,
    'name': prefs.getString('name') ?? '',
    'profilestatus': prefs.getString('profilestatus') ?? '',
  };
}