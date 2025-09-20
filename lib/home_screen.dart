
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socketNotifierProvider.notifier);
    state.listenLocation();
    final stream = ref.watch(socketStreamProvider);

    return stream.when(
        data: (data) => Scaffold(
          body: Center(
            child: Text("Location you send - $data"),
          ),
        ),
        error: (error, stack) => const SnackBar(content: Text("Ulanishda xatolik yuz berdi")),
        loading: () => Scaffold(
          body: Center(child: const CircularProgressIndicator(color: Color(0xff980C0F,))),
        )
    );
  }
}
