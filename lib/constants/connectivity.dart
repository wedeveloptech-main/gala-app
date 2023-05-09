import 'dart:io'; //InternetAddress utility
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart'; //For StreamController/Stream

extension ParseToString on ConnectivityResult {

  String toValue() {
    return this.toString().split('.').last;
  }
}

class ConnectivityStatusExample extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ConnectivityStatusExampleState();
  }
}

class _ConnectivityStatusExampleState extends State<ConnectivityStatusExample> {

  static const TextStyle textStyle = const TextStyle(
    fontSize: 16,
  );

  ConnectivityResult? _connectivityResult;
  late StreamSubscription _connectivitySubscription;
  bool? _isConnectionSuccessful;

  bool hasInternet = false;
  late StreamSubscription internetSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint(hasInternet.toString());
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
          final hasInternet = status == InternetConnectionStatus.connected;
          setState(() => this.hasInternet = hasInternet);
        });
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        ConnectivityResult result
        ) {
      print('Current connectivity status: $result');
      setState(() {
        _connectivityResult = result;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    internetSubscription.cancel();
    _connectivitySubscription.cancel();
  }


  Future<void> _checkConnectivityState() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.wifi) {
      print('Connected to a Wi-Fi network');
    } else if (result == ConnectivityResult.mobile) {
      print('Connected to a mobile network');
    } else {
      print('Not connected to any network');
    }

    setState(() {
      _connectivityResult = result;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Woolha.com Flutter Tutorial'),
        backgroundColor: Colors.teal,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connection status: ${_connectivityResult?.toValue()}',
              style: textStyle,
            ),
            Text(
              'Is connection success: $_isConnectionSuccessful',
              style: textStyle,
            ),
            OutlinedButton(
              child: const Text('Check internet connection'),
              onPressed: () => _checkConnectivityState(),
            ),
            OutlinedButton(
              child: const Text('Try connection'),
              onPressed: () => {},
            ),
          ],
        ),
      ),
    );
  }
}