import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/providers.dart';
import 'package:riverpod_project/socket_notifier.dart';

import 'home_screen.dart';

class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(socketNotifierProvider.notifier);
    final state = ref.watch(socketNotifierProvider);
    notifier.checkLocationPermission();

    ref.listen<SocketState>(socketNotifierProvider, (previous, next) {
      if (next == SocketState.connected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (next == SocketState.error){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ulanishda xatolik yuz berdi")),
        );
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70,),
            Center(child: Text("Entry Screen", style: TextStyle(fontSize: 18),)),
            SizedBox(height: 100,),
            Center(
              child: InkWell(
                  onTap: () async {
                    await notifier.connect();
                  },
                  child: state == SocketState.initial || state == SocketState.error
                      ? Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          color: Color(0xff980C0F),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Icon(
                        Icons.power_settings_new, size: 48, color: Colors.white,)
                  )
                      : CircularProgressIndicator(color: Color(0xff980C0F))
              ),
            )
          ],
        ),
      ),
    );
  }
}
