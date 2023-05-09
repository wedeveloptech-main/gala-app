import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _baseUrl = 'http://appdata.galacaterers.in';

  static Future<bool> loginUser(String phoneNumber) async {
    final response = await http.get(Uri.parse('$_baseUrl/requserlogin-ax.php?phno=$phoneNumber'));
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body)['data'];
      print('userData: $userData');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('cid', userData['cid']);
      prefs.setString('phoneno', userData['phoneno']);
      prefs.setString('salt', userData['salt']);
      prefs.setString('name', userData['name']);
      prefs.setString('profilestatus', userData['profilestatus']);
      print('cid value set to: ${userData['cid']}');
      return true;
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<String?> getCid() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs);
    final cid = prefs.getString('cid');
    print('getCid() returning: $cid');
    return cid;
  }

  static Future<String?> getPhoneno() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneno = prefs.getString('phoneno');
    print('getPhoneno() returning: $phoneno');
    return phoneno;
  }

  static Future<String?> getSalt() async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString('salt');
    print('getSalt() returning: $salt');
    return salt;
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    print('getName() returning: $name');
    return name;
  }

  static Future<String?> getProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final profilestatus = prefs.getString('profilestatus');
    print('getProfileStatus() returning: $profilestatus');
    return profilestatus;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}

void _handleLogout() async {
  // perform logout

  // clear the cid value from shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('cid');
  }