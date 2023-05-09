import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class CheckInternet extends ChangeNotifier {
  String status = 'waiting...';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  void checkConnectivity() async {
    var connectionResult = await _connectivity.checkConnectivity();
    if (connectionResult == ConnectivityResult.mobile) {
      status = "Connected to MobileData";
      notifyListeners();
    } else if (connectionResult == ConnectivityResult.wifi) {
      status = "Connected to Wifi";
      notifyListeners();
    } else {
      status = "Offline";
      notifyListeners();
    }
  }

  void checkRealtimeConnection() {
    _streamSubscription = _connectivity.onConnectivityChanged.listen((event) {
      switch (event) {
        case ConnectivityResult.mobile:
          {
            status = "Connected to MobileData";
            notifyListeners();
          }
          break;
        case ConnectivityResult.wifi:
          {
            status = "Connected to Wifi";
            notifyListeners();
          }
          break;
        default:
          {
            status = 'Offline';
            notifyListeners();
          }
          break;
      }
    });
  }
}