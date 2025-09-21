import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_project/socket_repository.dart';

enum SocketState {initial, connecting, connected, error}

class SocketNotifier extends StateNotifier<SocketState> {
  final SocketRepository repository;
  bool firstConnection = true;
  Position? currentPosition;
  StreamSubscription? locationSubscription;
  Timer? _retryTimer;
  SocketNotifier(this.repository) : super(SocketState.initial);

  Future<bool> checkLocationPermission() async{
    LocationPermission permission;
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled){
        return false;
      }
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }

    return true;
  }
  Future<bool> checkConnection() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    else{
      return false;
    }
  }

  Future<void> connect() async {
    state = SocketState.connecting;
    await repository.connect(
      onConnected: () async {
        state = SocketState.connected;
        listenLocation();
      },
      onError: (error) {
        state = SocketState.error;
        disconnect();
      },
      onDone: () {
        state = SocketState.error;
        disconnect();
      }
    );
  }

  void sendLocation(location) async {
    repository.sendLocation(location);
  }

  void handleData(dynamic data) async{
    currentPosition = data;
    print(currentPosition);
  }
  void handleError(dynamic error) async{
    locationSubscription?.cancel();
    state == SocketState.error;
    print(error);
  }

  Future<void>listenLocation() async {
    locationSubscription?.cancel();
    locationSubscription = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 2),
        )
    ).listen((event) {
      print(event);
      sendLocation(event);
    });
  }


  void disconnect(){
    repository.disconnect();
    locationSubscription?.cancel();
    // state = SocketState.initial;
  }

  void scheduleReconnect() async{
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
        print("🔄 Internet bor, qayta ulanib ko‘ryapmiz...");
        if (state == SocketState.connected || state == SocketState.initial){
          timer.cancel();
          _retryTimer = null;
        }else{
          connect();
        }
        Future.delayed(Duration(seconds: 5));
      } else {
        print("📵 Internet yo‘q, kutyapmiz...");
      }
    });
  }
}