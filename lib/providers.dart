
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/socket_notifier.dart';
import 'package:riverpod_project/socket_repository.dart';

final socketRepositoryProvider = Provider<SocketRepository>((ref) {
  return SocketRepository();
});

final socketNotifierProvider = StateNotifierProvider<SocketNotifier, SocketState>((ref) {
  final repository = ref.watch(socketRepositoryProvider);
  return SocketNotifier(repository);
});

final socketStreamProvider = StreamProvider.autoDispose<dynamic>((ref) {
  final repo = ref.watch(socketRepositoryProvider);
  return repo.stream;
});