
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // ref.read(socketNotifierProvider.notifier).listenLocation();
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(socketStreamProvider);
    ref.listen<AsyncValue>(
      socketStreamProvider,
          (prev, next) {
        if (next.hasError) {
          final notifier = ref.read(socketNotifierProvider.notifier);
          notifier.scheduleReconnect();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Aloqa uzildi, qayta ulanmoqda...")),
          );
        }
      },
    );

    return Scaffold(
      body: Center(
        child: stream.when(
            data: (location) =>Text('Location - $location'),
            error: (error, st) => Text("Xatolik  - $error"),
            loading: ()=> CircularProgressIndicator()),
      ),
    );
  }
}
